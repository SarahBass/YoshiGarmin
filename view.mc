import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Time;
import Toybox.Weather;
import Toybox.Activity;
import Toybox.ActivityMonitor;
import Toybox.Time.Gregorian;
import Toybox.UserProfile;
class VirtualPetNothingView extends WatchUi.WatchFace {
  
function initialize() {  WatchFace.initialize(); }

function onLayout(dc as Dc) as Void { }

function onShow() as Void { }

function onUpdate(dc as Dc) as Void {
/*                 _       _     _           
  __   ____ _ _ __(_) __ _| |__ | | ___  ___ 
  \ \ / / _` | '__| |/ _` | '_ \| |/ _ \/ __|
   \ V / (_| | |  | | (_| | |_) | |  __/\__ \
    \_/ \__,_|_|  |_|\__,_|_.__/|_|\___||___/
                                           */

    /*----------System Variables------------------------------*/
    var mySettings = System.getDeviceSettings();
    var screenHeightY = (System.getDeviceSettings().screenHeight)/360;
    var screenWidthX = (System.getDeviceSettings().screenWidth)/360;
    //Size Variations Pixel Circle
    //360 VenuS2 - The Model I designed it for 
    //390 Size up
    //416 Size up
    //454 Size up
    if (System.getDeviceSettings().screenHeight ==390){
        screenHeightY=screenHeightY*1.1;
        screenWidthX=screenWidthX *1.07;
    }
    if (System.getDeviceSettings().screenHeight ==416){
        screenHeightY=screenHeightY*1.15;
        screenWidthX=screenWidthX *1.17;
    }
    if (System.getDeviceSettings().screenHeight ==454){
        screenHeightY=screenHeightY*1.25;
        screenWidthX=screenWidthX *1.27;
    }
    var myStats = System.getSystemStats();
    var info = ActivityMonitor.getInfo();
    
    /*----------Clock and Calendar Variables------------------------------*/
    var timeFormat = "$1$:$2$";
    var clockTime = System.getClockTime();
    var today = Gregorian.info(Time.now(), Time.FORMAT_SHORT);
    var hours = clockTime.hour;
    if (!System.getDeviceSettings().is24Hour) {
        if (hours == 0) {
            hours = 12; // Display midnight as 12:00
        } else if (hours > 12) {
            hours = hours - 12;
        }
    } else {
        timeFormat = "$1$:$2$";
        hours = hours.format("%02d");
    }
    var timeString = Lang.format(timeFormat, [hours, clockTime.min.format("%02d")]);
    var weekdayArray = ["Day", "SUNDAY", "MONDAY", "TUESDAY", "WEDNESDAY", "THURSDAY", "FRIDAY", "SATURDAY"] as Array<String>;
    var monthArray = ["Month", "JANUARY", "FEBRUARY", "MARCH", "APRIL", "MAY", "JUNE", "JULY", "AUGUST", "SEPTEMBER", "OCTOBER", "NOVEMBER", "DECEMBER"] as Array<String>;
   

    /*----------Battery------------------------------*/
    var userBattery = "0";
    var batteryMeter = 1;

    if (myStats.battery != null) {
        userBattery = myStats.battery.toNumber().toString(); // Convert to string without zero padding
    } else {
        userBattery = "0";
    }

    if (myStats.battery != null) {
        batteryMeter = myStats.battery.toNumber();
    } else {
        batteryMeter = 1;
    }
        
    /*----------Steps------------------------------*/
    var userSTEPS = 0;
 if (info.steps != null){userSTEPS = info.steps.toNumber();}else{userSTEPS=0;} 
    var userCAL = 0;
    if (info.calories != null){userCAL = info.calories.toNumber();}else{userCAL=0;}  
   
   /*----------Weather------------------------------*/
   var getCC = Toybox.Weather.getCurrentConditions();
    var TEMP = "000";
    var FC = "0";
    if (getCC != null && getCC.temperature != null) {
        if (System.getDeviceSettings().temperatureUnits == 0) {
            FC = "C";
            TEMP = getCC.temperature.format("%d");
        } else {
            TEMP = (((getCC.temperature * 9) / 5) + 32).format("%d");
            FC = "F";
        }
    } else {
        TEMP = "000";
    }

    var cond = 0;
    if (getCC != null && getCC.condition != null) {
        cond = getCC.condition.toNumber();
    } else {
        cond = 0; // Default to sun condition if unavailable
    }

    var userHEART = "0";
    var heartRate = getHeartRate();

    if (heartRate == null) {
        userHEART = "0"; // Set to "0" if heart rate is unavailable
    } else {
        userHEART = heartRate.toString();
    }

    var moonnumber = getMoonPhase(today.year, ((today.month)-1), today.day);  
    var moon1 = moonArrFun(moonnumber);
    var centerX = (dc.getWidth()) / 2;
    var wordFont =  WatchUi.loadResource( Rez.Fonts.smallFont );
    var bigFont= WatchUi.loadResource( Rez.Fonts.bigFont );
    var funFont= WatchUi.loadResource( Rez.Fonts.funFont );
    View.onUpdate(dc);

 /*     _                           _            _    
     __| |_ __ __ ___      __   ___| | ___   ___| | __
    / _` | '__/ _` \ \ /\ / /  / __| |/ _ \ / __| |/ /
   | (_| | | | (_| |\ V  V /  | (__| | (_) | (__|   < 
    \__,_|_|  \__,_| \_/\_/    \___|_|\___/ \___|_|\_\
                                                   */

   //Draw Background
    var water= waterPhase(today.sec);
    water.draw(dc);
    //Draw Sprite
    var dog = dogPhase(today.sec,userSTEPS); //userSTEPS or (today.sec*180) fix 15 and 16 and 17 to be higher
    dog.draw(dc);
   //Draw Moon and Battery
    moon1.draw(dc);

    //Draw Top Font
    dc.setColor(0x000000, Graphics.COLOR_TRANSPARENT);  
    dc.drawText( 221 *screenWidthX,40*screenHeightY, wordFont, (TEMP+" " +FC), Graphics.TEXT_JUSTIFY_CENTER );
    dc.setColor(0xFFFFFF, Graphics.COLOR_TRANSPARENT);
    dc.drawText( centerX-2,0, bigFont, weather(cond), Graphics.TEXT_JUSTIFY_CENTER );
    dc.drawText(centerX,78*screenHeightY,wordFont,(weekdayArray[today.day_of_week]+" , "+ monthArray[today.month]+" "+ today.day +" " +today.year), Graphics.TEXT_JUSTIFY_CENTER );
    dc.drawText( 15 *screenWidthX,centerX-30 , funFont,  ("^"), Graphics.TEXT_JUSTIFY_CENTER );
    dc.drawText( 15 *screenWidthX,centerX , wordFont,  userHEART, Graphics.TEXT_JUSTIFY_CENTER );
    dc.drawText( centerX, (310)*screenHeightY, funFont,  ("$"), Graphics.TEXT_JUSTIFY_CENTER );
    dc.drawText( centerX, (340)*screenHeightY, wordFont,  (userSTEPS), Graphics.TEXT_JUSTIFY_CENTER );
    dc.drawText( 345 *screenWidthX,centerX-30 , funFont, "!", Graphics.TEXT_JUSTIFY_CENTER );
    dc.drawText( 345 *screenWidthX,centerX , wordFont, userCAL, Graphics.TEXT_JUSTIFY_CENTER );

    /*---------------Draw Battery---------------*/
     
    if (batteryMeter >= 10 && batteryMeter <= 32) {
        //Red
        dc.setColor(0xB00B1E, Graphics.COLOR_TRANSPARENT); 
        dc.fillRectangle(centerX * 350 / 360, centerX * 88 / 360, 9, 15);
    } else if (batteryMeter >= 33 && batteryMeter <= 65) {
       //Yellow
       dc.setColor(0xFFFF00, Graphics.COLOR_TRANSPARENT); 
        dc.fillRectangle(centerX * 350 / 360, centerX * 88 / 360, 9,15 );
    } else if (batteryMeter >= 66) {
       //Nothing
    }else{
        //Nothing
    }

}
/*            _     _ 
  __   _____ (_) __| |
  \ \ / / _ \| |/ _` |
   \ V / (_) | | (_| |
    \_/ \___/|_|\__,_|
                    */

function onHide() as Void { }
function onExitSleep() as Void {}
function onEnterSleep() as Void {}

/*                    _   _               
__      _____  __ _| |_| |__   ___ _ __ 
\ \ /\ / / _ \/ _` | __| '_ \ / _ \ '__|
 \ V  V /  __/ (_| | |_| | | |  __/ |   
  \_/\_/ \___|\__,_|\__|_| |_|\___|_|   
                                        */

function weather(cond) {
  if (cond == 0 || cond == 40){return "b";}//sun
  else if (cond == 50 || cond == 49 ||cond == 47||cond == 45||cond == 44||cond == 42||cond == 31||cond == 27||cond == 26||cond == 25||cond == 24||cond == 21||cond == 18||cond == 15||cond == 14||cond == 13||cond == 11||cond == 3){return "a";}//rain
  else if (cond == 52||cond == 20||cond == 2||cond == 1){return "e";}//cloud
  else if (cond == 5 || cond == 8|| cond == 9|| cond == 29|| cond == 30|| cond == 33|| cond == 35|| cond == 37|| cond == 38|| cond == 39){return "g";}//wind
  else if (cond == 51 || cond == 48|| cond == 46|| cond == 43|| cond == 10|| cond == 4){return "i";}//snow
  else if (cond == 32 || cond == 37|| cond == 41|| cond == 42){return "f";}//whirlwind 
  else {return "c";}//suncloudrain 
}

/*     _                                        
    __| |_ __ __ ___      __  _ __  _ __   __ _ 
   / _` | '__/ _` \ \ /\ / / | '_ \| '_ \ / _` |
  | (_| | | | (_| |\ V  V /  | |_) | | | | (_| |
   \__,_|_|  \__,_| \_/\_/   | .__/|_| |_|\__, |
                             |_|          |___/ */

//DrawOpacityGraphic - dog -
function dogPhase(seconds, steps){
  var screenHeightY = System.getDeviceSettings().screenHeight;
  var screenWidthX = System.getDeviceSettings().screenWidth;
  var venus2X = (244*screenWidthX/360)-((seconds%5)*10);
  var venus2Y = (230*screenHeightY/360);
 if (seconds%10>5){
    venus2X = (244*screenWidthX/360)-((seconds%5)*10);
 }
 else{
venus2X = (214*screenWidthX/360)+((seconds%5)*10);
 }

    if (screenHeightY > 400){
   venus2Y = venus2Y+30;
   venus2X = venus2X;}

  var dogARRAY = [
   (new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog0,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog1,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog2,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog3,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog4,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog5,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog6,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog7,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog8,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog9,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog10,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog11,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog12,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog13,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog14,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog15,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog16,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog17,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog18,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog19,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog20,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog21,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog22,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog23,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog24,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog25,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog26,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog27,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog28,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog29,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog30,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog31,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog32,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog33,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog34,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog35,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog36,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog37,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog38,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog39,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog40,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog41,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog42,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog43,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog44,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog45,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog46,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog47,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog48,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog49,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog50,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog51,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog52,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog53,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog54,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog55,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog56,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog57,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog58,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog59,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog60,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog61,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog62,
    :locX=> venus2X,
    :locY=>venus2Y-100
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog63,
    :locX=> venus2X,
    :locY=>venus2Y-100
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog64,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog65,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog66,
    :locX=> venus2X,
    :locY=>venus2Y-50
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog67,
    :locX=> venus2X,
    :locY=>venus2Y-50
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog68,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog69,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog70,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog71,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog72,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog73,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog74,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog75,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog76,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog77,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog78,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog79,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog80,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog81,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog82,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog83,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog84,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog85,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog86,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog87,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog88,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog89,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog90,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog91,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog92,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog93,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog94,
    :locX=> venus2X,
    :locY=>venus2Y
})),
(new WatchUi.Bitmap({
    :rezId=>Rez.Drawables.dog95,
    :locX=> venus2X,
    :locY=>venus2Y
}))
        ];
    if (seconds%10>5){
        return dogARRAY[(steps/360) + seconds%2 ];}
    else{
        return dogARRAY[(steps/360)+2 + seconds%2 ];
        }
       
        
}

//DrawOpacityGraphic - dog -
function waterPhase(seconds){
  var screenHeightY = System.getDeviceSettings().screenHeight;
  //var screenWidthX = System.getDeviceSettings().screenWidth;
  var venus2X = 0;
 // var venus2Y = 15;
  var venus2Y = screenHeightY -454;

      if (screenHeightY > 400){
   venus2Y = venus2Y+30;
    venus2X = 0-(seconds%30);
   }
    //Size Variations Pixel Circle
    //360 VenuS2 - The Model I designed it for 
    //390 Size up
    //416 Size up
    //454 Size up
    /*
  if (screenHeightY == 390){
   venus2Y = (200*screenHeightY/360);
  }
    if (screenHeightY == 416){
   venus2Y = (212*screenHeightY/360);
   venus2X = 120*screenWidthX/360;
  }
      if (screenHeightY == 454){
   venus2Y = (220*screenHeightY/360);
   venus2X = 130*screenWidthX/360;
  }*/
  var waterARRAY = [
    (new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.water0,
            :locX=> venus2X,
            :locY=>venus2Y
        }))
        ];
return  waterARRAY[0];  
  
}



/* _                     _       __       _       
  | |__   ___  __ _ _ __| |_    /__\ __ _| |_ ___ 
  | '_ \ / _ \/ _` | '__| __|  / \/// _` | __/ _ \
  | | | |  __/ (_| | |  | |_  / _  \ (_| | ||  __/
  |_| |_|\___|\__,_|_|   \__| \/ \_/\__,_|\__\___|
                                                */

private function getHeartRate() {
    // Initialize to null
    var heartRate = null;

    // Get the activity info if possible
    var info = Activity.getActivityInfo();
    if (info != null && info.currentHeartRate != null) {
        heartRate = info.currentHeartRate;
    } else { 
        // Fallback to `getHeartRateHistory`
        var history = ActivityMonitor.getHeartRateHistory(1, true);
        if (history != null) {
            var latestHeartRateSample = history.next();
            if (latestHeartRateSample != null && latestHeartRateSample.heartRate != null) {
                heartRate = latestHeartRateSample.heartRate;
            }
        }
    }

    // Could still be null if the device doesn't support it
    return heartRate;
}


/*
  __  __                 ___ _                 
 |  \/  |___  ___ _ _   | _ \ |_  __ _ ___ ___ 
 | |\/| / _ \/ _ \ ' \  |  _/ ' \/ _` (_-</ -_)
 |_|  |_\___/\___/_||_| |_| |_||_\__,_/__/\___|
 
*/
function getMoonPhase(year, month, day) {

      var c=0;
      var e=0;
      var jd=0;
      var b=0;

      if (month < 3) {
        year--;
        month += 12;
      }

      ++month; 

      c = 365.25 * year;

      e = 30.6 * month;

      jd = c + e + day - 694039.09; 

      jd /= 29.5305882; 

      b = (jd).toNumber(); 

      jd -= b; 

      b = Math.round(jd * 8); 

      if (b >= 8) {
        b = 0; 
      }
     
      return (b).toNumber();
    }

     /*
     0 => New Moon
     1 => Waxing Crescent Moon
     2 => Quarter Moon
     3 => Waxing Gibbous Moon
     4 => Full Moon
     5 => Waning Gibbous Moon
     6 => Last Quarter Moon
     7 => Waning Crescent Moon
     */
function moonArrFun(moonnumber){
    var screenHeightY = System.getDeviceSettings().screenHeight;
    var screenWidthX = System.getDeviceSettings().screenWidth;    
    var venus2Y = 25*(screenHeightY/360);
    var venus2XL = ((screenWidthX)*115/360);
    //Size Variations Pixel Circle
    //360 VenuS2 - The Model I designed it for 
    //390 Size up
    //416 Size up
    //454 Size up
    
    if (screenHeightY == 390){
        venus2XL = ((venus2XL)+4);
        venus2Y = ((screenWidthX)*130/360)-100;
    }
    if (screenHeightY == 416){
      venus2XL = ((venus2XL)+8);
        venus2Y = ((screenWidthX)*130/360)-105;
    }
        if (screenHeightY == 454){
        venus2XL = ((venus2XL)+15);
        venus2Y = ((screenWidthX)*130/360)-110;
    }
  var moonArray= [
          (new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.newmoon,//0
            :locX=> venus2XL,
            :locY=> venus2Y
        })),
        (new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.waxcres,//1
            :locX=> venus2XL,
            :locY=> venus2Y
        })),
        (new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.firstquar,//2
            :locX=> venus2XL,
            :locY=> venus2Y
        })),
                (new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.waxgib,//3
            :locX=> venus2XL,
            :locY=> venus2Y
        })),
                (new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.full,//4
            :locX=> venus2XL,
            :locY=> venus2Y
        })),
                (new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.wangib,//5
            :locX=> venus2XL,
            :locY=> venus2Y
        })),
            (new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.thirdquar,//6
            :locX=> venus2XL,
            :locY=> venus2Y
        })),
           (new WatchUi.Bitmap({
            :rezId=>Rez.Drawables.wancres,//7
            :locX=> venus2XL,
            :locY=> venus2Y,
        })),
        ];
        return moonArray[moonnumber];
}


}

/* 
       Horoscope, Zodiac, and Weather Font:
        A FAR
        B capricorn
        C CELCIUS
        D Celcius
        E SAGIT
        F TAUR
        G SCORP
        H VIRGO
        I LIBRA
        J LEO
        K BULL
        L SHEEP
        M PM
        N AM
        0 :
        a rain
        b sun
        c rainsuncloud
        d dragon
        e cloud
        f whirl
        g wind
        h rat
        i snow
        j dog
        k tiger
        l sun up
        m rabbit
        n sun down
        o snake
        p horse
        q rooster
        r monkey
        s pig
        t male
        u female
        v aquarius
        w aries
        x gemini
        y leo
        z libra
        */

// questionmark=calorie *=heart [=battery ]=steps @=battery #=phone
// = is small battery ^ is small steps ~ is small calories + is small heart
