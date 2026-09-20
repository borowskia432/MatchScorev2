import Toybox.ActivityRecording;
import Toybox.Activity;
import Toybox.FitContributor;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;

module SessionManager {

    var session as ActivityRecording.Session or Null = null;

    // Pola podsumowania końcowego sesji (cały mecz)
    var _scoreASummaryField as FitContributor.Field or Null = null;
    var _scoreBSummaryField as FitContributor.Field or Null = null;
    var _burstSummaryField as FitContributor.Field or Null = null;
    var _jumpSummaryField as FitContributor.Field or Null = null;
    
    // NOWE: Pola podsumowania wyniku w setach
    var _setsASummaryField as FitContributor.Field or Null = null;
    var _setsBSummaryField as FitContributor.Field or Null = null;

    // Pola przypisane do konkretnego lapa / seta (rozpiska na każdy set)
    var _lapScoreAField as FitContributor.Field or Null = null;
    var _lapScoreBField as FitContributor.Field or Null = null;
    var _lapBurstField as FitContributor.Field or Null = null;
    var _lapJumpField as FitContributor.Field or Null = null;

    var _nextLapDistanceMeters as Float = 1000.0;
    var _lastLapScoreA as Number = 0;
    var _lastLapScoreB as Number = 0;

    // Unikalne ID dla pól FIT (Session)
    const FIT_SCORE_A_SUM_ID = 1;
    const FIT_SCORE_B_SUM_ID = 2;
    const FIT_BURST_SUM_ID = 3;
    const FIT_JUMP_SUM_ID = 4;
    const FIT_SETS_A_SUM_ID = 5; // ID dla setów
    const FIT_SETS_B_SUM_ID = 6; // ID dla setów

    // Unikalne ID dla pól FIT (Lap / Set)
    const FIT_LAP_SCORE_A_ID = 11;
    const FIT_LAP_SCORE_B_ID = 12;
    const FIT_LAP_BURST_ID = 13;
    const FIT_LAP_JUMP_ID = 14;

    function isSessionActive() as Boolean {
        return (session != null) && session.isRecording();
    }

    function startSession(sessionName as String, sport as Activity.Sport) as Void {
        if (session == null) {
            System.println("SessionManager: Tworzenie nowej sesji...");
            
            // Wyresetuj stan meczu przy starcie nowej sesji
            AppConfig.resetMatch();
            GPSManager.startGPS();
SportsMetricsManager.resetSession();
BurstManager.reset();
JumpManager.reset();
            session = ActivityRecording.createSession({
                :name => sessionName,
                :sport => sport,
                :subSport => Activity.SUB_SPORT_MATCH
            });

            _nextLapDistanceMeters = 1000.0;

            var s = session;
            if (s != null) {
                // --- POLA SESJI (Podsumowanie całego meczu) ---
                _scoreASummaryField = s.createField(
                    "score_a_final", FIT_SCORE_A_SUM_ID, FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" }
                );

                _scoreBSummaryField = s.createField(
                    "score_b_final", FIT_SCORE_B_SUM_ID, FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" }
                );
                
                // NOWE: Pola do zapisu ostatecznego wyniku w setach
                _setsASummaryField = s.createField(
                    "sets_a_final", FIT_SETS_A_SUM_ID, FitContributor.DATA_TYPE_UINT8,
                    { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "sety" }
                );

                _setsBSummaryField = s.createField(
                    "sets_b_final", FIT_SETS_B_SUM_ID, FitContributor.DATA_TYPE_UINT8,
                    { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "sety" }
                );

                _burstSummaryField = s.createField(
                    "burst_count_final", FIT_BURST_SUM_ID, FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "zrywów" }
                );

                _jumpSummaryField = s.createField(
                    "jump_count_final", FIT_JUMP_SUM_ID, FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "wyskoki" }
                );

                // --- POLA LAPA (Statystyki dla każdego seta z osobna) ---
                _lapScoreAField = s.createField(
                    "set_score_a", FIT_LAP_SCORE_A_ID, FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_LAP, :units => "pkt" }
                );

                _lapScoreBField = s.createField(
                    "set_score_b", FIT_LAP_SCORE_B_ID, FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_LAP, :units => "pkt" }
                );

                _lapBurstField = s.createField(
                    "set_bursts", FIT_LAP_BURST_ID, FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_LAP, :units => "zrywów" }
                );

                _lapJumpField = s.createField(
                    "set_jumps", FIT_LAP_JUMP_ID, FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_LAP, :units => "wyskoki" }
                );

                s.start();
                System.println("SessionManager: Sesja wystartowała z obsługą pól FIT (Sesja + Lapy).");
            }
        }
    }

    function checkAutoLap() as Void {
        var s = session;
        if (s != null && s.isRecording()) {
            var info = Activity.getActivityInfo();
            if (info != null && info.elapsedDistance != null) {
                var currentDistance = info.elapsedDistance as Float;

                if (currentDistance >= _nextLapDistanceMeters) {
                    s.addLap();
                    _nextLapDistanceMeters += 1000.0;

                    if (Attention has :vibrate) {
                        var vibeProfile = [
                            new Attention.VibeProfile(80, 150),
                            new Attention.VibeProfile(0, 100),
                            new Attention.VibeProfile(80, 150)
                        ] as Array<Attention.VibeProfile>;
                        Attention.vibrate(vibeProfile);
                    }
                }
            }
        }
    }

    function pauseSession() as Void {
        var s = session;
        if (s != null && s.isRecording()) {
            s.stop();
        }
    }

    function resumeSession() as Void {
        var s = session;
        if (s != null && !s.isRecording()) {
            s.start();
        }
    }

    function writeLapSnapshot(scoreA as Number, scoreB as Number, bursts as Number, jumps as Number) as Void {
        _lastLapScoreA = scoreA;
        _lastLapScoreB = scoreB;

        if (_lapScoreAField != null) { _lapScoreAField.setData(scoreA); }
        if (_lapScoreBField != null) { _lapScoreBField.setData(scoreB); }
        if (_lapBurstField != null)  { _lapBurstField.setData(bursts); }
        if (_lapJumpField != null)   { _lapJumpField.setData(jumps); }
    }

    // Wywoływane przy kliknięciu "Nowy set" z menu
    function finalizeCurrentSet() as Void {
        var currentScoreA = AppConfig.volleyballScoreA;
        var currentScoreB = AppConfig.volleyballScoreB;

        if (currentScoreA > currentScoreB) {
            AppConfig.volleyballSetsA++;
        } else if (currentScoreB > currentScoreA) {
            AppConfig.volleyballSetsB++;
        }

        addManualLap();
    }

    function addManualLap() as Void {
        var s = session;
        if (s != null && s.isRecording()) {
            var currentScoreA = AppConfig.volleyballScoreA;
            var currentScoreB = AppConfig.volleyballScoreB;
            var currentBursts = SportsMetricsManager.getSetBursts();
            var currentJumps = SportsMetricsManager.getSetJumps();

            writeLapSnapshot(currentScoreA, currentScoreB, currentBursts, currentJumps);
            AppConfig.matchScoreA += currentScoreA;
            AppConfig.matchScoreB += currentScoreB;

            s.addLap();
            AppConfig.resetVolleyballScores();
            SportsMetricsManager.resetSet();
        }
    }

    function saveSession() as Boolean {
        var s = session;
        if (s != null) {
            
            // 1. Zapisz dane OSTATNIEGO (aktywnego) seta do pól lapa przed zamknięciem sesji
            if (s.isRecording()) {
                var currentScoreA = AppConfig.volleyballScoreA;
                var currentScoreB = AppConfig.volleyballScoreB;
                var currentBursts = SportsMetricsManager.getSetBursts();
                var currentJumps  = SportsMetricsManager.getSetJumps();

                if (currentScoreA == 0 && currentScoreB == 0 && (_lastLapScoreA > 0 || _lastLapScoreB > 0)) {
                    currentScoreA = _lastLapScoreA;
                    currentScoreB = _lastLapScoreB;
                }

                writeLapSnapshot(currentScoreA, currentScoreB, currentBursts, currentJumps);

                // Nie zwiększamy liczby setów tutaj, bo to już zostało policzone w finalizeCurrentSet().
                // Wartości session summary zapisujemy jako bieżące, już zatwierdzone stany.
                AppConfig.matchScoreA += currentScoreA;
                AppConfig.matchScoreB += currentScoreB;

                s.addLap();
            }

            // 2. Zapisz skumulowane dane całego meczu w polach sesji FIT (PUNKTY I SETY)
            if (_scoreASummaryField != null) { _scoreASummaryField.setData(AppConfig.matchScoreA); }
            if (_scoreBSummaryField != null) { _scoreBSummaryField.setData(AppConfig.matchScoreB); }

            if (_setsASummaryField != null) { _setsASummaryField.setData(AppConfig.volleyballSetsA); }
            if (_setsBSummaryField != null) { _setsBSummaryField.setData(AppConfig.volleyballSetsB); }

            if (_burstSummaryField != null) {
    _burstSummaryField.setData(
        SportsMetricsManager.getTotalBursts()
    );
}

if (_jumpSummaryField != null) {
    _jumpSummaryField.setData(
        SportsMetricsManager.getTotalJumps()
    );
}

            if (s.isRecording()) {
                s.stop();
            }

            var success = s.save();
            session = null;
            _scoreASummaryField = null;
            _scoreBSummaryField = null;
            _setsASummaryField = null;
            _setsBSummaryField = null;
            _burstSummaryField = null;
            _jumpSummaryField = null;
            _lapScoreAField = null;
            _lapScoreBField = null;
            _lapBurstField = null;
            _lapJumpField = null;

            GPSManager.stopGPS();
            return success;
        }

        GPSManager.stopGPS();
        return false;
    }

    function discardSession() as Void {
        var s = session;
        if (s != null) {
            if (s.isRecording()) {
                s.stop();
            }
            s.discard();
            session = null;
            
            _scoreASummaryField = null;
            _scoreBSummaryField = null;
            _setsASummaryField = null;
            _setsBSummaryField = null;
            _burstSummaryField = null;
            _jumpSummaryField = null;
            _lapScoreAField = null;
            _lapScoreBField = null;
            _lapBurstField = null;
            _lapJumpField = null;
        }

        GPSManager.stopGPS();
    }

    function isRecording() as Boolean {
        var s = session;
        return (s != null) ? s.isRecording() : false;
    }
}