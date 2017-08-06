var canvas_electr = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_electr] };
		m.group = canvasGroup;

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};

		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/electr.svg", {'font-mapper': font_mapper});

		var svg_keys = ["VDC1","VDC2","AGenLH","AAPU","AGenRH","VAC1","VAC2",
				"VINV1H","VINV1L","VINV2L","VINV2H"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.VDC1.setText("28.0");
		m.VDC2.setText("28.0");
		m.AGenLH.setText("70");
		m.AGenRH.setText("70");
		m.AAPU.setText("0");
		m.VAC1.setText("115");
		m.VAC2.setText("115");
		m.VINV1H.setText("115");
		m.VINV1L.setText("28.0");
		m.VINV2H.setText("115");
		m.VINV2L.setText("28.0");

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
