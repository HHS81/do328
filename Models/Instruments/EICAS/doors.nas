var canvas_doors = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_doors] };
		
		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "osifont-gpl2fe.ttf";
			}
		};
		
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EICAS/doors.svg", {'font-mapper': font_mapper});
		m["group"] = canvasGroup;

		return m;
	},
	show: func()
	{
		me["group"].show();
	},
	hide: func()
	{
		me["group"].hide();
	}
};
