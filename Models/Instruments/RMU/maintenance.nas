var canvas_maintenance = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_maintenance], rects:{} };
		m.group = canvasGroup;
		m.Instance = instance;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/maintenance.svg", {'font-mapper': font_mapper});

		var svg_keys = ["title"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}
		m.title.setText(sprintf("MAINTENANCE DATA SYSTEM %d", m.Instance+1));

		return m;
	},
	BtClick: func(input = -1) {
		if(input == 0 or input == 1) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.strapsmenu);
		}
		if(input == 2 or input == 3) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.software);
		}
		if(input == 4 or input == 5) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.maintlogmenu);
		}
		if(input == 6 or input == 7) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.rmusetup);
		}
		if(input == 10) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.frequencies);
		}
		if(input == 17) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.pagemenu);
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
