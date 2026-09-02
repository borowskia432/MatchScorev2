import Toybox.Activity;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

module BurstManager {

    var burstCount as Number = 0;

    var _isBursting as Boolean = false;
    var _lastBurstTime as Number = 0;

    // --- KONFIGURACJA DLA ORLIKA ---
    // Próg prędkości zrywu w m/s (3.61 m/s = ~13.0 km/h)
    const BURST_SPEED_THRESHOLD as Float = 3.61;
    
    // Próg dolny do zresetowania stanu zrywu (3.06 m/s = ~11.0 km/h)
    const BURST_RESET_THRESHOLD as Float = 3.06;

    // Minimalny odstęp czasu między zrywami (w sekundach)
    const COOLDOWN_SECONDS as Number = 4;

    //! Resetuje licznik zrywów przed nowym meczem
    function reset() as Void {
        burstCount = 0;
        _isBursting = false;
        _lastBurstTime = 0;
    }

    //! Metoda wywoływana cyklicznie (co 1 sekundę)
    function update() as Void {
        var info = Activity.getActivityInfo();
        
        if (info != null) {
            var speed = info.currentSpeed;
            if (speed == null) { 
                speed = 0.0; 
            }

            var currentTime = Time.now().value();

            // Sprawdzenie przekroczenia progu zrywu
            if (speed >= BURST_SPEED_THRESHOLD) {
                if (!_isBursting && (currentTime - _lastBurstTime) >= COOLDOWN_SECONDS) {
                    _isBursting = true;
                    burstCount++;
                    _lastBurstTime = currentTime;
                    System.println("BurstManager: Wykryto zryw! Łącznie: " + burstCount + " (Prędkość: " + (speed * 3.6) + " km/h)");
                }
            } else if (speed < BURST_RESET_THRESHOLD) {
                // Reset stanu, gdy gracz zwolni poniżej progu dolnego
                _isBursting = false;
            }
        }
    }

    //! Opcjonalna możliwość ręcznego dodania zrywu (np. przyciskiem)
    function addManualBurst() as Void {
        burstCount++;
        System.println("BurstManager: Ręcznie dodano zryw. Łącznie: " + burstCount);
    }
}