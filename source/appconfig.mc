import Toybox.Graphics;
import Toybox.Lang;

module AppConfig {
    var isBlackBackground as Boolean = true;

    function getBackgroundColor() as Graphics.ColorValue {
        return isBlackBackground ? Graphics.COLOR_BLACK : Graphics.COLOR_WHITE;
    }

    function getTextColor() as Graphics.ColorValue {
        return isBlackBackground ? Graphics.COLOR_WHITE : Graphics.COLOR_BLACK;
    }

    function setBlackBackground(isBlack as Boolean) as Void {
        isBlackBackground = isBlack;
    }
}