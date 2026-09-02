import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class SummaryView extends WatchUi.View {

    private var _data as SummaryData;

    function initialize(data as SummaryData) {
        View.initialize();
        _data = data;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var cx = dc.getWidth() / 2;
        var height = dc.getHeight();

        dc.setAntiAlias(true);

        // NAGŁÓWEK
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            18,
            Graphics.FONT_XTINY,
            "PODSUMOWANIE",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Poprawiona stała koloru: Graphics.COLOR_DK_GRAY
        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx - 50, 30, cx + 50, 30);

        var y = 48;

        // WYNIK MECZU (Widoczny tylko gdy hasScore = true)
        if (_data.hasScore) {
            dc.setColor(Graphics.COLOR_GREEN, Graphics.COLOR_TRANSPARENT);
            var scoreText = "Mecz: " + _data.scoreTeamA + " : " + _data.scoreTeamB;
            dc.drawText(
                cx,
                y,
                Graphics.FONT_SMALL,
                scoreText,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
            y += 28;
        }

        // STATYSTYKI TRENINGU
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var distStr = "Dystans: " + _data.distanceKm.format("%.2f") + " km";
        dc.drawText(cx, y, Graphics.FONT_XTINY, distStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        y += 22;

        var speedStr = "Vmax: " + _data.maxSpeedKmH.format("%.1f") + " km/h";
        dc.drawText(cx, y, Graphics.FONT_XTINY, speedStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        y += 22;

        var minHrStr = (_data.minHr > 0) ? _data.minHr.toString() : "--";
        var maxHrStr = (_data.maxHr > 0) ? _data.maxHr.toString() : "--";
        var hrStr = "HR Max/Min: " + maxHrStr + " / " + minHrStr;
        dc.drawText(cx, y, Graphics.FONT_XTINY, hrStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        y += 22;

        var sprintsStr = "Ilość zrywów: " + _data.sprintsCount;
        dc.drawText(cx, y, Graphics.FONT_XTINY, sprintsStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // STOPKA
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            height - 20,
            Graphics.FONT_XTINY,
            "[SELECT] Zamknij",
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}