import Toybox.Lang;

class SummaryData {
    public var distanceKm as Float = 0.0;
    public var maxSpeedKmH as Float = 0.0;
    public var maxHr as Number = 0;
    public var minHr as Number = 0;
    public var sprintsCount as Number = 0;
    public var jumpsCount as Number = 0; // Dodane pole na wyskoki
    public var calories as Number = 0;

    // Pola dla wyniku meczu
    public var hasScore as Boolean = false;
    public var scoreTeamA as Number = 0;
    public var scoreTeamB as Number = 0;

    // NOWE POLA DLA SIATKÓWKI:
    public var isVolleyball as Boolean = false;
    public var setsTeamA as Number = 0;
    public var setsTeamB as Number = 0;
}