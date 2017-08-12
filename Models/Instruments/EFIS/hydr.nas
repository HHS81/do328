var canvas_hydr = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_hydr] };
		m.group = canvasGroup;

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};

		#canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/hydr.svg", {'font-mapper': font_mapper});

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
