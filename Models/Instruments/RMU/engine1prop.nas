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
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/engine1prop.svg", {'font-mapper': font_mapper});

		var svg_keys = ["phase1","phase2","arrow1","arrow2","tq1","tq2","np1","np2",
				"itt1","itt2","nh1","nh2","fq1","fq2","alt","dp","ign1","ign2"];

		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.arrow1.set("clip", "rect(30, 350, 120, 0)");# top,right,bottom,left
		m.arrow2.set("clip", "rect(30, 350, 120, 0)");# top,right,bottom,left

		m.ign1.setText("MORE");
		m.ign1.setTranslation(-10,0);
		m.ign2.hide();

		m.timer = maketimer(0.1, m, m.update);
		return m;
	},
	update: func()
	{
		for(var n=0; n<2; n+=1){
			me["phase"~(n+1)].setText(getprop("instrumentation/fmc/phase-name") or "");
			me["arrow"~(n+1)].setTranslation(0, -(getprop("fdm/jsbsim/propulsion/engine["~n~"]/trq-percent") or 0)*0.75);
			me["tq"~(n+1)].setText(sprintf("%3.01f", getprop("fdm/jsbsim/propulsion/engine["~n~"]/trq-percent") or 0));
			me["np"~(n+1)].setText(sprintf("%3.01f", getprop("fdm/jsbsim/propulsion/engine["~n~"]/propeller-rpm") or 0));
			me["itt"~(n+1)].setText(sprintf("%3.0f", getprop("/fdm/jsbsim/propulsion/engine["~n~"]/itt-c") or 0));
			me["nh"~(n+1)].setText(sprintf("%3.01f", getprop("engines/engine["~n~"]/n1") or 0));
			me["fq"~(n+1)].setText(sprintf("%3.0f", getprop("consumables/fuel/tank["~((n*3)+0)~"]/level-lbs")+
								getprop("consumables/fuel/tank["~((n*3)+1)~"]/level-lbs")+
								getprop("consumables/fuel/tank["~((n*3)+2)~"]/level-lbs")));
		}

		me.alt.setText(sprintf("%3.0f", getprop("systems/pressurization/cabin-altitude-ft") or 0));
		me.dp.setText(sprintf("%3.0f", getprop("systems/pressurization/cabin-rate-fpm") or 0));
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
