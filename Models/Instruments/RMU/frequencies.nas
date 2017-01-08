var canvas_frequencies = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_frequencies], rects:{} };
		m.group = canvasGroup;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/frequencies.svg", {'font-mapper': font_mapper});

		var svg_keys = ["comFreq","navFreq","comStby", "navStby",
				"trspCode","trspMode","trspNum","adfFreq",
				"memCom","memNav","comNum","navNum","adfNum","mlsNum"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		var svg_rects = ["comStbyRect","navStbyRect","trspCodeRect",
				"adfRect","trspModeRect"];
		for(i=0; i<size(svg_rects); i=i+1) {
			m.rects[i] = canvasGroup.getElementById(svg_rects[i]);
		}

		m.comNum.setText(sprintf("%d",instance+1));
		m.navNum.setText(sprintf("%d",instance+1));
		m.adfNum.setText(sprintf("%d",instance+1));
		m.mlsNum.setText(sprintf("%d",instance+1));
		m.trspNum.setText("1");
		m.memCom.setText("MEMORY-1");
		m.memNav.setText("MEMORY-1");

		m.Instance = instance;
		m.ActivateRect(0);
		m.update();
		return m;
	},
	ActivateRect: func(input = -1) {
		for(i=0; i<size(me.rects); i=i+1) {
			if(input == i) {
				me.rects[i].show();
			}
			else {
				me.rects[i].hide();
			}
		}
		me.ActiveRect = input;
	},
	update: func() {
		me.comFreq.setText(sprintf("%.3f",getprop("instrumentation/comm["~me.Instance~"]/frequencies/selected-mhz")));
		me.comStby.setText(sprintf("%.3f",getprop("instrumentation/comm["~me.Instance~"]/frequencies/standby-mhz")));
		me.navFreq.setText(sprintf("%.3f",getprop("instrumentation/nav["~me.Instance~"]/frequencies/selected-mhz")));
		me.navStby.setText(sprintf("%.3f",getprop("instrumentation/nav["~me.Instance~"]/frequencies/standby-mhz")));
		me.adfFreq.setText(sprintf("%d",getprop("instrumentation/adf["~me.Instance~"]/frequencies/selected-khz")));
	},
	BtClick: func(input = -1) {

		if(input == 0) {
			var sel = getprop("instrumentation/comm["~me.Instance~"]/frequencies/selected-mhz");
			var stby = getprop("instrumentation/comm["~me.Instance~"]/frequencies/standby-mhz");
			setprop("instrumentation/comm["~me.Instance~"]/frequencies/selected-mhz", stby);
			setprop("instrumentation/comm["~me.Instance~"]/frequencies/standby-mhz", sel);
		}
		if(input == 1) {
			var sel = getprop("instrumentation/nav["~me.Instance~"]/frequencies/selected-mhz");
			var stby = getprop("instrumentation/nav["~me.Instance~"]/frequencies/standby-mhz");
			setprop("instrumentation/nav["~me.Instance~"]/frequencies/selected-mhz", stby);
			setprop("instrumentation/nav["~me.Instance~"]/frequencies/standby-mhz", sel);
		}
		if(input == 2) {
			me.ActivateRect(0);
		}
		if(input == 3) {
			me.ActivateRect(1);
		}
		if(input == 4) {
			me.ActivateRect(2);
		}
		if(input == 5) {
			me.ActivateRect(3);
		}
		me.update();
	},
	Knob: func(index = -1, input = -1) {
		var step = 1;

		if(me.ActiveRect == 0) {
			if(index == 1) {
				step = 0.025;
			}
			var freq = getprop("instrumentation/comm["~me.Instance~"]/frequencies/standby-mhz");
			if(input > 0) {
				freq = freq + step;
			}
			else {
				freq = freq - step;
			}
			if(freq >= 117.975 and freq <= 137) {
				setprop("instrumentation/comm["~me.Instance~"]/frequencies/standby-mhz", freq);
			}
		}
		if(me.ActiveRect == 1) {
			if(index == 1) {
				step = 0.025;
			}
			var freq = getprop("instrumentation/nav["~me.Instance~"]/frequencies/standby-mhz");
			if(input > 0) {
				freq = freq + step;
			}
			else {
				freq = freq - step;
			}
			if(freq >= 108 and freq <= 117.95) {
				setprop("instrumentation/nav["~me.Instance~"]/frequencies/standby-mhz", freq);
			}
		}
		if(me.ActiveRect == 3) {
			if(index == 0) {
				step = 100;
			}
			var freq = getprop("instrumentation/adf["~me.Instance~"]/frequencies/selected-khz");
			if(input > 0) {
				freq = freq + step;
			}
			else {
				freq = freq - step;
			}
			if(freq >= 180 and freq <= 1750) {
				setprop("instrumentation/adf["~me.Instance~"]/frequencies/selected-khz", freq);
			}
		}
		me.update();
	},
	show: func()
	{
		me.group.show();
	},
	hide: func()
	{
		me.group.hide();
	}
};
