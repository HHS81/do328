var canvasGroup = {};

var canvas_softkeys = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_softkeys] };
		
		var font_mapper = func(family, weight)
		{
			if(family == "Liberation Sans" and weight == "normal") {
				return "LiberationFonts/LiberationSans-Regular.ttf";
			}
		};
		
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EICAS/softkeys.svg", {'font-mapper': font_mapper});

		var svg_keys = ["title","sk1","sk2","sk3","sk4","sk5","knob"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		return m;
	},
	setSoftkeys: func(softkeys)
	{
		me["title"].setText(softkeys[0]);
		me["sk1"].setText(softkeys[1]);
		me["sk2"].setText(softkeys[2]);
		me["sk3"].setText(softkeys[3]);
		me["sk4"].setText(softkeys[4]);
		me["sk5"].setText(softkeys[5]);
		me["knob"].setText(softkeys[6]);
	}
};
