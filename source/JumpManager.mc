import Toybox.Math;
import Toybox.Lang;
import Toybox.Sensor;
import Toybox.System;

module JumpManager {

    var _isListening as Boolean = false;
    var _phase as Number = 0;
    var _phaseSamples as Number = 0;
    var _cooldownSamples as Number = 0;

    // Dane akcelerometru sa milli-G; prog jest podany w G.
    const TAKEOFF_THRESHOLD_G as Float = 1.35;
    const AIRBORNE_THRESHOLD_G as Float = 0.65;
    const LANDING_THRESHOLD_G as Float = 1.30;
    const MAX_PHASE_SAMPLES as Number = 20;
    const COOLDOWN_SAMPLES as Number = 50;

    // =====================================================
    // RESET
    // =====================================================
    function reset() as Void {
        _phase = 0;
        _phaseSamples = 0;
        _cooldownSamples = 0;
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
            processSample(magnitudeG);
        }
    }

    function processSample(magnitudeG as Float) as Void {
        if (_cooldownSamples > 0) {
            _cooldownSamples--;
            return;
        }

        if (_phase == 0) {
            if (magnitudeG >= TAKEOFF_THRESHOLD_G) {
                _phase = 1;
                _phaseSamples = 0;
            }
        } else if (_phase == 1) {
            _phaseSamples++;
            if (magnitudeG <= AIRBORNE_THRESHOLD_G) {
                _phase = 2;
                _phaseSamples = 0;
            } else if (_phaseSamples > MAX_PHASE_SAMPLES) {
                _phase = 0;
            }
        } else {
            _phaseSamples++;
            if (magnitudeG >= LANDING_THRESHOLD_G) {
                addJump();
                _phase = 0;
                _phaseSamples = 0;
                _cooldownSamples = COOLDOWN_SAMPLES;
            } else if (_phaseSamples > MAX_PHASE_SAMPLES) {
                _phase = 0;
            }
        }
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