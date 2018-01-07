# by xcvb85

var Mfd1Instance = {};
var Mfd2Instance = {};
var MfdSoftkeys = [["MAIN 1/2","DISPLAY","RADAR","SYSTEM","FMS","MFD\nFORMAT","RNG"], #0
		["MAIN 2/2","TEST","","MFD\nMAINT","","","RNG"], #1
		["DISPLAY","IF\nYOU","KNOW\nTHIS","CONTENT\nPLEASE","LET\nME","KNOW","RNG"], #2
		["RADAR","STBY\nTEST","WX\nGMAP","SECTOR","TGT\n","RADAR\nSUB","RNG"], #3
		["SYSTEM 1/3","FLIGHT\nCONTROL","HYDR","ENGINE","FUEL","NEXT",""], #4
		["SYSTEM 2/3","ELECTR","ECS","ICE\nPROTECT","APU","NEXT",""], #5
		["SYSTEM 3/3","CPCS/\nOXYGEN","DOORS","SYS\nMAINT","SENSOR\nDATA","NEXT",""], #6
		["FMS","WAYPNT\nIDENT","NAVAID\nAIRPRT","","","CURSOR","RNG"], #7
		["MFD FORMAT","IF\nYOU","KNOW\nTHIS","CONTENT\nPLEASE","LET\nME","KNOW","RNG"], #8
		["TEST","RAD ALT","ATC\nEICAS","TCAS","EFIS\nEICAS","EGPWS","RNG"], #9
		["MAINT","TREND","EXCEED","FAULT","GNDMNT","",""], #10
		["RADAR SUB","GAIN\nPRE VAR","RNG","TILT","RCT","","RNG"]]; #11
var Range=[0,0];
var TestActive=0;
var mfdListener=0;

var MFD = {
	new: func(group, instance)
	{
		var m = { parents: [MFD],
			Pages:{},
			SkInstance:{},
			SoftkeyFrames: [0,0,0,0,0],
			WxGmap: props.globals.initNode("/instrumentation/efis/wxGmap" ~ instance, 0, "BOOL"),
			Sector: props.globals.initNode("/instrumentation/efis/sector" ~ instance, 0, "BOOL"),
			TGT: props.globals.initNode("/instrumentation/efis/tgt" ~ instance, 0, "BOOL"),
			WptIdent: props.globals.initNode("/instrumentation/efis/wptIdent" ~ instance, 0, "BOOL"),
			Navaid: props.globals.initNode("/instrumentation/efis/navaid" ~ instance, 0, "BOOL"),
			};

		m.ActiveSoftkeys = 0; # indicates which page (softkeys) is shown
		m.SelectedSkPage = 0; # indicates which softkey gets a frame (page)
		m.SelectedSk = -1; # indicates which softkey gets a frame (softkey number)
		m.KnobMode = 1; # knob can have different functionalities

		m.Pages[0] = canvas_nd.new(group.createChild('group'));
		m.Pages[1] = canvas_flightctrl.new(group.createChild('group'));
		m.Pages[2] = canvas_hydr.new(group.createChild('group'));
		m.Pages[3] = canvas_engine.new(group.createChild('group'));
		m.Pages[4] = canvas_fuel.new(group.createChild('group'));

		m.Pages[5] = canvas_electr.new(group.createChild('group'));
		m.Pages[6] = canvas_ecs.new(group.createChild('group'));
		m.Pages[7] = canvas_ice.new(group.createChild('group'));
		m.Pages[8] = canvas_apu.new(group.createChild('group'));

		m.Pages[9] = canvas_cpcs.new(group.createChild('group'));
		m.Pages[10] = canvas_doors.new(group.createChild('group'));
		m.Pages[11] = canvas_maint.new(group.createChild('group'));

		m.Pages[12] = canvas_exceedance.new(group.createChild('group'));

		m.SkInstance = canvas_softkeys.new(group.createChild('group'));
		m.SkInstance.setSoftkeys(MfdSoftkeys[0]);

		m.i = 0;
		m.Instance = instance;
		m.ActivatePage(0);
		return m;
	},
	ActivatePage: func(input = -1)
	{
		for(me.i=0; me.i<size(me.Pages); me.i+=1) {
			if(me.i == input) {
				me.Pages[me.i].show();
			}
			else {
				me.Pages[me.i].hide();
			}
		}
	},
	# input: 0=back, 1=sk1...5=sk5
	BtClick: func(input = -1) {
		me.KnobMode = 1; # RNG active

		if(!getprop("systems/electrical/outputs/EFIS")) {
			return;
		}
		if(input == 0) {
			# back button pressed
			# go back to main menu
			if(me.ActiveSoftkeys == 0) {
				me.SkInstance.setSoftkeys(MfdSoftkeys[1]);
				me.ActiveSoftkeys = 1;
			}
			else if(me.ActiveSoftkeys == 11){
				# activate "RADAR"
				me.SkInstance.setSoftkeys(MfdSoftkeys[3]);
				me.SoftkeyFrames = [0,me.WxGmap.getValue(),me.Sector.getValue(),me.TGT.getValue(),0];
				me.SkInstance.drawFrames(me.SoftkeyFrames);
				me.SelectedSk = -1; #deactivate autoframes
				me.ActiveSoftkeys = 3;
			}
			else {
				me.SkInstance.setSoftkeys(MfdSoftkeys[0]);
				me.ActiveSoftkeys = 0;
			}
			me.ActivatePage(0);
			me.SelectedSkPage = 0;
			me.SelectedSk = -1;
		}
		else {
			# softkey pressed
			if(me.ActiveSoftkeys == 0) {
				# MAIN 1/2 menu
				if(input == 1) {
					# activate "DISPLAY"
					me.SkInstance.setSoftkeys(MfdSoftkeys[2]);
					me.ActiveSoftkeys = 2;
				}
				else if(input == 2) {
					# activate "RADAR"
					me.SkInstance.setSoftkeys(MfdSoftkeys[3]);
					me.SoftkeyFrames = [0,me.WxGmap.getValue(),me.Sector.getValue(),me.TGT.getValue(),0];
					me.SkInstance.drawFrames(me.SoftkeyFrames);
					me.SelectedSk = -1; #deactivate autoframes
					me.ActiveSoftkeys = 3;
				}
				else if(input == 3) {
					# activate "SYSTEM"
					me.KnobMode = 0; # RNG inactive
					me.SkInstance.setSoftkeys(MfdSoftkeys[4]);
					me.ActiveSoftkeys = 4;
				}
				else if(input == 4) {
					# activate "FMS"
					me.SkInstance.setSoftkeys(MfdSoftkeys[7]);
					me.SoftkeyFrames = [me.WptIdent.getValue(),me.Navaid.getValue(),0,0,0];
					me.SkInstance.drawFrames(me.SoftkeyFrames);
					me.SelectedSk = -1; #deactivate autoframes
					me.ActiveSoftkeys = 7;
				}
				else if(input == 5) {
					# activate "MFD\nFORMAT"
					me.SkInstance.setSoftkeys(MfdSoftkeys[8]);
					me.ActiveSoftkeys = 8;
				}
			}
			else if(me.ActiveSoftkeys == 1) {
				# MAIN 2/2 menu
				if(input == 1) {
					# activate "TEST"
					me.SkInstance.setSoftkeys(MfdSoftkeys[9]);
					me.ActiveSoftkeys = 9;
				}
				else if(input == 3) {
					# activate "MFD MAINT"
					me.KnobMode = 0; # RNG inactive
					me.SkInstance.setSoftkeys(MfdSoftkeys[10]);
					me.ActiveSoftkeys = 10;
				}
			}
			else if(me.ActiveSoftkeys == 3) {
				# RADAR menu
				# WX GMAP: show weather on map
				# SECTOR: refresh rate / quality
				# TGT: warning if dangerous weather outside of selected range

				me.SoftkeyFrames = [0,me.WxGmap.getValue(),me.Sector.getValue(),me.TGT.getValue(),0];
				me.SelectedSk = -1; #deactivate autoframes

				if(input == 2) {
					# activate "WX GMAP"
					if(me.SoftkeyFrames[1]) {
						me.SoftkeyFrames[1] = 0;
						me.WxGmap.setValue(0);
						me.SoftkeyFrames[2] = 0;
						me.Sector.setValue(0);
						me.SoftkeyFrames[3] = 0;
						me.TGT.setValue(0);
					}
					else {
						me.SoftkeyFrames[1] = 1;
						me.WxGmap.setValue(1);
					}
				}
				else if(input == 3) {
					# activate "SECTOR"
					if(me.SoftkeyFrames[2]) {
						me.SoftkeyFrames[2] = 0;
						me.Sector.setValue(0);
					}
					else if(me.SoftkeyFrames[1]) {
						me.SoftkeyFrames[2] = 1;
						me.Sector.setValue(1);
					}
				}
				else if(input == 4) {
					# activate "TGT"
					if(me.SoftkeyFrames[3]) {
						me.SoftkeyFrames[3] = 0;
						me.TGT.setValue(0);
					}
					else if(me.SoftkeyFrames[1]) {
						me.SoftkeyFrames[3] = 1;
						me.TGT.setValue(1);
					}
				}
				else if(input == 5) {
					# activate "RADAR SUB"
					MfdSoftkeys[11][6]="RNG";
					me.SkInstance.setSoftkeys(MfdSoftkeys[11]);
					me.ActiveSoftkeys = 11;

					# needed for frames
					me.SelectedSkPage = 11;
					me.SelectedSk = 1;
				}
				me.SkInstance.drawFrames(me.SoftkeyFrames);
			}
			else if(me.ActiveSoftkeys == 4) {
				me.KnobMode = 0; # RNG inactive

				# "SYSTEM 1/3" page
				if(input == 1) {
					# activate "FLIGHT CONTROL" page
					me.ActivatePage(1);
					me.SelectedSkPage = 4;
					me.SelectedSk = 0;
				}
				else if(input == 2) {
					# activate "HYDR" page
					me.ActivatePage(2);
					me.SelectedSkPage = 4;
					me.SelectedSk = 1;
				}
				else if(input == 3) {
					# activate "ENGINE" page
					me.ActivatePage(3);
					me.SelectedSkPage = 4;
					me.SelectedSk = 2;
				}
				else if(input == 4) {
					# activate "FUEL" page
					me.ActivatePage(4);
					me.SelectedSkPage = 4;
					me.SelectedSk = 3;
				}
				else if(input == 5) {
					# activate "SYSTEM 2/3" page
					me.SkInstance.setSoftkeys(MfdSoftkeys[5]);
					me.ActiveSoftkeys = 5;
				}
			}
			else if(me.ActiveSoftkeys == 5) {
				me.KnobMode = 0; # RNG inactive

				# "SYSTEM 2/3" page
				if(input == 1) {
					# activate "ELECTR" page
					me.ActivatePage(5);
					me.SelectedSkPage = 5;
					me.SelectedSk = 0;
				}
				else if(input == 2) {
					# activate "ECS" page
					me.ActivatePage(6);
					me.SelectedSkPage = 5;
					me.SelectedSk = 1;
				}
				else if(input == 3) {
					# activate "ICE" page
					me.ActivatePage(7);
					me.SelectedSkPage = 5;
					me.SelectedSk = 2;
				}
				else if(input == 4) {
					# activate "APU" page
					me.ActivatePage(8);
					me.SelectedSkPage = 5;
					me.SelectedSk = 3;
				}
				else if(input == 5) {
					# activate "SYSTEM 3/3" page
					me.SkInstance.setSoftkeys(MfdSoftkeys[6]);
					me.ActiveSoftkeys = 6;
				}
			}
			else if(me.ActiveSoftkeys == 6) {
				me.KnobMode = 0; # RNG inactive

				# "SYSTEM 3/3" page
				if(input == 1) {
					# activate "CPCS" page
					me.ActivatePage(9);
					me.SelectedSkPage = 6;
					me.SelectedSk = 0;
				}
				else if(input == 2) {
					# activate "DOORS" page
					me.ActivatePage(10);
					me.SelectedSkPage = 6;
					me.SelectedSk = 1;
				}
				else if(input == 3) {
					# activate "MAINT" page
					me.ActivatePage(11);
					me.SelectedSkPage = 6;
					me.SelectedSk = 2;
				}
				else if(input == 5) {
					# activate "SYSTEM 1/3" page
					me.SkInstance.setSoftkeys(MfdSoftkeys[4]);
					me.ActiveSoftkeys = 4;
				}
			}
			else if(me.ActiveSoftkeys == 7) {
				# FMS menu

				me.SoftkeyFrames = [me.WptIdent.getValue(),me.Navaid.getValue(),0,0,0];
				me.SelectedSk = -1; #deactivate autoframes

				if(input == 1) {
					# activate "WAYPNT IDENT"
					if(me.SoftkeyFrames[0]) {
						me.SoftkeyFrames[0] = 0;
						me.WptIdent.setValue(0);
					}
					else {
						me.SoftkeyFrames[0] = 1;
						me.WptIdent.setValue(1);
					}
				}
				else if(input == 2) {
					# activate "NAVAID AIRPRT"
					if(me.SoftkeyFrames[1]) {
						me.SoftkeyFrames[1] = 0;
						me.Navaid.setValue(0);
					}
					else {
						me.SoftkeyFrames[1] = 1;
						me.Navaid.setValue(1);
					}
				}
				me.SkInstance.drawFrames(me.SoftkeyFrames);
			}
			else if(me.ActiveSoftkeys == 9) {
				# "TEST" page
				if(input == 1) {
					# activate "RAD ALT" test
					me.SelectedSkPage = 9;
					me.SelectedSk = 0;

					# use listener to remove frame if button released
					mfdListener = setlistener("instrumentation/efis/mfd" ~(me.Instance+1)~ "btn1", func () {
						# sometimes called multiple times
						if(!getprop("instrumentation/efis/mfd" ~(me.Instance+1)~ "btn1")) {
							me.SelectedSk = -1;
							me.SkInstance.drawFrames([0,0,0,0,0]);
							removelistener(mfdListener);
						}
					});
				}
				else if(input == 2) {
					# activate "ATC EICAS" test
					me.SelectedSkPage = 9;
					me.SelectedSk = 1;

					setprop("instrumentation/mk-viii/inputs/discretes/beep", 1);
					TestActive=1;

					# use listener to remove frame if button released
					settimer(func () {
						me.SelectedSk = -1;
						me.SkInstance.drawFrames([0,0,0,0,0]);
						setprop("instrumentation/mk-viii/inputs/discretes/beep", 0);
						TestActive=0;
					}, 3);
				}
				else if(input == 3) {
					# activate "TCAS" test
					me.SelectedSkPage = 9;
					me.SelectedSk = 2;

					setprop("instrumentation/efis/tcas", 1);
					TestActive=1;

					# use listener to remove frame if button released
					settimer(func () {
						me.SelectedSk = -1;
						me.SkInstance.drawFrames([0,0,0,0,0]);
						setprop("instrumentation/efis/tcas", 0);
						TestActive=0;
					}, 2);
				}
				else if(input == 4) {
					# activate "EFIS EICAS" test
					me.SelectedSkPage = 9;
					me.SelectedSk = 3;

					# use listener to remove frame if button released
					mfdListener = setlistener("instrumentation/efis/mfd" ~(me.Instance+1)~ "btn4", func () {
						# sometimes called multiple times
						if(!getprop("instrumentation/efis/mfd" ~(me.Instance+1)~ "btn4")) {
							me.SelectedSk = -1;
							me.SkInstance.drawFrames([0,0,0,0,0]);
							removelistener(mfdListener);
						}
					});
				}
				else if(input == 5) {
					# activate "EGPWS" test
					me.SelectedSkPage = 9;
					me.SelectedSk = 4;

					setprop("instrumentation/mk-viii/inputs/discretes/self-test", 1);
					TestActive=1;

					# use timer to release button after long time
					settimer(func () {
						setprop("instrumentation/mk-viii/inputs/discretes/self-test", 0);
					}, 15);

					# use timer to remove frames after end of play
					settimer(func () {
						me.SelectedSk = -1;
						me.SkInstance.drawFrames([0,0,0,0,0]);
						TestActive=0;
					}, 30);
				}
			}
			else if(me.ActiveSoftkeys == 10) {
				me.KnobMode = 0; # RNG inactive

				# "MFD MAINT" page
				if(input == 2) {
					# activate "EXCEEDANCE" page
					me.ActivatePage(12);
					me.SelectedSkPage = 10;
					me.SelectedSk = 1;
				}
			}
			else if(me.ActiveSoftkeys == 11) {
				# RADAR SUB menu
				# GAIN: preset = fixed color scaling
				#       variable = scale colors to current weather
				# RNG:  range of map
				# TILT: tilt angle (range of vertical scanning)
				# RCT:  rain compensation (does only work in preset gain mode)
				if(input == 2) {
					# activate "RNG"
					MfdSoftkeys[11][6]="RNG";
					me.SkInstance.setSoftkeys(MfdSoftkeys[11]);
					me.SelectedSk = 1;
				}
				else if(input == 3) {
					# activate "TILT"
					me.KnobMode = 0; # RNG inactive
					MfdSoftkeys[11][6]="TILT";
					me.SkInstance.setSoftkeys(MfdSoftkeys[11]);
					me.SelectedSk = 2;
				}
				else if(input == 4) {
					# activate "RCT"
					me.KnobMode = 0; # RNG inactive
					MfdSoftkeys[11][6]="RCT";
					me.SkInstance.setSoftkeys(MfdSoftkeys[11]);
					me.SelectedSk = 3;
				}
			}
		}

		# check if you selected the page where the selected softkey is located
		if(me.ActiveSoftkeys == me.SelectedSkPage and me.ActiveSoftkeys > 0) {
			if(me.SelectedSk >= 0) {
				me.SoftkeyFrames = [0,0,0,0,0];
				me.SoftkeyFrames[me.SelectedSk] = 1;
				me.SkInstance.drawFrames(me.SoftkeyFrames);
			}
		}
	},
	GetKnobMode: func()
	{
		return me.KnobMode;
	}
};

var mfd1BtClick = func(input = -1) {
	Mfd1Instance.BtClick(input);
}

var mfd2BtClick = func(input = -1) {
	Mfd2Instance.BtClick(input);
}

var mfd1Knob = func(input = 0) {
	if(Mfd1Instance.GetKnobMode()) {
		Range[0] += input;
		if(Range[0] > 5) Range[0]=5;
		if(Range[0] < 0) Range[0]=0;
	}
}

var mfd2Knob = func(input = 0) {
	if(Mfd2Instance.GetKnobMode()) {
		Range[1] += input;
		if(Range[1] > 5) Range[1]=5;
		if(Range[1] < 0) Range[1]=0;
	}
}

mfdListener = setlistener("/sim/signals/fdm-initialized", func () {

	var mfd1Canvas = canvas.new({
		"name": "MFD1",
		"size": [1024, 1024],
		"view": [800, 950],
		"mipmapping": 1
	});
	mfd1Canvas.addPlacement({"node": "MFD1_Screen"});
	Mfd1Instance = MFD.new(mfd1Canvas.createGroup(), 0);

	var mfd2Canvas = canvas.new({
		"name": "MFD2",
		"size": [1024, 1024],
		"view": [800, 950],
		"mipmapping": 1
	});
	mfd2Canvas.addPlacement({"node": "MFD2_Screen"});
	Mfd2Instance = MFD.new(mfd2Canvas.createGroup(), 1);

	removelistener(mfdListener);
});
