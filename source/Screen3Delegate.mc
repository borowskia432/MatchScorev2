import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

class Screen3Delegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    // ... zachowaj istniejące metody w swoim pliku Screen3Delegate ...

    function onBack() as Boolean {
        // Przekazujemy parametr Boolean do showMenu()
        // false = bez wyników bramkowych meczu, true = z wynikami meczu
        ExitMenu.showMenu(false); 
        return true;
    }
}