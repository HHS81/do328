aircraft.livery.init("Aircraft/do328/Models/do328prop_liveries");

var gear_toggle = func(dir) {
	if(dir==-1) {
		dir=0;
		if(getprop("controls/gear/gear-down")) {
			if(getprop("gear/gear[1]/wow")) dir=1;
			if(getprop("controls/gear/gear-lock")) dir=1;
		}
	}
	setprop("controls/gear/gear-down", dir);
}

var reverse = func(index) {
	if(getprop("controls/engines/engine["~index~"]/latch")) {
		setprop("controls/engines/engine["~index~"]/latch", 0);
		setprop("controls/engines/engine["~index~"]/reverser", 0);
	}
	else {
		setprop("controls/engines/engine["~index~"]/latch", 1);

		if(getprop("controls/engines/engine["~index~"]/throttle") < 0.1) {
			setprop("controls/engines/engine["~index~"]/reverser", 1);
		}
	}
}

var start_engine = func(index) {
	if((getprop("systems/electrical/APU/Voltage") or 0) < 20) return;
	setprop("controls/engines/engine["~index~"]/starter", 1);
	setprop("fdm/jsbsim/propulsion/engine/EIP/state",1);
}

var stop_apu = func {
	setprop("controls/engines/engine[2]/starter", 0);
	setprop("controls/engines/engine[2]/cutoff", 1);
}

var apu_handler = func {
	if(getprop("controls/engines/engine[2]/cutoff") == 1) {
		if((getprop("engines/engine[2]/n2") or 0) > 20.0) {
			if((getprop("engines/engine[2]/starter") or 0) == 1) {
				setprop("controls/engines/engine[2]/cutoff", 0);
			}
		}
	}
}
var apu_timer = maketimer(0.1, apu_handler);
apu_timer.start();
