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
        var scoreA = ScoreManager.scoreA;
        var scoreB = ScoreManager.scoreB;
        var burstCount = BurstManager.burstCount;

        // Zapis sesji FIT do pamięci zegarka
        SessionManager.saveSession(scoreA, scoreB, burstCount);

        // Wyjście z aplikacji (zamyka proces)
        System.exit();
    }
}