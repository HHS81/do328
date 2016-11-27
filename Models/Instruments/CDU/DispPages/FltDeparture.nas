### Display FltDeparture ###
### C. LE MOIGNE (clm76) - 2015 ###

var fltDep = func(dep_airport,dep_rwy,display) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
	var xfile = airportinfo(dep_airport).runways;
		cdu.dspPages(xfile,display);		
		var nbPage = getprop("/instrumentation/cdu/nbpage");
		if (size(display) < 12) {var nrPage = substr(display,9,1)}
			else {var nrPage = substr(display,9,2)}
		var displayPage = nrPage+1;
		Dsp.page = "DEPT - RUNWAYS   "~displayPage~" / "~nbPage;;
		if (dep_rwy != "") {Dsp.line7l = "< SIDs"};
		Dsp.line7r = "FLT PLAN >";
		var ind = 0;
		foreach(var key;keys(xfile)) {
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

var fltSids = func(dep_airport,dep_rwy,display) {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
	var DepARPT = procedures.fmsDB.new(dep_airport);
	var xfile = [];		
		append(xfile,"DEFAULT");
		if (DepARPT != nil) {
			var SList = DepARPT.getSIDList(dep_rwy);
			foreach(var SID; SList) {
				append(xfile, SID.wp_name);
			}
		}
		cdu.dspPages(xfile,display);		
		nbPage = getprop("/instrumentation/cdu/nbpage");
		if (size(display) < 12) {var nrPage = substr(display,9,1)}
			else {var nrPage = substr(display,9,2)}
		var displayPage = nrPage+1;
		Dsp.page = "SIDS    "~displayPage~" / "~nbPage;
		Dsp.line7l = "< FLT PLAN";
		var ind = 0;
		foreach(var key;xfile) {;
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
