//
// Copyright 2015-2016 by Garmin Ltd. or its subsidiaries.
// Subject to Garmin SDK License Agreement and Wearables
// Application Developer Agreement.
//

using Toybox.WatchUi;
using Toybox.System;

var page = 1;
var pages = [MinimalBatteryView, MinimalCalView, MinimalBbView, MinimalActiveMinuteView, MinimalStepView, MinimalHeartiew, ];

class BaseInputDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onKey(evt) {
        if (page == pages.size()) {
            page = 1;
        } else {
            page = page + 1;
        }

        var newView = new pages[page -1]();
        var inputDelegate = new BaseInputDelegate();

        switchToView(newView, inputDelegate, WatchUi.SLIDE_IMMEDIATE);
        WatchUi.requestUpdate();
        return true;
    }
}

