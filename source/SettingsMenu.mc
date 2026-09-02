import Toybox.WatchUi;
import Toybox.System;
import Toybox.Lang;

module SettingsMenu {

   function createMenu() as [ Views, InputDelegates ] {
        var titleStr = WatchUi.loadResource(Rez.Strings.SettingsTitle) as String;
        var menu = new WatchUi.Menu2({ :title => titleStr });

        // 1. Uruchom / Zatrzymaj stoper (poprawiony operator 'has')
        var isRunning = (TimerManager has :isRunning) ? TimerManager.isRunning : false;
        var timerTitleRes = isRunning ? Rez.Strings.StopTimer : Rez.Strings.StartTimer;
        var timerTitle = WatchUi.loadResource(timerTitleRes) as String;
        
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
        var durationLabelStr = WatchUi.loadResource(Rez.Strings.TimerDurationLabel) as String;
        menu.addItem(
            new WatchUi.MenuItem(
                durationLabelStr,
                currentFormatted,
                "set_duration",
                null
            )
        );

        // 3. Włączenie / Wyłączenie dźwięku
        var soundEnabled = TimerManager.isSoundEnabled;
        var soundStatusRes = soundEnabled ? Rez.Strings.StatusOn : Rez.Strings.StatusOff;
        var soundStatus = WatchUi.loadResource(soundStatusRes) as String;
        var soundLabelStr = WatchUi.loadResource(Rez.Strings.SoundLabel) as String;
        
        menu.addItem(
            new WatchUi.MenuItem(
                soundLabelStr,
                soundStatus,
                "toggle_sound",
                null
            )
        );

        // 4. Kolor ekranu
        var colorLabelStr = WatchUi.loadResource(Rez.Strings.ScreenColor) as String;
        menu.addItem(
            new WatchUi.MenuItem(
                colorLabelStr,
                null,
                "screen_color",
                null
            )
        );

        return [menu, new SettingsMenuDelegate()] as [ Views, InputDelegates ];
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
            var newStatusRes = TimerManager.isSoundEnabled ? Rez.Strings.StatusOn : Rez.Strings.StatusOff;
            var newStatus = WatchUi.loadResource(newStatusRes) as String;
            item.setSubLabel(newStatus);
            WatchUi.requestUpdate();
        }
        else if (id.equals("screen_color")) {
            if (AppConfig has :toggleBackgroundColor) {
                AppConfig.toggleBackgroundColor();
            }
            WatchUi.popView(WatchUi.SLIDE_DOWN);
            WatchUi.requestUpdate();
        }
    }

    private function openDurationSubMenu() as Void {
        var subTitleStr = WatchUi.loadResource(Rez.Strings.TimerDurationLabel) as String;
        var subMenu = new WatchUi.Menu2({ :title => subTitleStr });

        subMenu.addItem(new WatchUi.MenuItem("30 s", null, "dur_30", null));
        subMenu.addItem(new WatchUi.MenuItem("5 min", null, "dur_300", null));
        subMenu.addItem(new WatchUi.MenuItem("10 min", null, "dur_600", null));
        subMenu.addItem(new WatchUi.MenuItem("15 min", null, "dur_900", null));

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