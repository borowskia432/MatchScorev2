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
        var saved = SessionManager.saveSession();
        if (!saved) {
            System.println("SessionManager: Nie udalo sie zapisac sesji.");
            return;
        }

        // Po zapisie zamykamy aplikacje i wracamy do ekranu zegarka.
        System.exit();
    }
}