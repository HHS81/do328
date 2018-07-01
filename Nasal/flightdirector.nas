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
var NAVsrc = 0; # 0: CPT, 1: FO
var NAVmode = "NAV"; # 0: NAV, MLS (not in use) or FMS
var Tmp = 0;

var FDBtClick = func(btn) {
	Lmode = Lateral.getValue();
	LAmode = Lateral_arm.getValue();
	Vmode = Vertical.getValue();
	VAmode = Vertical_arm.getValue();

	if(btn == "AP") {
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
	elsif(btn == "ALT") {
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
	elsif(btn == "FLCH") {
		var flcmode = "FLCH";
		var asel = "ASEL";

		# FMS
		if(NAVmode == "FMS") {
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
	elsif(btn == "NAV") {
		set_nav_mode();
		setprop("autopilot/settings/low-bank",0);
	}
	elsif(btn == "VNAV") {
		if(Vmode!="VALT") {
			if(NAVmode=="FMS") {
				Lateral.setValue("LNAV");
				Vertical.setValue("VALT");
			}
		}
		else {
			set_pitch();
		}
	}
	elsif(btn == "APP") {
		Lateral_arm.setValue("");
		Vertical_arm.setValue("");

		if(NAVmode == "NAV") {
			if(getprop("instrumentation/nav["~NAVsrc~"]/nav-loc") and
			   getprop("instrumentation/nav["~NAVsrc~"]/has-gs")) {
				Lateral_arm.setValue("LOC");
				Vertical_arm.setValue("GS");
			}
			Lateral.setValue("LOC");
			Vertical.setValue("GS");
		}
		setprop("autopilot/settings/low-bank", 0);
	}
	elsif(btn == "VS") {
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
	elsif(btn == "STBY") {
		Lateral_arm.setValue("");
		Vertical_arm.setValue("");
		set_pitch();
		set_roll();
		setprop("autopilot/settings/low-bank",0);
	}
	elsif(btn == "BANK") {
		if(Lmode=="HDG") {
			Tmp = getprop("autopilot/settings/low-bank");
			setprop("autopilot/settings/low-bank", 1 - Tmp);
		}
	}
	elsif(btn == "CPL") {
		if(NAVsrc == 0) {
			NAVsrc = 1;
		}
		else {
			NAVsrc = 0;
		}
		if(NAVmode != "FMS") {
			setprop("autopilot/settings/nav-source", NAVmode~(NAVsrc+1));
		}
	}
}

var pitch_wheel = func(dir) {
        Tmp = int(getprop("autopilot/settings/vertical-speed-fpm")) + (dir * 100);
        Tmp = (Tmp < -8000 ? -8000 : Tmp > 6000 ? 6000 : Tmp);
        setprop("autopilot/settings/vertical-speed-fpm", Tmp);
}

var nav_src_set = func(src){
	NAVmode = src;

	if(src == "FMS") {
		setprop("autopilot/settings/nav-source", src);
	}
	else if(src == "MLS") {
		setprop("autopilot/settings/nav-source", src~(NAVsrc+1));
	}
	else {
		setprop("autopilot/settings/nav-source", src~(NAVsrc+1));
	}
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

	if(NAVmode=="FMS") {
		if(getprop("autopilot/route-manager/active")) Lateral.setValue("LNAV");
	}
	else {
		if(getprop("instrumentation/nav["~NAVsrc~"]/data-is-valid")) {
			if(getprop("instrumentation/nav["~NAVsrc~"]/nav-loc")) {
				Lateral_arm.setValue("LOC");
			}
			else {
				Lateral_arm.setValue("VOR");
			}
			Lateral.setValue("HDG");
		}
	}
}
