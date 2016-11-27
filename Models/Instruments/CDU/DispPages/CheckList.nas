### Display CheckList pages ###
### C. LE MOIGNE (clm76) - 2015 ###

var checkList_0 = func {
	var Dsp = {page:"",line1l:"",line2l:"",line3l:"",line4l:"",line5l:"",line6l:"",line7l:"",line8l:"",
		line1r:"",line2r:"",line3r:"",line4r:"",line5r:"",line6r:"",line7r:"",line8r:""};
			Dsp.page = "CHECKLISTS     1 / 2";
			Dsp.line2l = "< START UP";
			Dsp.line4l = "< BEFORE TAXI";
			Dsp.line6l = "< BEFORE TAKE-OFF";
			Dsp.line2r = "TAKE-OFF >";
			Dsp.line4r = "CLIMB OUT >";
			Dsp.line6r = "APPROACH >";
			Dsp.line7r = "NEXT PAGE >";
	cdu.DspSet(Dsp);
}

