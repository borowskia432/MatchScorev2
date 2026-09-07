import Toybox.Lang;
import Toybox.System;

module ScoreManager {

    // Wyniki w bieżącym secie
    var scoreA as Number = 0;
    var scoreB as Number = 0;

    // Wygrane sety w meczu (Wynik w setach np. 1:0, 2:1)
    var setsA as Number = 0;
    var setsB as Number = 0;

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
        scoreA += delta;
        if (scoreA < 0) {
            scoreA = 0;
        }

        var event = new PointEvent("A", scoreA, scoreB);
        pointHistory.add(event);
        System.println("PUNKT dla A | Sete Score: " + scoreA + ":" + scoreB + " | Sets: " + setsA + ":" + setsB);
        
        checkSetWinCondition();
    }

    // Dodanie punktu dla Drużyny B
    function addScoreB(delta as Number) as Void {
        scoreB += delta;
        if (scoreB < 0) {
            scoreB = 0;
        }

        var event = new PointEvent("B", scoreA, scoreB);
        pointHistory.add(event);
        System.println("PUNKT dla B | Sete Score: " + scoreA + ":" + scoreB + " | Sets: " + setsA + ":" + setsB);
        
        checkSetWinCondition();
    }

    // Sprawdzenie warunku wygrania seta (Siatkówka: do 25 pkt, z zachowaniem 2 pkt przewagi od 24:24)
    function checkSetWinCondition() as Void {
        // Warunek 1: Ktoś osiągnął >= 25 punktów i ma co najmniej 2 punkty przewagi
        if ((scoreA >= 25 || scoreB >= 25) && (scoreA - scoreB >= 2 || scoreB - scoreA >= 2)) {
            if (scoreA > scoreB) {
                setsA += 1;
                System.println(">>> DRUŻYNA A WYGRYWA SET! Stan setów: " + setsA + ":" + setsB);
            } else {
                setsB += 1;
                System.println(">>> DRUŻYNA B WYGRYWA SET! Stan setów: " + setsA + ":" + setsB);
            }
        }
    }

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
        pointHistory = [] as Array<PointEvent>;
    }
}