#From Syd Adams King Air 200

########## MAIN ##############
var Startup = func{
	settimer(Startup1, 0);
	settimer(Startup2, 1);
}

var Startup1 = func{
	setprop("systems/electrical/Battery1/Connected",1);
	setprop("systems/electrical/Battery2/Connected",1);
	setprop("systems/electrical/DCTie/Connected",1);
	setprop("/systems/electrical/Consumers/nonEssBus1_Connected",1);
	setprop("/systems/electrical/Consumers/logo-lights_Connected",1);
	setprop("/systems/electrical/Consumers/wing-lights_Connected",1);
	setprop("/systems/electrical/Consumers/beacon_Connected",1);
	setprop("/systems/electrical/Consumers/strobe_Connected",1);
	setprop("/systems/electrical/Consumers/landing-lights_Connected",1);
	setprop("/systems/electrical/Consumers/taxi-lights_Connected",1);
	setprop("/systems/electrical/Consumers/nav-lights_Connected",1);
	#setprop("controls/lighting/instruments-norm",0.5);
	setprop("controls/engines/engine[0]/cutoff",1);
	setprop("controls/engines/engine[1]/cutoff",1);
	setprop("controls/engines/engine[0]/starter",1);
	setprop("controls/engines/engine[1]/starter",1);
}

var Startup2 = func{
	setprop("controls/engines/engine[0]/cutoff",0);
	setprop("controls/engines/engine[1]/cutoff",0);
	setprop("controls/electric/engine[0]/generator",1);
	setprop("controls/electric/engine[1]/generator",1);
	setprop("fdm/jsbsim/propulsion/engine/EIP/state",1);
	setprop("systems/electrical/Generator1/Connected",1);
	setprop("systems/electrical/Generator2/Connected",1);
}

var Shutdown = func{
	setprop("controls/electric/engine[0]/generator",0);
	setprop("controls/electric/engine[1]/generator",0);
	setprop("systems/electrical/Generator1/Connected",0);
	setprop("systems/electrical/Generator2/Connected",0);
	setprop("/systems/electrical/Consumers/logo-lights_Connected",0);
	setprop("/systems/electrical/Consumers/wing-lights_Connected",0);
	setprop("/systems/electrical/Consumers/beacon_Connected",0);
	setprop("/systems/electrical/Consumers/strobe_Connected",0);
	setprop("/systems/electrical/Consumers/landing-lights_Connected",0);
	setprop("/systems/electrical/Consumers/taxi-lights_Connected",0);
	setprop("/systems/electrical/Consumers/nav-lights_Connected",0);
	setprop("controls/engines/engine[0]/cutoff",1);
	setprop("controls/engines/engine[1]/cutoff",1);
	setprop("fdm/jsbsim/propulsion/engine/EIP/state",0);
	setprop("systems/electrical/Battery1/Connected",0);
	setprop("systems/electrical/Battery2/Connected",0);
	setprop("systems/electrical/DCTie/Connected",0);
}

setlistener("/sim/model/autostart", func(start) {
	if(start.getValue()){
		Startup();
	} else{
		Shutdown();
	}
},1,0);
