import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;

module MainMenu {
    function createMenu() as [ Views, InputDelegates ] {
        // Poprawne wywołanie loadResource bez błędnego rzutowania na Lang.Symbol
        var titleStr = WatchUi.loadResource(Rez.Strings.MainMenuTitle) as String;
        var runStr   = WatchUi.loadResource(Rez.Strings.FootballRun) as String;
        var fbStr    = WatchUi.loadResource(Rez.Strings.Football) as String;
        var vbStr    = WatchUi.loadResource(Rez.Strings.Volleyball) as String;

        var menu = new WatchUi.Menu2({:title => titleStr});

        menu.addItem(new WatchUi.MenuItem(
            runStr,
            null,
            "fb_run",
            null
        ));

        menu.addItem(new WatchUi.MenuItem(
            fbStr,
            null,
            "fb",
            null
        ));

        menu.addItem(new WatchUi.MenuItem(
            vbStr,
            null,
            "vb",
            null
        ));

        return [menu, new MainMenuDelegate()] as [ Views, InputDelegates ];
    }
}

class MainMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        if (id.equals("fb_run")) {
            SessionManager.startSession("Football Run", Activity.SPORT_RUNNING);
            WatchUi.pushView(new Screen1View(), new Screen1Delegate(), WatchUi.SLIDE_LEFT);
        } else if (id.equals("fb")) {
            SessionManager.startSession("Football", Activity.SPORT_SOCCER);
            WatchUi.pushView(new Screen2View(), new Screen2Delegate(), WatchUi.SLIDE_LEFT);
        } else if (id.equals("vb")) {
            SessionManager.startSession("Volleyball", Activity.SPORT_VOLLEYBALL);
            WatchUi.pushView(new Screen3View(), new Screen3Delegate(), WatchUi.SLIDE_LEFT);
        }
    }
}