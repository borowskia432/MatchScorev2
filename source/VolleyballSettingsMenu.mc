import Toybox.WatchUi;
import Toybox.Lang;

module VolleyballSettingsMenu {

    function createMenu() as [ Views, InputDelegates ] {
        var titleStr = WatchUi.loadResource(Rez.Strings.SettingsTitle) as String;
        var menu = new WatchUi.Menu2({:title => titleStr});

        // Pobieranie tekstów z zasobów (wsparcie dla PL/ENG)
        var newSetStr = WatchUi.loadResource(Rez.Strings.NewSet) as String;
        var colorLabelStr = WatchUi.loadResource(Rez.Strings.ScreenColor) as String;

        // Pozycja 1: Ręczne dodanie nowego seta / okrążenia (przesunięte na górę)
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
            // Wywołanie ręcznego lapa / nowego seta w sesji FIT
            if (SessionManager has :addManualLap) {
                SessionManager.addManualLap();
            }
            
            // Zamknij menu po dodaniu seta, aby wrócić do widoku meczu
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);

        } else if (id.equals("toggle_color")) {
            if (AppConfig has :toggleBackgroundColor) {
                AppConfig.toggleBackgroundColor();
            }
            
            // Zamknij menu natychmiastowo, co powróci do ekranu i zmusi go do przerysowania
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
}