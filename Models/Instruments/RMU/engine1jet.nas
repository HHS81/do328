var canvas_engine1 = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_engine1] };
		m.group = canvasGroup;
		m.Instance = instance;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/engine1jet.svg", {'font-mapper': font_mapper});

		var svg_keys = ["phase1","phase2","arrow1","arrow2","n11","n12","itt1","itt2",
				"n21","n22","fq1","fq2","alt","dp","ign1","ign2"];

		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.arrow1.set("clip", "rect(30, 350, 120, 0)");# top,right,bottom,left
		m.arrow2.set("clip", "rect(30, 350, 120, 0)");# top,right,bottom,left

		m.ign1.setText("MORE");
		m.ign1.setTranslation(-10,0);
		m.ign2.hide();

		m.active = 0;
		return m;
	},
	update: func()
	{
		var phase = getprop("instrumentation/fmc/phase-name") or "";

		var n1 = [	getprop("engines/engine[0]/n1") or 0,
				getprop("engines/engine[1]/n1") or 0];
		var itt = [	getprop("/fdm/jsbsim/propulsion/engine[0]/itt-c") or 0,
				getprop("/fdm/jsbsim/propulsion/engine[1]/itt-c") or 0];
		var n2 = [	getprop("engines/engine[0]/n2") or 0,
				getprop("engines/engine[1]/n2") or 0];
		var fuel = [	getprop("consumables/fuel/tank[0]/level-lbs")+
				getprop("consumables/fuel/tank[1]/level-lbs")+
				getprop("consumables/fuel/tank[2]/level-lbs"),
				getprop("consumables/fuel/tank[3]/level-lbs")+
				getprop("consumables/fuel/tank[4]/level-lbs")+
				getprop("consumables/fuel/tank[5]/level-lbs")];
		var ft =	getprop("systems/pressurization/cabin-altitude-ft") or 0;
		var rate =	getprop("systems/pressurization/cabin-rate-fpm") or 0;

		for(var n=0; n<2; n+=1){
			me["phase"~(n+1)].setText(phase);
			me["arrow"~(n+1)].setTranslation(0,-n1[n]*0.75);
			me["n1"~(n+1)].setText(sprintf("%3.01f",n1[n]));
			me["itt"~(n+1)].setText(sprintf("%3.0f",itt[n]));
			me["n2"~(n+1)].setText(sprintf("%3.01f",n2[n]));
			me["fq"~(n+1)].setText(sprintf("%3.0f",fuel[n]));
		}
		me.alt.setText(sprintf("%3.0f",ft));
		me.dp.setText(sprintf("%3.0f",rate));

		if(me.active == 1) {
			settimer(func me.update(), 0.3);
		}
	},
	BtClick: func(input = -1) {
		if(input == 10) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.engine2);
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
