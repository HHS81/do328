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
	setprop("/instrumentation/nonEssBus1/serviceable",1);
	setprop("/instrumentation/logo-lights/serviceable",1);
	setprop("/instrumentation/wing-lights/serviceable",1);
	setprop("/instrumentation/beacon/serviceable",1);
	setprop("/instrumentation/strobe/serviceable",1);
	setprop("/instrumentation/landing-lights/serviceable",1);
	setprop("/instrumentation/taxi-lights/serviceable",1);
	setprop("/instrumentation/nav-lights/serviceable",1);
	#setprop("controls/lighting/instruments-norm",0.5);
	setprop("controls/engines/engine[0]/cutoff",1);
	setprop("controls/engines/engine[1]/cutoff",1);
	setprop("controls/engines/engine[0]/starter",1);
	setprop("controls/engines/engine[1]/starter",1);
}

var Startup2 = func{
	setprop("controls/engines/engine[0]/cutoff",0);
	setprop("controls/engines/engine[1]/cutoff",0);
	setprop("fdm/jsbsim/propulsion/engine/EIP/state",1);
	setprop("systems/electrical/Generator1/Connected",1);
	setprop("systems/electrical/Generator2/Connected",1);
	setprop("/systems/electrical/Alternator1/Connected",1);
	setprop("/systems/electrical/Alternator2/Connected",1);
}

var Shutdown = func{
	setprop("systems/electrical/Generator1/Connected",0);
	setprop("systems/electrical/Generator2/Connected",0);
	setprop("/systems/electrical/Alternator1/Connected",1);
	setprop("/systems/electrical/Alternator2/Connected",1);
	setprop("/instrumentation/logo-lights/serviceable",0);
	setprop("/instrumentation/wing-lights/serviceable",0);
	setprop("/instrumentation/beacon/serviceable",0);
	setprop("/instrumentation/strobe/serviceable",0);
	setprop("/instrumentation/landing-lights/serviceable",0);
	setprop("/instrumentation/taxi-lights/serviceable",0);
	setprop("/instrumentation/nav-lights/serviceable",0);
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
