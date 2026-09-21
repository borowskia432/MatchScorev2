import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

class SummaryDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onSelect() as Boolean {
        saveAndExit();
        return true;
    }

    function onBack() as Boolean {
        saveAndExit();
        return true;
    }

    private function saveAndExit() as Void {

        // Zapis sesji FIT do pamięci zegarka.
        // SessionManager pobiera końcowe statystyki
        // bezpośrednio z SportsMetricsManager.
        SessionManager.saveSession();

        // Po zapisie zamykamy aplikacje i wracamy do ekranu zegarka.
        System.exit();
    }
}