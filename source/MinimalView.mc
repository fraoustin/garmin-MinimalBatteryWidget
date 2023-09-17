import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
using Toybox.ActivityMonitor;
using Toybox.SensorHistory;
using Toybox.UserProfile;

function getIteratorBb() {
    // Check device for SensorHistory compatibility
    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getBodyBatteryHistory)) {
        // Set up the method with parameters
        return Toybox.SensorHistory.getBodyBatteryHistory({:period => 400});
    }
    return null;
}

function getIteratorHeart() {
    // Check device for SensorHistory compatibility
    if ((Toybox has :SensorHistory) && (Toybox.SensorHistory has :getHeartRateHistory)) {
        return Toybox.SensorHistory.getHeartRateHistory({:period => 250});
    }
    return null;
}

function getColor(value as Float, colors as Array){
    var color = colors[0][1];
    for( var i = 0; i < colors.size(); i += 1 ) {
        if ( value <= colors[i][0]){
            color = colors[i][1];
        }
    }
    return color;

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

    function viewMonitor(dc as Dc, unit as Text, value as Float, str as Text, color as Graphics.ColorValue, logo as Text, table as Array) as Void {
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        var sizeFont = Graphics.getFontHeight(BoldFont);
        var sizeFontUnit = Graphics.getFontHeight(TinyFont);
        var sizeFontLogo = Graphics.getFontHeight(LogoFont);
        dc.drawText(dc.getWidth() -10, dc.getHeight()/2 - (sizeFont/2), BoldFont, str, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(dc.getWidth() -22, dc.getHeight()/2 +25, TinyFont, unit, Graphics.TEXT_JUSTIFY_RIGHT);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()*1/4, dc.getHeight()/2 - (sizeFontLogo/2), LogoFont, logo, Graphics.TEXT_JUSTIFY_CENTER);
        if (table.size() == 0) {
            lineColor(dc, color, value, 270, Math.toDegrees(Math.asin((sizeFont/2 -20) *1.0/ (dc.getHeight()/2 -15))), dc.getHeight()/2 -15, 10);
        } else {
            lineColor(dc, color, value, 180, Math.toDegrees(Math.asin((sizeFont/2 -20) *1.0/ (dc.getHeight()/2 -15))), dc.getHeight()/2 -15, 10);
            drawGraph(dc, dc.getWidth()/4, dc.getHeight()* 5/8, dc.getWidth()/2, dc.getHeight()* 1/4, table, 0, 100);
        }
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

    function drawGraph(dc as Dc, x as Lang.Numeric, y as Lang.Numeric, width as Lang.Numeric, height as Lang.Numeric, datas as Array, min as Lang.Numeric, max as Lang.Numeric) as Void {
        var level = height * 1.00 / (max - min);
        var pos = x + width;
        var maxminvalue = [[0, ""], [100, ""]];
        dc.setPenWidth(4);
        for( var i = 1; i < datas.size(); i += 1 ) {
            pos = pos -1;
            if (datas[i-1][0] != null and datas[i][0] != null) {
                dc.setColor(datas[i][1], Graphics.COLOR_TRANSPARENT);
                if (pos >= x) {
                    dc.drawLine(pos +1, y + height -(datas[i-1][0] - min) * level, pos, y + height -(datas[i][0] - min) * level);
                }
                if (datas[i][0] > maxminvalue[0][0]){
                    maxminvalue[0][0] = datas[i][0];
                    maxminvalue[0][1] = datas[i][2];
                }
                if (datas[i][0] < maxminvalue[1][0]){
                    maxminvalue[1][0] = datas[i][0];
                    maxminvalue[1][1] = datas[i][2];
                }
            }
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(x, y -10 , TinyFont, maxminvalue[0][1], Graphics.TEXT_JUSTIFY_RIGHT);
        dc.drawText(x, y +height -20, TinyFont, maxminvalue[1][1], Graphics.TEXT_JUSTIFY_RIGHT);
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
        viewMonitor(dc, unit, value, str, color, logo, []);
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
        viewMonitor(dc, unit, value, str, color, logo, []);
    }

}

class MinimalBbView extends MinimalView {

    function initialize() {
        MinimalView.initialize();
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout

        var bbIterator = getIteratorBb();
        var sampleBb = bbIterator.next();
        var value = 0;
        if (sampleBb != null) {
            value = sampleBb.data;
        }
        var str = Lang.format("$1$", [value.format("%d"),]);
        var array = [];
        var item = 0;
        var color = Graphics.COLOR_BLUE;
        var colors = [[100, Graphics.COLOR_BLUE], [80, Graphics.COLOR_GREEN], [40, Graphics.COLOR_YELLOW], [20, Graphics.COLOR_ORANGE], [10, Graphics.COLOR_RED]];
        while (sampleBb != null) {
            if (item % 3== 0) {
                try {
                    array.add([sampleBb.data, getColor(sampleBb.data, colors), Lang.format("$1$", [sampleBb.data.format("%d"),])]);
                }
                catch( ex ) {
                    // todo
                }
            }
            sampleBb = bbIterator.next();
            item = item +1;
        }
        var unit = "%";
        var logo = "6";
        View.onUpdate(dc);
        viewMonitor(dc, unit, value, str, color, logo, array);
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
        viewMonitor(dc, unit, value, str, color, logo, []);
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
        viewMonitor(dc, unit, value, str, color, logo, []);
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
        var str = Lang.format("$1$", [valueHeart,]);
        var value = valueHeart;
        if (valueHeart == null){
            value = 0;
            str = "--";
        } else {
            value = valueHeart /2; //max heart 200 bpm        
        }
        var color = Graphics.COLOR_RED;
        var array = [];
        try {
            var heartIterator = getIteratorHeart();
            if (heartIterator != null) {
                valueHeart = heartIterator.next();
                var item = 0;
                var heartRateZones = UserProfile.getHeartRateZones(0);
                var colors = [[heartRateZones[4], Graphics.COLOR_RED], [heartRateZones[3], Graphics.COLOR_ORANGE], [heartRateZones[2], Graphics.COLOR_GREEN], [70, Graphics.COLOR_BLUE], [50, Graphics.COLOR_LT_GRAY]];
                var delta = (heartRateZones[5] -20) /100;
                while (valueHeart != null) {
                    if (item % 2 == 0) {
                        try {
                            array.add([(valueHeart.data -20)/delta, getColor(valueHeart.data, colors), Lang.format("$1$", [valueHeart.data.format("%d"),])]); //max heart 200 bpm  
                        }
                        catch( ex ) {
                            // todo
                        }
                    }
                    valueHeart = heartIterator.next();
                    item = item +1;
                }
            }
        }
        catch( ex ) {
            array = [];
        }
        var unit = "Bpm";
        var logo = "5";
        View.onUpdate(dc);
        viewMonitor(dc, unit, value, str, color, logo, array);
    }
}