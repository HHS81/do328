var canvas_flightctrl = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_flightctrl] };
		m.group = canvasGroup;
		m.tmp = 0;
		
		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};
		
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/flightctrl.svg", {'font-mapper': font_mapper});
		
		var svg_keys = ["indicator_elev1","indicator_elev2",
				"indicator_rud",
				"indicator_ail1","indicator_ail2",
				"indicator_flaps1","indicator_flaps2",
				"readout_flaps1","readout_flaps2"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		var center = {};
		for(m.tmp=1; m.tmp<=2; m.tmp+=1) {
			center = m["indicator_elev"~m.tmp].getCenter();
			m["indicator_elev"~m.tmp].createTransform().setTranslation(-center[0], -center[1]);
			m["indicator_elev"~m.tmp~"_scale"] = m["indicator_elev"~m.tmp].createTransform();
			m["indicator_elev"~m.tmp].createTransform().setTranslation(center[0], center[1]);
			m["indicator_elev"~m.tmp~"_scale"].setScale(1,0);

			center = m["indicator_ail"~m.tmp].getCenter();
			m["indicator_ail"~m.tmp].createTransform().setTranslation(-center[0], -center[1]);
			m["indicator_ail"~m.tmp~"_scale"] = m["indicator_ail"~m.tmp].createTransform();
			m["indicator_ail"~m.tmp].createTransform().setTranslation(center[0], center[1]);
			m["indicator_ail"~m.tmp~"_scale"].setScale(1,0);

			center = m["indicator_flaps"~m.tmp].getCenter();
			m["indicator_flaps"~m.tmp].createTransform().setTranslation(-center[0], -center[1]);
			m["indicator_flaps"~m.tmp~"_scale"] = m["indicator_flaps"~m.tmp].createTransform();
			m["indicator_flaps"~m.tmp].createTransform().setTranslation(center[0], center[1]);
			m["indicator_flaps"~m.tmp~"_scale"].setScale(1,0);
		}
		center = m.indicator_rud.getCenter();
		m.indicator_rud.createTransform().setTranslation(-center[0], -center[1]);
		m.indicator_rud_scale = m.indicator_rud.createTransform();
		m.indicator_rud.createTransform().setTranslation(center[0], center[1]);
		m.indicator_rud_scale.setScale(0,1);

		m.active = 0;
		return m;
	},
	update: func()
	{
		me.tmp = getprop("controls/flight/elevator");
		me.indicator_elev1_scale.setScale(1,me.tmp);
		me.indicator_elev2_scale.setScale(1,me.tmp);

		me.indicator_rud_scale.setScale(getprop("controls/flight/rudder"),1);

		me.tmp = getprop("controls/flight/aileron");
		me.indicator_ail1_scale.setScale(1,-me.tmp);
		me.indicator_ail2_scale.setScale(1,me.tmp);

		me.tmp = getprop("surface-positions/flap-pos-norm");
		me.indicator_flaps1_scale.setScale(1,me.tmp);
		me.indicator_flaps2_scale.setScale(1,me.tmp);
		me.readout_flaps1.setText(sprintf("%2.0f",32*me.tmp));
		me.readout_flaps2.setText(sprintf("%2.0f",32*me.tmp));

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
