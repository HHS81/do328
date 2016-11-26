var canvasMFD2 = {};
var canvasMFD2Doors = {};
var doorsPageMFD2 = {};
var softkeysMFD2 = [["MAIN","CAPT\nSYSTEM","REF\nDATA","COPY","AHRS","F/O\nSYSTEM","MSG"],
		["SYSTEM 1/3","FLIGHT\nCONTROL","HYDR","ENGINE","FUEL","NEXT",""],
		["SYSTEM 2/3","ELECTR","ECS","ICE\nPROTECT","APU","NEXT",""],
		["SYSTEM 3/3","CPCS/\nOXYGEN","DOORS","","","NEXT",""]];

var mfd2BtClick = func(input = -1) {

}

setlistener("/nasal/canvas/loaded", func {

	canvasMFD2 = canvas.new({
		"name": "MFD2",
		"size": [1024, 1024],
		"view": [567, 673],
		"mipmapping": 1
	});
	canvasMFD2.addPlacement({"node": "MFD2_Screen"});
	var group = canvasMFD2.createGroup();

	doorsPageMFD2 = group.createChild('group');
	canvas_doors.new(doorsPageMFD2);

	var sk = group.createChild('group');
	var sk_instance = canvas_softkeys.new(sk);

	sk_instance.setSoftkeys(softkeysMFD2[3]);
}, 1);
