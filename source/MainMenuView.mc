import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Lang;

module MainMenu {
    function createMenu() as [ Views, InputDelegates ] {
        var menu = new WatchUi.Menu2({:title => WatchUi.loadResource(Rez.Strings.MainMenuTitle) as String});

        menu.addItem(new WatchUi.MenuItem(
            WatchUi.loadResource(Rez.Strings.FootballRun) as String,
            null,
            "fb_run",
            null
        ));

        menu.addItem(new WatchUi.MenuItem(
            WatchUi.loadResource(Rez.Strings.Football) as String,
            null,
            "fb",
            null
        ));

        menu.addItem(new WatchUi.MenuItem(
            WatchUi.loadResource(Rez.Strings.Volleyball) as String,
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
            // Stoper NIE uruchamia się automatycznie. Gracz uruchamia go z poziomu Menu.
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