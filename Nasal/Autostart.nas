#From Syd Adams King Air 200

setlistener("/sim/signals/fdm-initialized", func {
    settimer(update_systems,2);
});

setlistener("/sim/signals/reinit", func {
},0,0);


#controls.gearDown = func(v) {
#    if (v < 0) {
 #       if(!getprop("gear/gear[1]/wow"))setprop("/controls/gear/gear-down", 0);
 #   } elsif (v > 0) {
 #     setprop("/controls/gear/gear-down", 1);
 #   }
#}


########## MAIN ##############
var Startup = func{
	setprop("controls/electric/engine[0]/generator",1);
	setprop("controls/electric/engine[1]/generator",1);
	setprop("controls/electric/battery-switch",1);
	setprop("controls/electric/avionics-switch",1);
	setprop("controls/lighting/beacon",1);
	setprop("controls/lighting/strobe",1);
	setprop("controls/lighting/instruments-norm",0.5);
	setprop("controls/lighting/nav-lights",1);
	setprop("controls/engines/engine[0]/condition",1);
	setprop("controls/engines/engine[1]/condition",1);
    setprop("controls/engines/engine[0]/cutoff",0);
    setprop("controls/engines/engine[1]/cutoff",0);
    setprop("controls/engines/engine[0]/starter",1);
    setprop("controls/engines/engine[1]/starter",1);
    setprop("fdm/jsbsim/propulsion/engine/EIP/state",1);
}


var Shutdown = func{
	setprop("controls/electric/engine[0]/generator",0);
	setprop("controls/electric/engine[1]/generator",0);
	setprop("controls/electric/battery-switch",0);
	setprop("controls/electric/avionics-switch",0);
	setprop("controls/lighting/beacon",0);
	setprop("controls/lighting/strobe",0);
	setprop("controls/lighting/instruments-norm",0.5);
	setprop("controls/lighting/nav-lights",0);
	setprop("controls/engines/engine[0]/condition",0);
	setprop("controls/engines/engine[1]/condition",0);
    setprop("controls/engines/engine[0]/cutoff",1);
    setprop("controls/engines/engine[1]/cutoff",1);
    setprop("fdm/jsbsim/propulsion/engine/EIP/state",0);
}

setlistener("/sim/model/autostart", func(start) {
    if(start.getValue()){
            Startup();
    } else{
        Shutdown();
    }
},1,0);

var update_systems = func{

settimer(update_systems,0);
}