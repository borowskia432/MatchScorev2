import Toybox.ActivityRecording;
import Toybox.Activity;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;

module SessionManager {

    var session as ActivityRecording.Session or Null = null;
    var recordingTimer as Timer.Timer or Null = null;

    // Pola wykresu (RECORD)
    var _scoreARecordField as FitContributor.Field or Null = null;
    var _scoreBRecordField as FitContributor.Field or Null = null;

    // Pola podsumowania (SESSION)
    var _scoreASummaryField as FitContributor.Field or Null = null;
    var _scoreBSummaryField as FitContributor.Field or Null = null;

    // Identyfikatory pól zgodne z resources/contributions/fit_contributor.xml
    const FIT_SCORE_A_REC_ID = 0;
    const FIT_SCORE_B_REC_ID = 1;
    const FIT_SCORE_A_SUM_ID = 2;
    const FIT_SCORE_B_SUM_ID = 3;

    //! Klasa pomocnicza przekazująca zdarzenie Timera do modułu (wymagana, gdyż module nie posiada metody .method())
    class RecordingTimerDelegate {
        function onTimer() as Void {
            SessionManager.onRecordingTimerTick();
        }
    }

    //! Rozpoczyna nagrywanie sesji FIT oraz uruchamia stoper zapisu 1Hz
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

                // Uruchomienie cyklicznego stopera (1000 ms) do zasilania wykresu
                startRecordingTimer();
            }
        }
    }

    //! Uruchamia stoper odświeżania ramek FIT
    function startRecordingTimer() as Void {
        if (recordingTimer == null) {
            recordingTimer = new Timer.Timer();
            var t = recordingTimer;
            if (t != null) {
                var timerDelegate = new RecordingTimerDelegate();
                t.start(timerDelegate.method(:onTimer), 1000, true);
            }
        }
    }

    //! Zatrzymuje stoper
    function stopRecordingTimer() as Void {
        var t = recordingTimer;
        if (t != null) {
            t.stop();
            recordingTimer = null;
        }
    }

    //! Wywoływane co 1 sekundę – przekazuje aktualny wynik do bufora ramki FIT
    function onRecordingTimerTick() as Void {
        var s = session;
        if (s != null && s.isRecording()) {
            var fA = _scoreARecordField;
            if (fA != null) {
                fA.setData(ScoreManager.scoreA);
            }

            var fB = _scoreBRecordField;
            if (fB != null) {
                fB.setData(ScoreManager.scoreB);
            }
        }
    }

    //! Zachowane dla wstecznej kompatybilności ze ScoreManager
    function updateScoreChart(scoreA as Number, scoreB as Number) as Void {
        // Zapis odbywa się automatycznie w onRecordingTimerTick()
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
        stopRecordingTimer();

        var s = session;
        if (s != null) {
            System.println("SessionManager: Zapisywanie sesji...");

            // 1. Zapis ostatecznego wyniku w polach Podsumowania (SESSION)
            var fASum = _scoreASummaryField;
            if (fASum != null) {
                fASum.setData(scoreA);
            }

            var fBSum = _scoreBSummaryField;
            if (fBSum != null) {
                fBSum.setData(scoreB);
            }

            // 2. Ostatnia ramka danych dla wykresu
            if (s.isRecording()) {
                var fA = _scoreARecordField;
                if (fA != null) { fA.setData(scoreA); }
                var fB = _scoreBRecordField;
                if (fB != null) { fB.setData(scoreB); }

                s.stop();
            }

            // 3. Zapis pliku FIT
            var success = s.save();
            System.println("SessionManager: Status zapisu = " + success);

            session = null;
            _scoreARecordField = null;
            _scoreBRecordField = null;
            _scoreASummaryField = null;
            _scoreBSummaryField = null;

            return success;
        }
        return false;
    }

    //! Odrzuca sesję bez zapisu
    function discardSession() as Void {
        stopRecordingTimer();

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