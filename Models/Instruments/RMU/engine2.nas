var canvas_engine2 = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_engine2] };
		m.group = canvasGroup;
		m.Instance = instance;
		m.n = 0;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/engine2.svg", {'font-mapper': font_mapper});

		var svg_keys = ["ff1","ff2","oilt1","oilt2","oilp1","oilp2"];

		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.active = 0;
		return m;
	},
	update: func()
	{
		for(me.n=0; me.n<2; me.n+=1){
			me["ff"~(me.n+1)].setText(sprintf("%3.0f",(getprop("engines/engine["~me.n~"]/fuel-flow_pph") or 0)));
			me["oilt"~(me.n+1)].setText(sprintf("%3.0f",(getprop("engines/engine["~me.n~"]/oil-temperature-degf") or 0)));
			me["oilp"~(me.n+1)].setText(sprintf("%3.0f",(getprop("engines/engine["~me.n~"]/oil-pressure-psi") or 0)));
		}

		if(me.active == 1) {
			settimer(func me.update(), 0.3);
		}
	},
	BtClick: func(input = -1) {
		if(input == 10) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.engine1);
		}
		if(input == 17) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.pagemenu);
		}
	},
	Knob: func(index = -1, input = -1) {
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
