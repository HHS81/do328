var canvas_flightctrl = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_flightctrl] };
		m.group = canvasGroup;
		
		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "LiberationFonts/LiberationSans-Regular.ttf";
			}
		};
		
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EICAS/flightctrl.svg", {'font-mapper': font_mapper});
		
		var svg_keys = ["indicator_elev1","indicator_elev2",
				"indicator_rud",
				"indicator_ail1","indicator_ail2",
				"indicator_flaps1","indicator_flaps2",
				"readout_flaps1","readout_flaps2"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		var center = {};
		for(var n=1; n<=2; n=n+1) {
			center = m["indicator_elev"~n].getCenter();
			m["indicator_elev"~n].createTransform().setTranslation(-center[0], -center[1]);
			m["indicator_elev"~n~"_scale"] = m["indicator_elev"~n].createTransform();
			m["indicator_elev"~n].createTransform().setTranslation(center[0], center[1]);
			m["indicator_elev"~n~"_scale"].setScale(1,0);

			center = m["indicator_ail"~n].getCenter();
			m["indicator_ail"~n].createTransform().setTranslation(-center[0], -center[1]);
			m["indicator_ail"~n~"_scale"] = m["indicator_ail"~n].createTransform();
			m["indicator_ail"~n].createTransform().setTranslation(center[0], center[1]);
			m["indicator_ail"~n~"_scale"].setScale(1,0);

			center = m["indicator_flaps"~n].getCenter();
			m["indicator_flaps"~n].createTransform().setTranslation(-center[0], -center[1]);
			m["indicator_flaps"~n~"_scale"] = m["indicator_flaps"~n].createTransform();
			m["indicator_flaps"~n].createTransform().setTranslation(center[0], center[1]);
			m["indicator_flaps"~n~"_scale"].setScale(1,0);
		}
		center = m["indicator_rud"].getCenter();
		m["indicator_rud"].createTransform().setTranslation(-center[0], -center[1]);
		m["indicator_rud_scale"] = m["indicator_rud"].createTransform();
		m["indicator_rud"].createTransform().setTranslation(center[0], center[1]);
		m["indicator_rud_scale"].setScale(0,1);

		m.active = 0;
		return m;
	},
	update: func()
	{
		var flctrl = [	getprop("controls/flight/elevator"),
				getprop("controls/flight/rudder"),
				getprop("controls/flight/aileron"),
				getprop("controls/flight/flaps"),
				getprop("surface-positions/flap-pos-norm")];

		me["indicator_elev1_scale"].setScale(1,flctrl[0]);
		me["indicator_elev2_scale"].setScale(1,flctrl[0]);
		me["indicator_rud_scale"].setScale(flctrl[1],1);
		me["indicator_ail1_scale"].setScale(1,-flctrl[2]);
		me["indicator_ail2_scale"].setScale(1,flctrl[2]);
		me["indicator_flaps1_scale"].setScale(1,flctrl[4]);
		me["indicator_flaps2_scale"].setScale(1,flctrl[4]);
		me["readout_flaps1"].setText(sprintf("%2.0f",32*flctrl[3]));
		me["readout_flaps2"].setText(sprintf("%2.0f",32*flctrl[3]));

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
