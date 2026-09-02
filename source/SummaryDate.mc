import Toybox.Lang;

class SummaryData {
    public var distanceKm as Float = 0.0;
    public var maxSpeedKmH as Float = 0.0;
    public var maxHr as Number = 0;
    public var minHr as Number = 0;
    public var sprintsCount as Number = 0;
    public var calories as Number = 0; // Dodane pole na kalorie

    // Pola dla View2
    public var hasScore as Boolean = false;
    public var scoreTeamA as Number = 0;
    public var scoreTeamB as Number = 0;
}