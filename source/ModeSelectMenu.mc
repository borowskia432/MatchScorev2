import Toybox.WatchUi;
import Toybox.Lang;
import Toybox.Activity;

module ModeSelectMenu {

    function createMenu() as [ Views, InputDelegates ] {
        var titleStr = "Select Mode";
        if (Rez has :Strings && Rez.Strings has :SelectModeTitle) {
            titleStr = WatchUi.loadResource(Rez.Strings.SelectModeTitle) as String;
        }

        var menu = new WatchUi.Menu2({:title => titleStr});

        var manualStr = "Manual Laps / Sets";
        if (Rez has :Strings && Rez.Strings has :ModeManual) {
            manualStr = WatchUi.loadResource(Rez.Strings.ModeManual) as String;
        }

        var autoStr = "Auto-Lap (1km)";
        if (Rez has :Strings && Rez.Strings has :ModeAuto) {
            autoStr = WatchUi.loadResource(Rez.Strings.ModeAuto) as String;
        }

        menu.addItem(new WatchUi.MenuItem(manualStr, null, "mode_manual", null));
        menu.addItem(new WatchUi.MenuItem(autoStr, null, "mode_auto", null));

        return [menu, new ModeSelectMenuDelegate()] as [ Views, InputDelegates ];
    }
}

class ModeSelectMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        if (id.equals("mode_manual")) {
            AppConfig.isAutoLapEnabled = false;
        } else if (id.equals("mode_auto")) {
            AppConfig.isAutoLapEnabled = true;
        }

        // Startujemy sesję FIT na podstawie zapisanego wcześniej sportu w AppConfig
        SessionManager.startSession(AppConfig.selectedSportName, AppConfig.selectedSportEnum);

        // Przechodzimy do właściwego ekranu w zależności od dyscypliny
        if (AppConfig.selectedSportEnum == Activity.SPORT_VOLLEYBALL) {
            WatchUi.switchToView(new Screen3View(), new Screen3Delegate(), WatchUi.SLIDE_IMMEDIATE);
        } else if (AppConfig.selectedSportEnum == Activity.SPORT_SOCCER) {
            WatchUi.switchToView(new Screen2View(), new Screen2Delegate(), WatchUi.SLIDE_IMMEDIATE);
        } else {
            WatchUi.switchToView(new Screen1View(), new Screen1Delegate(), WatchUi.SLIDE_IMMEDIATE);
        }
    }
}