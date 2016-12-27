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

		m.active = 0;
		return m;
	},
	update: func()
	{
		var tq = [0,getprop("/fdm/jsbsim/propulsion/engine[0]/trq-percent"), getprop("/fdm/jsbsim/propulsion/engine[1]/trq-percent")];
		var np = [0,getprop("/fdm/jsbsim/propulsion/engine[0]/propeller-rpm"),getprop("/fdm/jsbsim/propulsion/engine[1]/propeller-rpm")];
		var itt = [0,getprop("/fdm/jsbsim/propulsion/engine[0]/itt-c"),getprop("/fdm/jsbsim/propulsion/engine[1]/itt-c")];
		var nh = [0,getprop("engines/engine[0]/n1"),getprop("engines/engine[0]/n1")];
		var ft = getprop("systems/pressurization/cabin-altitude-ft") or 0;
		var rate = getprop("systems/pressurization/cabin-rate-fpm") or 0;

		for(var n = 1; n<=2; n+=1){
			if(tq[n] != nil){
				me["readout_tq"~n].setText(sprintf("%3.01f",tq[n]));
				me["dial_tq"~n].setRotation(tq[n] * (270/100) * math.pi/180);
			}

			if(np[n] != nil){
				me["readout_np"~n].setText(sprintf("%3.01f",np[n]/13));
				me["dial_np"~n].setRotation(np[n] * (270/1300) * math.pi/180);
			}

			if(itt[n] != nil){
				me["readout_itt"~n].setText(sprintf("%3.0f",itt[n]));
				me["dial_itt"~n].setRotation(itt[n] * (270/730) * math.pi/180);
			}

			if(nh[n] != nil){
				me["readout_nh"~n].setText(sprintf("%3.01f",nh[n]));

				if (nh[n] > 0){
					me["dial_nh"~n].setRotation(nh[n] * (270/100) * math.pi/180);
				}
			}

		}

		me.readout_ft.setText(sprintf("%3.0f",ft));
		me.readout_fpm.setText(sprintf("%3.0f",rate));

		me.msgWarning.setText(getprop("instrumentation/eicas/msg/warning"));
		me.msgCaution.setText(getprop("instrumentation/eicas/msg/caution"));
		me.msgAdvisory.setText(getprop("instrumentation/eicas/msg/advisory"));
		me.msgMemo.setText(getprop("instrumentation/eicas/msg/memo"));

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
