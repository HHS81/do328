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
		var m = { parents: [MFD], Pages:{}, SkInstance:{} };

		m.ActiveSoftkeys = 0; # indicates which page (MfdSoftkeys) is shown
		m.ActivatedSk = [0,0]; # indicates which softkey gets a frame [page, softkey number]

		m.Pages[0] = canvas_nd.new(group.createChild('group'));
		m.Pages[1] = canvas_doors.new(group.createChild('group'));
		m.Pages[2] = canvas_fuel.new(group.createChild('group'));
		m.Pages[3] = canvas_apu.new(group.createChild('group'));
		m.Pages[4] = canvas_flightctrl.new(group.createChild('group'));

		m.SkInstance = canvas_softkeys.new(group.createChild('group'));
		m.SkInstance.setSoftkeys(MfdSoftkeys[0]);
		m.ActivatePage(0);

		return m;
	},
	ActivatePage: func(input = -1)
	{
		for(var i=0; i<size(me.Pages); i=i+1) {
			if(i == input) {
				me.Pages[i].show();
			}
			else {
				me.Pages[i].hide();
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
			me.ActiveSoftkeys = 0;
			me.ActivatedSk = [0,0];
		}
		else {
			# softkey pressed
			if(me.ActiveSoftkeys == 0) {
				# main menu
				if(input == 3) {
					# activate "SYSTEM"
					me.SkInstance.setSoftkeys(MfdSoftkeys[1]);
					me.ActiveSoftkeys = 1;
				}
			}
			else if(me.ActiveSoftkeys == 1) {
				# "SYSTEM 1/3" page
				if(input == 1) {
					# activate "FLIGHT CONTROL" page
					me.ActivatePage(4);
					me.ActivatedSk = [1,1];
				}
				else if(input == 4) {
					# activate "FUEL" page
					me.ActivatePage(2);
					me.ActivatedSk = [1,4];
				}
				else if(input == 5) {
					# activate "SYSTEM 2/3" page
					me.SkInstance.setSoftkeys(MfdSoftkeys[2]);
					me.ActiveSoftkeys = 2;
				}
			}
			else if(me.ActiveSoftkeys == 2) {
				# "SYSTEM 2/3" page
				if(input == 4) {
					# activate "APU" page
					me.ActivatePage(3);
					me.ActivatedSk = [2,4];
				}
				else if(input == 5) {
					# activate "SYSTEM 3/3" page
					me.SkInstance.setSoftkeys(MfdSoftkeys[3]);
					me.ActiveSoftkeys = 3;
				}
			}
			else if(me.ActiveSoftkeys == 3) {
				# "SYSTEM 3/3" page
				if(input == 2) {
					# activate "DOORS" page
					me.ActivatePage(1);
					me.ActivatedSk = [3,2];
				}
				else if(input == 5) {
					# activate "SYSTEM 1/3" page
					me.SkInstance.setSoftkeys(MfdSoftkeys[1]);
					me.ActiveSoftkeys = 1;
				}
			}
		}
	
		# check if you selected the page where the selected softkey is located
		if(me.ActiveSoftkeys == me.ActivatedSk[0] and me.ActiveSoftkeys > 0) {
			var softkeyFrames = [0,0,0,0,0];
			var index = me.ActivatedSk[1]-1;
	
			if(index >= 0) {
				softkeyFrames[index] = 1;
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

setlistener("/nasal/canvas/loaded", func {

	var mfd1Canvas = canvas.new({
		"name": "MFD1",
		"size": [512, 512],
		"view": [800, 950],
		"mipmapping": 1
	});
	mfd1Canvas.addPlacement({"node": "MFD1_Screen"});
	Mfd1Instance = MFD.new(mfd1Canvas.createGroup());

	var mfd2Canvas = canvas.new({
		"name": "MFD2",
		"size": [512, 512],
		"view": [800, 950],
		"mipmapping": 1
	});
	mfd2Canvas.addPlacement({"node": "MFD2_Screen"});
	Mfd2Instance = MFD.new(mfd2Canvas.createGroup());
}, 1);
