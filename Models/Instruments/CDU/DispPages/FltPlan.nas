### Display Flightplan ###
### C. LE MOIGNE (clm76) - 2015 ###


var fltPlan_0 = func(dep_airport,dep_rwy,dest_airport,dest_rwy) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
	var rep = "";
	var path = "autopilot/route-manager/route/wp[";
	var legb = "]/leg-bearing-true-deg";
	var legd = "]/leg-distance-nm";
			Dsp.page = "ACTIVE FLT PLAN     1 / 1";
			Dsp.line1l = " ORIGIN / ETD";
			Dsp.line2l = "----";
			if (dep_airport != "") {
				Dsp.line2l = dep_airport ~" "~ dep_rwy;
			}
			Dsp.line3l = "< LOAD FPL";
			Dsp.line4l = "";
			Dsp.line5l = "     RECALL OR CREATE";
			Dsp.line6l = "       FPL NAMED";
			Dsp.line7l = "< FPL LIST";
			Dsp.line1r = "";
			Dsp.line2r = "";
			Dsp.line3r = "DEST  ";
			Dsp.line4r = "----";
			if (dest_airport != "") {
				Dsp.line4r = dest_airport ~" "~ dest_rwy;
			}
			Dsp.line5r = "";
			Dsp.line6r = "---------";
			Dsp.line7r = "PERF INIT >";
	cdu.DspSet(Dsp);
}

var fltPlan_1 = func(dep_airport,dep_rwy,dest_airport,dest_rwy,num,flt_closed,marker) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
	var rep = "";
	var path = "autopilot/route-manager/route/wp[";
	var legb = "]/leg-bearing-true-deg";
	var legd = "]/leg-distance-nm";
	var spd = 0;
			Dsp.page = "ACTIVE FLT PLAN     1 / 6";
			Dsp.line1l = " ORIGIN / ETD";
			Dsp.line2l = "----";
			Dsp.line3l = " VIA TO";
			Dsp.line4l = "----";
			Dsp.line5l = " VIA TO";
			Dsp.line6l = "----";
			Dsp.line7l = "< DEPARTURE";
			Dsp.line1r = "SPD CMD  ";		
			Dsp.line5r = "DEST ";
			Dsp.line7r = "ARRIVAL >";
			if (dest_airport != "") {
				Dsp.line6r = dest_airport~" "~ dest_rwy;
			}
			if (dep_airport != "") {
				var ind = 0;
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				Dsp.line2l = dep_airport ~" "~ dep_rwy~rep;
			}
			if (num == 2 and flt_closed == 1) {
				var ind = 1;
				Dsp.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				Dsp.line4l = dest_airport~" "~ dest_rwy;
			}	else if (num >2) {
				var ind = 1;
				Dsp.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
					if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
					else {rep=""}
				Dsp.line4l = getprop(path~ind~"]/id")~rep;	
				Dsp.line3r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					Dsp.line3r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				Dsp.line4r = set_Speed(path,ind,spd);
			}
			if (num == 3 and flt_closed == 1) {
				var ind = 2;
				Dsp.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				Dsp.line6l = dest_airport~" "~ dest_rwy;
			} else if (num > 3 or (num == 3 and dest_airport == "")) {
				var ind = 2;
				Dsp.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				Dsp.line6l = getprop(path~ind~"]/id")~rep;
				Dsp.line5r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					Dsp.line5r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				Dsp.line6r = set_Speed(path,ind,spd);
			}
	cdu.DspSet(Dsp);
}

var fltPlan_2 = func(dest_airport,dest_rwy,num,flt_closed,marker) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
	var rep = "";
	var path = "autopilot/route-manager/route/wp[";
	var legb = "]/leg-bearing-true-deg";
	var legd = "]/leg-distance-nm";
	var spd = 0;
			Dsp.page = "ACTIVE FLT PLAN     2 / 6";
			Dsp.line1l = " VIA TO";
			Dsp.line2l = "----";
			Dsp.line3l = " VIA TO";
			Dsp.line4l = "----";
			Dsp.line5l = " VIA TO";
			Dsp.line6l = "----";
			Dsp.line7l = "< DEPARTURE";
			Dsp.line5r = "DEST ";
			Dsp.line6r = dest_airport~" "~ dest_rwy;
			Dsp.line7r = "ARRIVAL >";

			if (num == 4 and flt_closed == 1) {
				var ind = 3;
				Dsp.line1l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				Dsp.line2l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 4 or (num == 4 and dest_airport == "")) {
				var ind = 3;
				Dsp.line1l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				Dsp.line2l = getprop(path~ind~"]/id")~rep;
				Dsp.line1r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					Dsp.line1r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				Dsp.line2r = set_Speed(path,ind,spd);
			}
			if (num == 5 and flt_closed == 1) {
				var ind = 4;
				Dsp.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				Dsp.line4l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 5 or (num == 5 and dest_airport == "")) {
				var ind = 4;
				Dsp.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				Dsp.line4l = getprop(path~ind~"]/id")~rep;
				Dsp.line3r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					Dsp.line3r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				Dsp.line4r = set_Speed(path,ind,spd);
			}
			if (num == 6 and flt_closed == 1) {
				var ind = 5;
				Dsp.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				Dsp.line6l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 6 or (num == 6 and dest_airport == "")) {
				var ind = 5;
				Dsp.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),getprop(path~ind~legd));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				Dsp.line6l = getprop(path~ind~"]/id")~rep;
				Dsp.line5r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					Dsp.line5r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				Dsp.line6r = set_Speed(path,ind,spd);
			}
	cdu.DspSet(Dsp);
}

var fltPlan_3 = func(dest_airport,dest_rwy,num,flt_closed,marker) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
	var rep = "";
	var path = "autopilot/route-manager/route/wp[";
	var legb = "]/leg-bearing-true-deg";
	var legd = "]/leg-distance-nm";
	var spd = 0;
			Dsp.page = "ACTIVE FLT PLAN     3 / 6";
			Dsp.line1l = " VIA TO";
			Dsp.line2l = "----";
			Dsp.line3l = " VIA TO";
			Dsp.line4l = "----";
			Dsp.line5l = " VIA TO";
			Dsp.line6l = "----";
			Dsp.line7l = "< DEPARTURE";
			Dsp.line5r = "DEST ";
			Dsp.line6r = dest_airport~" "~ dest_rwy;
			Dsp.line7r = "ARRIVAL >";
			if (num == 7 and flt_closed == 1) {
				var ind = 6;
				Dsp.line1l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				Dsp.line2l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 7 or (num == 7 and dest_airport == "")) {
				var ind = 6;
				Dsp.line1l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				Dsp.line2l = getprop(path~ind~"]/id")~rep;
				Dsp.line1r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					Dsp.line1r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				Dsp.line2r = set_Speed(path,ind,spd);
			}
			if (num == 8 and flt_closed == 1) {
				var ind = 7;
				Dsp.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				Dsp.line4l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 8 or (num == 8 and dest_airport == "")) {
				var ind = 7;
				Dsp.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				Dsp.line4l = getprop(path~ind~"]/id")~rep;
				Dsp.line3r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					Dsp.line3r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				Dsp.line4r = set_Speed(path,ind,spd);
			}
			if (num == 9 and flt_closed == 1) {
				var ind = 8;
				Dsp.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				Dsp.line6l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 9 or (num == 9 and dest_airport == "")) {
				var ind = 8;
				Dsp.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				Dsp.line6l = getprop(path~ind~"]/id")~rep;
				Dsp.line5r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					Dsp.line5r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				Dsp.line6r = set_Speed(path,ind,spd);
			}
	cdu.DspSet(Dsp);
}

var fltPlan_4 = func(dest_airport,dest_rwy,num,flt_closed,marker) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
	var rep = "";
	var path = "autopilot/route-manager/route/wp[";
	var legb = "]/leg-bearing-true-deg";
	var legd = "]/leg-distance-nm";
	var spd = 0;
			Dsp.page = "ACTIVE FLT PLAN     4 / 6";
			Dsp.line1l = " VIA TO";
			Dsp.line2l = "----";
			Dsp.line3l = " VIA TO";
			Dsp.line4l = "----";
			Dsp.line5l = " VIA TO";
			Dsp.line6l = "----";
			Dsp.line7l = "< DEPARTURE";
			Dsp.line5r = "DEST ";
			Dsp.line6r = dest_airport~" "~ dest_rwy;
			Dsp.line7r = "ARRIVAL >";
			if (num == 10 and flt_closed == 1) {
				var ind = 9;
				Dsp.line1l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				Dsp.line2l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 10 or (num == 10 and dest_airport == "")) {
				var ind = 9;
				Dsp.line1l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				Dsp.line2l = getprop(path~ind~"]/id")~rep;
				Dsp.line1r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					Dsp.line1r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				Dsp.line2r = set_Speed(path,ind,spd);
			}
			if (num == 11 and flt_closed == 1) {
				var ind = 10;
				Dsp.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				Dsp.line4l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 11 or (num == 11 and dest_airport == "")) {
				var ind = 10;
				Dsp.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				Dsp.line4l = getprop(path~ind~"]/id")~rep;
				Dsp.line3r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					Dsp.line3r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				Dsp.line4r = set_Speed(path,ind,spd);
			}
			if (num == 12 and flt_closed == 1) {
				var ind = 11;
				Dsp.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				Dsp.line6l = dest_airport~" "~ dest_rwy;
			}
			else if (num > 12 or (num == 12 and dest_airport == "")) {
				var ind = 11;
				Dsp.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				Dsp.line6l = getprop(path~ind~"]/id")~rep;
				Dsp.line5r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					Dsp.line5r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				Dsp.line6r = set_Speed(path,ind,spd);
				}
	cdu.DspSet(Dsp);
}

var fltPlan_5 = func(dest_airport,dest_rwy,num,flt_closed,marker) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
	var rep = "";
	var path = "autopilot/route-manager/route/wp[";
	var legb = "]/leg-bearing-true-deg";
	var legd = "]/leg-distance-nm";
	var spd = 0;
			Dsp.page = "ACTIVE FLT PLAN     5 / 6";
			Dsp.line1l = " VIA TO";
			Dsp.line2l = "----";
			Dsp.line3l = " VIA TO";
			Dsp.line4l = "----";
			Dsp.line5l = " VIA TO";
			Dsp.line6l = "----";
			Dsp.line7l = "< DEPARTURE";
			Dsp.line5r = "DEST ";
			Dsp.line6r = dest_airport~" "~ dest_rwy;
			Dsp.line7r = "ARRIVAL >";
			if (num == 13 and flt_closed == 1) {
				var ind = 12;
				Dsp.line1l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				Dsp.line2l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 13 or (num == 13 and dest_airport == "")) {
				var ind = 12;
				Dsp.line1l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				Dsp.line2l = getprop(path~ind~"]/id")~rep;
				Dsp.line1r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					Dsp.line1r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				Dsp.line2r = set_Speed(path,ind,spd);
			}
			if (num == 14 and flt_closed == 1) {
				var ind = 13;
				Dsp.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				Dsp.line4l = dest_airport~" "~ dest_rwy;
			}	
			else if (num > 14 or (num == 14 and dest_airport == "")) {
				var ind = 13;
				Dsp.line3l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				Dsp.line4l = getprop(path~ind~"]/id")~rep;
				Dsp.line3r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					Dsp.line3r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				Dsp.line4r = set_Speed(path,ind,spd);
			}
			if (num == 15 and flt_closed == 1) {
				var ind = 14;
				Dsp.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				Dsp.line6l = dest_airport~" "~ dest_rwy;
			}
			else if (num > 15 or (num == 15 and dest_airport == "")) {
				var ind = 14;
				Dsp.line5l = sprintf("   %3i   %.1f",getprop(path~ind~legb),math.ceil(getprop(path~ind~legd)));
				if (getprop(path~ind~"]/id")==marker) {rep="   <--"}
				else {rep=""}
				Dsp.line6l = getprop(path~ind~"]/id")~rep;
				Dsp.line5r = "-----";
				if (getprop(path~ind~"]/altitude-ft") > 0) {
					Dsp.line5r = sprintf("%3i",int(getprop(path~ind~"]/altitude-ft")/100)*100);
				}
				Dsp.line6r = set_Speed(path,ind,spd);
				}
	cdu.DspSet(Dsp);
}

var fltPlan_6 = func(dep_airport,dest_airport,dest_rwy,num,marker) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
	var rep = "";
	var path = "autopilot/route-manager/route/wp[";
	var legb = "]/leg-bearing-true-deg";
	var legd = "]/leg-distance-nm";
	var spd = 0;
		if (num <= 1) {
			var i = 0;
			var j = 0;
		}	
		else {
			var i = num - 1;
			var j = num - 2;
		}
			Dsp.page = "ACTIVE FLT PLAN     6 / 6";
			Dsp.line1l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp["~j~"]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp["~j~"]/leg-distance-nm"));
			Dsp.line2l = getprop("autopilot/route-manager/route/wp["~j~"]/id");
			Dsp.line3l = "   "~sprintf("%3i   %3i",getprop("autopilot/route-manager/route/wp["~i~"]/leg-bearing-true-deg"),getprop("autopilot/route-manager/route/wp["~i~"]/leg-distance-nm"));
			Dsp.line4l = dest_airport~" "~ dest_rwy;
			Dsp.line5l = "";
			Dsp.line6l = "     SAVE FLP TO";
			Dsp.line7l = "< DEPARTURE";
			Dsp.line1r = "";
			Dsp.line2r = set_Speed(path,j,spd);
			Dsp.line3r = "";
			Dsp.line4r = "";
			Dsp.line5r = "";
			Dsp.line6r = dep_airport~"-"~dest_airport~"--";
			if (getprop("autopilot/route-manager/flight-plan")) {
				Dsp.line5r = "SAVED";
				Dsp.line6r = getprop("autopilot/route-manager/flight-plan");
			}
			if (getprop("autopilot/route-manager/active")) {
				Dsp.line7r = "PERF INIT >";
			} else {Dsp.line7r = ""}

	cdu.DspSet(Dsp);
}

var set_Speed = func(path,ind,spd) {
		var search = find("-",getprop(path~ind~"]/id"));
		if (getprop(path~ind~"]/speed")) {
			var speed = path~ind~"]/speed";
			var spd_kt = getprop(speed);
			if (left(spd_kt,2) == "0.") {	## conversion mach -> kt ##
				spd_kt = sprintf("%.0f",int(spd_kt*661.47));
				setprop(speed,spd_kt);
			}
			spd = spd_kt~" / "~ sprintf("%.2f",spd_kt*0.0015);
		} else {
				if (search != -1) {
					var spd_kt = getprop("autopilot/settings/climb-speed-kt");
					spd = spd_kt~" / "~ sprintf("%.2f",spd_kt*0.0015);
				} else {spd = "  /   "}
		}
}
