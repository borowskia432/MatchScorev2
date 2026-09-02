import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class MatchScoreV2App extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function onStart(state as Dictionary or Null) as Void {
    }

    function onStop(state as Dictionary or Null) as Void {
    }

    // Jawne rzutowanie na tablicę [ WatchUi.View, WatchUi.InputDelegate ] 
    // satisfies type checker for getInitialView without using restrictive 'as [Views, InputDelegates]' keywords.
    function getInitialView() {
        return MainMenu.createMenu() as [WatchUi.Views, WatchUi.InputDelegates];
    }
}