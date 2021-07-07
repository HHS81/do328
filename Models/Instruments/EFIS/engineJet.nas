var canvas_engine = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_engine] };
		m.group = canvasGroup;
		m.n = 0;

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};

		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/engineJet.svg", {'font-mapper': font_mapper});

		var svg_keys = ["readout_n1_1","readout_n1_2","readout_n2_1","readout_n2_2",
				"readout_itt1","readout_itt2","readout_vib1","readout_vib2",
				"readout_oilTemp1","readout_oilTemp2","readout_oilPrss1","readout_oilPrss2",
				"arrowOilTemp1","arrowOilTemp2","arrowOilPrss1","arrowOilPrss2",
				"readout_ff1","readout_ff2","hideme"];

		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.hideme.hide();
		m.timer = maketimer(0.1, m, m.update);
		return m;
	},
	update: func()
	{
		for(me.n = 0; me.n<2; me.n+=1) {
			me["readout_n1_"~(me.n+1)].setText(sprintf("%3.01f", getprop("engines/engine["~me.n~"]/n1") or 0));
			me["readout_n2_"~(me.n+1)].setText(sprintf("%3.01f", getprop("engines/engine["~me.n~"]/n1") or 0));

			# oil temperature
			me.tmp = getprop("engines/engine["~me.n~"]/oil-temperature-degf") or 0;
			me["readout_oilTemp"~(me.n+1)].setText(sprintf("%3.01f", me.tmp));
			me["arrowOilTemp"~(me.n+1)].setTranslation(me.tmp*0.675, 0); #135/200
			me["readout_ff"~(me.n+1)].setText(sprintf("%3.0f",(getprop("engines/engine["~me.n~"]/fuel-flow_pph") or 0)));

			# oil pressure
			me.tmp = getprop("engines/engine["~me.n~"]/oil-pressure-psi") or 0;
			me["readout_oilPrss"~(me.n+1)].setText(sprintf("%3.01f", me.tmp));
			me["arrowOilPrss"~(me.n+1)].setTranslation(me.tmp*1.8, 0); #135/40
		}
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
