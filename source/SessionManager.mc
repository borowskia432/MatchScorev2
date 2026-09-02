import Toybox.ActivityRecording;
import Toybox.Activity;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.System;

module SessionManager {

    var session as ActivityRecording.Session or Null = null;

    // Pola do wykresu (RECORD) - bez modyfikatora private
    var _scoreARecordField as FitContributor.Field or Null = null;
    var _scoreBRecordField as FitContributor.Field or Null = null;

    // Pola do podsumowania aktywności (SESSION) - bez modyfikatora private
    var _scoreASummaryField as FitContributor.Field or Null = null;
    var _scoreBSummaryField as FitContributor.Field or Null = null;

    // Identyfikatory pól MUSZĄ być zgodne z resources/contributions/fit_contributions.xml
    const FIT_SCORE_A_REC_ID = 0;
    const FIT_SCORE_B_REC_ID = 1;
    const FIT_SCORE_A_SUM_ID = 2;
    const FIT_SCORE_B_SUM_ID = 3;

    //! Rozpoczyna nagrywanie sesji FIT
    function startSession(sessionName as String, sport as Activity.Sport) as Void {
        if (session == null) {
            System.println("SessionManager: Tworzenie nowej sesji...");
            
            session = ActivityRecording.createSession({
                :name => sessionName,
                :sport => sport,
                :subSport => Activity.SUB_SPORT_MATCH
            });

            var s = session;
            if (s != null) {
                // 1. Pola wykresu (RECORD)
                _scoreARecordField = s.createField(
                    "score_a_chart",
                    FIT_SCORE_A_REC_ID,
                    FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "pkt" }
                );

                _scoreBRecordField = s.createField(
                    "score_b_chart",
                    FIT_SCORE_B_REC_ID,
                    FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_RECORD, :units => "pkt" }
                );

                // 2. Pola podsumowania (SESSION)
                _scoreASummaryField = s.createField(
                    "score_a_final",
                    FIT_SCORE_A_SUM_ID,
                    FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" }
                );

                _scoreBSummaryField = s.createField(
                    "score_b_final",
                    FIT_SCORE_B_SUM_ID,
                    FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" }
                );

                s.start();
                System.println("SessionManager: Sesja wystartowała.");

                // Zapisujemy początkowy stan wykresu (0:0)
                updateScoreChart(ScoreManager.scoreA, ScoreManager.scoreB);
            }
        }
    }

    //! Aktualizuje stan punktowy na wykresie osi czasu
    function updateScoreChart(scoreA as Number, scoreB as Number) as Void {
        var s = session;
        if (s != null && s.isRecording()) {
            var fA = _scoreARecordField;
            if (fA != null) {
                fA.setData(scoreA);
            }

            var fB = _scoreBRecordField;
            if (fB != null) {
                fB.setData(scoreB);
            }
        }
    }

    //! Wstrzymuje nagrywanie sesji (Pauza)
    function pauseSession() as Void {
        var s = session;
        if (s != null && s.isRecording()) {
            s.stop();
            System.println("SessionManager: Sesja wstrzymana.");
        }
    }

    //! Wznawia nagrywanie po pauzie
    function resumeSession() as Void {
        var s = session;
        if (s != null && !s.isRecording()) {
            s.start();
            System.println("SessionManager: Sesja wznowiona.");
        }
    }

    //! Zapisuje sesję z aktualnym wynikiem meczu do Garmin Connect
    function saveSession(scoreA as Number, scoreB as Number) as Boolean {
        var s = session;
        if (s != null) {
            System.println("SessionManager: Zapisywanie sesji...");
            
            // Zapisz ostateczny wynik w polach Podsumowania (SESSION)
            var fASum = _scoreASummaryField;
            if (fASum != null) {
                fASum.setData(scoreA);
            }

            var fBSum = _scoreBSummaryField;
            if (fBSum != null) {
                fBSum.setData(scoreB);
            }

            if (s.isRecording()) {
                updateScoreChart(scoreA, scoreB);
                s.stop();
            }

            var success = s.save();
            System.println("SessionManager: Status zapisu = " + success);

            session = null;
            _scoreARecordField = null;
            _scoreBRecordField = null;
            _scoreASummaryField = null;
            _scoreBSummaryField = null;

            return success;
        }
        System.println("SessionManager: Brak aktywnej sesji do zapisu!");
        return false;
    }

    //! Odrzuca sesję bez zapisu
    function discardSession() as Void {
        var s = session;
        if (s != null) {
            if (s.isRecording()) {
                s.stop();
            }
            s.discard();
            System.println("SessionManager: Sesja odrzucona.");
            
            session = null;
            _scoreARecordField = null;
            _scoreBRecordField = null;
            _scoreASummaryField = null;
            _scoreBSummaryField = null;
        }
    }

    //! Sprawdza, czy aktywność jest w trakcie nagrywania
    function isRecording() as Boolean {
        var s = session;
        if (s != null) {
            return s.isRecording();
        }
        return false;
    }
}