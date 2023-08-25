import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class MinimalBatteryWidgetApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    // onStart() is called on application start up
    function onStart(state as Dictionary?) as Void {
    }

    // onStop() is called when your application is exiting
    function onStop(state as Dictionary?) as Void {
    }

    // Return the initial view of your application here
    function getInitialView() as Array<Views or InputDelegates>? {
        return [ new MinimalBatteryWidgetView() ] as Array<Views or InputDelegates>;
    }

    // Return the glance view of your application here
    function getGlanceView() {
        return [ new WidgetGlanceView() ];
    }

}

function getApp() as MinimalBatteryWidgetApp {
    return Application.getApp() as MinimalBatteryWidgetApp;
}