import Toybox.ActivityRecording;
import Toybox.Activity;
import Toybox.FitContributor;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;

module SessionManager {

    var session as ActivityRecording.Session or Null = null;

    // Wynik każdego seta zapisany jako osobne pole sesji FIT
    var _set1AField as FitContributor.Field or Null = null;
    var _set1BField as FitContributor.Field or Null = null;
    var _set2AField as FitContributor.Field or Null = null;
    var _set2BField as FitContributor.Field or Null = null;
    var _set3AField as FitContributor.Field or Null = null;
    var _set3BField as FitContributor.Field or Null = null;
    var _set4AField as FitContributor.Field or Null = null;
    var _set4BField as FitContributor.Field or Null = null;
    var _set5AField as FitContributor.Field or Null = null;
    var _set5BField as FitContributor.Field or Null = null;
    var _footballScoreAField as FitContributor.Field or Null = null;
    var _footballScoreBField as FitContributor.Field or Null = null;
    var _burstSummaryField as FitContributor.Field or Null = null;
    var _jumpSummaryField as FitContributor.Field or Null = null;
    
    // NOWE: Pola podsumowania wyniku w setach
    var _setsASummaryField as FitContributor.Field or Null = null;
    var _setsBSummaryField as FitContributor.Field or Null = null;

    var _nextLapDistanceMeters as Float = 1000.0;

    // Unikalne ID dla pól FIT (Session)
    const FIT_SET_1_A_ID = 1;
    const FIT_SET_1_B_ID = 2;
    const FIT_SET_2_A_ID = 3;
    const FIT_SET_2_B_ID = 4;
    const FIT_SET_3_A_ID = 5;
    const FIT_SET_3_B_ID = 6;
    const FIT_SET_4_A_ID = 7;
    const FIT_SET_4_B_ID = 8;
    const FIT_SET_5_A_ID = 9;
    const FIT_SET_5_B_ID = 10;
    const FIT_SETS_A_SUM_ID = 11;
    const FIT_SETS_B_SUM_ID = 12;
    const FIT_BURST_SUM_ID = 13;
    const FIT_JUMP_SUM_ID = 14;
    const FIT_FOOTBALL_SCORE_A_ID = 15;
    const FIT_FOOTBALL_SCORE_B_ID = 16;

    function isSessionActive() as Boolean {
        return (session != null) && session.isRecording();
    }

    function startSession(sessionName as String, sport as Activity.Sport) as Void {
        if (session == null) {
            System.println("SessionManager: Tworzenie nowej sesji...");
            
            // Wyresetuj stan meczu przy starcie nowej sesji
            AppConfig.resetMatch();
            ScoreManager.resetScore();
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
                if (sport == Activity.SPORT_VOLLEYBALL) {
                    // --- WYNIKI POSZCZEGOLNYCH SETOW (pola sesji) ---
                    _set1AField = s.createField("set_1_a", FIT_SET_1_A_ID, FitContributor.DATA_TYPE_UINT16, { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" });
                    _set1BField = s.createField("set_1_b", FIT_SET_1_B_ID, FitContributor.DATA_TYPE_UINT16, { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" });
                    _set2AField = s.createField("set_2_a", FIT_SET_2_A_ID, FitContributor.DATA_TYPE_UINT16, { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" });
                    _set2BField = s.createField("set_2_b", FIT_SET_2_B_ID, FitContributor.DATA_TYPE_UINT16, { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" });
                    _set3AField = s.createField("set_3_a", FIT_SET_3_A_ID, FitContributor.DATA_TYPE_UINT16, { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" });
                    _set3BField = s.createField("set_3_b", FIT_SET_3_B_ID, FitContributor.DATA_TYPE_UINT16, { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" });
                    _set4AField = s.createField("set_4_a", FIT_SET_4_A_ID, FitContributor.DATA_TYPE_UINT16, { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" });
                    _set4BField = s.createField("set_4_b", FIT_SET_4_B_ID, FitContributor.DATA_TYPE_UINT16, { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" });
                    _set5AField = s.createField("set_5_a", FIT_SET_5_A_ID, FitContributor.DATA_TYPE_UINT16, { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" });
                    _set5BField = s.createField("set_5_b", FIT_SET_5_B_ID, FitContributor.DATA_TYPE_UINT16, { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" });
                } else {
                    _footballScoreAField = s.createField("football_score_a", FIT_FOOTBALL_SCORE_A_ID, FitContributor.DATA_TYPE_UINT16, { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "bramki" });
                    _footballScoreBField = s.createField("football_score_b", FIT_FOOTBALL_SCORE_B_ID, FitContributor.DATA_TYPE_UINT16, { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "bramki" });
                }

                // --- POLA PODSUMOWANIA SESJI ---
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

                s.start();
                System.println("SessionManager: Sesja wystartowała z polami FIT dla setów.");
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

    function writeSetScore(setNumber as Number, scoreA as Number, scoreB as Number) as Void {
        if (setNumber == 1) {
            if (_set1AField != null) { _set1AField.setData(scoreA); }
            if (_set1BField != null) { _set1BField.setData(scoreB); }
        } else if (setNumber == 2) {
            if (_set2AField != null) { _set2AField.setData(scoreA); }
            if (_set2BField != null) { _set2BField.setData(scoreB); }
        } else if (setNumber == 3) {
            if (_set3AField != null) { _set3AField.setData(scoreA); }
            if (_set3BField != null) { _set3BField.setData(scoreB); }
        } else if (setNumber == 4) {
            if (_set4AField != null) { _set4AField.setData(scoreA); }
            if (_set4BField != null) { _set4BField.setData(scoreB); }
        } else if (setNumber == 5) {
            if (_set5AField != null) { _set5AField.setData(scoreA); }
            if (_set5BField != null) { _set5BField.setData(scoreB); }
        }
    }

    // Wywoływane przy kliknięciu "Nowy set" z menu
    function finalizeCurrentSet() as Void {
        var currentScoreA = AppConfig.volleyballScoreA;
        var currentScoreB = AppConfig.volleyballScoreB;
        var setNumber = AppConfig.volleyballSetsA + AppConfig.volleyballSetsB + 1;

        if (setNumber <= 5 && (currentScoreA > 0 || currentScoreB > 0)) {
            writeSetScore(setNumber, currentScoreA, currentScoreB);
        }

        if (currentScoreA > currentScoreB) {
            AppConfig.volleyballSetsA++;
        } else if (currentScoreB > currentScoreA) {
            AppConfig.volleyballSetsB++;
        }

        AppConfig.matchScoreA += currentScoreA;
        AppConfig.matchScoreB += currentScoreB;
        AppConfig.resetVolleyballScores();
        SportsMetricsManager.resetSet();
    }

    function saveSession() as Boolean {
        var s = session;
        if (s != null) {
            
            // Zapisz niezatwierdzony, aktualnie wyświetlany set jako kolejny set sesji.
            if (s.isRecording() && (AppConfig.volleyballScoreA > 0 || AppConfig.volleyballScoreB > 0)) {
                var currentScoreA = AppConfig.volleyballScoreA;
                var currentScoreB = AppConfig.volleyballScoreB;
                var setNumber = AppConfig.volleyballSetsA + AppConfig.volleyballSetsB + 1;

                if (setNumber <= 5) { writeSetScore(setNumber, currentScoreA, currentScoreB); }
                // Nie zwiększamy liczby setów tutaj, bo to już zostało policzone w finalizeCurrentSet().
                AppConfig.matchScoreA += currentScoreA;
                AppConfig.matchScoreB += currentScoreB;
            }

            // Zapisz końcowy wynik setów oraz statystyki całej sesji.
            if (AppConfig.selectedSportEnum != Activity.SPORT_VOLLEYBALL) {
                if (_footballScoreAField != null) { _footballScoreAField.setData(ScoreManager.scoreA); }
                if (_footballScoreBField != null) { _footballScoreBField.setData(ScoreManager.scoreB); }
            }

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
            _set1AField = null;
            _set1BField = null;
            _set2AField = null;
            _set2BField = null;
            _set3AField = null;
            _set3BField = null;
            _set4AField = null;
            _set4BField = null;
            _set5AField = null;
            _set5BField = null;
            _footballScoreAField = null;
            _footballScoreBField = null;
            _setsASummaryField = null;
            _setsBSummaryField = null;
            _burstSummaryField = null;
            _jumpSummaryField = null;

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
            
            _set1AField = null;
            _set1BField = null;
            _set2AField = null;
            _set2BField = null;
            _set3AField = null;
            _set3BField = null;
            _set4AField = null;
            _set4BField = null;
            _set5AField = null;
            _set5BField = null;
            _footballScoreAField = null;
            _footballScoreBField = null;
            _setsASummaryField = null;
            _setsBSummaryField = null;
            _burstSummaryField = null;
            _jumpSummaryField = null;
        }

        GPSManager.stopGPS();
    }

    function isRecording() as Boolean {
        var s = session;
        return (s != null) ? s.isRecording() : false;
    }
}