import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Timer;
import Toybox.Lang;

class JumpCalibrationView extends WatchUi.View {

    private var _timer as Timer.Timer or Null = null;
    private var _seconds as Number = 0;
    private var _complete as Boolean = false;
    private var _title as String = "";
    private var _instruction as String = "";
    private var _progress as String = "";
    private var _done as String = "";
    private var _ready as String = "";

    function initialize() {
        View.initialize();
        _title = WatchUi.loadResource(Rez.Strings.JumpCalibrationTitle) as String;
        _instruction = WatchUi.loadResource(Rez.Strings.JumpCalibrationInstruction) as String;
        _progress = WatchUi.loadResource(Rez.Strings.JumpCalibrationProgress) as String;
        _done = WatchUi.loadResource(Rez.Strings.JumpCalibrationDone) as String;
        _ready = WatchUi.loadResource(Rez.Strings.JumpCalibrationReady) as String;
    }

    function onShow() as Void {
        JumpManager.beginCalibration();
        _timer = new Timer.Timer();
        _timer.start(method(:onTick), 1000, true);
    }

    function onHide() as Void {
        if (_timer != null) {
            _timer.stop();
            _timer = null;
        }
        if (JumpManager.isCalibrating()) {
            JumpManager.cancelCalibration();
        }
    }

    function onTick() as Void {
        _seconds++;
        if (_seconds >= 10) {
            JumpManager.finishCalibration();
            _complete = true;
            if (_timer != null) {
                _timer.stop();
                _timer = null;
            }
        }
        WatchUi.requestUpdate();
    }

    function isComplete() as Boolean {
        return _complete;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;

        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        dc.drawText(cx, height * 0.18, Graphics.FONT_SMALL, _title, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        if (_complete) {
            dc.drawText(cx, height * 0.43, Graphics.FONT_SMALL, _done, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(cx, height * 0.68, Graphics.FONT_XTINY, _ready, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            dc.drawText(cx, height * 0.36, Graphics.FONT_XTINY, _instruction, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
            dc.drawText(cx, height * 0.58, Graphics.FONT_NUMBER_HOT, Lang.format(_progress, [_seconds]), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }
}

class JumpCalibrationDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }

    function onSelect() as Boolean {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        return true;
    }
}
