import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Activity;
import Toybox.System;
import Toybox.Lang;

class Screen3View extends WatchUi.View {

    // Cache dla zasobów tekstowych
     private var _setsLabel as String = "";
    private var _teamALabel as String = "";
    private var _teamBLabel as String = "";
    private var _labelBursts as String = "";
    private var _labelJumps as String = "";
    function initialize() {
        View.initialize();
        
         _setsLabel = WatchUi.loadResource(Rez.Strings.SetsLabel) as String;
        _teamALabel = WatchUi.loadResource(Rez.Strings.TeamA) as String;
        _teamBLabel = WatchUi.loadResource(Rez.Strings.TeamB) as String;
        _labelBursts = WatchUi.loadResource(Rez.Strings.LabelBursts) as String;
        _labelJumps = WatchUi.loadResource(Rez.Strings.LabelJumps) as String;
    }

    function onShow() as Void {
        // Uruchamiamy główny, modułowy timer z logiką
        TimerManager.startBackgroundTick();
    }

    function onHide() as Void {
        // Zatrzymujemy timer z logiką, gdy wychodzimy z widoku
        TimerManager.stopBackgroundTick();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        // Ustawienie tła
        dc.setColor(AppConfig.getBackgroundColor(), AppConfig.getBackgroundColor());
        dc.clear();
        dc.setAntiAlias(true);

        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;

        // Pasek HR
        HrArcRenderer.draw(dc, cx, height / 2, width);

        // 1. Stan setów
        var setsString = _setsLabel + ": " + AppConfig.volleyballSetsA.toString() + " - " + AppConfig.volleyballSetsB.toString();
        dc.drawText(cx, 45, Graphics.FONT_XTINY, setsString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
 // 2. Etykiety Drużyn
        dc.drawText(cx - 65, 80, Graphics.FONT_SMALL, _teamALabel, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(cx + 65, 80, Graphics.FONT_SMALL, _teamBLabel, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // 3. Wyniki
        var scoreString = AppConfig.volleyballScoreA.toString() + " : " + AppConfig.volleyballScoreB.toString();
        dc.drawText(cx, 130, Graphics.FONT_NUMBER_HOT, scoreString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Dane aktywności
        var info = Activity.getActivityInfo();
        
        var maxSpeedMps = (info != null && info.maxSpeed != null) ? info.maxSpeed : 0.0;
        var currentSpeedMps = (info != null && info.currentSpeed != null) ? info.currentSpeed : 0.0;

        var vmaxKmH = maxSpeedMps * 3.6;
        var metersPerMin = currentSpeedMps * 60.0;

        var speedMetricsText = Lang.format("Vmax: $1$ km/h | $2$ M/min", [
            vmaxKmH.format("%.1f"), 
            metersPerMin.format("%.0f")
        ]);

        dc.drawText(
            cx,
            height * 0.60, 
            Graphics.FONT_XTINY,
            speedMetricsText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // HR + Dystans
        var hrVal = (info != null && info.currentHeartRate != null) ? info.currentHeartRate.toString() : "--";
        var distVal = (info != null && info.elapsedDistance != null) ? (info.elapsedDistance / 1000.0) : 0.00;

        var hrDistText = Lang.format("HR: $1$ | $2$ km", [
            hrVal, 
            distVal.format("%.2f")
        ]);

        dc.drawText(
            cx,
            height * 0.67, 
            Graphics.FONT_SMALL,
            hrDistText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Zrywy + Wyskoki
        var bursts = SportsMetricsManager.getTotalBursts();
        var jumps = SportsMetricsManager.getTotalJumps();

        var volleyballStatsText = Lang.format("$1$: $2$ | $3$: $4$", [
            _labelBursts, 
            bursts, 
            _labelJumps, 
            jumps
        ]);

        dc.drawText(
            cx,
            height * 0.79, 
            Graphics.FONT_XTINY,
            volleyballStatsText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Godzina
        var sysTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [
            sysTime.hour.format("%02d"), 
            sysTime.min.format("%02d")
        ]);

        dc.drawText(
            cx,
            height * 0.88, 
            Graphics.FONT_SMALL,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}