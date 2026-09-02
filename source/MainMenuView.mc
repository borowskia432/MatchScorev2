import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;

module MainMenu {
    function createMenu() as [ Views, InputDelegates ] {
        var titleStr = WatchUi.loadResource(Rez.Strings.MainMenuTitle) as String;
        var runStr   = WatchUi.loadResource(Rez.Strings.FootballRun) as String;
        var fbStr    = WatchUi.loadResource(Rez.Strings.Football) as String;
        var vbStr    = WatchUi.loadResource(Rez.Strings.Volleyball) as String;

        var menu = new WatchUi.Menu2({:title => titleStr});

        menu.addItem(new WatchUi.MenuItem(runStr, null, "fb_run", null));
        menu.addItem(new WatchUi.MenuItem(fbStr, null, "fb", null));
        menu.addItem(new WatchUi.MenuItem(vbStr, null, "vb", null));

        return [menu, new MainMenuDelegate()] as [ Views, InputDelegates ];
    }
}

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        // 1. Zapisujemy wybrany sport w AppConfig do późniejszego wykorzystania
        if (id.equals("fb_run")) {
            AppConfig.selectedSportName = "Football Run";
            AppConfig.selectedSportEnum = Activity.SPORT_RUNNING;
        } else if (id.equals("fb")) {
            AppConfig.selectedSportName = "Football";
            AppConfig.selectedSportEnum = Activity.SPORT_SOCCER;
        } else if (id.equals("vb")) {
            AppConfig.selectedSportName = "Volleyball";
            AppConfig.selectedSportEnum = Activity.SPORT_VOLLEYBALL;
        }

        // 2. Przechodzimy do menu wyboru trybu okrążeń zamiast od razu startować sesję
        var modeMenuData = ModeSelectMenu.createMenu();
        WatchUi.pushView(modeMenuData[0], modeMenuData[1], WatchUi.SLIDE_LEFT);
    }
}