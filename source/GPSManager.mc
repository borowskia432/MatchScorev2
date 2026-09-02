import Toybox.Position;
import Toybox.System;
import Toybox.Lang;

module GPSManager {

    var isGpsActive as Boolean = false;

    //! Wewnętrzna klasa listenera, umożliwiająca utworzenie wskaźnika Lang.Method
    class GPSListener {
        function onPosition(info as Position.Info) as Void {
            // Callback pozycji - rejestracja punktów GPS w tle odbywa się automatycznie w systemie Garmin FIT
        }
    }

    var _listener as GPSListener or Null = null;

    //! Uruchamia odbiornik GPS w trybie ciągłym
    function startGPS() as Void {
        if (!isGpsActive) {
            _listener = new GPSListener();
            var listenerObj = _listener;

            if (listenerObj != null) {
                Position.enableLocationEvents(
                    Position.LOCATION_CONTINUOUS, 
                    listenerObj.method(:onPosition)
                );
                isGpsActive = true;
                System.println("GPSManager: Odbiornik GPS został włączony.");
            }
        }
    }

    //! Wyłącza odbiornik GPS w celu oszczędzania baterii
    function stopGPS() as Void {
        if (isGpsActive) {
            Position.enableLocationEvents(Position.LOCATION_DISABLE, null);
            _listener = null;
            isGpsActive = false;
            System.println("GPSManager: Odbiornik GPS został wyłączony.");
        }
    }
}