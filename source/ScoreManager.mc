import Toybox.Lang;
import Toybox.System;

module ScoreManager {

    var scoreA as Number = 0;
    var scoreB as Number = 0;

    class GoalEvent {
        var team as String;          // "A" lub "B"
        var wallClockTime as String; // Godzina rzeczywista np. "18:45:12"
        var scoreA as Number;        // Wynik A po golu
        var scoreB as Number;        // Wynik B po golu

        function initialize(teamName as String, currentScoreA as Number, currentScoreB as Number) {
            self.team = teamName;
            self.scoreA = currentScoreA;
            self.scoreB = currentScoreB;
            self.wallClockTime = ScoreManager.getFormattedClockTime();
        }
    }

    var goalHistory as Array<GoalEvent> = [] as Array<GoalEvent>;

    function getFormattedClockTime() as String {
        var clock = System.getClockTime();
        return Lang.format("$1$:$2$:$3$", [
            clock.hour.format("%02d"),
            clock.min.format("%02d"),
            clock.sec.format("%02d")
        ]);
    }

    function addScoreA(delta as Number) as Void {
        scoreA += delta;
        if (scoreA < 0) {
            scoreA = 0;
        }

        var event = new GoalEvent("A", scoreA, scoreB);
        goalHistory.add(event);
        System.println("GOL dla A | Wynik: " + scoreA + ":" + scoreB);
    }

    function addScoreB(delta as Number) as Void {
        scoreB += delta;
        if (scoreB < 0) {
            scoreB = 0;
        }

        var event = new GoalEvent("B", scoreA, scoreB);
        goalHistory.add(event);
        System.println("GOL dla B | Wynik: " + scoreA + ":" + scoreB);
    }

    function resetScore() as Void {
        scoreA = 0;
        scoreB = 0;
        goalHistory = [] as Array<GoalEvent>;
    }
}