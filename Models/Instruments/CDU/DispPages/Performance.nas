### Display Performances Data ###
### C. LE MOIGNE (clm76) - 2015 ###

var perfPage_0 = func() {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
			Dsp.page = "PERFORMANCE INIT  1 / 3";
			Dsp.line1l = "";
			Dsp.line2l = "";
			Dsp.line3l = "  ACFT TYPE";
			Dsp.line4l = string.uc(getprop("sim/description"));
			Dsp.line5l = "";
			Dsp.line6l = "";
			Dsp.line7l = "< FLT PLAN";
			Dsp.line1r = "";
			Dsp.line2r = "";
			Dsp.line3r = "TAIL #";
			Dsp.line4r = string.uc(getprop("sim/multiplay/callsign"));
			Dsp.line5r = "";
			Dsp.line6r = "";
			Dsp.line7r = "NEXT PAGE >";
	cdu.DspSet(Dsp);
}

var perfPage_1 = func() {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var ClimbSpeed_kt = sprintf("%.0f",getprop("autopilot/settings/climb-speed-kt"));
		var ClimbSpeed_mc = sprintf("%.2f",getprop("autopilot/settings/climb-speed-kt")*0.0015);
		var DescSpeed_kt = getprop("autopilot/settings/descent-speed-kt");
		var DescSpeed_mc = sprintf("%.2f",getprop("autopilot/settings/descent-speed-kt")*0.0015);
		var CruiseSpeed_kt = getprop("autopilot/settings/cruise-speed-kt");
		var CruiseSpeed_mc = sprintf("%.2f",getprop("autopilot/settings/cruise-speed-mach"));
		var Cruise_alt = getprop("autopilot/settings/asel");
			Dsp.page = "PERFORMANCE INIT  2 / 3";
			Dsp.line1l = " CLIMB";
			Dsp.line2l = ClimbSpeed_kt~" / "~ClimbSpeed_mc;
			Dsp.line3l = " CRUISE";
			Dsp.line4l = CruiseSpeed_kt~" / "~CruiseSpeed_mc;
			Dsp.line5l = " DESCENT";
			Dsp.line6l = DescSpeed_kt~" / "~DescSpeed_mc;
			Dsp.line7l = "< DEP/APP SPD";
			Dsp.line1r = "";
			Dsp.line2r = "";
			Dsp.line3r = "<---------> ALTITUDE >";
			Dsp.line4r = "FL "~Cruise_alt;
			Dsp.line5r = "";
			Dsp.line6r = "";
			Dsp.line7r = "";
	cdu.DspSet(Dsp);
}

var perfPage_2 = func() {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var DepSpeed = getprop("autopilot/settings/dep-speed-kt");
		var Agl = getprop("autopilot/settings/dep-agl-limit-ft");
		var Nm = sprintf("%.1f",getprop("autopilot/settings/dep-limit-nm"));
			Dsp.page = "DEPARTURE SPEED  1 / 1";
			Dsp.line1l = " SPEED LIMIT";
			Dsp.line2l = DepSpeed~"";
			Dsp.line3l = " AGL <-------- LIMIT --------> NM";
			Dsp.line4l = Agl~"";
			Dsp.line5l = "";
			Dsp.line6l = "";
			Dsp.line7l = "< APP SPD";
			Dsp.line1r = "";
			Dsp.line2r = "";
			Dsp.line3r = "";
			Dsp.line4r = Nm~"      ";
			Dsp.line5r = "";
			Dsp.line6r = "";
			Dsp.line7r = "RETURN > ";
	cdu.DspSet(Dsp);
}

var perfPage_3 = func() {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var AppSpeed5 = getprop("autopilot/settings/app5-speed-kt");
		var AppSpeed15 = getprop("autopilot/settings/app15-speed-kt");
		var AppSpeed39 = getprop("autopilot/settings/app35-speed-kt");
			Dsp.page = "APPROACH SPEED  1 / 1";
			Dsp.line1l = " FLAPS 5";
			Dsp.line2l = AppSpeed5~"";
			Dsp.line3l = " FLAPS 15";
			Dsp.line4l = AppSpeed15~"";
			Dsp.line5l = " FLAPS 35";
			Dsp.line6l = AppSpeed39~"";
			Dsp.line7l = "< NEXT PAGE";
			Dsp.line1r = "";
			Dsp.line2r = "";
			Dsp.line3r = "";
			Dsp.line4r = "";
			Dsp.line5r = "";
			Dsp.line6r = "";
			Dsp.line7r = "RETURN > ";
	cdu.DspSet(Dsp);
}

var perfPage_4 = func() {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var Wfuel = sprintf("%3i", math.ceil(getprop("consumables/fuel/total-fuel-lbs")));
		var Wcrew = getprop("sim/weight[0]/weight-lb");
		var Wpass = getprop("sim/weight[1]/weight-lb");
		var Wcarg = getprop("sim/weight[2]/weight-lb");
			Dsp.page = "PERFORMANCE INIT  3 / 3";
			Dsp.line1l = " BOW";
			Dsp.line2l = "21700";
			Dsp.line3l = " FUEL";
			Dsp.line4l = Wfuel;
			Dsp.line5l = " CARGO";
			Dsp.line6l = Wcarg;
			Dsp.line7l = "";
			Dsp.line1r = "PASS/CREW LBS  ";
			Dsp.line2r = int(Wpass/170) + int(Wcrew/170) ~" / 170";
			Dsp.line3r = "PASS WT  ";
			Dsp.line4r = sprintf("%3i",Wpass + Wcrew);
			Dsp.line5r = "GROSS WT  ";
			Dsp.line6r = sprintf("%3i",21700 + Wfuel + Wcrew + Wpass + Wcarg);
			Dsp.line7r = "RETURN >";
	cdu.DspSet(Dsp);
}

