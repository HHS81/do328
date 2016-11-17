var canvasGroup = {};

var canvas_softkeys = {
	new: func(canvasGroup, id)
	{
		var m = { parents: [canvas_softkeys] };
		
		var font_mapper = func(family, weight)
		{
			if(family == "Liberation Sans" and weight == "normal") {
				return "LiberationFonts/LiberationSans-Regular.ttf";
			}
		};
		
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EICAS/softkeys.svg", {'font-mapper': font_mapper});

		var svg_keys = ["title","sk1","sk2","sk3","sk4","sk5"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		setlistener("/canvas/softkeys"~id, func {
			var softkeys = split(";", getprop("/canvas/softkeys"~id));

			if(size(softkeys) != 6) {
				m["title"].setText("INVALID");
				for(var n = 1; n<=5; n+=1){
					m["sk"~n].setText("");
				}
			}
			else {
				m["title"].setText(softkeys[0]);
				for(var n = 1; n<=5; n+=1){
					m["sk"~n].setText(softkeys[n]);
				}
			}
		}, 1);

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
	}
};
