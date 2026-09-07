import Toybox.Lang;

module SportsMetricsManager {

    // =====================================================
    // STATYSTYKI CAŁEJ SESJI
    // =====================================================

    // Łączna liczba zrywów w całej sesji
    var totalBursts as Number = 0;

    // Łączna liczba wyskoków w całej sesji
    var totalJumps as Number = 0;


    // =====================================================
    // STATYSTYKI AKTUALNEGO SETA
    // =====================================================

    // Liczba zrywów w aktualnym secie
    var setBursts as Number = 0;

    // Liczba wyskoków w aktualnym secie
    var setJumps as Number = 0;


    // =====================================================
    // RESET CAŁEJ SESJI
    // =====================================================

    function resetSession() as Void {
        totalBursts = 0;
        totalJumps = 0;

        setBursts = 0;
        setJumps = 0;
    }


    // =====================================================
    // NOWY SET
    // =====================================================

    function resetSet() as Void {
        setBursts = 0;
        setJumps = 0;
    }


    // =====================================================
    // DODANIE ZRYWU
    // =====================================================

    function addBurst() as Void {
        totalBursts++;
        setBursts++;
    }


    // =====================================================
    // DODANIE WYSKOKU
    // =====================================================

    function addJump() as Void {
        totalJumps++;
        setJumps++;
    }


    // =====================================================
    // POBIERANIE STATYSTYK SESJI
    // =====================================================

    function getTotalBursts() as Number {
        return totalBursts;
    }


    function getTotalJumps() as Number {
        return totalJumps;
    }


    // =====================================================
    // POBIERANIE STATYSTYK SETA
    // =====================================================

    function getSetBursts() as Number {
        return setBursts;
    }


    function getSetJumps() as Number {
        return setJumps;
    }
}