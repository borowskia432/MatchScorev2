import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Lang;

class VolleyballSummaryView extends WatchUi.View {

    private var _data as SummaryData;

    function initialize(data as SummaryData) {
        View.initialize();
        _data = data;
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(AppConfig.getBackgroundColor(), AppConfig.getBackgroundColor());
        dc.clear();

        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;

        dc.setAntiAlias(true);

        // =====================================================
        // NAGŁÓWEK
        // =====================================================
        dc.setColor(Graphics.COLOR_YELLOW, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            height * 0.06,
            Graphics.FONT_XTINY,
            WatchUi.loadResource(Rez.Strings.SummaryTitle) as String,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        dc.setColor(Graphics.COLOR_DK_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawLine(cx - (width * 0.18), height * 0.11, cx + (width * 0.18), height * 0.11);

        var y = height * 0.18;
        var footerY = height - 12;
        var rowCount = _data.hasScore ? 7 : 6;
        var rowGap = (footerY - y) / rowCount;

        // =====================================================
        // WYNIK MECZU (Siatkówka - Sety + Małe Punkty)
        // =====================================================
        if (_data.hasScore) {
            // 1. Wyświetlamy Sety
            dc.setColor(Graphics.COLOR_BLUE, Graphics.COLOR_TRANSPARENT);
            var setsLabel = WatchUi.loadResource(Rez.Strings.SetsLabel) as String;
            var setsText = Lang.format("$1$: $2$ : $3$", [setsLabel, _data.setsTeamA, _data.setsTeamB]);
            dc.drawText(
                cx,
                y,
                Graphics.FONT_SMALL, // Mniejsza czcionka dla setów
                setsText,
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
            );
            y += rowGap;

    
        }

        // =====================================================
        // STATYSTYKI TRENINGU
        // =====================================================
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);

        var distLabel = WatchUi.loadResource(Rez.Strings.DistanceLabel) as String;
        var distStr = Lang.format("$1$ $2$ $3$", [distLabel, _data.distanceKm.format("%.2f"), WatchUi.loadResource(Rez.Strings.DistanceUnit) as String]);
        dc.drawText(cx, y, Graphics.FONT_XTINY, distStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        y += rowGap;

        var speedLabel = WatchUi.loadResource(Rez.Strings.MaxSpeedLabel) as String;
        var speedStr = Lang.format("$1$ $2$ $3$", [speedLabel, _data.maxSpeedKmH.format("%.1f"), WatchUi.loadResource(Rez.Strings.SpeedUnit) as String]);
        dc.drawText(cx, y, Graphics.FONT_XTINY, speedStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        y += rowGap;

        var minHrStr = (_data.minHr > 0) ? _data.minHr.toString() : "--";
        var maxHrStr = (_data.maxHr > 0) ? _data.maxHr.toString() : "--";
        var hrLabel = WatchUi.loadResource(Rez.Strings.HrLabel) as String;
        var hrStr = Lang.format("$1$ $2$ / $3$", [hrLabel, maxHrStr, minHrStr]);
        dc.drawText(cx, y, Graphics.FONT_XTINY, hrStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        y += rowGap;

        var sprintsLabel = WatchUi.loadResource(Rez.Strings.LabelSummarySprints) as String;
        var sprintsStr = Lang.format("$1$: $2$", [sprintsLabel, _data.sprintsCount]);
        dc.drawText(cx, y, Graphics.FONT_XTINY, sprintsStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        y += rowGap;

        var jumpsCount = ((_data has :jumpsCount) && (_data.jumpsCount != null)) ? _data.jumpsCount : 0;
        var jumpsLabel = WatchUi.loadResource(Rez.Strings.LabelSummaryJumps) as String;
        var jumpsStr = Lang.format("$1$: $2$", [jumpsLabel, jumpsCount]);
        dc.drawText(cx, y, Graphics.FONT_XTINY, jumpsStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        y += rowGap;

        // =====================================================
        // KALORIE
        // =====================================================
        var calLabel = WatchUi.loadResource(Rez.Strings.CaloriesLabel) as String;
        var calStr = Lang.format("$1$ $2$ $3$", [calLabel, _data.calories, WatchUi.loadResource(Rez.Strings.CaloriesUnit) as String]);
        dc.drawText(cx, y, Graphics.FONT_XTINY, calStr, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // =====================================================
        // STOPKA
        // =====================================================
        dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            cx,
            footerY,
            Graphics.FONT_XTINY,
            WatchUi.loadResource(Rez.Strings.CloseHint) as String,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}