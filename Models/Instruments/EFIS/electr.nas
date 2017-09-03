var canvas_electr = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_electr] };
		m.group = canvasGroup;
		m.active = 0;
		m.tmp = 0;

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};

		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/electr.svg", {'font-mapper': font_mapper});

		var svg_keys = ["VDC1","VDC2","VAC1","VAC2","VINV1H","VINV1L","VINV2L","VINV2H",
				"AGenLH","AAPU","AGenRH","FailBatt1","FailBatt2","DCTie"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.AAPU.setText("0");
		m.VAC1.setText("115");
		m.VAC2.setText("115");
		m.VINV1H.setText("115");
		m.VINV1L.setText("28.0");
		m.VINV2H.setText("115");
		m.VINV2L.setText("28.0");

		return m;
	},
	update: func()
	{
		if(getprop("systems/electrical/DCTie/Connected")) {
			me.DCTie.show();
		}
		else {
			me.DCTie.hide();
		}

		if(getprop("systems/electrical/Battery1/Connected")) {
			me.FailBatt1.hide();
		}
		else {
			me.FailBatt1.show();
		}

		if(getprop("systems/electrical/Battery2/Connected")) {
			me.FailBatt2.hide();
		}
		else {
			me.FailBatt2.show();
		}

		me.VDC1.setText(sprintf("%2.01f", getprop("systems/electrical/DCBus1/Voltage") or 0));
		me.VDC2.setText(sprintf("%2.01f", getprop("systems/electrical/DCBus2/Voltage") or 0));
		me.AGenLH.setText(sprintf("%3.0f", getprop("systems/electrical/Generator1/Current") or 0));
		me.AGenRH.setText(sprintf("%3.0f", getprop("systems/electrical/Generator2/Current") or 0));

		if(me.active == 1) {
			settimer(func me.update(), 0.1);
		}
	},
	show: func()
	{
		me.active = 1;
		me.update();
		me.group.show();
	},
	hide: func()
	{
		me.active = 0;
		me.group.hide();
	}
};
