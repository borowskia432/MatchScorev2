import Toybox.Math;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.System;
import Toybox.Application;

module JumpManager {

    var _isListening as Boolean = false;
    var _phase as Number = 0;
    var _phaseSamples as Number = 0;
    var _thresholdSamples as Number = 0;
    var _cooldownSamples as Number = 0;
    var _isCalibrating as Boolean = false;
    var _calibrationSamples as Number = 0;
    var _calibrationSum as Float = 0.0;
    var _calibrationSumSquares as Float = 0.0;
    var _restBaselineG as Float = 1.0;
    var _noiseG as Float = 0.05;

    // Dane akcelerometru sa milli-G; progi sa podane w G.
    const TAKEOFF_THRESHOLD_G as Float = 1.65;
    const AIRBORNE_THRESHOLD_G as Float = 0.75;
    const LANDING_THRESHOLD_G as Float = 1.45;
    const TAKEOFF_CONFIRM_SAMPLES as Number = 2;
    const AIRBORNE_CONFIRM_SAMPLES as Number = 3;
    const LANDING_CONFIRM_SAMPLES as Number = 2;
    const MAX_PHASE_SAMPLES as Number = 18;
    const COOLDOWN_SAMPLES as Number = 75;
    const CALIBRATION_STORAGE_KEY as String = "jump_calibration";

    // =====================================================
    // RESET
    // =====================================================
    function reset() as Void {
        _phase = 0;
        _phaseSamples = 0;
        _thresholdSamples = 0;
        _cooldownSamples = 0;
        loadCalibration();
        System.println("JumpManager: reset");
    }

    function start() as Void {
        reset();

        var options = {
            :period => 1,
            :accelerometer => {
                :enabled => true,
                :sampleRate => 25,
                :includePower => false,
                :includePitch => false,
                :includeRoll => false,
                :includeTimestamps => false
            }
        };

        try {
            Sensor.registerSensorDataListener(new Lang.Method(self, :onSensorData), options);
            _isListening = true;
            System.println("JumpManager: akcelerometr uruchomiony");
        } catch (e) {
            _isListening = false;
            System.println("JumpManager: blad akcelerometru " + e.getErrorMessage());
        }
    }

    function stop() as Void {
        if (_isListening) {
            Sensor.unregisterSensorDataListener();
            _isListening = false;
        }
        reset();
    }

    function onSensorData(sensorData as Sensor.SensorData) as Void {
        var accelData = sensorData.accelerometerData;
        if (accelData == null || accelData.x == null || accelData.y == null || accelData.z == null) {
            return;
        }

        var sampleCount = accelData.x.size();
        for (var i = 0; i < sampleCount; i++) {
            var x = accelData.x[i];
            var y = accelData.y[i];
            var z = accelData.z[i];
            var magnitudeG = Math.sqrt((x * x + y * y + z * z)) / 1000.0;
            if (_isCalibrating) {
                _calibrationSamples++;
                _calibrationSum += magnitudeG;
                _calibrationSumSquares += magnitudeG * magnitudeG;
            } else {
                processSample(magnitudeG);
            }
        }
    }

    function beginCalibration() as Void {
        if (!_isListening) {
            start();
        }
        _isCalibrating = true;
        _calibrationSamples = 0;
        _calibrationSum = 0.0;
        _calibrationSumSquares = 0.0;
        resetDetectionState();
    }

    function finishCalibration() as Void {
        if (_calibrationSamples > 10) {
            var average = _calibrationSum / _calibrationSamples;
            var variance = (_calibrationSumSquares / _calibrationSamples) - (average * average);
            _restBaselineG = average;
            _noiseG = Math.sqrt(variance > 0.0 ? variance : 0.0).toFloat();
            Application.Storage.setValue(CALIBRATION_STORAGE_KEY, [_restBaselineG, _noiseG]);
        }
        _isCalibrating = false;
        resetDetectionState();
    }

    function cancelCalibration() as Void {
        _isCalibrating = false;
        resetDetectionState();
    }

    function isCalibrating() as Boolean {
        return _isCalibrating;
    }

    function getRestBaselineG() as Float {
        return _restBaselineG;
    }

    function getNoiseG() as Float {
        return _noiseG;
    }

    function resetDetectionState() as Void {
        _phase = 0;
        _phaseSamples = 0;
        _thresholdSamples = 0;
        _cooldownSamples = 0;
    }

    function loadCalibration() as Void {
        var saved = Application.Storage.getValue(CALIBRATION_STORAGE_KEY) as Array<Number> or Null;
        if (saved != null && saved.size() >= 2) {
            _restBaselineG = saved[0].toFloat();
            _noiseG = saved[1].toFloat();
        }
    }

    function processSample(magnitudeG as Float) as Void {
        if (_cooldownSamples > 0) {
            _cooldownSamples--;
            return;
        }

        if (_phase == 0) {
            if (magnitudeG >= getTakeoffThresholdG()) {
                _thresholdSamples++;
                if (_thresholdSamples >= TAKEOFF_CONFIRM_SAMPLES) {
                    _phase = 1;
                    _phaseSamples = 0;
                    _thresholdSamples = 0;
                }
            } else {
                _thresholdSamples = 0;
            }
        } else if (_phase == 1) {
            _phaseSamples++;
            if (magnitudeG <= getAirborneThresholdG()) {
                _thresholdSamples++;
                if (_thresholdSamples >= AIRBORNE_CONFIRM_SAMPLES) {
                    _phase = 2;
                    _phaseSamples = 0;
                    _thresholdSamples = 0;
                }
            } else if (_phaseSamples > MAX_PHASE_SAMPLES) {
                _phase = 0;
                _thresholdSamples = 0;
            } else {
                _thresholdSamples = 0;
            }
        } else {
            _phaseSamples++;
            if (magnitudeG >= getLandingThresholdG()) {
                _thresholdSamples++;
                if (_thresholdSamples >= LANDING_CONFIRM_SAMPLES) {
                    addJump();
                    _phase = 0;
                    _phaseSamples = 0;
                    _thresholdSamples = 0;
                    _cooldownSamples = COOLDOWN_SAMPLES;
                }
            } else if (_phaseSamples > MAX_PHASE_SAMPLES) {
                _phase = 0;
                _thresholdSamples = 0;
            } else {
                _thresholdSamples = 0;
            }
        }
    }

    function getNoiseMarginG() as Float {
        var margin = _noiseG * 6.0;
        return margin > 0.10 ? margin : 0.10;
    }

    function getTakeoffThresholdG() as Float {
        var threshold = _restBaselineG + 0.55 + getNoiseMarginG();
        return threshold > TAKEOFF_THRESHOLD_G ? threshold : TAKEOFF_THRESHOLD_G;
    }

    function getAirborneThresholdG() as Float {
        var threshold = _restBaselineG - 0.25 - getNoiseMarginG();
        return threshold < AIRBORNE_THRESHOLD_G ? threshold : AIRBORNE_THRESHOLD_G;
    }

    function getLandingThresholdG() as Float {
        var threshold = _restBaselineG + 0.35 + getNoiseMarginG();
        return threshold > LANDING_THRESHOLD_G ? threshold : LANDING_THRESHOLD_G;
    }

    // =====================================================
    // DODANIE WYSKOKU
    //
    // Ta funkcja jest wywoływana przez algorytm wykrywania wyskoku.
    // =====================================================
    function addJump() as Void {
        SportsMetricsManager.addJump();
        SessionManager.recordJumpCount(SportsMetricsManager.getTotalJumps());

        System.println(
            "JumpManager: Wykryto wyskok! " +
            "Łącznie: " + SportsMetricsManager.getTotalJumps()
        );
    }

    // =====================================================
    // RĘCZNE DODANIE WYSKOKU
    //
    // Przydatne podczas testowania na symulatorze.
    // =====================================================
    function addManualJump() as Void {
        SportsMetricsManager.addJump();
        SessionManager.recordJumpCount(SportsMetricsManager.getTotalJumps());

        System.println(
            "JumpManager: Ręcznie dodano wyskok. " +
            "Łącznie: " + SportsMetricsManager.getTotalJumps()
        );
    }
}