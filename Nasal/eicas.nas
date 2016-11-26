# by xcvb85

var eicasPages = {};
var eicasInstance = {};
var activeSoftkeysEicas = 0;
var sk_instance = {};
var activatedSk = [0,0];
var softkeysEicas = [["MAIN","CAPT\nSYSTEM","REF\nDATA","COPY","AHRS","F/O\nSYSTEM","MSG"],
		["SYSTEM 1/3","FLIGHT\nCONTROL","HYDR","ENGINE","FUEL","NEXT",""],
		["SYSTEM 2/3","ELECTR","ECS","ICE\nPROTECT","APU","NEXT",""],
		["SYSTEM 3/3","CPCS/\nOXYGEN","DOORS","","","NEXT",""],
		["REF DATA","T/O","CLIMB","CRUISE","LANDG","SINGLE\nENGINE","MSG"],
		["T/O","FLAPS\n12","V1\n102","VR\n108","V2\n113","T/O TQ","MSG"],
		["CLIMB","???","???","???","???","???","MSG"],
		["CRUISE","VC\n130","???","VSTD\n180","L100%\nR100%","","MSG"],
		["LANDG","FLAPS\n32","VFL0\n170","VREF\n110","L100%\nR100%","","MSG"],
		["T/O TQ","TEMP °C\n18","TEMP °F\n64","","L100\nR100","","MSG"]];

var activateEicasPage = func(input = -1) {

	for(var i=0; i<size(eicasPages); i=i+1) {
		if(i == input) {
			eicasPages[i].show();
		}
		else {
			eicasPages[i].hide();
		}
	}
}

var eicasBtClick = func(input = -1) {

	if(input == 0) {
		# back button pressed
		if(activeSoftkeysEicas > 4) {
			# go back to "REF DATA"
			sk_instance.setSoftkeys(softkeysEicas[4]);
			activeSoftkeysEicas = 4;
		}
		else {
			# go back to main menu
			sk_instance.setSoftkeys(softkeysEicas[0]);
			activateEicasPage(0);
			activeSoftkeysEicas = 0;
			activatedSk = [0,0];
		}
	}
	else {
		# softkey pressed
		if(activeSoftkeysEicas == 0) {
			# main menu
			if(input == 2) {
				# activate "REF DATA" page
				sk_instance.setSoftkeys(softkeysEicas[4]);
				activeSoftkeysEicas = 4;
			}
			else if(input == 5) {
				# activate "F/O SYSTEM" page
				sk_instance.setSoftkeys(softkeysEicas[1]);
				activeSoftkeysEicas = 1;
			}
		}
		else if(activeSoftkeysEicas == 1) {
			# "SYSTEM 1/3" page
			if(input == 4) {
				# activate "FUEL" page
				activateEicasPage(2);
				activatedSk = [1,4];
			}
			else if(input == 5) {
				# activate "SYSTEM 2/3" page
				sk_instance.setSoftkeys(softkeysEicas[2]);
				activeSoftkeysEicas = 2;
			}
		}
		else if(activeSoftkeysEicas == 2) {
			# "SYSTEM 2/3" page
			if(input == 4) {
				# activate "APU" page
				activateEicasPage(3);
				activatedSk = [2,4];
			}
			else if(input == 5) {
				# activate "SYSTEM 3/3" page
				sk_instance.setSoftkeys(softkeysEicas[3]);
				activeSoftkeysEicas = 3;
			}
		}
		else if(activeSoftkeysEicas == 3) {
			# "SYSTEM 3/3" page
			if(input == 2) {
				# activate "DOORS" page
				activateEicasPage(1);
				activatedSk = [3,2];
			}
			else if(input == 5) {
				# activate "SYSTEM 1/3" page
				sk_instance.setSoftkeys(softkeysEicas[1]);
				activeSoftkeysEicas = 1;
			}
		}
		else if(activeSoftkeysEicas == 4) {
			# "REF DATA" page
			if(input == 1) {
				# activate "T/O"
				sk_instance.setSoftkeys(softkeysEicas[5]);
				sk_instance.drawFrames([1,1,1,1,0]);
				activeSoftkeysEicas = 5;
				activatedSk = [4,1];
			}
			else if(input == 2) {
				# activate "CLIMB"
				sk_instance.setSoftkeys(softkeysEicas[6]);
				sk_instance.drawFrames([1,1,1,1,0]);
				activeSoftkeysEicas = 6;
				activatedSk = [4,2];
			}
			else if(input == 3) {
				# activate "CRUISE"
				sk_instance.setSoftkeys(softkeysEicas[7]);
				sk_instance.drawFrames([1,1,1,1,0]);
				activeSoftkeysEicas = 7;
				activatedSk = [4,3];
			}
			else if(input == 4) {
				# activate "LANDG"
				sk_instance.setSoftkeys(softkeysEicas[8]);
				sk_instance.drawFrames([1,1,1,1,0]);
				activeSoftkeysEicas = 8;
				activatedSk = [4,4];
			}
		}
	}

	if(activeSoftkeysEicas == activatedSk[0] and activeSoftkeysEicas > 0) {
		var softkeyFrames = [0,0,0,0,0];
		softkeyFrames[activatedSk[1]-1] = 1;
		sk_instance.drawFrames(softkeyFrames);
	}
}

setlistener("/nasal/canvas/loaded", func {

	canvasEicas = canvas.new({
		"name": "EICAS",
		"size": [1024, 1024],
		"view": [567, 673],
		"mipmapping": 1
	});
	canvasEicas.addPlacement({"node": "EICAS_Screen"});
	var group = canvasEicas.createGroup();

	eicasPages[0] = group.createChild('group');
	eicasInstance = canvas_eicas.new(eicasPages[0], 0);
	eicasInstance.slow_update();
	eicasInstance.fast_update();

	eicasPages[1] = group.createChild('group');
	canvas_doors.new(eicasPages[1]);

	eicasPages[2] = group.createChild('group');
	canvas_fuel.new(eicasPages[2]);

	eicasPages[3] = group.createChild('group');
	canvas_apu.new(eicasPages[3]);

	var sk = group.createChild('group');
	sk_instance = canvas_softkeys.new(sk);

	sk_instance.setSoftkeys(softkeysEicas[0]);
	activateEicasPage(0);
}, 1);
