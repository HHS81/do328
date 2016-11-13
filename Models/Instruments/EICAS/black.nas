# ==============================================================================
# Boeing 747-400 EICAS by Gijs de Rooy
# ==============================================================================

var canvas_group = {};
var primary_dialog = {};
var canvas_black = {};

var class_black = {
	new: func(canvas_group)
	{
		var m = { parents: [class_black] };
		
		var font_mapper = func(family, weight)
		{
			if( family == "Liberation Sans" and weight == "normal" )
				return "LiberationFonts/LiberationSans-Regular.ttf";
		};
		
		canvas.parsesvg(canvas_group, "Aircraft/do328/Models/Instruments/EICAS/black.svg", {'font-mapper': font_mapper});
		
		return m;
	}
};

setlistener("/nasal/canvas/loaded", func {
	canvas_black = canvas.new({
		"name": "Black",
		"size": [1024, 1024],
		"view": [567, 673],
		"mipmapping": 1
	});
	canvas_black.addPlacement({"node": "MFD1_Screen"});
	canvas_black.addPlacement({"node": "MFD2_Screen"});
	var group = canvas_black.createGroup();
	class_black.new(group);
}, 1);

