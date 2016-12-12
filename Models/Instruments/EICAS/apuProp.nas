var canvas_apu = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_apu] };
		m.group = canvasGroup;
		
		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "osifont-gpl2fe.ttf";
			}
		};
		
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EICAS/apuProp.svg", {'font-mapper': font_mapper});

		return m;
	},
	show: func()
	{
		me.group.show();
	},
	hide: func()
	{
		me.group.hide();
	}
};
