import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;
import Toybox.Activity;

module ExitMenu {

    function showMenu(isFromView2 as Boolean) as Void {
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
            new ExitMenuDelegate(isFromView2),
            WatchUi.SLIDE_UP
        );
    }
}

class ExitMenuDelegate extends WatchUi.Menu2InputDelegate {

    private var _isFromView2 as Boolean;

    function initialize(isFromView2 as Boolean) {
        Menu2InputDelegate.initialize();
        _isFromView2 = isFromView2;
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        if (id.equals("save")) {
            // 1. Zatrzymujemy stoper aplikacji (jeśli działa)
            if (TimerManager.isRunning) {
                TimerManager.toggleTimer();
            }

            // 2. Przygotowujemy dane do podsumowania
            var summaryData = new SummaryData();
            var info = Activity.getActivityInfo();

            if (info != null) {
                if (info.elapsedDistance != null) {
                    summaryData.distanceKm = info.elapsedDistance / 1000.0;
                }
                if (info.maxSpeed != null) {
                    summaryData.maxSpeedKmH = info.maxSpeed * 3.6;
                }
                if (info.maxHeartRate != null) {
                    summaryData.maxHr = info.maxHeartRate;
                }
                if (info.currentHeartRate != null) {
                    summaryData.minHr = info.currentHeartRate; // Lub przypisz wartość z własnej logiki
                }
            }

            // Pobranie zrywów z Twojego menedżera
            summaryData.sprintsCount = BurstManager.burstCount;

            // 3. Konfiguracja wyników meczu
            if (_isFromView2) {
                summaryData.hasScore = true;
                summaryData.scoreTeamA = ScoreManager.scoreA;
                summaryData.scoreTeamB = ScoreManager.scoreB;
            } else {
                summaryData.hasScore = false;
            }

            // 4. Przejście do widoku podsumowania
            WatchUi.switchToView(
                new SummaryView(summaryData),
                new SummaryDelegate(),
                WatchUi.SLIDE_LEFT
            );
        }
        else if (id.equals("discard")) {
            if (TimerManager.isRunning) {
                TimerManager.toggleTimer();
            }

            SessionManager.discardSession();
            System.exit();
        }
        else if (id.equals("cancel")) {
            WatchUi.popView(WatchUi.SLIDE_DOWN);
        }
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}