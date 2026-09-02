import Toybox.WatchUi;
import Toybox.Lang;

class Screen3Delegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onBack() as Boolean {
        ExitMenu.showMenu();
        return true;
    }

    function onSelect() as Boolean {
    var settings = SettingsMenu.createMenu();
    WatchUi.pushView(settings[0], settings[1], WatchUi.SLIDE_UP);
    return true;
}
}