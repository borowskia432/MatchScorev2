import Toybox.Lang;
import Toybox.System;

module JumpManager {

    // =====================================================
    // RESET
    // =====================================================

    function reset() as Void {

        System.println("JumpManager: reset");
    }


    // =====================================================
    // DODANIE WYSKOKU
    //
    // Ta funkcja jest wywoływana przez algorytm
    // wykrywania wyskoku.
    // =====================================================

    function addJump() as Void {

        SportsMetricsManager.addJump();

        System.println(
            "JumpManager: Wykryto wyskok! " +
            "Łącznie: " +
            SportsMetricsManager.getTotalJumps()
        );
    }


    // =====================================================
    // RĘCZNE DODANIE WYSKOKU
    //
    // Przydatne podczas testowania.
    // =====================================================

    function addManualJump() as Void {

        SportsMetricsManager.addJump();

        System.println(
            "JumpManager: Ręcznie dodano wyskok. " +
            "Łącznie: " +
            SportsMetricsManager.getTotalJumps()
        );
    }
}