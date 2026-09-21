import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;

class Screen2View extends WatchUi.View {

    private var _refreshTimer as Timer.Timer or Null = null;

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        if (_refreshTimer == null) {
            _refreshTimer = new Timer.Timer();
            _refreshTimer.start(new Lang.Method(self, :onRefresh), 1000, true);
        }
    }

    function onHide() as Void {
        if (_refreshTimer != null) {
            _refreshTimer.stop();
            _refreshTimer = null;
        }
    }

    function onRefresh() as Void {
        BurstManager.update();
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(AppConfig.getBackgroundColor(), AppConfig.getBackgroundColor());
        dc.clear();
        dc.setAntiAlias(true);

        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;
        var screenSize = width < height ? width : height;
        var horizontalScale = screenSize / 280.0;

        // Pasek HR (Współdzielony renderer)
        HrArcRenderer.draw(dc, cx, height / 2, screenSize);

        dc.setColor(AppConfig.getTextColor(), Graphics.COLOR_TRANSPARENT);

        // Status
        var statusText = TimerManager.isRunning
            ? (WatchUi.loadResource(Rez.Strings.StatusToChange) as String)
            : (WatchUi.loadResource(Rez.Strings.StatusPause) as String);

        dc.drawText(cx, height * 0.114, Graphics.FONT_XTINY, statusText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Stoper
        dc.drawText(cx, height * 0.186, Graphics.FONT_SMALL, TimerManager.getFormattedTime(), Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Drużyna A & B
        dc.drawText(cx - (65 * horizontalScale), height * 0.321, Graphics.FONT_SMALL, WatchUi.loadResource(Rez.Strings.TeamA) as String, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(cx + (65 * horizontalScale), height * 0.321, Graphics.FONT_SMALL, WatchUi.loadResource(Rez.Strings.TeamB) as String, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Wynik
        var scoreString = ScoreManager.scoreA.toString() + " : " + ScoreManager.scoreB.toString();
        dc.drawText(cx, height * 0.464, Graphics.FONT_NUMBER_HOT, scoreString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Dane Aktywności
        var info = Activity.getActivityInfo();
        var maxSpeedMps = (info != null && info.maxSpeed != null) ? info.maxSpeed : 0.0;
        var currentSpeedMps = (info != null && info.currentSpeed != null) ? info.currentSpeed : 0.0;

        var vmaxKmH = maxSpeedMps * 3.6;
        var metersPerMin = currentSpeedMps * 60.0;

        var speedMetricsText = Lang.format("$1$ $2$ $3$ | $4$ $5$", [
            WatchUi.loadResource(Rez.Strings.MaxSpeedLabel) as String,
            vmaxKmH.format("%.1f"),
            WatchUi.loadResource(Rez.Strings.SpeedUnit) as String,
            metersPerMin.format("%.0f"),
            WatchUi.loadResource(Rez.Strings.MetersPerMinuteUnit) as String
        ]);
        dc.drawText(cx, height * 0.636, Graphics.FONT_XTINY, speedMetricsText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var hrVal = (info != null && info.currentHeartRate != null) ? info.currentHeartRate.toString() : "--";
        var distVal = (info != null && info.elapsedDistance != null) ? info.elapsedDistance / 1000.0 : 0.00;

        var hrDistText = Lang.format("$1$ $2$ | $3$ $4$", [
            WatchUi.loadResource(Rez.Strings.HeartRateLabel) as String,
            hrVal,
            distVal.format("%.2f"),
            WatchUi.loadResource(Rez.Strings.DistanceUnit) as String
        ]);
        dc.drawText(cx, height * 0.721, Graphics.FONT_SMALL, hrDistText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Statystyki siatkarskie – z uwzględnieniem tłumaczeń
        var bursts = SportsMetricsManager.getTotalBursts();
        var jumps = SportsMetricsManager.getTotalJumps();

        var labelBursts = WatchUi.loadResource(Rez.Strings.LabelBursts) as String;
        var labelJumps = WatchUi.loadResource(Rez.Strings.LabelJumps) as String;

        var volleyballStatsText = labelBursts + ": " + bursts + " | " + labelJumps + ": " + jumps;
        dc.drawText(cx, height * 0.821, Graphics.FONT_XTINY, volleyballStatsText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Godzina
        var sysTime = System.getClockTime();
        var timeString = sysTime.hour.format("%02d") + ":" + sysTime.min.format("%02d");
        dc.drawText(cx, height * 0.936, Graphics.FONT_SMALL, timeString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}