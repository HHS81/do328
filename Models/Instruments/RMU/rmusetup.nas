var canvas_rmusetup = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_rmusetup], rects:{} };
		m.group = canvasGroup;
		m.Instance = instance;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/rmusetup.svg", {'font-mapper': font_mapper});

		var svg_keys = ["title","atc_sw","tcasd_sw","tcasr","tcasr_sw"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}
		m.title.setText(sprintf("RMU SETUP SYSTEM %d", m.Instance+1));
		m.tcasd_sw.setText("ENABLED");
		m.tcasr_sw.setText("ENABLED");

		return m;
	},
	BtClick: func(input = -1) {
		if(input == 2 or input == 3) {
			var atcId = getprop("instrumentation/rmu["~me.Instance~"]/atcId");

			if(atcId) {
				setprop("instrumentation/rmu["~me.Instance~"]/atcId", 0);
				me.atc_sw.setText("DISABLED");
			}
			else {
				setprop("instrumentation/rmu["~me.Instance~"]/atcId", 1);
				me.atc_sw.setText("ENABLED");
			}
		}
		if(input == 4 or input == 5) {
			var tcasDisplay = getprop("instrumentation/rmu["~me.Instance~"]/tcasDisplay");

			if(tcasDisplay) {
				setprop("instrumentation/rmu["~me.Instance~"]/tcasDisplay", 0);
				me.tcasd_sw.setText("DISABLED");
				me.tcasr.hide();
				me.tcasr_sw.hide();
			}
			else {
				setprop("instrumentation/rmu["~me.Instance~"]/tcasDisplay", 1);
				me.tcasd_sw.setText("ENABLED");
				me.tcasr.show();
				me.tcasr_sw.show();
			}
		}
		if((input == 6 or input == 7) and getprop("instrumentation/rmu["~me.Instance~"]/tcasDisplay")) {
			var tcasRange = getprop("instrumentation/rmu["~me.Instance~"]/tcasRange");

			if(tcasRange) {
				setprop("instrumentation/rmu["~me.Instance~"]/tcasRange", 0);
				me.tcasr_sw.setText("DISABLED");
			}
			else {
				setprop("instrumentation/rmu["~me.Instance~"]/tcasRange", 1);
				me.tcasr_sw.setText("ENABLED");
			}
		}
		if(input == 10) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.frequencies);
		}
		if(input == 11 or input == 17) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.maintenance);
		}
	},
	Knob: func(index = -1, input = -1) {
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
