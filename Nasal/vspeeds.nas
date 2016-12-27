# Calculate V-speeds
var V1 = "";
var V2 = "";
var VR = "";
var Vref= "";
setprop("/fdm/jsbsim/inertia/weight-lbs",28000);

var vspeeds = func {
	
	WT = getprop("/fdm/jsbsim/inertia/weight-lbs");

	# 3rd order polynomial
	V1   = WT*WT*WT*0.879E-11 - WT*WT*0.694E-06 + WT*0.01996 - 101.5;
	VR   = WT*WT*WT*2.198E-11 - WT*WT*1.703E-06 + WT*0.04569 - 317.0;
	V2   = WT*WT*WT*1.319E-11 - WT*WT*1.059E-06 + WT*0.03006 - 187.2;
	Vref = WT*WT*WT*0.942E-11 - WT*WT*0.748E-06 + WT*0.02177 - 122.0;

	setprop("/instrumentation/fmc/vspeeds/V1",V1);
	setprop("/instrumentation/fmc/vspeeds/VR",VR);
	setprop("/instrumentation/fmc/vspeeds/V2",V2);
	setprop("/instrumentation/fmc/vspeeds/Vref",Vref);
}
var do_vspeeds = func {
	vspeeds();
	settimer(do_vspeeds, 1);
}

_setlistener("/sim/signals/fdm-initialized", do_vspeeds);
