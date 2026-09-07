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

        // 1. Konfiguracja sportu i trybu lapa bezpośrednio przy wyborze z menu
        if (id.equals("fb_run")) {
            AppConfig.selectedSportName = "Football Run";
            AppConfig.selectedSportEnum = Activity.SPORT_RUNNING;
            AppConfig.isAutoLapEnabled = true; // Bieg z auto-lapem
        } else if (id.equals("fb")) {
            AppConfig.selectedSportName = "Football";
            AppConfig.selectedSportEnum = Activity.SPORT_SOCCER;
            AppConfig.isAutoLapEnabled = true; // Piłka nożna z auto-lapem
        } else if (id.equals("vb")) {
            AppConfig.selectedSportName = "Volleyball";
            AppConfig.selectedSportEnum = Activity.SPORT_VOLLEYBALL;
            AppConfig.isAutoLapEnabled = false; // Siatkówka z manualnym lapem (nowy set)
        }

        // 2. Uruchomienie sesji treningowej Garmin
        SessionManager.startSession(AppConfig.selectedSportName, AppConfig.selectedSportEnum);

        // 3. Przejście do odpowiedniego ekranu widoku (Siatkówka -> Screen3, Inne -> Screen2)
        if (id.equals("vb")) {
            WatchUi.switchToView(new Screen3View(), new Screen3Delegate(), WatchUi.SLIDE_IMMEDIATE);
        } else {
            WatchUi.switchToView(new Screen2View(), new Screen2Delegate(), WatchUi.SLIDE_IMMEDIATE);
        }
    }
}