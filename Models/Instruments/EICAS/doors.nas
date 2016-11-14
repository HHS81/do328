var canvas_group = {};

var canvas_doors = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_doors] };
		
		var font_mapper = func(family, weight)
		{
			if(family == "Liberation Sans" and weight == "normal") {
				return "LiberationFonts/LiberationSans-Regular.ttf";
			}
		};
		
		canvas.parsesvg(canvas_group, "Aircraft/do328/Models/Instruments/EICAS/doors.svg", {'font-mapper': font_mapper});
		
		return m;
	},
	slow_update: func()
	{
	},
	fast_update: func()
	{
	}
};
