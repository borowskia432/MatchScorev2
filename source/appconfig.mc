import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Activity;

module AppConfig {
    var isAutoLapEnabled as Boolean = false;
    var isBlackBackground as Boolean = true;

    // Przechowywanie wybranego sportu z MainMenu
    var selectedSportName as String = "Volleyball";
    var selectedSportEnum as Activity.Sport = Activity.SPORT_VOLLEYBALL;

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
}