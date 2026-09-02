
import Toybox.WatchUi;
import Toybox.Graphics;
import Toybox.Activity;
import Toybox.UserProfile;
import Toybox.Time;
import Toybox.System;
import Toybox.Math;
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

        drawHrArc(
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

        var statusText =
            TimerManager.isRunning
            ? WatchUi.loadResource(
                Rez.Strings.StatusToChange
              ) as String
            : WatchUi.loadResource(
                Rez.Strings.StatusPause
              ) as String;

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
            52,
            Graphics.FONT_SMALL,
            TimerManager.getFormattedTime(),
            Graphics.TEXT_JUSTIFY_CENTER |
            Graphics.TEXT_JUSTIFY_VCENTER
        );

        // =====================================================
        // DRUŻYNA A
        // =====================================================

        dc.drawText(
            cx - 65,
            90,
            Graphics.FONT_SMALL,
            WatchUi.loadResource(
                Rez.Strings.TeamA
            ) as String,
            Graphics.TEXT_JUSTIFY_CENTER |
            Graphics.TEXT_JUSTIFY_VCENTER
        );

        // =====================================================
        // DRUŻYNA B
        // =====================================================

        dc.drawText(
            cx + 65,
            90,
            Graphics.FONT_SMALL,
            WatchUi.loadResource(
                Rez.Strings.TeamB
            ) as String,
            Graphics.TEXT_JUSTIFY_CENTER |
            Graphics.TEXT_JUSTIFY_VCENTER
        );

        // =====================================================
        // WYNIK
        // =====================================================

        var scoreString =
            ScoreManager.scoreA.toString() +
            " : " +
            ScoreManager.scoreB.toString();

        dc.drawText(
            cx,
            130,
            Graphics.FONT_NUMBER_HOT,
            scoreString,
            Graphics.TEXT_JUSTIFY_CENTER |
            Graphics.TEXT_JUSTIFY_VCENTER
        );

        // =====================================================
        // DANE AKTYWNOŚCI
        // =====================================================

        var info = Activity.getActivityInfo();

        // =====================================================
        // VMAX
        // =====================================================

        var maxSpeedMps = 0.0;

        if (info != null && info.maxSpeed != null) {
            maxSpeedMps = info.maxSpeed;
        }

        var vmaxKmH =
            maxSpeedMps * 3.6;

        // =====================================================
        // AKTUALNA PRĘDKOŚĆ
        // =====================================================

        var currentSpeedMps = 0.0;

        if (info != null && info.currentSpeed != null) {
            currentSpeedMps = info.currentSpeed;
        }

        var metersPerMin =
            currentSpeedMps * 60.0;

        // =====================================================
        // VMAX + M/MIN
        // =====================================================

        var speedMetricsText =
            "Vmax: " +
            vmaxKmH.format("%.1f") +
            " km/h | " +
            metersPerMin.format("%.0f") +
            " M/min";

        dc.drawText(
            cx,
            178,
            Graphics.FONT_XTINY,
            speedMetricsText,
            Graphics.TEXT_JUSTIFY_CENTER |
            Graphics.TEXT_JUSTIFY_VCENTER
        );

        // =====================================================
        // HR
        // =====================================================

        var hrVal = "--";

        if (info != null &&
            info.currentHeartRate != null) {

            hrVal =
                info.currentHeartRate.toString();
        }

        // =====================================================
        // DYSTANS
        // =====================================================

        var distVal = 0.00;

        if (info != null &&
            info.elapsedDistance != null) {

            distVal =
                info.elapsedDistance / 1000.0;
        }

        var hrDistText =
            "HR: " +
            hrVal +
            " | " +
            distVal.format("%.2f") +
            " km";

        dc.drawText(
            cx,
            202,
            Graphics.FONT_SMALL,
            hrDistText,
            Graphics.TEXT_JUSTIFY_CENTER |
            Graphics.TEXT_JUSTIFY_VCENTER
        );

        // =====================================================
        // GODZINA
        // =====================================================

        var sysTime =
            System.getClockTime();

        var timeString =
            sysTime.hour.format("%02d") +
            ":" +
            sysTime.min.format("%02d");

        dc.drawText(
            cx,
            262,
            Graphics.FONT_SMALL,
            timeString,
            Graphics.TEXT_JUSTIFY_CENTER |
            Graphics.TEXT_JUSTIFY_VCENTER
        );
    }


    // =========================================================
    // PASEK HR
    //
    // Grubość:
    // -3, -2, -1, 0, +1, +2
    //
    // Łącznie 6 nakładanych łuków.
    // =========================================================

    private function drawHrArc(
        dc as Graphics.Dc,
        cx as Number,
        cy as Number,
        width as Number
    ) as Void {

        // =====================================================
        // PROMIEŃ
        // =====================================================

        var baseRadius =
            (width / 2) - 6;


        // =====================================================
        // STREFA NIEBIESKA
        // =====================================================

        dc.setColor(
            Graphics.COLOR_BLUE,
            Graphics.COLOR_TRANSPARENT
        );

        for (var rOffset = -3;
             rOffset <= 2;
             rOffset++) {

            dc.drawArc(
                cx,
                cy,
                baseRadius + rOffset,
                Graphics.ARC_CLOCKWISE,
                140,
                121
            );
        }


        // =====================================================
        // STREFA ZIELONA
        // =====================================================

        dc.setColor(
            Graphics.COLOR_GREEN,
            Graphics.COLOR_TRANSPARENT
        );

        for (var rOffset = -3;
             rOffset <= 2;
             rOffset++) {

            dc.drawArc(
                cx,
                cy,
                baseRadius + rOffset,
                Graphics.ARC_CLOCKWISE,
                119,
                101
            );
        }


        // =====================================================
        // STREFA ŻÓŁTA
        // =====================================================

        dc.setColor(
            Graphics.COLOR_YELLOW,
            Graphics.COLOR_TRANSPARENT
        );

        for (var rOffset = -3;
             rOffset <= 2;
             rOffset++) {

            dc.drawArc(
                cx,
                cy,
                baseRadius + rOffset,
                Graphics.ARC_CLOCKWISE,
                99,
                81
            );
        }


        // =====================================================
        // STREFA POMARAŃCZOWA
        // =====================================================

        dc.setColor(
            Graphics.COLOR_ORANGE,
            Graphics.COLOR_TRANSPARENT
        );

        for (var rOffset = -3;
             rOffset <= 2;
             rOffset++) {

            dc.drawArc(
                cx,
                cy,
                baseRadius + rOffset,
                Graphics.ARC_CLOCKWISE,
                79,
                61
            );
        }


        // =====================================================
        // STREFA CZERWONA
        // =====================================================

        dc.setColor(
            Graphics.COLOR_RED,
            Graphics.COLOR_TRANSPARENT
        );

        for (var rOffset = -3;
             rOffset <= 2;
             rOffset++) {

            dc.drawArc(
                cx,
                cy,
                baseRadius + rOffset,
                Graphics.ARC_CLOCKWISE,
                59,
                40
            );
        }


        // =====================================================
        // ZAKRES HR
        // =====================================================

        var minHr = 100;
        var maxHr = 190;

        if (UserProfile has :getHeartRateZones) {

            var zones =
                UserProfile.getHeartRateZones(
                    UserProfile.HR_ZONE_SPORT_GENERIC
                );

            if (zones != null &&
                zones.size() >= 6) {

                minHr = zones[0];
                maxHr = zones[5];
            }

        } else {

            var profile =
                UserProfile.getProfile();

            var age = 30;

            if (profile != null &&
                profile.birthYear != null) {

                var currentYear =
                    Time.Gregorian.info(
                        Time.now(),
                        Time.FORMAT_SHORT
                    ).year;

                age =
                    currentYear -
                    profile.birthYear;
            }

            maxHr =
                220 -
                age;

            minHr =
                (maxHr * 0.5).toNumber();
        }


        // =====================================================
        // ZABEZPIECZENIE HR
        // =====================================================

        if (minHr >= maxHr) {
            minHr = 100;
            maxHr = 190;
        }


        // =====================================================
        // AKTUALNE HR
        // =====================================================

        var info =
            Activity.getActivityInfo();

        var currentHr = 0;

        if (info != null &&
            info.currentHeartRate != null) {

            currentHr =
                info.currentHeartRate;
        }


        // =====================================================
        // KĄT WSKAŹNIKA
        // =====================================================

        var angle = 140.0;

        if (currentHr > 0) {

            if (currentHr <= minHr) {

                angle = 140.0;

            } else if (currentHr >= maxHr) {

                angle = 40.0;

            } else {

                var ratio =
                    (currentHr - minHr).toFloat() /
                    (maxHr - minHr).toFloat();

                angle =
                    140.0 -
                    (ratio * 100.0);
            }
        }


        // =====================================================
        // WSKAŹNIK HR
        // =====================================================

        var rad =
            Math.toRadians(angle);

        var rInner =
            baseRadius - 6;

        var rOuter =
            baseRadius + 6;

        var x1 =
            cx +
            (rInner * Math.cos(rad));

        var y1 =
            cy -
            (rInner * Math.sin(rad));

        var x2 =
            cx +
            (rOuter * Math.cos(rad));

        var y2 =
            cy -
            (rOuter * Math.sin(rad));


        // =====================================================
        // RYSOWANIE WSKAŹNIKA
        // =====================================================

        dc.setColor(
            AppConfig.getTextColor(),
            Graphics.COLOR_TRANSPARENT
        );

        dc.drawLine(
            x1.toNumber(),
            y1.toNumber(),
            x2.toNumber(),
            y2.toNumber()
        );
    }
}

