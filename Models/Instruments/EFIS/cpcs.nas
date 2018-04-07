var canvas_cpcs = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_cpcs] };
		m.group = canvasGroup;
		m.tmp = 0;

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};

		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/cpcs.svg", {'font-mapper': font_mapper});

		var svg_keys = ["readout_ca", "readout_dp", "readout_cr", "readout_le",
				"slider_ca", "slider_dp", "slider_cr", "arrow_up", "arrow_dn"];

		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.timer = maketimer(0.1, m, m.update);
		m.arrow_up.hide();
		m.arrow_dn.hide();
		return m;
	},
	update: func()
	{
		me.tmp = getprop("systems/pressurization/cabin-altitude-ft") or 0;
		me.readout_ca.setText(sprintf("%d", me.tmp));
		me.slider_ca.setTranslation(0, -me.tmp*0.025); # 200/9000

		me.tmp = getprop("systems/pressurization/cabin-rate-fpm") or 0;
		me.readout_dp.setText(sprintf("%d", me.tmp));
		me.slider_dp.setTranslation(0, -me.tmp*30); # 300/10

		me.tmp = getprop("systems/pressurization/cabin-rate-fpm") or 0;
		me.readout_cr.setText(sprintf("%d", abs(me.tmp)));

		if(me.tmp > 0) {
			me.arrow_up.show();
			me.arrow_dn.hide();
		}
		else if(me.tmp < 0) {
			me.arrow_up.hide();
			me.arrow_dn.show();
		}
		else {
			me.arrow_up.hide();
			me.arrow_dn.hide();
		}
		me.slider_cr.setTranslation(0, -me.tmp*0.15); # 150/1000

		me.readout_le.setText(sprintf("%d", getprop("systems/pressurization/land_elevation") or 0));
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
