
call_torquecompution = func {

   
var trqlbs1 = props.globals.getNode("/fdm/jsbsim/propulsion/engine/torque-lbs",1);
var trqlbs2 = props.globals.getNode("/fdm/jsbsim/propulsion/engine[1]/torque-lbs",1);

trq1 =  getprop("/engines/engine/thruster/torque");
trq2 = getprop("/engines/engine[1]/thruster/torque");

trqlbs1.setDouleValue(trq1);
trqlbs2.setDouleValue(trq2);


   # schedule the next call
   settimer(call_torquecompution, 0.0);   
}
 
init = func {
   settimer(call_groundspoilers, 0.0);
}

init();
  