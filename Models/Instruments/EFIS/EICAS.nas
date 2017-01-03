# by xcvb85

var eicasPages = {};
var eicasSkInstance = {};
var eicasActiveSoftkeys = 0; # indicates which page (eicasSoftkeys) is shown
var eicasActivatedSk = [0,0]; # indicates which softkey gets a frame [page, softkey number]
var eicasSoftkeys = [["MAIN","CAPT\nSYSTEM","REF\nDATA","COPY","AHRS","F/O\nSYSTEM","MSG"], #0
		["SYSTEM 1/3","FLIGHT\nCONTROL","HYDR","ENGINE","FUEL","NEXT",""], #1
		["SYSTEM 2/3","ELECTR","ECS","ICE\nPROTECT","APU","NEXT",""], #2
		["SYSTEM 3/3","CPCS/\nOXYGEN","DOORS","SYS\nMAINT","SENSOR\nDATA","NEXT",""], #3
		["REF DATA","T/O","CLIMB","CRUISE","LANDG","SINGLE\nENGINE","MSG"], #4
		["T/O","FLAPS\n12","V1\n102","VR\n108","V2\n113","T/O TQ","MSG"], #5
		["CLIMB","VCL\n200","","","L 94%\nR 94%","","MSG"], #6
		["CRUISE","VC\n130","???","VSTD\n180","L 80%\nR 80%","","MSG"], #7
		["LANDG","FLAPS\n32","VFL0\n170","VREF\n110","L100%\nR100%","","MSG"], #8
		["T/O TQ","TEMP °C\n18","TEMP °F\n64","","L100\nR100","","MSG"], #9
		["MAINT","TREND","EXCEED","FAULT","GNDMNT","","RNG"]]; #10

var eicasActivatePage = func(input = -1) {

	for(var i=0; i<size(eicasPages); i=i+1) {
		if(i == input) {
			eicasPages[i].show();
		}
		else {
			eicasPages[i].hide();
		}
	}
}

# input: 0=back, 1=sk1...5=sk5
var eicasBtClick = func(input = -1) {

	if(getprop("systems/electrical/outputs/efis") < 1) {
		return;
	}
	if(input == 0) {
		# back button pressed
		if(eicasActiveSoftkeys > 4) {
			# go back to "REF DATA"
			eicasSkInstance.setSoftkeys(eicasSoftkeys[4]);
			eicasActiveSoftkeys = 4;
		}
		else {
			# go back to main menu
			eicasSkInstance.setSoftkeys(eicasSoftkeys[0]);
			eicasActivatePage(0);
			eicasActiveSoftkeys = 0;
			eicasActivatedSk = [0,0];
		}
	}
	else {
		# softkey pressed
		if(eicasActiveSoftkeys == 0) {
			# main menu
			if(input == 1 or input == 5) {
				# activate "CAPT SYSTEM" or "F/O SYSTEM" page
				# where is the difference?
				eicasSkInstance.setSoftkeys(eicasSoftkeys[1]);
				eicasActiveSoftkeys = 1;
			}
			else if(input == 2) {
				# activate "REF DATA" page
				eicasSkInstance.setSoftkeys(eicasSoftkeys[4]);
				eicasActiveSoftkeys = 4;
			}
		}
		else if(eicasActiveSoftkeys == 1) {
			# "SYSTEM 1/3" page
			if(input == 1) {
				# activate "FLIGHT CONTROL" page
				eicasActivatePage(4);
				eicasActivatedSk = [1,1];
			}
			else if(input == 4) {
				# activate "FUEL" page
				eicasActivatePage(2);
				eicasActivatedSk = [1,4];
			}
			else if(input == 5) {
				# activate "SYSTEM 2/3" page
				eicasSkInstance.setSoftkeys(eicasSoftkeys[2]);
				eicasActiveSoftkeys = 2;
			}
		}
		else if(eicasActiveSoftkeys == 2) {
			# "SYSTEM 2/3" page
			if(input == 4) {
				# activate "APU" page
				eicasActivatePage(3);
				eicasActivatedSk = [2,4];
			}
			else if(input == 5) {
				# activate "SYSTEM 3/3" page
				eicasSkInstance.setSoftkeys(eicasSoftkeys[3]);
				eicasActiveSoftkeys = 3;
			}
		}
		else if(eicasActiveSoftkeys == 3) {
			# "SYSTEM 3/3" page
			if(input == 2) {
				# activate "DOORS" page
				eicasActivatePage(1);
				eicasActivatedSk = [3,2];
			}
			else if(input == 5) {
				# activate "SYSTEM 1/3" page
				eicasSkInstance.setSoftkeys(eicasSoftkeys[1]);
				eicasActiveSoftkeys = 1;
			}
		}
		else if(eicasActiveSoftkeys == 4) {
			# "REF DATA" page
			if(input == 1) {
				# activate "T/O"
				setprop("instrumentation/fmc/phase-name", "TO");
				eicasSoftkeys[5][2] = sprintf("V1\n%3.0f",getprop("/instrumentation/fmc/vspeeds/V1"));
				eicasSoftkeys[5][3] = sprintf("VR\n%3.0f",getprop("/instrumentation/fmc/vspeeds/VR"));
				eicasSoftkeys[5][4] = sprintf("V2\n%3.0f",getprop("/instrumentation/fmc/vspeeds/V2"));
				eicasSkInstance.setSoftkeys(eicasSoftkeys[5]);
				eicasSkInstance.drawFrames([1,1,1,1,0]);
				eicasActiveSoftkeys = 5;
				eicasActivatedSk = [4,1];
			}
			else if(input == 2) {
				# activate "CLIMB"
				eicasSkInstance.setSoftkeys(eicasSoftkeys[6]);
				eicasSkInstance.drawFrames([0,0,0,1,0]);
				eicasActiveSoftkeys = 6;
				eicasActivatedSk = [4,2];
			}
			else if(input == 3) {
				# activate "CRUISE"
				eicasSkInstance.setSoftkeys(eicasSoftkeys[7]);
				eicasSkInstance.drawFrames([1,1,1,1,0]);
				eicasActiveSoftkeys = 7;
				eicasActivatedSk = [4,3];
			}
			else if(input == 4) {
				# activate "LANDG"
				setprop("instrumentation/fmc/phase-name", "LANDG");
				eicasSoftkeys[8][3] = sprintf("VREF\n%3.0f",getprop("/instrumentation/fmc/vspeeds/Vref"));
				eicasSkInstance.setSoftkeys(eicasSoftkeys[8]);
				eicasSkInstance.drawFrames([1,1,1,1,0]);
				eicasActiveSoftkeys = 8;
				eicasActivatedSk = [4,4];
			}
		}
	}

	# check if you selected the page where the selected softkey is located
	if(eicasActiveSoftkeys == eicasActivatedSk[0] and eicasActiveSoftkeys > 0) {
		var softkeyFrames = [0,0,0,0,0];
		var index = eicasActivatedSk[1]-1;

		if(index >= 0) {
			softkeyFrames[index] = 1;
			eicasSkInstance.drawFrames(softkeyFrames);
		}
	}
}

setlistener("/nasal/canvas/loaded", func {

	eicasCanvas = canvas.new({
		"name": "EICAS",
		"size": [512, 512],
		"view": [800, 950],
		"mipmapping": 1
	});
	eicasCanvas.addPlacement({"node": "EICAS_Screen"});
	var group = eicasCanvas.createGroup();

	eicasPages[0] = canvas_eicas.new(group.createChild('group'));
	eicasPages[1] = canvas_doors.new(group.createChild('group'));
	eicasPages[2] = canvas_fuel.new(group.createChild('group'));
	eicasPages[3] = canvas_apu.new(group.createChild('group'));
	eicasPages[4] = canvas_flightctrl.new(group.createChild('group'));

	eicasSkInstance = canvas_softkeys.new(group.createChild('group'));

	eicasSkInstance.setSoftkeys(eicasSoftkeys[0]);
	eicasActivatePage(0);
}, 1);
