import Toybox.Graphics;
import Toybox.Activity;
import Toybox.UserProfile;
import Toybox.Time;
import Toybox.Math;
import Toybox.Lang;

class HrArcRenderer {

    public static function draw(
        dc as Graphics.Dc,
        cx as Number,
        cy as Number,
        width as Number
    ) as Void {
        var baseRadius = (width / 2) - 6;

        // Rysowanie stref tętna (Łuki)
        drawZoneArcs(dc, cx, cy, baseRadius);

        // Wyznaczanie aktualnego tętna i wskaźnika (wskazówki)
        var hrLimits = getHeartRateLimits();
        var minHr = hrLimits[0];
        var maxHr = hrLimits[1];

        var info = Activity.getActivityInfo();
        var currentHr = 0;
        if (info != null && info.currentHeartRate != null) {
            currentHr = info.currentHeartRate;
        }

        var angle = 140.0;
        if (currentHr > 0) {
            if (currentHr <= minHr) {
                angle = 140.0;
            } else if (currentHr >= maxHr) {
                angle = 40.0;
            } else {
                var ratio = (currentHr - minHr).toFloat() / (maxHr - minHr).toFloat();
                angle = 140.0 - (ratio * 100.0);
            }
        }

        var rad = Math.toRadians(angle);
        var rInner = baseRadius - 6;
        var rOuter = baseRadius + 6;

        var x1 = cx + (rInner * Math.cos(rad));
        var y1 = cy - (rInner * Math.sin(rad));
        var x2 = cx + (rOuter * Math.cos(rad));
        var y2 = cy - (rOuter * Math.sin(rad));

        dc.setColor(AppConfig.getTextColor(), Graphics.COLOR_TRANSPARENT);
        dc.drawLine(x1.toNumber(), y1.toNumber(), x2.toNumber(), y2.toNumber());
    }

    private static function drawZoneArcs(dc as Graphics.Dc, cx as Number, cy as Number, baseRadius as Number) as Void {
        var colors = [
            Graphics.COLOR_BLUE,
            Graphics.COLOR_GREEN,
            Graphics.COLOR_YELLOW,
            Graphics.COLOR_ORANGE,
            Graphics.COLOR_RED
        ];

        var ranges = [
            [140, 121],
            [119, 101],
            [99, 81],
            [79, 61],
            [59, 40]
        ];

        for (var i = 0; i < colors.size(); i++) {
            dc.setColor(colors[i], Graphics.COLOR_TRANSPARENT);
            var range = ranges[i];
            for (var rOffset = -3; rOffset <= 2; rOffset++) {
                dc.drawArc(cx, cy, baseRadius + rOffset, Graphics.ARC_CLOCKWISE, range[0], range[1]);
            }
        }
    }

    private static function getHeartRateLimits() as Array<Number> {
        var minHr = 100;
        var maxHr = 190;

        if (UserProfile has :getHeartRateZones) {
            var zones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
            if (zones != null && zones.size() >= 6) {
                minHr = zones[0];
                maxHr = zones[5];
            }
        } else {
            var profile = UserProfile.getProfile();
            var age = 30;
            if (profile != null && profile.birthYear != null) {
                var currentYear = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).year;
                age = currentYear - profile.birthYear;
            }
            maxHr = 220 - age;
            minHr = (maxHr * 0.5).toNumber();
        }

        if (minHr >= maxHr) {
            minHr = 100;
            maxHr = 190;
        }

        return [minHr, maxHr];
    }
}