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

var NAVsrc = 0; # 0: CPT, 1: FO
var NAVmode = "NAV"; # 0: NAV, MLS (not in use) or FMS
var Tmp = 0;

var FDBtClick = func(btn) {
	if(btn == "AP") {
		if(!AP.getValue()) {
			Lateral_arm.setValue("");
			Vertical_arm.setValue("");

			AP.setValue(1);
		}
		else {
			AP.setValue(0);
		}
	}
	elsif(btn == "HDG") {
		if(Lateral.getValue() != "HDG") {
			Lateral.setValue("HDG");
		}
		else {
			Lateral.setValue("ROLL");
			setprop("autopilot/settings/target-roll-deg", 0.0);
		}
		Lateral_arm.setValue("");
		Vertical_arm.setValue("");
	}
	elsif(btn == "ALT") {
		if(Vertical.getValue() != "ALT") {
			Vertical.setValue("ALT");
			setprop("autopilot/settings/altitude",
				(getprop("instrumentation/altimeter/mode-c-alt-ft") * 0.01));
		}
		else {
			Vertical.setValue("PTCH");
			setprop("autopilot/settings/target-pitch-deg", getprop("orientation/pitch-deg"));
		}
		Lateral_arm.setValue("");
		Vertical_arm.setValue("");
	}
	elsif(btn == "FLCH") {
		var flcmode = "FLCH";
		var asel = "ASEL";

		if(NAVmode == "FMS") {
			flcmode = "VFLC";
			asel = "VASEL";
		}

		if(Vertical.getValue() != flcmode) {
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
			Vertical.setValue("PTCH");
			setprop("autopilot/settings/target-pitch-deg", getprop("orientation/pitch-deg"));
		}
	}
	elsif(btn == "NAV") {
		set_nav_mode();
		setprop("autopilot/settings/low-bank",0);
	}
	elsif(btn == "VNAV") {
		if(Vertical.getValue()!="VALT") {
			if(NAVmode=="FMS") {
				Lateral.setValue("LNAV");
				Vertical.setValue("VALT");
			}
		}
		else {
			Vertical.setValue("PTCH");
			setprop("autopilot/settings/target-pitch-deg", getprop("orientation/pitch-deg"));
		}
	}
	elsif(btn == "APP") {
		if(NAVmode == "NAV") {
			if(!getprop("instrumentation/nav["~NAVsrc~"]/gs-in-range")) {
				# no ILS at all -> STBY
				Lateral_arm.setValue("");
				Vertical_arm.setValue("");
				Lateral.setValue("HDG");
				Vertical.setValue("PTCH");
				setprop("autopilot/settings/target-pitch-deg", 3.0);
			}
			else if(getprop("instrumentation/nav["~NAVsrc~"]/nav-loc") and
				getprop("instrumentation/nav["~NAVsrc~"]/has-gs")) {
				# activate ILS catch settings
				Lateral_arm.setValue("LOC");
				Vertical_arm.setValue("GS");
				Lateral.setValue("HDG");
				Vertical.setValue("GS");
			}
		}
		setprop("autopilot/settings/low-bank", 0);
	}
	elsif(btn == "VS") {
		Lateral_arm.setValue("");
		Vertical_arm.setValue("");
		if(Vertical.getValue()!="VS"){
			Vertical.setValue("VS");
			Tmp = (int(getprop("autopilot/internal/vert-speed-fpm") * 0.01)) * 100;
			setprop("autopilot/settings/vertical-speed-fpm", Tmp);
		}
		else {
			Vertical.setValue("PTCH");
			setprop("autopilot/settings/target-pitch-deg", getprop("orientation/pitch-deg"));
		}
	}
	elsif(btn == "STBY") {
		Lateral_arm.setValue("");
		Vertical_arm.setValue("");
		Vertical.setValue("PTCH");
		setprop("autopilot/settings/target-pitch-deg", getprop("orientation/pitch-deg"));
		Lateral.setValue("ROLL");
		setprop("autopilot/settings/target-roll-deg", 0.0);
		setprop("autopilot/settings/low-bank",0);
	}
	elsif(btn == "BANK") {
		if(Lateral.getValue()=="HDG") {
			# TODO: bool instead of 0/1
			Tmp = getprop("autopilot/settings/low-bank") or 0;
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

var NAVBtClick = func(btn) {
	if(btn == "NAV") {
		setprop("autopilot/settings/nav-source", btn~(NAVsrc+1));
	}
	elsif(btn == "MLS") {
		setprop("autopilot/settings/nav-source", btn~(NAVsrc+1));
	}
	elsif(btn == "FMS") {
		setprop("autopilot/settings/nav-source", btn);
	}
}

var pitch_wheel = func(dir) {
        Tmp = int(getprop("autopilot/settings/vertical-speed-fpm")) + (dir * 100);
        Tmp = (Tmp < -8000 ? -8000 : Tmp > 6000 ? 6000 : Tmp);
        setprop("autopilot/settings/vertical-speed-fpm", Tmp);
}

########    FD INTERNAL ACTIONS  #############

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
