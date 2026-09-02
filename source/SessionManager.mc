import Toybox.ActivityRecording;
import Toybox.Activity;
import Toybox.FitContributor;
import Toybox.Lang;

module SessionManager {

    var session as ActivityRecording.Session or Null = null;

    var _scoreAField as FitContributor.Field or Null = null;
    var _scoreBField as FitContributor.Field or Null = null;

    // Identyfikatory pól MUSZĄ być identyczne z id w resources/fit_contributor.xml
    const FIT_SCORE_A_ID = 0;
    const FIT_SCORE_B_ID = 1;

    //! Rozpoczyna nagrywanie sesji FIT (aktywności fizycznej)
    function startSession(sessionName as String, sport as Activity.Sport) as Void {
        if (session == null) {
            session = ActivityRecording.createSession({
                :name => sessionName,
                :sport => sport,
                :subSport => Activity.SUB_SPORT_MATCH
            });

            var s = session;
            if (s != null) {
                // Tworzenie pól Custom FIT na podstawie deklaracji z fit_contributor.xml
                _scoreAField = s.createField(
                    "score_a",
                    FIT_SCORE_A_ID,
                    FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" }
                );

                _scoreBField = s.createField(
                    "score_b",
                    FIT_SCORE_B_ID,
                    FitContributor.DATA_TYPE_UINT16,
                    { :mesgType => FitContributor.MESG_TYPE_SESSION, :units => "pkt" }
                );

                s.start();
            }
        }
    }

    //! Wstrzymuje nagrywanie sesji (Pauza)
    function pauseSession() as Void {
        var s = session;
        if (s != null && s.isRecording()) {
            s.stop();
        }
    }

    //! Wznawia nagrywanie po pauzie
    function resumeSession() as Void {
        var s = session;
        if (s != null && !s.isRecording()) {
            s.start();
        }
    }

    //! Zapisuje sesję z aktualnym wynikiem meczu do Garmin Connect
    function saveSession(scoreA as Number, scoreB as Number) as Boolean {
        var s = session;
        if (s != null) {
            if (s.isRecording()) {
                s.stop();
            }

            // Wpisanie wyników do struktury FIT tuż przed jej zapisaniem
            var fA = _scoreAField;
            if (fA != null) {
                fA.setData(scoreA);
            }

            var fB = _scoreBField;
            if (fB != null) {
                fB.setData(scoreB);
            }

            var success = s.save();
            session = null;
            _scoreAField = null;
            _scoreBField = null;
            return success;
        }
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
            session = null;
            _scoreAField = null;
            _scoreBField = null;
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