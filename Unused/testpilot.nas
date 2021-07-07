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


call_testpilot = func {
SPEED= getprop("/instrumentation/airspeed-indicator/indicated-speed-kt");

if (getprop("/gear/gear[0]/wow")=="false"){
print ("Vr at ", SPEED ,"     "); 
#screen.log.write("Vr at ", SPEED ," ", 1, 0, 0);
}

if (getprop("/gear/gear[2]/wow")=="false"){
print ("V2 at ", SPEED ,"     "); 
#screen.log.write("V2 at ", SPEED ," ", 1, 0, 0);
}

if (getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") > 109){

interpolate ("/controls/flight/elevator", -0.3, 0.3);
#interpolate ("/controls/flight/elevator", -0.99, 0.1);


}
if (getprop("/instrumentation/airspeed-indicator/indicated-speed-kt") > 113){

interpolate ("/controls/flight/elevator", 0.0, 1.0);
#interpolate ("/controls/flight/elevator", -0.99, 0.1);


}

 

   # schedule the next call
   settimer(call_testpilot, 0.0);   
}
 
init = func {
   settimer(call_testpilot, 0.0);
}

init();
  