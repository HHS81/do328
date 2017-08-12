# by xcvb85

var Mfd1Instance = {};
var Mfd2Instance = {};
var MfdSoftkeys = [["MAIN 1/2","DISPLAY","RADAR","SYSTEM","FMS","MFD\nFORMAT","RNG"], #0
		["SYSTEM 1/3","FLIGHT\nCONTROL","HYDR","ENGINE","FUEL","NEXT",""], #1
		["SYSTEM 2/3","ELECTR","ECS","ICE\nPROTECT","APU","NEXT",""], #2
		["SYSTEM 3/3","CPCS/\nOXYGEN","DOORS","SYS\nMAINT","SENSOR\nDATA","NEXT",""]]; #3

var MFD = {
	new: func(group)
	{
		var m = { parents: [MFD], Pages:{}, SkInstance:{}, i:0 };

		m.ShownSkPage = 0; # indicates which page (softkeys) is shown
		m.SelectedSkPage = 0; # indicates which softkey gets a frame (page)
		m.SelectedSk = -1; # indicates which softkey gets a frame (softkey number)

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

		m.SkInstance = canvas_softkeys.new(group.createChild('group'));
		m.SkInstance.setSoftkeys(MfdSoftkeys[0]);
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

		if(getprop("systems/electrical/outputs/efis") < 1) {
			return;
		}
		if(input == 0) {
			# back button pressed
			# go back to main menu
			me.SkInstance.setSoftkeys(MfdSoftkeys[0]);
			me.ActivatePage(0);
			me.ShownSkPage = 0;
			me.SelectedSkPage = 0;
			me.SelectedSk = -1;
		}
		else {
			# softkey pressed
			if(me.ShownSkPage == 0) {
				# main menu
				if(input == 3) {
					# activate "SYSTEM"
					me.SkInstance.setSoftkeys(MfdSoftkeys[1]);
					me.ShownSkPage = 1;
				}
			}
			else if(me.ShownSkPage == 1) {
				# "SYSTEM 1/3" page
				if(input == 1) {
					# activate "FLIGHT CONTROL" page
					me.ActivatePage(1);
					me.SelectedSkPage = 1;
					me.SelectedSk = 0;
				}
				else if(input == 4) {
					# activate "FUEL" page
					me.ActivatePage(4);
					me.SelectedSkPage = 1;
					me.SelectedSk = 3;
				}
				else if(input == 5) {
					# activate "SYSTEM 2/3" page
					me.SkInstance.setSoftkeys(MfdSoftkeys[2]);
					me.ShownSkPage = 2;
				}
			}
			else if(me.ShownSkPage == 2) {
				# "SYSTEM 2/3" page
				if(input == 1) {
					# activate "ELECTR" page
					me.ActivatePage(5);
					me.SelectedSkPage = 2;
					me.SelectedSk = 0;
				}
				else if(input == 2) {
					# activate "ECS" page
					me.ActivatePage(6);
					me.SelectedSkPage = 2;
					me.SelectedSk = 1;
				}
				else if(input == 3) {
					# activate "ICE" page
					me.ActivatePage(7);
					me.SelectedSkPage = 2;
					me.SelectedSk = 2;
				}
				else if(input == 4) {
					# activate "APU" page
					me.ActivatePage(8);
					me.SelectedSkPage = 2;
					me.SelectedSk = 3;
				}
				else if(input == 5) {
					# activate "SYSTEM 3/3" page
					me.SkInstance.setSoftkeys(MfdSoftkeys[3]);
					me.ShownSkPage = 3;
				}
			}
			else if(me.ShownSkPage == 3) {
				# "SYSTEM 3/3" page
				if(input == 1) {
					# activate "CPCS" page
					me.ActivatePage(9);
					me.SelectedSkPage = 3;
					me.SelectedSk = 0;
				}
				else if(input == 2) {
					# activate "DOORS" page
					me.ActivatePage(10);
					me.SelectedSkPage = 3;
					me.SelectedSk = 1;
				}
				else if(input == 5) {
					# activate "SYSTEM 1/3" page
					me.SkInstance.setSoftkeys(MfdSoftkeys[1]);
					me.ShownSkPage = 1;
				}
			}
		}

		# check if you selected the page where the selected softkey is located
		if(me.ShownSkPage == me.SelectedSkPage and me.ShownSkPage > 0) {

			if(me.SelectedSk >= 0) {
				var softkeyFrames = [0,0,0,0,0];
				softkeyFrames[me.SelectedSk] = 1;
				me.SkInstance.drawFrames(softkeyFrames);
			}
		}
	}
};

var mfd1BtClick = func(input = -1) {
	Mfd1Instance.BtClick(input);
}

var mfd2BtClick = func(input = -1) {
	Mfd2Instance.BtClick(input);
}

var mfdListener = setlistener("/sim/signals/fdm-initialized", func () {

	var mfd1Canvas = canvas.new({
		"name": "MFD1",
		"size": [1024, 1024],
		"view": [800, 950],
		"mipmapping": 1
	});
	mfd1Canvas.addPlacement({"node": "MFD1_Screen"});
	Mfd1Instance = MFD.new(mfd1Canvas.createGroup());

	var mfd2Canvas = canvas.new({
		"name": "MFD2",
		"size": [1024, 1024],
		"view": [800, 950],
		"mipmapping": 1
	});
	mfd2Canvas.addPlacement({"node": "MFD2_Screen"});
	Mfd2Instance = MFD.new(mfd2Canvas.createGroup());

	removelistener(mfdListener);
});
