var canvas_engine = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_engine] };
		m.group = canvasGroup;

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};

		#canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/engine.svg", {'font-mapper': font_mapper});

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
