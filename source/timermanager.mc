import Toybox.Timer;
import Toybox.Attention;
import Toybox.WatchUi;
import Toybox.Lang;

module TimerManager {
    var _timer as Timer.Timer or Null = null;
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

    function startTimer() as Void {
        if (!isRunning) {
            isRunning = true;
            if (_timer == null) {
                _timer = new Timer.Timer();
            }
            _timer.start(new Lang.Method(TimerManager, :onTick), 1000, true);
        }
    }

    function stopTimer() as Void {
        if (isRunning) {
            isRunning = false;
            if (_timer != null) {
                _timer.stop();
            }
        }
    }

    function toggleTimer() as Void {
        if (isRunning) {
            stopTimer();
        } else {
            startTimer();
        }
    }

    function onTick() as Void {
        if (!isRunning) {
            return;
        }

        // Cykliczne sprawdzanie Auto Lapa co 1 sekundę trwania treningu
        SessionManager.checkAutoLap();

        if (_restSeconds > 0) {
            _restSeconds--;
            if (_restSeconds == 0) {
                secondsRemaining = defaultDurationSeconds;
            }
            WatchUi.requestUpdate();
            return;
        }

        if (secondsRemaining > 0) {
            secondsRemaining--;

            if (secondsRemaining == 10) {
                notify10SecondsRemaining();
            } else if (secondsRemaining == 0) {
                notifyTimeUp();
                _restSeconds = 5;
            }
        }

        WatchUi.requestUpdate();
    }

    function getFormattedTime() as String {
        var min = secondsRemaining / 60;
        var sec = secondsRemaining % 60;
        return min.format("%02d") + ":" + sec.format("%02d");
    }

    function notify10SecondsRemaining() as Void {
        if (isSoundEnabled && (Attention has :playTone)) {
            Attention.playTone(5 as Attention.Tone);
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
            Attention.playTone(12 as Attention.Tone);
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

    function vibe3Short() as Void {
        notify10SecondsRemaining();
    }

    function vibe2Long() as Void {
        notifyTimeUp();
    }
}