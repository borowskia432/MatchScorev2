import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Activity;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.System;

class Screen3View extends WatchUi.View {

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
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(AppConfig.getBackgroundColor(), AppConfig.getBackgroundColor());
        dc.clear();
        dc.setAntiAlias(true);

        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;

        // Pasek HR (Współdzielony renderer)
        HrArcRenderer.draw(dc, cx, height / 2, width);

        dc.setColor(AppConfig.getTextColor(), Graphics.COLOR_TRANSPARENT);

        // Drużyna A & B
        dc.drawText(cx - 65, 75, Graphics.FONT_SMALL, WatchUi.loadResource(Rez.Strings.TeamA) as String, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(cx + 65, 75, Graphics.FONT_SMALL, WatchUi.loadResource(Rez.Strings.TeamB) as String, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Wynik pobierany z AppConfig (zgodny z delegatem i nowym setem)
        var scoreString = AppConfig.volleyballScoreA.toString() + " : " + AppConfig.volleyballScoreB.toString();
        dc.drawText(cx, 125, Graphics.FONT_NUMBER_HOT, scoreString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Dane Aktywności
        var info = Activity.getActivityInfo();
        var maxSpeedMps = (info != null && info.maxSpeed != null) ? info.maxSpeed : 0.0;
        var currentSpeedMps = (info != null && info.currentSpeed != null) ? info.currentSpeed : 0.0;

        var vmaxKmH = maxSpeedMps * 3.6;
        var metersPerMin = currentSpeedMps * 60.0;

        var speedMetricsText = "Vmax: " + vmaxKmH.format("%.1f") + " km/h | " + metersPerMin.format("%.0f") + " M/min";
        dc.drawText(cx, 165, Graphics.FONT_XTINY, speedMetricsText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        var hrVal = (info != null && info.currentHeartRate != null) ? info.currentHeartRate.toString() : "--";
        var distVal = (info != null && info.elapsedDistance != null) ? info.elapsedDistance / 1000.0 : 0.00;

        var hrDistText = "HR: " + hrVal + " | " + distVal.format("%.2f") + " km";
        dc.drawText(cx, 185, Graphics.FONT_XTINY, hrDistText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Statystyki siatkarskie – z uwzględnieniem tłumaczeń
        var bursts = (BurstManager has :burstCount) ? BurstManager.burstCount : 0;
        var jumps = (JumpManager has :jumpCount) ? JumpManager.jumpCount : 0;
        
        var labelBursts = WatchUi.loadResource(Rez.Strings.LabelBursts) as String;
        var labelJumps = WatchUi.loadResource(Rez.Strings.LabelJumps) as String;
        
        var volleyballStatsText = labelBursts + ": " + bursts + " | " + labelJumps + ": " + jumps;
        dc.drawText(cx, 205, Graphics.FONT_XTINY, volleyballStatsText, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        // Godzina
        var sysTime = System.getClockTime();
        var timeString = sysTime.hour.format("%02d") + ":" + sysTime.min.format("%02d");
        dc.drawText(cx, 230, Graphics.FONT_SMALL, timeString, Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
    }
}