var canvas_apu = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_apu] };
		m.group = canvasGroup;
		m.tmp = 0;

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};

		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/apuProp.svg", {'font-mapper': font_mapper});

		var svg_keys = ["readout_n","readout_egt","dial_n","dial_egt",
				"readout_a","OverloadN","OverloadEGT"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}
		
		m.OverloadN.hide();
		m.OverloadEGT.hide();

		m.timer = maketimer(0.1, m, m.update);
		return m;
	},
	update: func()
	{
		me.readout_n.setText(sprintf("%3.01f", getprop("engines/engine[2]/n2") or 0));
		me.dial_n.setRotation((270/100) * D2R * (getprop("engines/engine[2]/n2") or 0));

		me.tmp = ((getprop("engines/engine[2]/egt-degf") or 0)-32)/1.8;
		if(me.tmp < 0) me.tmp = 0;

		me.readout_egt.setText(sprintf("%3.01f", me.tmp));
		me.dial_egt.setRotation((270/740) * D2R * me.tmp);

		me.readout_a.setText(sprintf("%3.01f", getprop("systems/electrical/APU/Current") or 0));
	},
	show: func()
	{
		me.update();
		me.timer.start();
		me.group.show();
	},
	hide: func()
	{
		me.timer.stop();
		me.group.hide();
	}
};
