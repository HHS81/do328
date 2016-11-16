var canvasGroup = {};

var canvas_doors = {
	new: func(canvasGroup, id)
	{
		var m = { parents: [canvas_doors] };
		
		var font_mapper = func(family, weight)
		{
			if(family == "Liberation Sans" and weight == "normal") {
				return "LiberationFonts/LiberationSans-Regular.ttf";
			}
		};
		
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EICAS/doors.svg", {'font-mapper': font_mapper});

		var sk = canvasGroup.createChild('group');
		canvas_softkeys.new(sk, id);

		return m;
	}
};
