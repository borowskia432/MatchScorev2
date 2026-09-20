import Toybox.Activity;
import Toybox.Lang;
import Toybox.System;
import Toybox.Time;

module JumpManager {

    var _isJumping as Boolean = false;
    var _lastJumpTime as Number = 0;
    var _lastSpeed as Float = 0.0;

    const JUMP_SPEED_THRESHOLD as Float = 3.2;
    const JUMP_RESET_THRESHOLD as Float = 2.6;
    const JUMP_COOLDOWN_SECONDS as Number = 2;

    // =====================================================
    // RESET
    // =====================================================
    function reset() as Void {
        _isJumping = false;
        _lastJumpTime = 0;
        _lastSpeed = 0.0;
        System.println("JumpManager: reset");
    }

    // =====================================================
    // AKTUALIZACJA
    // Wykrywanie skoku na podstawie chwilowej prędkości.
    // Debounce: skok liczymy tylko po przejściu z wartości niższej
    // pod próg i po chwilowym pauzie między zliczeniami.
    // =====================================================
    function update() as Void {
        if (SessionManager has :isSessionActive) {
            if (!SessionManager.isSessionActive()) {
                _isJumping = false;
                _lastSpeed = 0.0;
                return;
            }
        }

        var info = Activity.getActivityInfo();
        var speed = 0.0;

        if (info != null && info.currentSpeed != null) {
            speed = info.currentSpeed;
        }

        var currentTime = Time.now().value();
        var crossedThreshold = (speed >= JUMP_SPEED_THRESHOLD) && (_lastSpeed < JUMP_SPEED_THRESHOLD);

        if (crossedThreshold && !_isJumping && (currentTime - _lastJumpTime) >= JUMP_COOLDOWN_SECONDS) {
            _isJumping = true;
            _lastJumpTime = currentTime;
            addJump();
        } else if (speed < JUMP_RESET_THRESHOLD) {
            _isJumping = false;
        }

        _lastSpeed = speed;
    }

    // =====================================================
    // DODANIE WYSKOKU
    //
    // Ta funkcja jest wywoływana przez algorytm wykrywania wyskoku.
    // =====================================================
    function addJump() as Void {
        SportsMetricsManager.addJump();

        System.println(
            "JumpManager: Wykryto wyskok! " +
            "Łącznie: " + SportsMetricsManager.getTotalJumps()
        );
    }

    // =====================================================
    // RĘCZNE DODANIE WYSKOKU
    //
    // Przydatne podczas testowania na symulatorze.
    // =====================================================
    function addManualJump() as Void {
        SportsMetricsManager.addJump();

        System.println(
            "JumpManager: Ręcznie dodano wyskok. " +
            "Łącznie: " + SportsMetricsManager.getTotalJumps()
        );
    }
}