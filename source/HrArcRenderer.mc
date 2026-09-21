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
        if (baseRadius < 1) {
            return;
        }

        var hrLimits = getHeartRateLimits();
        var minHr = hrLimits[0];
        var maxHr = hrLimits[1];

        var info = Activity.getActivityInfo();
        var currentHr = 0;
        if (info != null && info.currentHeartRate != null) {
            currentHr = info.currentHeartRate;
        }

        // Ten sam układ pięciu stref jest używany na każdym ekranie.
        drawZoneArcs(dc, cx, cy, baseRadius, getActiveZone(currentHr, hrLimits));

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

    private static function drawZoneArcs(
        dc as Graphics.Dc,
        cx as Number,
        cy as Number,
        baseRadius as Number,
        activeZone as Number
    ) as Void {
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
            var innerOffset = (i == activeZone) ? -5 : -2;
            var outerOffset = (i == activeZone) ? 4 : 1;
            for (var rOffset = innerOffset; rOffset <= outerOffset; rOffset++) {
                dc.drawArc(cx, cy, baseRadius + rOffset, Graphics.ARC_CLOCKWISE, range[0], range[1]);
            }
        }
    }

    private static function getActiveZone(currentHr as Number, hrLimits as Array<Number>) as Number {
        if (currentHr <= 0) {
            return -1;
        }

        var minHr = hrLimits[0];
        var maxHr = hrLimits[1];
        if (currentHr <= minHr) {
            return 0;
        }
        if (currentHr >= maxHr) {
            return 4;
        }

        var ratio = (currentHr - minHr).toFloat() / (maxHr - minHr).toFloat();
        var zone = (ratio * 5.0).toNumber();
        return zone > 4 ? 4 : zone;
    }

    private static function getHeartRateLimits() as Array<Number> {
        var minHr = 100.0;
        var maxHr = 190.0;
        var hasValidProfileZones = false;

        if (UserProfile has :getHeartRateZones) {
            var zones = UserProfile.getHeartRateZones(UserProfile.HR_ZONE_SPORT_GENERIC);
            if (zones != null && zones.size() >= 6) {
                minHr = zones[0].toFloat();
                maxHr = zones[5].toFloat();
                hasValidProfileZones = minHr > 0 && maxHr > minHr;
            }
        }

        if (!hasValidProfileZones) {
            var profile = UserProfile.getProfile();
            var age = 30;
            if (profile != null && profile.birthYear != null) {
                var currentYear = Time.Gregorian.info(Time.now(), Time.FORMAT_SHORT).year;
                age = currentYear - profile.birthYear;
            }

            if (age < 13 || age > 100) {
                age = 30;
            }
            maxHr = (208 - (0.7 * age)).toFloat();
            minHr = (maxHr * 0.5).toFloat();
        }

        if (minHr >= maxHr) {
            minHr = 100;
            maxHr = 190;
        }

        return [minHr, maxHr];
    }
}