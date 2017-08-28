var canvas_apu = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_apu] };
		m.group = canvasGroup;
		
		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};

		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/apuProp.svg", {'font-mapper': font_mapper});

		var svg_keys = ["OverloadN","OverloadEGT"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}
		
		m.OverloadN.hide();
		m.OverloadEGT.hide();

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
