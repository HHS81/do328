var eicasInstance = {};
var canvasEicas = {};
var eicasPage = {};
var canvasEicasDoors = {};
var doorsPageEicas = {};

var eicasBtClick = func(input = -1) {

	if(input == 1) {
		eicasPage.hide();
		doorsPageEicas.show();
	}
	else if(input == 2){
		eicasPage.hide();
		doorsPageEicas.show();
	}
	else if(input == 3){
		eicasPage.hide();
		doorsPageEicas.show();
	}
	else if(input == 4){
		eicasPage.hide();
		doorsPageEicas.show();
	}
	else if(input == 5){
		eicasPage.hide();
		doorsPageEicas.show();
	}
	else {
		doorsPageEicas.hide();
		eicasPage.show();
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

	eicasPage = group.createChild('group');
	eicasInstance = canvas_eicas.new(eicasPage);
	eicasInstance.slow_update();
	eicasInstance.fast_update();

	doorsPageEicas = group.createChild('group');
	canvas_doors.new(doorsPageEicas);

	doorsPageEicas.hide();
	eicasPage.show();
}, 1);
