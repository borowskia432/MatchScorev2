import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

module ExitMenu {

    function showMenu() as Void {
        var menu = new WatchUi.Menu2({
            :title => WatchUi.loadResource(
                Rez.Strings.ExitMenuTitle
            ) as String
        });

        menu.addItem(
            new WatchUi.MenuItem(
                WatchUi.loadResource(Rez.Strings.SaveAndExit) as String,
                null,
                "save",
                null
            )
        );

        menu.addItem(
            new WatchUi.MenuItem(
                WatchUi.loadResource(Rez.Strings.DiscardAndExit) as String,
                null,
                "discard",
                null
            )
        );

        menu.addItem(
            new WatchUi.MenuItem(
                WatchUi.loadResource(Rez.Strings.ReturnToMain) as String,
                null,
                "cancel",
                null
            )
        );

        WatchUi.pushView(
            menu,
            new ExitMenuDelegate(),
            WatchUi.SLIDE_UP
        );
    }
}

class ExitMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        if (id.equals("save")) {
            var scoreA = ScoreManager.scoreA;
            var scoreB = ScoreManager.scoreB;
            var burstCount = BurstManager.burstCount; // <-- Pobranie zrywów

            // 1. Zatrzymujemy stoper aplikacji (jeśli działa)
            if (TimerManager.isRunning) {
                TimerManager.toggleTimer();
            }

            // 2. Zapisujemy wyniki, zrywy i kończymy sesję FIT
            SessionManager.saveSession(scoreA, scoreB, burstCount); // <-- Przekazujemy 3 argumenty

            // 3. Całkowite zamknięcie aplikacji Garmin i wyjście do systemu zegarka
            System.exit();
        }
        else if (id.equals("discard")) {
            // 1. Zatrzymujemy stoper aplikacji (jeśli działa)
            if (TimerManager.isRunning) {
                TimerManager.toggleTimer();
            }

            // 2. Odrzucamy nagrywanie sesji FIT
            SessionManager.discardSession();

            // 3. Całkowite zamknięcie aplikacji Garmin i wyjście do systemu zegarka
            System.exit();
        }
        else if (id.equals("cancel")) {
            // Powrót do trwającego meczu (zdejmujemy tylko ExitMenu ze stosu)
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}