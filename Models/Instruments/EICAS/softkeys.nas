var canvas_softkeys = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_softkeys] };
		
		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};
		
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EICAS/softkeys.svg", {'font-mapper': font_mapper});

		var svg_keys = ["title","sk1","sk2","sk3","sk4","sk5","knob","frame1","frame2","frame3","frame4","frame5"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.path = canvasGroup.createChild("path").setStrokeLineWidth(3).set("stroke", "rgba(255,255,255,1)");

		return m;
	},
	drawFrames: func(selectedSoftkeys)
	{
		me.path.reset();

		if(size(selectedSoftkeys) == 5) {

			for(var n = 0; n<5; n=n+1) {

				if(selectedSoftkeys[n] == 1) {
					var center = me["sk"~(n+1)].getCenter();
					var bbox = me["sk"~(n+1)].getBoundingBox();

					me["path"].moveTo(center[0]+bbox[0]-5,center[1]+bbox[1])
						.lineTo(center[0]+bbox[2]+5,center[1]+bbox[1])
						.lineTo(center[0]+bbox[2]+5,center[1]+bbox[3]+15)
						.lineTo(center[0]+bbox[0]-5,center[1]+bbox[3]+15)
						.lineTo(center[0]+bbox[0]-5,center[1]+bbox[1]);
				}
			}
		}
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
		me["path"].reset();
	}
};
