import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.ActivityMonitor;
using Toybox.SensorHistory;

function getIterator() {
    // Check device for SensorHistory compatibility
    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
        // Set up the method with parameters
        return Toybox.SensorHistory.getBodyBatteryHistory({});
    }
    return null;
}

class MinimalView extends WatchUi.View {

    const BoldFont = Application.loadResource(Rez.Fonts.BoldFont);
    const LogoFont = Application.loadResource(Rez.Fonts.LogoFont);
    const TinyFont = Graphics.FONT_TINY;

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    function viewMonitor(dc as Dc, unit as Text, value as Float, str as Text, color as Graphics.ColorValue, logo as Text) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var sizeFont = Graphics.getFontHeight(BoldFont);
        var sizeFontUnit = Graphics.getFontHeight(TinyFont);
        var sizeFontLogo = Graphics.getFontHeight(LogoFont);
        dc.drawText(dc.getWidth() -10, dc.getHeight()/2 - (sizeFont/2), BoldFont, str, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(dc.getWidth() -22, dc.getHeight()/2 +25, TinyFont, unit, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()*1/4, dc.getHeight()/2 - (sizeFontLogo/2), LogoFont, logo, Graphics.TEXT_JUSTIFY_CENTER);
        lineColor(dc, color, value, 270, Math.toDegrees(Math.asin((sizeFont/2 -20) *1.0/ (dc.getHeight()/2 -15))), dc.getHeight()/2 -15, 10);
    }

    function lineColor(dc as Dc, color as Graphics.ColorValue, value as Float, start as Decimal, end as Decimal, level as Number, penWidth as Number) as Void {
        var delta = (start - end)/100.0;
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(penWidth);
        var val = value;
        if (value < 0) {
            val = 0;
        }
        if (value > 100){
            val = 100;
        }
        end = start - delta * val;
        if (start > end) {
            dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, level, Graphics.ARC_CLOCKWISE, start, end);
            dc.fillCircle(Math.cos(Math.toRadians(start))*level + dc.getWidth()/2, Math.sin(Math.toRadians(start))*level*-1 + dc.getHeight()/2, penWidth/2 -1);
            dc.fillCircle(Math.cos(Math.toRadians(end))*level + dc.getWidth()/2, Math.sin(Math.toRadians(end))*level*-1 + dc.getHeight()/2, penWidth/2 -1);
        }
    }

}

class MinimalBatteryView extends MinimalView {

    function initialize() {
        MinimalView.initialize();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        var value = System.getSystemStats().battery;
        var str = Lang.format("$1$", [value.format("%d"),]);
        var color = Graphics.COLOR_GREEN;
        if (value < 20) {
            color = Graphics.COLOR_ORANGE;
        }
        if (value < 10) {
            color = Graphics.COLOR_RED;
        }
        var unit = "%";
        var logo = "3";
        View.onUpdate(dc);
        viewMonitor(dc, unit, value, str, color, logo);
    }

}

class MinimalCalView extends MinimalView {

    function initialize() {
        MinimalView.initialize();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        var info = ActivityMonitor.getInfo();
        var value = info.calories * 100 / 3000;
        var str = Lang.format("$1$", [info.calories.format("%d"),]);
        var color = Graphics.COLOR_RED;
        var unit = "kCal";
        var logo = "2";
        View.onUpdate(dc);
        viewMonitor(dc, unit, value, str, color, logo);
    }

}

class MinimalBbView extends MinimalView {

    function initialize() {
        MinimalView.initialize();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout

        var bbIterator = getIterator();
        var sampleBb = bbIterator.next();
        var value = 0;
        if (sampleBb != null) {
            value = sampleBb.data;
        }
        var str = Lang.format("$1$", [value.format("%d"),]);
        var color = Graphics.COLOR_BLUE;
        var unit = "%";
        var logo = "6";
        View.onUpdate(dc);
        viewMonitor(dc, unit, value, str, color, logo);
    }

}

class MinimalActiveMinuteView extends MinimalView {

    function initialize() {
        MinimalView.initialize();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        var info = ActivityMonitor.getInfo();
        var value = info.activeMinutesWeek.total * 100 / info.activeMinutesWeekGoal;
        var str = Lang.format("$1$", [info.activeMinutesWeek.total.format("%d"),]);
        var color = Graphics.COLOR_YELLOW;
        var unit = "min";
        var logo = "1";
        View.onUpdate(dc);
        viewMonitor(dc, unit, value, str, color, logo);
    }
}

class MinimalStepView extends MinimalView {

    function initialize() {
        MinimalView.initialize();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        var info = ActivityMonitor.getInfo();
        var value = info.steps * 100 / info.stepGoal;
        var distance = info.distance / (100*1000.0);
        var str = Lang.format("$1$", [distance.format("%.1f"),]);
        var color = Graphics.COLOR_PINK;
        var unit = "Km";
        var logo = "4";
        View.onUpdate(dc);
        viewMonitor(dc, unit, value, str, color, logo);
    }
}

class MinimalHeartiew extends MinimalView {

    function initialize() {
        MinimalView.initialize();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        var info = Activity.getActivityInfo();
        var valueHeart = info.currentHeartRate;
        var str = valueHeart;
        var value = valueHeart;
        if (valueHeart == null){
            value = 0;
            str = "--";
        } else {
            value = valueHeart /2; //max heart 200 bpm        
        }
        var color = Graphics.COLOR_RED;
        var unit = "Bpm";
        var logo = "5";
        View.onUpdate(dc);
        viewMonitor(dc, unit, value, str, color, logo);
    }
}