import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

module SettingsMenu {

    function createMenu() as Array<WatchUi.Menu2 or WatchUi.Menu2InputDelegate> {
        var menu = new WatchUi.Menu2({ :title => "Ustawienia" });

        // 1. Uruchom / Zatrzymaj stoper
        var timerTitle = TimerManager.isRunning ? "Zatrzymaj stoper" : "Uruchom stoper";
        menu.addItem(
            new WatchUi.MenuItem(
                timerTitle,
                null,
                "toggle_timer",
                null
            )
        );

        // 2. Wybór czasu stopera
        var currentFormatted = TimerManager.getFormattedTime();
        menu.addItem(
            new WatchUi.MenuItem(
                "Czas stopera",
                currentFormatted,
                "set_duration",
                null
            )
        );

        // 3. Włączenie / Wyłączenie dźwięku
        var soundStatus = TimerManager.isSoundEnabled ? "Włączone" : "Wyłączone";
        menu.addItem(
            new WatchUi.MenuItem(
                "Dźwięk przy zmianie",
                soundStatus,
                "toggle_sound",
                null
            )
        );

        // 4. Kolor ekranu
        menu.addItem(
            new WatchUi.MenuItem(
                "Kolor ekranu",
                null,
                "screen_color",
                null
            )
        );

        return [menu, new SettingsMenuDelegate()] as Array<WatchUi.Menu2 or WatchUi.Menu2InputDelegate>;
    }
}

class SettingsMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        if (id.equals("toggle_timer")) {
            TimerManager.toggleTimer();
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.requestUpdate();
        }
        else if (id.equals("set_duration")) {
            openDurationSubMenu();
        }
        else if (id.equals("toggle_sound")) {
            TimerManager.toggleSound();
            var newStatus = TimerManager.isSoundEnabled ? "Włączone" : "Wyłączone";
            item.setSubLabel(newStatus);
            WatchUi.requestUpdate();
        }
        else if (id.equals("screen_color")) {
            // Dodano obsługę zmiany koloru tła (sprawdź, czy funkcja nazywa się toggleBackgroundColor w AppConfig)
            if (AppConfig has :toggleBackgroundColor) {
                AppConfig.toggleBackgroundColor();
            }
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.requestUpdate();
        }
    }

    private function openDurationSubMenu() as Void {
        var subMenu = new WatchUi.Menu2({ :title => "Czas stopera" });

        subMenu.addItem(new WatchUi.MenuItem("30 sekund", null, "dur_30", null));
        subMenu.addItem(new WatchUi.MenuItem("5 minut", null, "dur_300", null));
        subMenu.addItem(new WatchUi.MenuItem("10 minut", null, "dur_600", null));
        subMenu.addItem(new WatchUi.MenuItem("15 minut", null, "dur_900", null));

        WatchUi.pushView(subMenu, new DurationMenuDelegate(), WatchUi.SLIDE_UP);
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class DurationMenuDelegate extends WatchUi.Menu2InputDelegate {

    function initialize() {
        Menu2InputDelegate.initialize();
    }

    function onSelect(item as WatchUi.MenuItem) as Void {
        var id = item.getId() as String;

        if (id.equals("dur_30")) {
            TimerManager.setDuration(30);
        } else if (id.equals("dur_300")) {
            TimerManager.setDuration(300);
        } else if (id.equals("dur_600")) {
            TimerManager.setDuration(600);
        } else if (id.equals("dur_900")) {
            TimerManager.setDuration(900);
        }

        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.popView(WatchUi.SLIDE_DOWN);
        WatchUi.requestUpdate();
    }

    function onBack() as Void {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}