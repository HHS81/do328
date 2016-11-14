var canvasMFD2 = {};
var canvasMFD2Doors = {};
var doorsPageMFD2 = {};

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
}, 1);
