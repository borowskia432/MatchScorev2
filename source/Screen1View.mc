import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Activity;
import Toybox.System;
import Toybox.Lang;
import Toybox.Timer;

class Screen1View extends WatchUi.View {

    private var _refreshTimer as Timer.Timer or Null = null;

    function initialize() {
        View.initialize();
    }

    function onShow() as Void {
        if (_refreshTimer == null) {
            _refreshTimer = new Timer.Timer();

            _refreshTimer.start(
                new Lang.Method(self, :onRefresh),
                1000,
                true
            );
        }
    }

    function onHide() as Void {
        if (_refreshTimer != null) {
            _refreshTimer.stop();
            _refreshTimer = null;
        }
    }

    function onRefresh() as Void {

        // Aktualizacja detekcji zrywów
        BurstManager.update();

        // Odświeżenie ekranu
        WatchUi.requestUpdate();
    }

    function onUpdate(dc as Graphics.Dc) as Void {

        dc.setColor(
            AppConfig.getBackgroundColor(),
            AppConfig.getBackgroundColor()
        );

        dc.clear();
        dc.setAntiAlias(true);

        var width = dc.getWidth();
        var height = dc.getHeight();
        var cx = width / 2;


        // =====================================================
        // PASEK HR
        // =====================================================

        HrArcRenderer.draw(
            dc,
            cx,
            height / 2,
            width
        );


        dc.setColor(
            AppConfig.getTextColor(),
            Graphics.COLOR_TRANSPARENT
        );


        // =====================================================
        // STATUS
        // =====================================================

        var statusText = TimerManager.isRunning
            ? (WatchUi.loadResource(
                Rez.Strings.StatusToChange
              ) as String)
            : (WatchUi.loadResource(
                Rez.Strings.StatusPause
              ) as String);

        dc.drawText(
            cx,
            32,
            Graphics.FONT_XTINY,
            statusText,
            Graphics.TEXT_JUSTIFY_CENTER |
            Graphics.TEXT_JUSTIFY_VCENTER
        );


        // =====================================================
        // STOPER
        // =====================================================

        dc.drawText(
            cx,
            65,
            Graphics.FONT_MEDIUM,
            TimerManager.getFormattedTime(),
            Graphics.TEXT_JUSTIFY_CENTER |
            Graphics.TEXT_JUSTIFY_VCENTER
        );


        // =====================================================
        // DANE AKTYWNOŚCI
        // =====================================================

        var info = Activity.getActivityInfo();

        var maxSpeedMps =
            (info != null && info.maxSpeed != null)
            ? info.maxSpeed
            : 0.0;

        var currentSpeedMps =
            (info != null && info.currentSpeed != null)
            ? info.currentSpeed
            : 0.0;


        var vmaxKmH = maxSpeedMps * 3.6;
        var metersPerMin = currentSpeedMps * 60.0;


        var speedMetricsText =
            "Vmax: " +
            vmaxKmH.format("%.1f") +
            " km/h | " +
            metersPerMin.format("%.0f") +
            " M/min";


        dc.drawText(
            cx,
            140,
            Graphics.FONT_XTINY,
            speedMetricsText,
            Graphics.TEXT_JUSTIFY_CENTER |
            Graphics.TEXT_JUSTIFY_VCENTER
        );


        // =====================================================
        // HR + DYSTANS
        // =====================================================

        var hrVal =
            (info != null && info.currentHeartRate != null)
            ? info.currentHeartRate.toString()
            : "--";


        var distVal =
            (info != null && info.elapsedDistance != null)
            ? info.elapsedDistance / 1000.0
            : 0.00;


        var hrDistText =
            "HR: " +
            hrVal +
            " | " +
            distVal.format("%.2f") +
            " km";


        dc.drawText(
            cx,
            175,
            Graphics.FONT_SMALL,
            hrDistText,
            Graphics.TEXT_JUSTIFY_CENTER |
            Graphics.TEXT_JUSTIFY_VCENTER
        );


        // =====================================================
        // ZRYWY + WYSKOKI
        //
        // WAŻNE:
        // Dane pobieramy teraz z SportsMetricsManager,
        // a nie bezpośrednio z BurstManager / JumpManager.
        // =====================================================

        var bursts =
            SportsMetricsManager.getTotalBursts();

        var jumps =
            SportsMetricsManager.getTotalJumps();


        var labelBursts =
            WatchUi.loadResource(
                Rez.Strings.LabelBursts
            ) as String;


        var labelJumps =
            WatchUi.loadResource(
                Rez.Strings.LabelJumps
            ) as String;


        var volleyballStatsText =
            labelBursts +
            ": " +
            bursts +
            " | " +
            labelJumps +
            ": " +
            jumps;


        dc.drawText(
            cx,
            205,
            Graphics.FONT_XTINY,
            volleyballStatsText,
            Graphics.TEXT_JUSTIFY_CENTER |
            Graphics.TEXT_JUSTIFY_VCENTER
        );


        // =====================================================
        // GODZINA
        // =====================================================

        var sysTime = System.getClockTime();

        var timeString =
            sysTime.hour.format("%02d") +
            ":" +
            sysTime.min.format("%02d");


        dc.drawText(
            cx,
            230,
            Graphics.FONT_SMALL,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER |
            Graphics.TEXT_JUSTIFY_VCENTER
        );
    }
}