# by xcvb85

var mfd2Pages = {};
var mfd2SkInstance = {};
var mfd2ActiveSoftkeys = 0; # indicates which page (mfd2Softkeys) is shown
var mfd2ActivatedSk = [0,0]; # indicates which softkey gets a frame [page, softkey number]
var mfd2Softkeys = [["MAIN 1/2","DISPLAY","RADAR","SYSTEM","FMS","MFD\nFORMAT","RNG"], #0
		["SYSTEM 1/3","FLIGHT\nCONTROL","HYDR","ENGINE","FUEL","NEXT",""], #1
		["SYSTEM 2/3","ELECTR","ECS","ICE\nPROTECT","APU","NEXT",""], #2
		["SYSTEM 3/3","CPCS/\nOXYGEN","DOORS","SYS\nMAINT","SENSOR\nDATA","NEXT",""]]; #3

var mfd2ActivatePage = func(input = -1) {

	for(var i=0; i<size(mfd2Pages); i=i+1) {
		if(i == input) {
			mfd2Pages[i].show();
		}
		else {
			mfd2Pages[i].hide();
		}
	}
}

# input: 0=back, 1=sk1...5=sk5
var mfd2BtClick = func(input = -1) {

	if(input == 0) {
		# back button pressed
		# go back to main menu
		mfd2SkInstance.setSoftkeys(mfd2Softkeys[0]);
		mfd2ActivatePage(0);
		mfd2ActiveSoftkeys = 0;
		mfd2ActivatedSk = [0,0];
	}
	else {
		# softkey pressed
		if(mfd2ActiveSoftkeys == 0) {
			# main menu
			if(input == 3) {
				# activate "SYSTEM"
				mfd2SkInstance.setSoftkeys(mfd2Softkeys[1]);
				mfd2ActiveSoftkeys = 1;
			}
		}
		else if(mfd2ActiveSoftkeys == 1) {
			# "SYSTEM 1/3" page
			if(input == 1) {
				# activate "FLIGHT CONTROL" page
				mfd2ActivatePage(4);
				mfd2ActivatedSk = [1,1];
			}
			else if(input == 4) {
				# activate "FUEL" page
				mfd2ActivatePage(2);
				mfd2ActivatedSk = [1,4];
			}
			else if(input == 5) {
				# activate "SYSTEM 2/3" page
				mfd2SkInstance.setSoftkeys(mfd2Softkeys[2]);
				mfd2ActiveSoftkeys = 2;
			}
		}
		else if(mfd2ActiveSoftkeys == 2) {
			# "SYSTEM 2/3" page
			if(input == 4) {
				# activate "APU" page
				mfd2ActivatePage(3);
				mfd2ActivatedSk = [2,4];
			}
			else if(input == 5) {
				# activate "SYSTEM 3/3" page
				mfd2SkInstance.setSoftkeys(mfd2Softkeys[3]);
				mfd2ActiveSoftkeys = 3;
			}
		}
		else if(mfd2ActiveSoftkeys == 3) {
			# "SYSTEM 3/3" page
			if(input == 2) {
				# activate "DOORS" page
				mfd2ActivatePage(1);
				mfd2ActivatedSk = [3,2];
			}
			else if(input == 5) {
				# activate "SYSTEM 1/3" page
				mfd2SkInstance.setSoftkeys(mfd2Softkeys[1]);
				mfd2ActiveSoftkeys = 1;
			}
		}
	}

	# check if you selected the page where the selected softkey is located
	if(mfd2ActiveSoftkeys == mfd2ActivatedSk[0] and mfd2ActiveSoftkeys > 0) {
		var softkeyFrames = [0,0,0,0,0];
		var index = mfd2ActivatedSk[1]-1;

		if(index >= 0) {
			softkeyFrames[index] = 1;
			mfd2SkInstance.drawFrames(softkeyFrames);
		}
	}
}

setlistener("/nasal/canvas/loaded", func {

	mfd2Canvas = canvas.new({
		"name": "EICAS",
		"size": [512, 512],
		"view": [567, 673],
		"mipmapping": 1
	});
	mfd2Canvas.addPlacement({"node": "MFD2_Screen"});
	var group = mfd2Canvas.createGroup();

	mfd2Pages[0] = canvas_nd.new(group.createChild('group'));
	mfd2Pages[1] = canvas_doors.new(group.createChild('group'));
	mfd2Pages[2] = canvas_fuel.new(group.createChild('group'));
	mfd2Pages[3] = canvas_apu.new(group.createChild('group'));
	mfd2Pages[4] = canvas_flightctrl.new(group.createChild('group'));

	mfd2SkInstance = canvas_softkeys.new(group.createChild('group'));

	mfd2SkInstance.setSoftkeys(mfd2Softkeys[0]);
	mfd2ActivatePage(0);
}, 1);
