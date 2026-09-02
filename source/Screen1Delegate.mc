import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;
import Toybox.Timer;

class Screen1Delegate extends WatchUi.BehaviorDelegate {

    private var _upTimer as Timer.Timer or Null = null;
    private var _downTimer as Timer.Timer or Null = null;

    private const DOUBLE_PRESS_THRESHOLD as Number = 220;

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Boolean {
        return openSettingsMenu();
    }

    function onMenu() as Boolean {
        return openSettingsMenu();
    }

    function onKey(keyEvent as WatchUi.KeyEvent) as Boolean {
        var key = keyEvent.getKey();

        if (key == WatchUi.KEY_UP) {
            var tUp = _upTimer;
            if (tUp != null) {
                tUp.stop();
                _upTimer = null;
                
                ScoreManager.addScoreA(-1);
                WatchUi.requestUpdate();
            } else {
                var timer = new Timer.Timer();
                _upTimer = timer;
                timer.start(method(:onKeyUpTimeout), DOUBLE_PRESS_THRESHOLD, false);
            }
            return true;
        } 
        else if (key == WatchUi.KEY_DOWN) {
            var tDown = _downTimer;
            if (tDown != null) {
                tDown.stop();
                _downTimer = null;

                ScoreManager.addScoreB(-1);
                WatchUi.requestUpdate();
            } else {
                var timer = new Timer.Timer();
                _downTimer = timer;
                timer.start(method(:onKeyDownTimeout), DOUBLE_PRESS_THRESHOLD, false);
            }
            return true;
        } 
        else if (key == WatchUi.KEY_ENTER || key == WatchUi.KEY_START) {
            return openSettingsMenu();
        }

        return false;
    }

    function onKeyUpTimeout() as Void {
        _upTimer = null;
        ScoreManager.addScoreA(1);
        WatchUi.requestUpdate();
    }

    function onKeyDownTimeout() as Void {
        _downTimer = null;
        ScoreManager.addScoreB(1);
        WatchUi.requestUpdate();
    }

    private function openSettingsMenu() as Boolean {
        cancelPendingTimers();
        var menuPair = SettingsMenu.createMenu();
        WatchUi.pushView(menuPair[0], menuPair[1], WatchUi.SLIDE_UP);
        return true;
    }

    function onBack() as Boolean {
        cancelPendingTimers();
        ExitMenu.showMenu();
        return true;
    }

    function onTap(clickEvent as WatchUi.ClickEvent) as Boolean {
        var coords = clickEvent.getCoordinates();
        var screenWidth = System.getDeviceSettings().screenWidth;

        if (coords[0] < screenWidth / 2) {
            ScoreManager.addScoreA(1);
        } else {
            ScoreManager.addScoreB(1);
        }

        WatchUi.requestUpdate();
        return true;
    }

    private function cancelPendingTimers() as Void {
        var tUp = _upTimer;
        if (tUp != null) {
            tUp.stop();
            _upTimer = null;
        }
        var tDown = _downTimer;
        if (tDown != null) {
            tDown.stop();
            _downTimer = null;
        }
    }
}