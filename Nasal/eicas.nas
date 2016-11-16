# by xcvb85

var eicasPages = {};
var eicasInstance = {};
var activeSoftkeysEicas = 0;
var softkeysEicas = ["MAIN;CAPT\nSYSTEM;REF\nDATA;COPY;AHRS;F/O\nSYSTEM",
		"SYSTEM 1/3;FLIGHT\nCONTROL;HYDR;ENGINE;FUEL;NEXT",
		"SYSTEM 2/3;ELECTR;ECS;ICE\nPROTECT;APU;NEXT",
		"SYSTEM 3/3;CPCS/\nOXYGEN;DOORS;;;NEXT"];

var activateEicasPage = func(input = -1) {

	for(var i=0; i<3; i=i+1) {
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
		setprop("/canvas/softkeys0", softkeysEicas[0]);
		activateEicasPage(0);
		activeSoftkeysEicas = 0;
	}
	else {
		if(activeSoftkeysEicas == 0) {
			if(input == 5) {
				setprop("/canvas/softkeys0", softkeysEicas[1]);
				activeSoftkeysEicas = 1;
			}
		}
		else if(activeSoftkeysEicas == 1) {
			if(input == 4) {
				activateEicasPage(2);
			}
			else if(input == 5) {
				setprop("/canvas/softkeys0", softkeysEicas[2]);
				activeSoftkeysEicas = 2;
			}
		}
		else if(activeSoftkeysEicas == 2) {
			if(input == 5) {
				setprop("/canvas/softkeys0", softkeysEicas[3]);
				activeSoftkeysEicas = 3;
			}
		}
		else if(activeSoftkeysEicas == 3) {
			if(input == 2) {
				activateEicasPage(1);
			}
			else if(input == 5) {
				setprop("/canvas/softkeys0", softkeysEicas[1]);
				activeSoftkeysEicas = 1;
			}
		}
	}
}

setlistener("/nasal/canvas/loaded", func {
	setprop("/canvas/softkeys0", softkeysEicas[0]);

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
	canvas_doors.new(eicasPages[1], 0);

	eicasPages[2] = group.createChild('group');
	canvas_fuel.new(eicasPages[2], 0);

	activateEicasPage(0);
}, 1);
