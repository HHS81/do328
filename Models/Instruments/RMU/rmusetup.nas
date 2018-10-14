var canvas_rmusetup = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_rmusetup] };
		m.group = canvasGroup;
		m.Instance = instance;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/rmusetup.svg", {'font-mapper': font_mapper});

		var svg_keys = ["title","mls_sw","atc_sw","tcasd_sw","tcasr","tcasr_sw","auto_sw"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}
		m.title.setText(sprintf("RMU SETUP SYSTEM %d", m.Instance+1));
		m.tcasd_sw.setText("ENABLED");
		m.tcasr_sw.setText("ENABLED");

		return m;
	},
	BtClick: func(input = -1) {
		if(input == 0 or input == 1) {
			if(getprop("instrumentation/rmu["~me.Instance~"]/mlsDsp") or 0) {
				setprop("instrumentation/rmu["~me.Instance~"]/mlsDsp", 0);
				me.mls_sw.setText("DISABLED");
			}
			else {
				setprop("instrumentation/rmu["~me.Instance~"]/mlsDsp", 1);
				me.mls_sw.setText("ENABLED");
			}
		}
		if(input == 2 or input == 3) {
			if(getprop("instrumentation/rmu["~me.Instance~"]/atcId") or 0) {
				setprop("instrumentation/rmu["~me.Instance~"]/atcId", 0);
				me.atc_sw.setText("DISABLED");
			}
			else {
				setprop("instrumentation/rmu["~me.Instance~"]/atcId", 1);
				me.atc_sw.setText("ENABLED");
			}
		}
		if(input == 4 or input == 5) {
			if(getprop("instrumentation/rmu["~me.Instance~"]/tcasDsp") or 0) {
				setprop("instrumentation/rmu["~me.Instance~"]/tcasDsp", 0);
				me.tcasd_sw.setText("DISABLED");
				me.tcasr.hide();
				me.tcasr_sw.hide();
			}
			else {
				setprop("instrumentation/rmu["~me.Instance~"]/tcasDsp", 1);
				me.tcasd_sw.setText("ENABLED");
				me.tcasr.show();
				me.tcasr_sw.show();
			}
		}
		if((input == 6 or input == 7) and getprop("instrumentation/rmu["~me.Instance~"]/tcasDsp")) {
			if(getprop("instrumentation/rmu["~me.Instance~"]/tcasRange") or 0) {
				setprop("instrumentation/rmu["~me.Instance~"]/tcasRange", 0);
				me.tcasr_sw.setText("DISABLED");
			}
			else {
				setprop("instrumentation/rmu["~me.Instance~"]/tcasRange", 1);
				me.tcasr_sw.setText("ENABLED");
			}
		}
		if(input == 8 or input == 9) {
			if(getprop("instrumentation/rmu["~me.Instance~"]/autoBright") or 0) {
				setprop("instrumentation/rmu["~me.Instance~"]/autoBright", 0);
				me.auto_sw.setText("DISABLED");
			}
			else {
				setprop("instrumentation/rmu["~me.Instance~"]/autoBright", 1);
				me.auto_sw.setText("ENABLED");
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
