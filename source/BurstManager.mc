import Toybox.Activity;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

module BurstManager {

    var _isBursting as Boolean = false;
    var _lastBurstTime as Number = 0;

    // =====================================================
    // KONFIGURACJA ZRYWU
    // =====================================================

    // 3.61 m/s = około 13 km/h
    const BURST_SPEED_THRESHOLD as Float = 3.61;

    // Poniżej tej prędkości zryw zostaje zakończony
    // 3.06 m/s = około 11 km/h
    const BURST_RESET_THRESHOLD as Float = 3.06;

    // Minimalny odstęp pomiędzy kolejnymi zrywami
    const COOLDOWN_SECONDS as Number = 4;


    // =====================================================
    // RESET
    // =====================================================

    function reset() as Void {

        _isBursting = false;
        _lastBurstTime = 0;

        System.println("BurstManager: reset");
    }


    // =====================================================
    // AKTUALIZACJA
    // Wywoływana cyklicznie, np. co 1 sekundę
    // =====================================================

    function update() as Void {
        if (SessionManager has :isSessionActive) {
            if (!SessionManager.isSessionActive()) {
                _isBursting = false;
                return;
            }
        }

        var info = Activity.getActivityInfo();
        var speed = 0.0;

        if (info != null) {
            speed = info.currentSpeed;
            if (speed == null) {
                speed = 0.0;
            }
        }

        var currentTime = Time.now().value();


        // =================================================
        // ROZPOCZĘCIE ZRYWU
        // =================================================

        if (speed >= BURST_SPEED_THRESHOLD) {

            if (!_isBursting &&
                (currentTime - _lastBurstTime) >= COOLDOWN_SECONDS) {

                _isBursting = true;
                _lastBurstTime = currentTime;

                // WAŻNE:
                // Licznik całej sesji znajduje się teraz
                // w SportsMetricsManager.
                SportsMetricsManager.addBurst();

                System.println(
                    "BurstManager: Wykryto zryw! " +
                    "Łącznie: " +
                    SportsMetricsManager.getTotalBursts() +
                    " | Prędkość: " +
                    (speed * 3.6) +
                    " km/h"
                );
            }

        }

        // =================================================
        // ZAKOŃCZENIE ZRYWU
        // =================================================

        else if (speed < BURST_RESET_THRESHOLD) {

            _isBursting = false;
        }
    }


    // =====================================================
    // RĘCZNE DODANIE ZRYWU
    // =====================================================

    function addManualBurst() as Void {

        SportsMetricsManager.addBurst();

        System.println(
            "BurstManager: Ręcznie dodano zryw. " +
            "Łącznie: " +
            SportsMetricsManager.getTotalBursts()
        );
    }
}