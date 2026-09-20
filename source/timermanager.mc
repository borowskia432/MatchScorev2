import Toybox.Timer;
import Toybox.Attention;
import Toybox.WatchUi;
import Toybox.Lang;

module TimerManager {
    
    // Klasa pomocnicza wymagana przez Monkey C do obsługi timera z poziomu modułu
    class TimerDelegate {
        function onTick() as Void {
            TimerManager.onTick();
        }
    }

    var _timer as Timer.Timer or Null = null;
    var _timerDelegate as TimerDelegate or Null = null;
    
    // Flaga określająca, czy stoper odlicza czas
    var isRunning as Boolean = false; 
    
    var defaultDurationSeconds as Number = 300; 
    var secondsRemaining as Number = 300;
    var _restSeconds as Number = 0;

    var isSoundEnabled as Boolean = true;

    function toggleSound() as Void {
        isSoundEnabled = !isSoundEnabled;
    }

    function setDuration(seconds as Number) as Void {
        defaultDurationSeconds = seconds;
        if (!isRunning) {
            secondsRemaining = seconds;
        }
    }

    // =====================================================
    // ZARZĄDZANIE TIMEREM SPRZĘTOWYM
    // =====================================================
    
    function startBackgroundTick() as Void {
        if (_timer == null) {
            _timer = new Timer.Timer();
            _timerDelegate = new TimerDelegate();
            _timer.start(_timerDelegate.method(:onTick), 1000, true);
        }
    }

    function stopBackgroundTick() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
            _timerDelegate = null;
        }
    }

    // =====================================================
    // LOGIKA STOPERA (Biznesowa)
    // =====================================================

    function startTimer() as Void {
        isRunning = true;
        startBackgroundTick();
        WatchUi.requestUpdate();
    }

    function stopTimer() as Void {
        isRunning = false;
        WatchUi.requestUpdate();
    }

    function toggleTimer() as Void {
        isRunning = !isRunning;
        if (isRunning) {
            startBackgroundTick();
        }
        WatchUi.requestUpdate();
    }

    // Wywoływane co 1 sekundę przez fizyczny zegar
    function onTick() as Void {
        // Sensor/metryka sesji działa niezależnie od stopera na zegarku.
        // Stoper nie jest źródłem liczenia wyskoków ani zrywów.
        BurstManager.update();
        JumpManager.update();

        // 1. Logika odliczania stopera (działa tylko gdy isRunning == true)
        if (isRunning) {
            if (_restSeconds > 0) {
                _restSeconds--;
                if (_restSeconds == 0) {
                    secondsRemaining = defaultDurationSeconds;
                }
            } else if (secondsRemaining > 0) {
                secondsRemaining--;

                if (secondsRemaining == 10) {
                    notify10SecondsRemaining();
                } else if (secondsRemaining == 0) {
                    notifyTimeUp();
                    _restSeconds = 5;
                }
            }
        }

        // 3. Odświeżanie ekranu zegarka
        WatchUi.requestUpdate();
    }

    function getFormattedTime() as String {
        var min = secondsRemaining / 60;
        var sec = secondsRemaining % 60;
        return min.format("%02d") + ":" + sec.format("%02d");
    }

    // =====================================================
    // ALERTY I DŹWIĘKI
    // =====================================================

    function notify10SecondsRemaining() as Void {
        if (isSoundEnabled && (Attention has :playTone)) {
            Attention.playTone(Attention.TONE_ALERT_LO); 
        }

        if (Attention has :vibrate) {
            var vibeData = [
                new Attention.VibeProfile(100, 150),
                new Attention.VibeProfile(0, 100),
                new Attention.VibeProfile(100, 150),
                new Attention.VibeProfile(0, 100),
                new Attention.VibeProfile(100, 150)
            ] as Array<Attention.VibeProfile>;
            Attention.vibrate(vibeData);
        }
    }

    function notifyTimeUp() as Void {
        if (isSoundEnabled && (Attention has :playTone)) {
            Attention.playTone(Attention.TONE_TIME_ALERT);
        }

        if (Attention has :vibrate) {
            var vibeData = [
                new Attention.VibeProfile(100, 700),
                new Attention.VibeProfile(0, 200),
                new Attention.VibeProfile(100, 700)
            ] as Array<Attention.VibeProfile>;
            Attention.vibrate(vibeData);
        
        }
    }
    // Resetowanie stopera do wartości początkowej
    function resetTimer() as Void {
        isRunning = false;
        secondsRemaining = defaultDurationSeconds;
        _restSeconds = 0;
        stopBackgroundTick();
        WatchUi.requestUpdate();
    }
}