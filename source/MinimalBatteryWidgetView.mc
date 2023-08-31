import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MinimalBatteryWidgetView extends WatchUi.View {

    const BoldFont = Application.loadResource(Rez.Fonts.BoldFont);
    const LogoFont = Application.loadResource(Rez.Fonts.LogoFont);

    function initialize() {
        View.initialize();
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.MainLayout(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Call the parent onUpdate function to redraw the layout
        var value = System.getSystemStats().battery;
        var gradient = [[0, 10, Graphics.COLOR_DK_RED],
                        [10, 20, Graphics.COLOR_ORANGE],
                        [20, 100, Graphics.COLOR_DK_GREEN]];
        View.onUpdate(dc);
        viewMonitor(dc, value, Graphics.COLOR_BLACK, gradient);
    }

    function viewMonitor(dc as Dc, value as Float, colorBackground as Graphics.ColorValue, gradient as Array) as Void {
        var valueString = Lang.format("$1$%", [value.format("%d"), ]);
        dc.setColor(colorBackground, colorBackground);
        dc.fillRectangle(0, 0, dc.getWidth(), dc.getHeight());
        var color = lineColor(dc,gradient, value);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2 -96, BoldFont, valueString, Graphics.TEXT_JUSTIFY_CENTER);
        dc.drawText(dc.getWidth()/2, dc.getHeight()/2 +12, LogoFont, "1", Graphics.TEXT_JUSTIFY_CENTER);
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function lineColor(dc as Dc, segments as Array, value as Float) as Graphics.ColorValue {
        var penWidthNoValue = 5;
        var penWidthValue = 10;
        var interSegments = 2;
        var start = 210;
        var end = -30;
        var delta = (start - end)/100.0;
        dc.setPenWidth(penWidthNoValue);
        var val = value;
        if (value < segments[0][0]) {
            val = segments[0][0];
        }
        if (value > segments[segments.size()-1][1]){
            val = segments[segments.size()-1][1];
        }
        for (var i = 0; i < segments.size(); i++) {
            dc.setColor(segments[i][2], Graphics.COLOR_TRANSPARENT);
            dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getHeight()/2 - penWidthNoValue/2, Graphics.ARC_CLOCKWISE, start - delta * segments[i][0] -interSegments, start - delta * segments[i][1]);
        }
        dc.setPenWidth(penWidthValue);
        var lastColor = segments[0][2];
        for (var i = 0; i < segments.size(); i++) {
            dc.setColor(segments[i][2], Graphics.COLOR_TRANSPARENT);
            if (value >= segments[i][0]) {
                lastColor = segments[i][2];
                if ( value >= segments[i][1]){
                    dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getHeight()/2 - penWidthValue/2, Graphics.ARC_CLOCKWISE, start - delta * segments[i][0] -interSegments, start - delta * segments[i][1]);
                } else {
                    dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getHeight()/2 - penWidthValue/2, Graphics.ARC_CLOCKWISE, start - delta * segments[i][0] -interSegments, start - delta * value);
                }
            }
        }
        dc.setColor(Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getHeight()/2 - penWidthValue/2, Graphics.ARC_CLOCKWISE, start - delta * value +2, start - delta * value);
        return lastColor;
    }

}
