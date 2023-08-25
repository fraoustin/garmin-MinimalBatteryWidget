import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;

class MinimalBatteryWidgetView extends WatchUi.View {

    const BoldFont = Application.loadResource(Rez.Fonts.BoldFont);
    const IconsFont = Application.loadResource(Rez.Fonts.MaterialFont);

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
        View.onUpdate(dc);
        var color = Graphics.COLOR_LT_GRAY;      
        if (System.getSystemStats().battery <= 80) {
            color = Graphics.COLOR_BLUE;
        }
        if (System.getSystemStats().battery <= 60) {
            color = Graphics.COLOR_GREEN;
        }
        if (System.getSystemStats().battery <= 40) {
            color = Graphics.COLOR_ORANGE;
        }
        if (System.getSystemStats().battery <= 20) {
            color = Graphics.COLOR_RED;
        }
        var batteryString = Lang.format("$1$%", [System.getSystemStats().battery.format("%d"), ]);
        var batteryView = View.findDrawableById("BatteryLabel") as Text;
        batteryView.setFont(IconsFont);
        batteryView.setLocation(WatchUi.LAYOUT_HALIGN_CENTER, WatchUi.LAYOUT_VALIGN_CENTER);
        var batteryValue = View.findDrawableById("BatteryValue") as Text;
        batteryValue.setFont(BoldFont);
        batteryValue.setLocation(dc.getWidth()/2, dc.getHeight()*1/24);
        batteryValue.setText(batteryString);
        batteryView.setText("1"); 
        batteryView.setColor(color);
        batteryValue.setColor(color);
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.setPenWidth(3);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getHeight()/2-dc.getHeight()*1/8, Graphics.ARC_COUNTER_CLOCKWISE, 90+25, 90+45);
        dc.drawArc(dc.getWidth()/2, dc.getHeight()/2, dc.getHeight()/2-dc.getHeight()*1/8, Graphics.ARC_COUNTER_CLOCKWISE, 90-45, 90-25);
        if (System.getSystemStats().battery <= 5) {
            batteryView.setText("0");
        } else {
            dc.setColor(color, color);
            dc.setPenWidth(1);
            var bloc = [20, 40, 60, 80, 100];
            var x = dc.getWidth()/2 -14;
            var y = dc.getHeight()/2 -28 +58;
            var height = 58;
            var width = 28;
            var remaining = System.getSystemStats().battery;
            for (var i = 0; i < bloc.size(); i++) {
                if (System.getSystemStats().battery >= bloc[i]) {
                    y = y - 50/bloc.size();
                    dc.fillRectangle(x , y, width, 50/bloc.size());
                    y = y - 2;
                    remaining = System.getSystemStats().battery - bloc[i];
                }
            }
            dc.fillRectangle(x , y -(remaining*58/100), width, remaining*58/100);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

}
