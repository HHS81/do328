### Display CduStart ###
### C. LE MOIGNE (clm76) - 2015 ###


var fltList_search = func(Dsp){
	var display = getprop("/instrumentation/cdu/display");
	var savePath = getprop("/sim/fg-home")~"/aircraft-data/FlightPlans/";
	var xfile = subvec(directory(savePath),2);
	var p = 0;
	var displayPage = 0;
	var nbPage = getprop("/instrumentation/cdu/nbpage");

	cdu.dspPages(xfile,display);				
		if (size(display) < 12) {var nrPage = substr(display,9,1)}
		else {var nrPage = substr(display,9,2)}	
	var displayPage = nrPage + 1;
	var nbFiles = size(xfile);
	if (nbFiles == 0) {
		setprop("instrumentation/cdu/input","*NO FILE*");		
		displayPage = 0;
	}
	Dsp.page = "FLIGHT PLAN LIST   "~displayPage~" / "~nbPage;			
		forindex(ind;xfile) {		
			if (left(xfile[ind],4) == getprop("autopilot/route-manager/departure/airport")) {
				var n = p-(6*nrPage);	
				if(n==0) {Dsp.line2l = left(xfile[ind],size(xfile[ind])-4)};
				if(n==1) {Dsp.line4l = left(xfile[ind],size(xfile[ind])-4)};
				if(n==2) {Dsp.line6l = left(xfile[ind],size(xfile[ind])-4)};
				if(n==3) {Dsp.line2r = left(xfile[ind],size(xfile[ind])-4)};
				if(n==4) {Dsp.line4r = left(xfile[ind],size(xfile[ind])-4)};
				if(n==5) {Dsp.line6r = left(xfile[ind],size(xfile[ind])-4)};
				p+=1;
			}
		}
}

var fltList = func {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
	fltList_search(Dsp);
	Dsp.line7l = "< FLT PLAN";
	cdu.DspSet(Dsp);
}
