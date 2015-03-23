using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.System as Sys;
using Toybox.Lang as Lang;
using Toybox.Time.Gregorian as Gregorian;
using Toybox.Time as Time;
using Toybox.ActivityMonitor as ActivityMonitor;

class garminsimplewatchfaceView extends Ui.WatchFace {

    var stargate;
    var chevrons = [
        [ [105,2  ],[112,2  ],[108,11 ] ],
        [ [170,20 ],[177,26 ],[168,31 ] ],
        [ [211,76 ],[213,83 ],[204,82 ] ],
        [ [211,145],[208,152],[202,146] ],
        [ [169,200],[163,203],[162,194] ],
        [ [54 ,203],[55 ,194],[47 ,199] ],
        [ [8  ,152],[16 ,145],[6  ,145] ],
        [ [3  ,83 ],[13 ,82 ],[6  ,76 ] ],
        [ [41 ,26 ],[48 ,31 ],[47 ,21 ] ]
    ];

    //! Load your resources here
    function onLayout(dc) {
        stargate = Ui.loadResource(Rez.Drawables.id_stargate);
    }

    //! Restore the state of the app and prepare the view to be shown
    function onShow() {
    }

    //! Update the view
    function onUpdate(dc) {
        // Get and show the current time
        dc.setColor(Gfx.COLOR_BLACK, Gfx.COLOR_BLACK);
        dc.clear();
        
        // Draw the background
        var bgX = (dc.getWidth() - 218) / 2;
        var bgY = (dc.getHeight() - 218) / 2 - 1;
        dc.drawBitmap(bgX, bgY, stargate);
        
        // Device settings
        var settings = System.getDeviceSettings();
        
        // Get date/time strings
        var moment = Time.now();
        var info = Gregorian.info(moment, Time.FORMAT_MEDIUM);
        
        
        var hour;
        if (settings.is24Hour) {
            hour = info.hour;
        } else if (info.hour > 12) {
            hour = info.hour - 12;
        } else if (info.hour == 0) {
            hour = 12;
        } else {
            hour = info.hour;
        }
        
        // This will be used to correct centering of the text when hour starts with a 1
        var hourStartsWith1;
        if (hour > 9 && hour < 20) {
            hourStartsWith1 = true;
        } else if (hour == 1 && !settings.is24Hour) {
            hourStartsWith1 = true;
        } else {
            hourStartsWith1 = false;
        }
        
        var minuteString;
        if (info.min >= 10) {
            minuteString = Lang.format("$1$", [info.min.format("%d")]);
        } else {
            minuteString = Lang.format("0$1$", [info.min.format("%d")]);
        }
        var hourString;
        if (settings.is24Hour && hour < 10) {
            hourString = Lang.format("0$1$", [hour]);   
        } else {
            hourString = Lang.format("$1$", [hour]);
        }
        var dateString = Lang.format("$1$ $2$", [info.day_of_week, info.day]);
        
        // Position the elements horizontally
        var hourWidth = dc.getTextWidthInPixels(hourString, Gfx.FONT_NUMBER_HOT);
        var minuteWidth = dc.getTextWidthInPixels(minuteString, Gfx.FONT_NUMBER_HOT);
        var totalWidth = hourWidth + minuteWidth;
        var hourX = (dc.getWidth() / 2) - (totalWidth / 2);
        if (hourStartsWith1) {
            hourX = hourX - 5;
        }        
        var minX = hourX + hourWidth;
        var dateX = dc.getWidth() / 2;
        
        // Position elements vertically
        var timeHeight = dc.getFontHeight(Gfx.FONT_NUMBER_HOT);
        var dateHeight = dc.getFontHeight(Gfx.FONT_SMALL);
        var batteryIndicatorHeight = 10;
        var totalHeight = timeHeight + dateHeight + batteryIndicatorHeight;
        var timeY = (dc.getHeight() / 2) - (totalHeight / 2) - 5;
        var batteryIndicatorY = timeY + timeHeight;
        var dateY = batteryIndicatorY + batteryIndicatorHeight;
        
        // Render the hour text
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(hourX, timeY, Gfx.FONT_NUMBER_HOT, hourString, Gfx.TEXT_JUSTIFY_LEFT);
        
        // Draw the minute text
        dc.setColor(Gfx.COLOR_BLUE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(minX, timeY, Gfx.FONT_NUMBER_HOT, minuteString, Gfx.TEXT_JUSTIFY_LEFT);

        // Draw the date text       
        var dateWidth = dc.getTextWidthInPixels(dateString, Gfx.FONT_SMALL);
        dc.setColor(Gfx.COLOR_WHITE, Gfx.COLOR_TRANSPARENT);
        dc.drawText(dateX, dateY, Gfx.FONT_SMALL, dateString, Gfx.TEXT_JUSTIFY_CENTER);
        
        // Draw the battery indicator
        drawBatteryIndicator(dc, batteryIndicatorY);
        
        // Activity Tracking
        var activity = ActivityMonitor.getInfo();
        dc.setColor(Gfx.COLOR_ORANGE, Gfx.COLOR_ORANGE);
        for (var n = 0; n < 9; n++) {
            var chevronPercent = 100*(n+1)/9;
            var stepsGoalPercent = 100*activity.steps / activity.stepGoal;
            if (stepsGoalPercent >= chevronPercent) {
                dc.fillPolygon(chevrons[n]);
            }
        }
    }
    
    function drawBatteryIndicator(dc, batteryIndicatorY) {
        // Draw the battery life
        var stats = Sys.getSystemStats();
        var percent = stats.battery;
        var remainingString = Lang.format("$1$%", [percent.format("%d")]);
        
        var batteryIndicatorStartX = dc.getWidth() / 2;
        var blockSpace = 2;
        var blockWidth = 6;
        var blockHeight = 6;
        
        var numBlocks = 10;
        
        var batteryIndicatorWidth = (numBlocks * blockWidth) + ((numBlocks-1) * blockSpace);
        var batteryIndicatorX = (dc.getWidth() / 2) - (batteryIndicatorWidth / 2);
        
        // Draw the blocks
        var currentX = batteryIndicatorX;
        for (var i = 0; i < numBlocks; i++) {
            if (percent > ((i * 10) + 5)) {
                if (percent > 20) {
                    dc.setColor(Gfx.COLOR_GREEN, Gfx.COLOR_GREEN);
                } else {
                    dc.setColor(Gfx.COLOR_RED, Gfx.COLOR_RED);
                }
                dc.fillRoundedRectangle(currentX, batteryIndicatorY, blockWidth, blockHeight, blockWidth / 2);
            } else {
                dc.setColor(Gfx.COLOR_DK_GRAY, Gfx.COLOR_DK_GRAY);
                dc.fillRoundedRectangle(currentX, batteryIndicatorY, blockWidth, blockHeight, blockWidth / 4);
            }
            currentX = currentX + blockWidth + blockSpace;
        }
    }

    //! The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() {
    }

    //! Terminate any active timers and prepare for slow updates.
    function onEnterSleep() {
    }

}