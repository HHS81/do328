##########################################
# Flight Director/Autopilot controller.
# Syd Adams
# Daniel Overbeck
##########################################

var Lateral = props.globals.getNode("autopilot/locks/heading");
var Lateral_arm = props.globals.getNode("autopilot/locks/heading-arm");
var Vertical = props.globals.getNode("autopilot/locks/altitude");
var Vertical_arm = props.globals.getNode("autopilot/locks/altitude-arm");
var AP = props.globals.getNode("autopilot/locks/AP-status");

var Lmode = nil;
var LAmode = nil;
var Vmode = nil;
var VAmode = nil;
var NAVSRC = 0;
var Tmp = 0;

var FD_set_mode = func(btn) {
	Lmode = Lateral.getValue();
	LAmode = Lateral_arm.getValue();
	Vmode = Vertical.getValue();
	VAmode = Vertical_arm.getValue();

	if(btn == "ap") {
		if(!AP.getValue()) {
			Lateral_arm.setValue("");
			Vertical_arm.setValue("");

			if(Vmode=="PTCH") set_pitch();
			if(Lmode=="ROLL") set_roll();

			AP.setValue(1);
		}
		else {
			AP.setValue(0);
		}
	}
	elsif(btn == "hdg") {
		if(Lmode != "HDG") {
			Lateral.setValue("HDG");
		}
		else {
			set_roll();
		}
		Lateral_arm.setValue("");
		Vertical_arm.setValue("");
	}
	elsif(btn == "alt") {
		if(Vmode != "ALT") {
			Vertical.setValue("ALT");
			setprop("autopilot/settings/altitude",
				(getprop("instrumentation/altimeter/mode-c-alt-ft") * 0.01));
		}
		else {
			set_pitch();
		}
		Lateral_arm.setValue("");
		Vertical_arm.setValue("");
	}
	elsif(btn == "flc") {
		var flcmode = "FLC";
		var asel = "ASEL";

		if(NAVSRC == "FMS") {
			flcmode = "VFLC";
			asel = "VASEL";
		}

		if(Vmode != flcmode) {
			var mc = getprop("instrumentation/airspeed-indicator/indicated-mach");
			var kt = int(getprop("instrumentation/airspeed-indicator/indicated-speed-kt"));

			if(!getprop("autopilot/settings/changeover")) {
				if(kt > 80 and kt < 340) {
					setprop(Vertical, flcmode);
					setprop(Vertical_arm, asel);
					setprop("autopilot/settings/target-speed-kt", kt);
					setprop("autopilot/settings/target-speed-mach", mc);
				}
			}
			else {
				if(mc > 0.40 and mc < 0.85) {
					setprop(Vertical,flcmode);
					setprop(Vertical_arm,asel);
					setprop("autopilot/settings/target-speed-kt",kt);
					setprop("autopilot/settings/target-speed-mach",mc);
				}
			}
		}
		else {
			set_pitch();
		}
	}
	elsif(btn == "nav") {
		set_nav_mode();
		setprop("autopilot/settings/low-bank",0);
	}
	elsif(btn == "vnav") {
		if(Vmode!="VALT") {
			if(NAVSRC=="FMS") {
				Lateral.setValue("LNAV");
				Vertical.setValue("VALT");
			}
		}
		else {
			set_pitch();
		}
	}
	elsif(btn == "app") {
		Lateral_arm.setValue("");
		Vertical_arm.setValue("");

	# NAVSRC = 2: FMS
		if(NAVSRC < 2) {
			#if(getprop("instrumentation/nav["~NAVSRC~"]/nav-loc") and
			#   getprop("instrumentation/nav["~NAVSRC~"]/has-gs")) {
			#	Lateral_arm.setValue("LOC");
			#	Vertical_arm.setValue("GS");
			#}
			Lateral.setValue("LOC");
			Vertical.setValue("GS");
		}
		setprop("autopilot/settings/low-bank", 0);
	}
	elsif(btn == "vs") {
		Lateral_arm.setValue("");
		Vertical_arm.setValue("");
		if(Vmode!="VS"){
			Vertical.setValue("VS");
			Tmp = (int(getprop("autopilot/internal/vert-speed-fpm") * 0.01)) * 100;
			setprop("autopilot/settings/vertical-speed-fpm", Tmp);
		}
		else {
			set_pitch();
		}
	}
	elsif(btn == "stby") {
		Lateral_arm.setValue("");
		Vertical_arm.setValue("");
		set_pitch();
		set_roll();
		setprop("autopilot/settings/low-bank",0);
	}
	elsif(btn == "bank") {
		if(Lmode=="HDG") {
			Tmp = getprop("autopilot/settings/low-bank");
			setprop("autopilot/settings/low-bank", 1 - Tmp);
		}
	}
}

var pitch_wheel=func(dir) {
        Tmp = int(getprop("autopilot/settings/vertical-speed-fpm")) + (dir * 100);
        Tmp = (Tmp < -8000 ? -8000 : Tmp > 6000 ? 6000 : Tmp);
        setprop("autopilot/settings/vertical-speed-fpm", Tmp);
}

########    FD INTERNAL ACTIONS  #############

var set_pitch = func {
	Vertical.setValue("PTCH");
	setprop("autopilot/settings/target-pitch-deg", getprop("orientation/pitch-deg"));
}

var set_roll = func {
	Lateral.setValue("ROLL");
	setprop("autopilot/settings/target-roll-deg", 0.0);
}

var set_nav_mode = func {
	Lateral_arm.setValue("");
	Vertical_arm.setValue("");

	if(NAVSRC==2) {
		if(getprop("autopilot/route-manager/active")) Lateral.setValue("LNAV");
	}
	else {
		if(getprop("instrumentation/nav["~NAVSRC~"]/data-is-valid")) {
			if(getprop("instrumentation/nav["~NAVSRC~"]/nav-loc")) {
				Lateral_arm.setValue("LOC");
			}
			else {
				Lateral_arm.setValue("VOR");
			}
			Lateral.setValue("HDG");
		}
	}
}
