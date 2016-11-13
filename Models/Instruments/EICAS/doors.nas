# ==============================================================================
# Boeing 747-400 EICAS by Gijs de Rooy
# ==============================================================================

var canvas_group = {};
var primary_dialog = {};
var canvas_doors = {};

var class_doors = {
	new: func(canvas_group)
	{
		var m = { parents: [class_doors] };
		
		var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(canvas_group, "Aircraft/do328/Models/Instruments/EICAS/doors.svg", {'font-mapper': font_mapper});
		
		return m;
	}
};

setlistener("/nasal/canvas/loaded", func {
	canvas_doors = canvas.new({
		"name": "doors",
		"size": [1024, 1024],
		"view": [567, 673],
		"mipmapping": 1
	});
	canvas_doors.addPlacement({"node": "MFD2_Screen"});
	var group = canvas_doors.createGroup();
	class_doors.new(group);
}, 1);
