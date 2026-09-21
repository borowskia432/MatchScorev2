import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Activity;
import Toybox.System;
import Toybox.Lang;

class Screen1View extends WatchUi.View {

    // Cache dla zasobów tekstowych
    private var _statusToChangeStr as String = "";
    private var _statusPauseStr as String = "";
    private var _labelBursts as String = "";
    private var _labelJumps as String = "";
    private var _maxSpeedLabel as String = "";
    private var _heartRateLabel as String = "";
    private var _speedUnit as String = "";
    private var _metersPerMinuteUnit as String = "";
    private var _distanceUnit as String = "";

    function initialize() {
        View.initialize();
        
        _statusToChangeStr = WatchUi.loadResource(Rez.Strings.StatusToChange) as String;
        _statusPauseStr    = WatchUi.loadResource(Rez.Strings.StatusPause) as String;
        _labelBursts       = WatchUi.loadResource(Rez.Strings.LabelBursts) as String;
        _labelJumps        = WatchUi.loadResource(Rez.Strings.LabelJumps) as String;
        _maxSpeedLabel     = WatchUi.loadResource(Rez.Strings.MaxSpeedLabel) as String;
        _heartRateLabel    = WatchUi.loadResource(Rez.Strings.HeartRateLabel) as String;
        _speedUnit         = WatchUi.loadResource(Rez.Strings.SpeedUnit) as String;
        _metersPerMinuteUnit = WatchUi.loadResource(Rez.Strings.MetersPerMinuteUnit) as String;
        _distanceUnit      = WatchUi.loadResource(Rez.Strings.DistanceUnit) as String;
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
        var screenSize = width < height ? width : height;

        // Pasek HR
        HrArcRenderer.draw(dc, cx, height / 2, screenSize);

        // Kolor tekstu
        dc.setColor(AppConfig.getTextColor(), Graphics.COLOR_TRANSPARENT);

        // Status
        var statusText = TimerManager.isRunning ? _statusToChangeStr : _statusPauseStr;
        
        dc.drawText(
            cx,
            height * 0.12, 
            Graphics.FONT_XTINY,
            statusText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Stoper
        dc.drawText(
            cx,
            height * 0.25, 
            Graphics.FONT_MEDIUM,
            TimerManager.getFormattedTime(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // Dane aktywności
        var info = Activity.getActivityInfo();
        
        var maxSpeedMps = (info != null && info.maxSpeed != null) ? info.maxSpeed : 0.0;
        var currentSpeedMps = (info != null && info.currentSpeed != null) ? info.currentSpeed : 0.0;

        var vmaxKmH = maxSpeedMps * 3.6;
        var metersPerMin = currentSpeedMps * 60.0;

        var speedMetricsText = Lang.format("$1$ $2$ $3$ | $4$ $5$", [
            _maxSpeedLabel,
            vmaxKmH.format("%.1f"), 
            _speedUnit,
            metersPerMin.format("%.0f"),
            _metersPerMinuteUnit
        ]);

        dc.drawText(
            cx,
            height * 0.54, 
            Graphics.FONT_XTINY,
            speedMetricsText,
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );

        // HR + Dystans
        var hrVal = (info != null && info.currentHeartRate != null) ? info.currentHeartRate.toString() : "--";
        var distVal = (info != null && info.elapsedDistance != null) ? (info.elapsedDistance / 1000.0) : 0.00;

        var hrDistText = Lang.format("$1$ $2$ | $3$ $4$", [
            _heartRateLabel,
            hrVal, 
            distVal.format("%.2f"),
            _distanceUnit
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