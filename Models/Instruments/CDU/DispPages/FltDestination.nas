### Display FltDestination ###
### C. LE MOIGNE (clm76) - 2015 ###

var fltArrv = func(dest_airport) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
	page = "ARRIVAL     1 / 1";
	Dsp.line1l = "< RUNWAY";
	Dsp.line3l = "< STAR";
	Dsp.line5l = "< APPROACH";
	Dsp.line7l = "< FLT-PLAN";
	Dsp.line1r = "AIRPORT ";
	Dsp.line2r = dest_airport;
	Dsp.line7r = "LANDING >";
	cdu.DspSet(Dsp);
}

var fltArwy = func(dest_airport,display) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var xfile = airportinfo(dest_airport).runways;
		cdu.dspPages(xfile,display);
		nbPage = getprop("/instrumentation/cdu/nbpage");
		if (size(display) < 12) {var nrPage = substr(display,9,1)}
			else {var nrPage = substr(display,9,2)}
		var displayPage = nrPage+1;
		Dsp.page = dest_airport~" RUNWAYS "~displayPage~" / "~nbPage;
		Dsp.line7l = "< ARRIVAL";
		Dsp.line7r = "";
		var ind = 0;
		foreach(var key;keys(xfile)) {;
			if (key != "") {
				var n = ind-(6*nrPage);		
				if (n==0) {Dsp.line2l = key};
				if (n==1) {Dsp.line4l = key};
				if (n==2) {Dsp.line6l = key};
				if (n==3) {Dsp.line2r = key};
				if (n==4) {Dsp.line4r = key};
				if (n==5) {Dsp.line6r = key};
				ind+=1;	
			}	
		}
	cdu.DspSet(Dsp);
}

var fltStars = func(dest_airport,dest_rwy,display) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var xfile = [];
		var DestARPT = procedures.fmsDB.new(dest_airport);
		if (DestARPT !=nil) {
			if (dest_rwy != "") {		
				var STARlist = DestARPT.getSTARList(dest_rwy);
			} else {
					var STARlist = DestARPT.getAllSTARList();
			}		
			foreach(var STAR; STARlist) {
				append(xfile, STAR.wp_name);
			}
		}
		cdu.dspPages(xfile,display);
		nbPage = getprop("/instrumentation/cdu/nbpage");
		if (size(display) < 12) {var nrPage = substr(display,9,1)}
			else {var nrPage = substr(display,9,2)}
		Dsp.page = dest_airport~" STAR "~(nrPage+1)~" / "~nbPage;
		Dsp.line7l = "< ARRIVAL";
		Dsp.line7r = "RUNWAY >";
		var ind = 0;
		foreach(var key;xfile) {
			if (key != "") {
				var n = ind-(6*nrPage);		
				if (n==0) {Dsp.line2l = key};
				if (n==1) {Dsp.line4l = key};
				if (n==2) {Dsp.line6l = key};
				if (n==3) {Dsp.line2r = key};
				if (n==4) {Dsp.line4r = key};
				if (n==5) {Dsp.line6r = key};
				ind+=1;	
			}	
		}
	cdu.DspSet(Dsp);
}

var fltAppr = func(dest_airport,dest_rwy,display) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
		var DestARPT = procedures.fmsDB.new(dest_airport);
		var xfile = [];
		append(xfile,"DEFAULT");
		if (DestARPT !=nil) {
			if (dest_rwy != "") {		
				var Applist = DestARPT.getApproachList(dest_rwy);
			} else {
				var Applist = DestARPT.getAllApproachList();
			}		
			foreach(var APPR; Applist) {
				append(xfile, APPR.wp_name);
			}
		}
		cdu.dspPages(xfile,display);				
		nbPage = getprop("/instrumentation/cdu/nbpage");
		if (size(display) < 12) {var nrPage = substr(display,9,1)}
			else {var nrPage = substr(display,9,2)}
		Dsp.page = dest_airport~" APPROACH "~(nrPage+1)~" / "~nbPage;
		Dsp.line7l = "< ARRIVAL";
		Dsp.line7r = "RUNWAY >";
		var ind = 0;
		foreach(var key;xfile) {
			if (key != "") {
				var n = ind-(6*nrPage);		
				if (n==0) {Dsp.line2l = key};
				if (n==1) {Dsp.line4l = key};
				if (n==2) {Dsp.line6l = key};
				if (n==3) {Dsp.line2r = key};
				if (n==4) {Dsp.line4r = key};
				if (n==5) {Dsp.line6r = key};
			ind+=1;	
			}	
		}
	cdu.DspSet(Dsp);
}

