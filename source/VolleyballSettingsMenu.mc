import Toybox.WatchUi;
import Toybox.Lang;

module VolleyballSettingsMenu {

    function createMenu() as [ Views, InputDelegates ] {
        // Bezpośrednie ładowanie zasobów tekstowych
        var titleStr = WatchUi.loadResource(Rez.Strings.SettingsTitle) as String;
        var menu = new WatchUi.Menu2({:title => titleStr});

        var colorLabelStr = WatchUi.loadResource(Rez.Strings.ScreenColor) as String;

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

        if (id.equals("toggle_color")) {
            if (AppConfig has :toggleBackgroundColor) {
                AppConfig.toggleBackgroundColor();
            }
            
            // Zamknij menu natychmiastowo, co powróci do ekranu i zmusi go do przerysowania
            WatchUi.popView(WatchUi.SLIDE_IMMEDIATE);
        }
    }
}