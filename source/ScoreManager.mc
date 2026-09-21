import Toybox.Lang;
import Toybox.System;

module ScoreManager {

    // Wyniki w bieżącym secie
    var scoreA as Number = 0;
    var scoreB as Number = 0;

    // Wygrane sety w meczu (Wynik w setach np. 1:0, 2:1)
    var setsA as Number = 0;
    var setsB as Number = 0;
    var matchScoreA as Number = 0;
    var matchScoreB as Number = 0;

    class PointEvent {
        var team as String;          // "A" lub "B"
        var wallClockTime as String; // Godzina rzeczywista np. "18:45:12"
        var scoreA as Number;        // Wynik A po punkcie
        var scoreB as Number;        // Wynik B po punkcie

        function initialize(teamName as String, currentScoreA as Number, currentScoreB as Number) {
            self.team = teamName;
            self.scoreA = currentScoreA;
            self.scoreB = currentScoreB;
            self.wallClockTime = ScoreManager.getFormattedClockTime();
        }
    }

    var pointHistory as Array<PointEvent> = [] as Array<PointEvent>;

    function getFormattedClockTime() as String {
        var clock = System.getClockTime();
        return Lang.format("$1$:$2$:$3$", [
            clock.hour.format("%02d"),
            clock.min.format("%02d"),
            clock.sec.format("%02d")
        ]);
    }

    // Dodanie punktu dla Drużyny A
    function addScoreA(delta as Number) as Void {
        if (setsA + setsB >= 5) {
            return;
        }
        scoreA += delta;
        if (scoreA < 0) {
            scoreA = 0;
        }

        var event = new PointEvent("A", scoreA, scoreB);
        pointHistory.add(event);
        System.println("PUNKT dla A | Sete Score: " + scoreA + ":" + scoreB + " | Sets: " + setsA + ":" + setsB);
        
    }

    // Dodanie punktu dla Drużyny B
    function addScoreB(delta as Number) as Void {
        if (setsA + setsB >= 5) {
            return;
        }
        scoreB += delta;
        if (scoreB < 0) {
            scoreB = 0;
        }

        var event = new PointEvent("B", scoreA, scoreB);
        pointHistory.add(event);
        System.println("PUNKT dla B | Sete Score: " + scoreA + ":" + scoreB + " | Sets: " + setsA + ":" + setsB);
        
    }

    function removeScoreA() as Void {
        if (scoreA > 0) {
            scoreA--;
        }
    }

    function removeScoreB() as Void {
        if (scoreB > 0) {
            scoreB--;
        }
    }

    function isCurrentSetWon() as Boolean {
        var target = (setsA + setsB >= 4) ? 15 : 25;
        var scoreDifference = scoreA - scoreB;
        return (scoreA >= target || scoreB >= target) &&
            (scoreDifference >= 2 || scoreDifference <= -2);
    }

    function completeCurrentSet() as Boolean {
        if (!isCurrentSetWon() || setsA + setsB >= 5) {
            return false;
        }

        matchScoreA += scoreA;
        matchScoreB += scoreB;
        if (scoreA > scoreB) {
            setsA++;
        } else {
            setsB++;
        }

        resetSetScore();
        return true;
    }

    function finishCurrentSet() as Boolean {
        if (scoreA == 0 && scoreB == 0) {
            return false;
        }

        matchScoreA += scoreA;
        matchScoreB += scoreB;
        if (isCurrentSetWon() && setsA + setsB < 5) {
            if (scoreA > scoreB) {
                setsA++;
            } else {
                setsB++;
            }
        }

        resetSetScore();
        return true;
    }

    function getScoreA() as Number { return scoreA; }
    function getScoreB() as Number { return scoreB; }
    function getSetsA() as Number { return setsA; }
    function getSetsB() as Number { return setsB; }
    function getMatchScoreA() as Number { return matchScoreA + scoreA; }
    function getMatchScoreB() as Number { return matchScoreB + scoreB; }

    // Reset punktów w bieżącym secie (wywoływane np. przy starcie nowego seta)
    function resetSetScore() as Void {
        scoreA = 0;
        scoreB = 0;
        pointHistory = [] as Array<PointEvent>;
    }

    // Pełny reset meczu
    function resetScore() as Void {
        scoreA = 0;
        scoreB = 0;
        setsA = 0;
        setsB = 0;
        matchScoreA = 0;
        matchScoreB = 0;
        pointHistory = [] as Array<PointEvent>;
    }
}