var canvas_eicas = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_eicas] };
		m.group = canvasGroup;
		
		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};
		
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/eicasJet.svg", {'font-mapper': font_mapper});

		var svg_keys = ["msgMemo","msgWarning","msgCaution","msgAdvisory",
				"readout_n1_1","readout_n1_2","dial_n1_1","dial_n1_2",
				"readout_itt1","readout_itt2","dial_itt1","dial_itt2",
				"readout_n2_1","readout_n2_2","dial_n2_1","dial_n2_2",
				"readout_ft","readout_fpm"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.active = 0;
		return m;
	},
	slow_update: func()
	{
		me["msgWarning"].setText(getprop("instrumentation/eicas/msg/warning"));
		me["msgCaution"].setText(getprop("instrumentation/eicas/msg/caution"));
		me["msgAdvisory"].setText(getprop("instrumentation/eicas/msg/advisory"));
		me["msgMemo"].setText(getprop("instrumentation/eicas/msg/memo"));

		settimer(func me.slow_update(), 0.3);
	},
	fast_update: func()
	{
		var n1 = [0,getprop("engines/engine[0]/n1"),getprop("engines/engine[1]/n1")];
		var itt = [0,getprop("/fdm/jsbsim/propulsion/engine[0]/itt-c"),getprop("/fdm/jsbsim/propulsion/engine[1]/itt-c")];
		var n2 = [0,getprop("engines/engine[0]/n2"),getprop("engines/engine[1]/n2")];
		var ft = getprop("systems/pressurization/cabin-altitude-ft") or 0;
		var rate = getprop("systems/pressurization/cabin-rate-fpm") or 0;

		for(var n = 1; n<=2; n+=1){

			if(n1[n] != nil){
				me["readout_n1_"~n].setText(sprintf("%3.01f",n1[n]));

				if (n1[n] > 0){
					me["dial_n1_"~n].setRotation(n1[n] * (270/100) * math.pi/180);
				}
			}

			if(itt[n] != nil){
				me["readout_itt"~n].setText(sprintf("%3.0f",itt[n]));
				me["dial_itt"~n].setRotation(itt[n] * (270/730) * math.pi/180);
			}

			if(n2[n] != nil){
				me["readout_n2_"~n].setText(sprintf("%3.01f",n2[n]));

				if (n1[n] > 0){
					me["dial_n2_"~n].setRotation(n2[n] * (270/100) * math.pi/180);
				}
			}

		}

		me.readout_ft.setText(sprintf("%3.0f",ft));
		me.readout_fpm.setText(sprintf("%3.0f",rate));

		if(me.active == 1) {
			settimer(func me.fast_update(), 0.1);
		}
	},
	show: func()
	{
		me.active = 1;
		me.fast_update();
		me.slow_update();
		me.group.show();
	},
	hide: func()
	{
		me.active = 0;
		me.group.hide();
	}
};
