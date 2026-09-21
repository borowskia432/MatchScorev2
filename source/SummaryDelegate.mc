import Toybox.WatchUi;
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

        // Po zapisie wracamy do menu aplikacji zamiast otwierać ekran systemowy zegarka.
        var menuPair = MainMenu.createMenu();
        WatchUi.switchToView(
            menuPair[0],
            menuPair[1],
            WatchUi.SLIDE_IMMEDIATE
        );
    }
}