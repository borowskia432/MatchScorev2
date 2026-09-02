import Toybox.ActivityRecording;
import Toybox.Activity;
import Toybox.FitContributor;
import Toybox.Attention;
import Toybox.Lang;
import Toybox.System;

module SessionManager {

    var session as ActivityRecording.Session or Null = null;

    // Pola podsumowania końcowego sesji
    var _scoreASummaryField as FitContributor.Field or Null = null;
    var _scoreBSummaryField as FitContributor.Field or Null = null;
    var _burstSummaryField as FitContributor.Field or Null = null;

    // Usunięto słowo 'private' – zmienne w module nie używają modyfikatorów dostępu
    var _nextLapDistanceMeters as Float = 1000.0;

    const FIT_SCORE_A_SUM_ID = 1;
    const FIT_SCORE_B_SUM_ID = 2;
    const FIT_BURST_SUM_ID = 3;

    function startSession(sessionName as String, sport as Activity.Sport) as Void {
        if (session == null) {
            System.println("SessionManager: Tworzenie nowej sesji...");
            
            GPSManager.startGPS();

            session = ActivityRecording.createSession({
                :name => sessionName,
                :sport => sport,
                :subSport => Activity.SUB_SPORT_MATCH
            });

            _nextLapDistanceMeters = 1000.0;

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

        GPSManager.stopGPS();
    }

    function isRecording() as Boolean {
        var s = session;
        return (s != null) ? s.isRecording() : false;
    }
}