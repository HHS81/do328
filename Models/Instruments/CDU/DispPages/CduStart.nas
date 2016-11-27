### Display CduStart ###
### C. LE MOIGNE (clm76) - 2015 ###

var navIdent = func {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		Dsp.page = "NAV IDENT     1/1";
		Dsp.line1l = "DATE";
		Dsp.line2l = getprop("instrumentation/cdu/date");
		Dsp.line3l = "TIME";
		Dsp.line4l = getprop("instrumentation/cdu/time");
		Dsp.line5l = "SW";
		Dsp.line6l = "NZ5.4";
		Dsp.line7l = "< MAINTENANCE";
		Dsp.line1r = "ACTIVE NDB";
		Dsp.line2r = "01 JAN - 31 DEC";
		Dsp.line3r = "";
		Dsp.line4r = "01 JAN - 31 DEC";
		Dsp.line5r = "NDB V4.00";
		Dsp.line6r = "WORLD 2-01";
		Dsp.line7r = "POS INIT >";
		setprop("instrumentation/cdu/nbpage",0);
	cdu.DspSet(Dsp);
}

var posInit = func(my_lat,my_long,dep_airport,dep_rwy) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		Dsp.page = "POSITION INIT    1/1";
		Dsp.line1l = "LAST POS";
		Dsp.line2r = "LOAD";
		Dsp.line3l = "REF WPT";
		Dsp.line4r = "LOAD";
		Dsp.line5l = "GPS 1 POS";
		Dsp.line6r = "LOAD";
		if (getprop("instrumentation/cdu/pos-init") == 1) {		
			Dsp.line2l = my_lat~" "~my_long;
			Dsp.line1r = "(LOADED)";
			Dsp.line2r = "";
			Dsp.line3l = dep_airport ~ "-" ~ dep_rwy ~ "   REF WPT";
			Dsp.line3r = "(LOADED)";
			Dsp.line4r = "";
			Dsp.line4l = "---*--.-  ---*--.-";
			Dsp.line5l = "GPS 1 POS";
			Dsp.line6l = my_lat~" "~my_long;
			Dsp.line5r = "(LOADED)";
			Dsp.line6r = "";
			Dsp.line7r = "FLT PLAN >";
		} else {
				Dsp.line2l = "";
				Dsp.line6l = "";
			  Dsp.line7r = "";
		}
	cdu.DspSet(Dsp);
}

