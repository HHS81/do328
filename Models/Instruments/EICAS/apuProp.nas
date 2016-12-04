var canvasGroup = {};

var canvas_apu = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_apu] };
		
		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "LiberationFonts/LiberationSans-Regular.ttf";
			}
		};
		
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EICAS/apuProp.svg", {'font-mapper': font_mapper});
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
