import Toybox.WatchUi;
import Toybox.Lang;

module VolleyballSettingsMenu {

    function createMenu() as [ Views, InputDelegates ] {
        var titleStr = WatchUi.loadResource(Rez.Strings.SettingsTitle) as String;
        var menu = new WatchUi.Menu2({:title => titleStr});

        var newSetStr = WatchUi.loadResource(Rez.Strings.NewSet) as String;
        var colorLabelStr = WatchUi.loadResource(Rez.Strings.ScreenColor) as String;
        var calibrationStr = WatchUi.loadResource(Rez.Strings.JumpCalibration) as String;

        // Pozycja 1: Ręczne dodanie nowego seta / okrążenia
        menu.addItem(new WatchUi.MenuItem(
            newSetStr,
            null,
            "new_set",
            null
        ));

        // Pozycja 2: Zmiana koloru tła
        menu.addItem(new WatchUi.MenuItem(
            colorLabelStr,
            null,
            "toggle_color",
            null
        ));

        menu.addItem(new WatchUi.MenuItem(
            calibrationStr,
            null,
            "calibrate_jumps",
            null
        ));

        return [menu, new VolleyballSettingsMenuDelegate()] as [ Views, InputDelegates ];
    }
}

class VolleyballSettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        if (id.equals("new_set")) {
            SessionManager.finalizeCurrentSet();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);

        } else if (id.equals("toggle_color")) {
            AppConfig.toggleBackgroundColor();
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        } else if (id.equals("calibrate_jumps")) {
            WatchUi.pushView(new JumpCalibrationView(), new JumpCalibrationDelegate(), WatchUi.SLIDE_UP);
        }
    }
}