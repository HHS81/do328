### Display Progress pages ###
### C. LE MOIGNE (clm76) - 2015 ###

var progPage_0 = func(dest_airport,marker) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var FuelEstWp = int((getprop("/autopilot/internal/nav-distance")/getprop("/velocities/groundspeed-kt"))*(getprop("/engines/engine[0]/fuel-flow_pph")+getprop("/engines/engine[1]/fuel-flow_pph")));
		var FuelEstDest = int((getprop("/autopilot/route-manager/distance-remaining-nm")/getprop("/velocities/groundspeed-kt"))*(getprop("/engines/engine[0]/fuel-flow_pph")+getprop("/engines/engine[1]/fuel-flow_pph")));
		var ETA = getprop("autopilot/route-manager/wp/eta");
			if (ETA == nil) {ETA = "0:00"}
		var Est_time = getprop("/autopilot/internal/nav-ttw");
			if (Est_time == nil or size(Est_time) > 10) {var ETE = "0:00"}
			else {ETE = substr(Est_time,4)}
		var Nav_type = getprop("/autopilot/internal/nav-type");
		var Nav1_id = getprop("/instrumentation/nav[0]/nav-id");
		var Nav1_freq = getprop("/instrumentation/nav[0]/frequencies/selected-mhz-fmt");
		var Nav2_id = getprop("/instrumentation/nav[1]/nav-id");
		var Nav2_freq = getprop("/instrumentation/nav[1]/frequencies/selected-mhz-fmt");

			Dsp.page = "PROGRESS     1 / 2";
			Dsp.line1l = " TO          DIST";
			Dsp.line2l = marker~sprintf("   %.1f",getprop("/autopilot/internal/nav-distance"));
			Dsp.line3l = "DEST";
			Dsp.line4l = dest_airport~sprintf("     %3i",getprop("autopilot/route-manager/distance-remaining-nm"));		
			if (Nav_type != "") {
				if (Nav_type == "VOR1" or Nav_type == "ADF1" or Nav_type == "FMS1") { 
					Dsp.line5l = "          "~Nav_type~" <--";
				}			
				else {Dsp.line5r = "--> "~Nav_type~"          "}
			}
			Dsp.line6l = "     "~Nav1_id~" "~Nav1_freq;
			Dsp.line7l = "< AIR DATA";
			Dsp.line1r = " ETE         FUEL ";
			Dsp.line2r = ETA~"      "~FuelEstWp;
			Dsp.line3r = ""; 
			Dsp.line4r = ETE~"      "~FuelEstDest;
			Dsp.line6r = Nav2_id~" "~Nav2_freq~"    ";
			Dsp.line7r = "CHK LIST >";
	cdu.DspSet(Dsp);
}

