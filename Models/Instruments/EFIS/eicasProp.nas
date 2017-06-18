var canvas_eicas = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_eicas] };
		m.frameCounter = 0;
		m.group = canvasGroup;

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};
		
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/eicasProp.svg", {'font-mapper': font_mapper});
		
		var svg_keys = ["msgMemo","msgWarning","msgCaution","msgAdvisory",
				"readout_tq1","readout_tq2","dial_tq1","dial_tq2",
				"readout_np1","readout_np2","dial_np1","dial_np2",
				"readout_itt1","readout_itt2","dial_itt1","dial_itt2",
				"readout_nh1","readout_nh2","dial_nh1","dial_nh2",
				"readout_ft","readout_fpm"];

		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.msgMemo.setText("");
		m.msgWarning.setText("");
		m.msgCaution.setText("");
		m.msgAdvisory.setText("");

		m.active = 0;
		return m;
	},
	update: func()
	{
		me.updateFast();

		me.frameCounter += 1;
		if(me.frameCounter > 3) {
			me.frameCounter = 0;
			me.updateSlow();
		}

		if(me.active == 1) {
			settimer(func me.update(), 0.1);
		}
	},
	updateFast: func()
	{
		for(me.n = 0; me.n<2; me.n+=1) {
			me["dial_tq"~(me.n+1)].setRotation((270/100) * D2R *
					(getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/trq-percent") or 0));

			me["dial_np"~(me.n+1)].setRotation((270/1300) * D2R *
					(getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/propeller-rpm") or 0));

			me["dial_itt"~(me.n+1)].setRotation((270/730) * D2R *
					(getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/itt-c") or 0));

			me["dial_nh"~(me.n+1)].setRotation((270/100) * D2R *
					(getprop("engines/engine[0]/n1") or 0));
		}
	},
	updateSlow: func()
	{
		for(me.n = 0; me.n<2; me.n+=1) {
			me["readout_tq"~(me.n+1)].setText(sprintf("%3.01f", 
				getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/trq-percent") or 0));

			me["readout_np"~(me.n+1)].setText(sprintf("%3.01f",
				(getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/propeller-rpm") or 0)/13));

			me["readout_itt"~(me.n+1)].setText(sprintf("%3.0f",
				getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/itt-c") or 0));

			me["readout_nh"~(me.n+1)].setText(sprintf("%3.01f", getprop("engines/engine[0]/n1") or 0));
		}

		me.readout_ft.setText(sprintf("%3.0f", getprop("systems/pressurization/cabin-altitude-ft") or 0));
		me.readout_fpm.setText(sprintf("%3.0f", getprop("systems/pressurization/cabin-rate-fpm") or 0));

		#me.msgWarning.setText(getprop("instrumentation/eicas/msg/warning"));
		#me.msgCaution.setText(getprop("instrumentation/eicas/msg/caution"));
		#me.msgAdvisory.setText(getprop("instrumentation/eicas/msg/advisory"));
		#me.msgMemo.setText(getprop("instrumentation/eicas/msg/memo"));
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
