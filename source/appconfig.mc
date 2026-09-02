import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Activity;

module AppConfig {
    var isAutoLapEnabled as Boolean = false;
    var isBlackBackground as Boolean = true;

    // Przechowywanie wybranego sportu z MainMenu
    var selectedSportName as String = "Volleyball";
    var selectedSportEnum as Activity.Sport = Activity.SPORT_VOLLEYBALL;

    // Stan punktacji dla BIEŻĄCEGO seta
    var volleyballScoreA as Number = 0;
    var volleyballScoreB as Number = 0;

    // Skumulowany wynik CAŁEGO MECZU (suma ze wszystkich setów)
    var matchScoreA as Number = 0;
    var matchScoreB as Number = 0;

    function getBackgroundColor() as Graphics.ColorValue {
        return isBlackBackground ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;
    }

    function getTextColor() as Graphics.ColorValue {
        return isBlackBackground ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
    }

    function setBlackBackground(isBlack as Boolean) as Void {
        isBlackBackground = isBlack;
    }

    function toggleBackgroundColor() as Void {
        isBlackBackground = !isBlackBackground;
    }

    // Resetowanie punktów tylko dla bieżącego seta
    function resetVolleyballScores() as Void {
        volleyballScoreA = 0;
        volleyballScoreB = 0;
    }

    // Reset całego meczu (wywoływane przy starcie nowej sesji)
    function resetMatch() as Void {
        volleyballScoreA = 0;
        volleyballScoreB = 0;
        matchScoreA = 0;
        matchScoreB = 0;
    }
}