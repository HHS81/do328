#From Syd Adams King Air 200

########## MAIN ##############
var Startup = func{
	settimer(Startup1, 0);
	settimer(Startup2, 1);
}

var Startup1 = func{
	setprop("controls/electric/battery-switch",1);
	setprop("controls/electric/avionics-switch",1);
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
}

var Shutdown = func{
	setprop("controls/electric/engine[0]/generator",0);
	setprop("controls/electric/engine[1]/generator",0);
	setprop("controls/electric/battery-switch",0);
	setprop("controls/electric/avionics-switch",0);
	setprop("controls/engines/engine[0]/cutoff",1);
	setprop("controls/engines/engine[1]/cutoff",1);
}

setlistener("/sim/model/autostart", func(start) {
	if(start.getValue()){
		Startup();
	} else{
		Shutdown();
	}
},1,0);
