import Toybox.Lang;

module ScoreManager {

    var scoreA as Number = 0;
    var scoreB as Number = 0;

    //! Dodaje lub odejmuje punkty dla Drużyny A
    function addScoreA(delta as Number) as Void {
        scoreA += delta;
        if (scoreA < 0) {
            scoreA = 0;
        }
        // Wyślij zaktualizowany punkt do pliku FIT
        SessionManager.updateScoreChart(scoreA, scoreB);
    }

    //! Dodaje lub odejmuje punkty dla Drużyny B
    function addScoreB(delta as Number) as Void {
        scoreB += delta;
        if (scoreB < 0) {
            scoreB = 0;
        }
        // Wyślij zaktualizowany punkt do pliku FIT
        SessionManager.updateScoreChart(scoreA, scoreB);
    }

    //! Resetuje wynik meczu
    function resetScore() as Void {
        scoreA = 0;
        scoreB = 0;
        SessionManager.updateScoreChart(scoreA, scoreB);
    }
}