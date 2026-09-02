import Toybox.ActivityRecording;
import Toybox.Activity;
import Toybox.FitContributor;
import Toybox.Lang;
import Toybox.System;

module SessionManager {

    var session as ActivityRecording.Session or Null = null;

    // Pola podsumowania końcowego sesji
    var _scoreASummaryField as FitContributor.Field or Null = null;
    var _scoreBSummaryField as FitContributor.Field or Null = null;
    var _burstSummaryField as FitContributor.Field or Null = null;

    const FIT_SCORE_A_SUM_ID = 1;
    const FIT_SCORE_B_SUM_ID = 2;
    const FIT_BURST_SUM_ID = 3;

    function startSession(sessionName as String, sport as Activity.Sport) as Void {
        if (session == null) {
            System.println("SessionManager: Tworzenie nowej sesji...");
            
            // 1. Włączamy odbiór GPS przed rozpoczęciem nagrywania
            GPSManager.startGPS();

            session = ActivityRecording.createSession({
                :name => sessionName,
                :sport => sport,
                :subSport => Activity.SUB_SPORT_MATCH
            });

            var s = session;
            if (s != null) {
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

                _burstSummaryField = s.createField(
                    "burst_count_final",
                    FIT_BURST_SUM_ID,
                    FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "zrywów" }
                );

                s.start();
                System.println("SessionManager: Sesja wystartowała z obsługą GPS.");
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

    function saveSession(scoreA as Number, scoreB as Number, burstCount as Number) as Boolean {
        var s = session;
        if (s != null) {
            var fASum = _scoreASummaryField;
            if (fASum != null) { fASum.setData(scoreA); }

            var fBSum = _scoreBSummaryField;
            if (fBSum != null) { fBSum.setData(scoreB); }

            var fBurst = _burstSummaryField;
            if (fBurst != null) { fBurst.setData(burstCount); }

            if (s.isRecording()) {
                s.stop();
            }

            var success = s.save();
            session = null;
            _scoreASummaryField = null;
            _scoreBSummaryField = null;
            _burstSummaryField = null;

            // 2. Wyłączamy moduł GPS po zapisaniu sesji
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
            _burstSummaryField = null;
        }

        // 3. Wyłączamy moduł GPS po odrzuceniu sesji
        GPSManager.stopGPS();
    }

    function isRecording() as Boolean {
        var s = session;
        return (s != null) ? s.isRecording() : false;
    }
}