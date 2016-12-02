# by xcvb85

var mfd1Pages = {};
var mfd1SkInstance = {};
var mfd1ActiveSoftkeys = 0; # indicates which page (mfd1Softkeys) is shown
var mfd1ActivatedSk = [0,0]; # indicates which softkey gets a frame [page, softkey number]
var mfd1Softkeys = [["MAIN 1/2","DISPLAY","RADAR","SYSTEM","FMS","MFD\nFORMAT","RNG"], #0
		["SYSTEM 1/3","FLIGHT\nCONTROL","HYDR","ENGINE","FUEL","NEXT",""], #1
		["SYSTEM 2/3","ELECTR","ECS","ICE\nPROTECT","APU","NEXT",""], #2
		["SYSTEM 3/3","CPCS/\nOXYGEN","DOORS","SYS\nMAINT","SENSOR\nDATA","NEXT",""]]; #3

var mfd1ActivatePage = func(input = -1) {

	for(var i=0; i<size(mfd1Pages); i=i+1) {
		if(i == input) {
			mfd1Pages[i].show();
		}
		else {
			mfd1Pages[i].hide();
		}
	}
}

# input: 0=back, 1=sk1...5=sk5
var mfd1BtClick = func(input = -1) {

	if(input == 0) {
		# back button pressed
		# go back to main menu
		mfd1SkInstance.setSoftkeys(mfd1Softkeys[0]);
		mfd1ActivatePage(0);
		mfd1ActiveSoftkeys = 0;
		mfd1ActivatedSk = [0,0];
	}
	else {
		# softkey pressed
		if(mfd1ActiveSoftkeys == 0) {
			# main menu
			if(input == 3) {
				# activate "SYSTEM"
				mfd1SkInstance.setSoftkeys(mfd1Softkeys[1]);
				mfd1ActiveSoftkeys = 1;
			}
		}
		else if(mfd1ActiveSoftkeys == 1) {
			# "SYSTEM 1/3" page
			if(input == 1) {
				# activate "FLIGHT CONTROL" page
				mfd1ActivatePage(4);
				mfd1ActivatedSk = [1,1];
			}
			else if(input == 4) {
				# activate "FUEL" page
				mfd1ActivatePage(2);
				mfd1ActivatedSk = [1,4];
			}
			else if(input == 5) {
				# activate "SYSTEM 2/3" page
				mfd1SkInstance.setSoftkeys(mfd1Softkeys[2]);
				mfd1ActiveSoftkeys = 2;
			}
		}
		else if(mfd1ActiveSoftkeys == 2) {
			# "SYSTEM 2/3" page
			if(input == 4) {
				# activate "APU" page
				mfd1ActivatePage(3);
				mfd1ActivatedSk = [2,4];
			}
			else if(input == 5) {
				# activate "SYSTEM 3/3" page
				mfd1SkInstance.setSoftkeys(mfd1Softkeys[3]);
				mfd1ActiveSoftkeys = 3;
			}
		}
		else if(mfd1ActiveSoftkeys == 3) {
			# "SYSTEM 3/3" page
			if(input == 2) {
				# activate "DOORS" page
				mfd1ActivatePage(1);
				mfd1ActivatedSk = [3,2];
			}
			else if(input == 5) {
				# activate "SYSTEM 1/3" page
				mfd1SkInstance.setSoftkeys(mfd1Softkeys[1]);
				mfd1ActiveSoftkeys = 1;
			}
		}
	}

	# check if you selected the page where the selected softkey is located
	if(mfd1ActiveSoftkeys == mfd1ActivatedSk[0] and mfd1ActiveSoftkeys > 0) {
		var softkeyFrames = [0,0,0,0,0];
		var index = mfd1ActivatedSk[1]-1;

		if(index >= 0) {
			softkeyFrames[index] = 1;
			mfd1SkInstance.drawFrames(softkeyFrames);
		}
	}
}

setlistener("/nasal/canvas/loaded", func {

	mfd1Canvas = canvas.new({
		"name": "EICAS",
		"size": [1024, 1024],
		"view": [567, 673],
		"mipmapping": 1
	});
	mfd1Canvas.addPlacement({"node": "MFD1_Screen"});
	var group = mfd1Canvas.createGroup();

	mfd1Pages[0] = canvas_nd.new(group.createChild('group'));
	mfd1Pages[1] = canvas_doors.new(group.createChild('group'));
	mfd1Pages[2] = canvas_fuel.new(group.createChild('group'));
	mfd1Pages[3] = canvas_apu.new(group.createChild('group'));
	mfd1Pages[4] = canvas_flightctrl.new(group.createChild('group'));

	mfd1SkInstance = canvas_softkeys.new(group.createChild('group'));

	mfd1SkInstance.setSoftkeys(mfd1Softkeys[0]);
	mfd1ActivatePage(0);
}, 1);
