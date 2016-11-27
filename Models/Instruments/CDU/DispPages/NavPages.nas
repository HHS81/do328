### Display Nav Pages ###
### C. LE MOIGNE (clm76) - 2015 ###

var navPage_0 = func {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:""};
			Dsp.page = "NAV INDEX     1 / 2";
			Dsp.line1l = "< FPL LIST";
			Dsp.line2l = "";
			Dsp.line3l = "< WPT LIST";
			Dsp.line4l = "";
			Dsp.line5l = "< DEPARTURE";
			Dsp.line6l = "";
			Dsp.line7l = "< NEXT PAGE";
			Dsp.line1r = "FPL SEL >";
			Dsp.line2r = "";
			Dsp.line3r = "DATA BASE >";
			Dsp.line4r = "";
			Dsp.line5r = "ARRIVAL >";
			Dsp.line6r = "";
			Dsp.line7r = "NEXT PAGE >";
	cdu.DspSet(Dsp);
}

var navPage_1 = func {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:""};
			Dsp.page = "NAV INDEX     2 / 2";
			Dsp.line1l = "< CONVERSION";
			Dsp.line2l = "";
			Dsp.line3l = "< IDENT";
			Dsp.line4l = "          IN PROGRESS";
			Dsp.line5l = "< POS INIT";
			Dsp.line6l = "";
			Dsp.line7l = "< PREV PAGE";
			Dsp.line1r = "PATTERNS >";
			Dsp.line2r = "";
			Dsp.line3r = "MAINTENANCE >";
			Dsp.line4r = "";
			Dsp.line5r = "CROSS PTS >";
			Dsp.line6r = "";
			Dsp.line7r = "PREV PAGE >";
	cdu.DspSet(Dsp);
}

var navList = func {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:""};
	displaypages.fltList_search(Dsp);		
	Dsp.line7r = "FPL SEL >";
	cdu.DspSet(Dsp);
}

var navSel_0 = func {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:""};
	var flp = getprop("instrumentation/cdu/input");
			Dsp.page = "FLIGHT PLAN LIST     1 / 1";
			Dsp.line1l = " SHOW FPL";
			Dsp.line2l = "----------";
			Dsp.line1r = "ORG / DEST ";
			if (flp != "") {Dsp.line2r = left(flp,4)~" / "~substr(flp,5,4)}
			Dsp.line7r = "FPL SEL >";
	cdu.DspSet(Dsp);
}

var navSel_1 = func (navSel,navWp,navRwy,g_speed,dist,flp_closed) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:""};
	var ete_h = int(dist/g_speed);
	var ete_mn = int((dist/g_speed-ete_h)*60);
			Dsp.page = "     "~navSel~"   1 / 1";
			Dsp.line1l = " ORGIN        DIST / ETE";
			Dsp.line2l = navWp.vector[0]~" "~navRwy.vector[0]~"   "~sprintf("%.0f",dist)~" / "~sprintf("%02d",ete_h)~" + "~sprintf("%02d",ete_mn);
			Dsp.line3l = " VIA TO";
				for (var i=1;i<size(navWp.vector)-1;i+=1) {
					if (i <4) {
						Dsp.line4l = Dsp.line4l~navWp.vector[i]~" + ";
					} else if (i>=4 and i<8) {
						Dsp.line5l = Dsp.line5l~navWp.vector[i]~" + ";
					}
				}
				if (flp_closed) {
					if (i<4) {
						Dsp.line4l = Dsp.line4l~navWp.vector[size(navWp.vector)-1];
					}
					if (i>=4 and i<8) {
						Dsp.line5l = Dsp.line5l~navWp.vector[size(navWp.vector)-1];
					}
					Dsp.line6l = "     SAVE FLP TO";
					if (size(navSel) == 9 ){Dsp.line6r = navSel~"--"}
					if (size(navSel) == 10 ){Dsp.line6r = navSel~"-"}
					if (size(navSel) >= 11 ){Dsp.line6r = left(navSel,11)}					
				}
			if (Dsp.line4l == "") {Dsp.line4l = "----"}
			Dsp.line1r = "GS ";
			Dsp.line2r = " @  "~g_speed;
			Dsp.line3r = "DEST ";
			Dsp.line4r = navWp.vector[size(navWp.vector)-1]~" "~navRwy.vector[1];
			Dsp.line7l = "< FPL LIST";
	cdu.DspSet(Dsp);
}

var navPage_Dept = func(dep_airport,dep_rwy,my_lat,my_long) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:""};
			Dsp.page = "DEPARTURE   1 / 1";
			Dsp.line1l = "WAYPOINT";
			Dsp.line2l = dep_airport;
			Dsp.line3l = "NAME";
			Dsp.line4l = string.uc(getprop("autopilot/route-manager/departure/name"));
			Dsp.line5l = "LAT - LON";
			Dsp.line6l = my_lat~" - "~my_long;
			Dsp.line7l = "< SIDS";
			Dsp.line1r = "TYPE";
			Dsp.line2r = "AIRPORT";
			Dsp.line3r = "";
			Dsp.line4r = "";
			Dsp.line5r = "RUNWAY";
			Dsp.line6r = dep_rwy;
			Dsp.line7r = "";
	cdu.DspSet(Dsp);
}

var navPage_Dest = func(dest_airport,dest_rwy,my_lat,my_long) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:""};
			Dsp.page = "DESTINATION   1 / 1";
			Dsp.line1l = "WAYPOINT";
			Dsp.line2l = dest_airport;
			Dsp.line3l = "NAME";
			Dsp.line4l = string.uc(getprop("autopilot/route-manager/destination/name"));
			Dsp.line5l = "LAT - LON";
			Dsp.line6l = my_lat~" - "~my_long;
			Dsp.line7l = "< STARS";
			Dsp.line1r = "TYPE";
			Dsp.line2r = "AIRPORT";
			Dsp.line3r = "";
			Dsp.line4r = "";
			Dsp.line5r = "RUNWAY";
			Dsp.line6r = dest_rwy;
			Dsp.line7r = "APPROACH >";
	cdu.DspSet(Dsp);
}

