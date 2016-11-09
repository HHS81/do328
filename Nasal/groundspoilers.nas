# Controls systems that depend on the air-ground sensor
# (also called "squat-switch") position.  This assumes
# the airplane always starts on the ground (just like the
# real airplane).

#To-Do:
#from for 328 Turboprop: http://quizlet.com/7103759/do328-flight-controls-flash-cards/:
#What conditions are required for the ground spoilers to arm?:
#Gnd spoiler button has to be pressed, gear handle down 
#and gear down and locked, and condition levers have to be 
#greater than 85%
#From videos when main gear and nose gear wheel has WOW inner and outer spoiler will be deployed
#Dornier 328-jet is different: Main gear wheel WOW inner spoiler depolyed, when nose gear wheel WOW then the outer spoiler is deployed as well
#

INAIR = "false";
REJECT = "false";
LANDED = "false";

call_groundspoilers = func {

   WOW = getprop("/gear/gear[0]/wow");
   GROUNDSPEED = getprop("/velocities/uBody-fps") * 0.593;  
 
   if (WOW == 1) {
      # nose gear strut is compressed

     if (INAIR == "false") {
             
        if ((getprop("/controls/flight/spoiler-armed") == "true") and (REJECT=="false")) {
          if (getprop("/controls/engines/engine[0]/throttle") < 0.1) { 
            if (GROUNDSPEED > 60.0) {
              REJECT = "true";
              print ("Rejecting Takeoff at ", GROUNDSPEED, " kts ground speed.");
            }
          }
        }

        if (REJECT == "true") {
          if (GROUNDSPEED < 2.0) {
            REJECT = "false";
	    setprop("/controls/flight/spoiler-armed", "false");
	} else {
	setprop("/controls/flight/spoilers", 1.0);
          } 
        }

        if (LANDED == "true") {
	if (GROUNDSPEED < 2.0){
          if (getprop("/controls/engines/engine[0]/throttle") > 0.1) { 
             LANDED = "false";
	     setprop("/controls/flight/spoiler-armed", "false");
	     setprop("/controls/flight/spoilers", 0.0);
	}
          if (GROUNDSPEED < 2.0) {
            LANDED = "false";
	    setprop("/controls/flight/spoiler-armed", "false");
	     setprop("/controls/flight/spoilers", 0.0);
	}
        }
}	


     } else {
       # we have touched down
       INAIR = "false";
       LANDED = "true";

        var SPOILERARM = getprop("/controls/flight/spoiler-armed");

        if (SPOILERARM == "false") {
          # so do nothing here
        }
        elsif (SPOILERARM == "true")  {
	  setprop("/controls/flight/spoilers", 1.0);
	  setprop("/controls/flight/spoiler-armed", "false");
	
        }else {
          
          setprop("/controls/flight/spoiler-armed", "false");
	  setprop("/controls/flight/spoilers", 0.0);
        }

        
       
     }

   } else {
      # nose gear is not compressed
      INAIR = "true";
      LANDED = "false";
   }


   # schedule the next call
   settimer(call_groundspoilers, 0.1);   
}
 
init = func {
   settimer(call_groundspoilers, 0.0);
}

init();
  