using Toybox.WatchUi as Ui;
using Toybox.Graphics as Graphics;
import Toybox.Lang;
import Toybox.System;

(:glance)
class WidgetGlanceView extends Ui.GlanceView {
	
    const BoldFont = Application.loadResource(Rez.Fonts.BoldFont);

    function initialize() {
      GlanceView.initialize();
    }
    
    function onUpdate(dc) {
      var batteryString = Lang.format("$1$%", [System.getSystemStats().battery.format("%d"), ]);
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
      dc.setColor(color, Graphics.COLOR_TRANSPARENT);
      dc.drawText(0, dc.getHeight()/2 -24, BoldFont, batteryString, Graphics.TEXT_JUSTIFY_LEFT);
    }
}