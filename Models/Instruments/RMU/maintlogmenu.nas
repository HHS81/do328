var canvas_maintlogmenu = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_maintlogmenu] };
		m.group = canvasGroup;
		m.Instance = instance;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/maintlogmenu.svg", {'font-mapper': font_mapper});

		var svg_keys = ["title"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}
		m.title.setText(sprintf("MAINTENANCE LOG SYSTEM %d", m.Instance+1));

		return m;
	},
	BtClick: func(input = -1) {
		if(input == 0) {
			setprop("instrumentation/rmu["~me.Instance~"]/topic", "COM");
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.maintlog);
		}
		if(input == 1) {
			setprop("instrumentation/rmu["~me.Instance~"]/topic", "NAV");
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.maintlog);
		}
		if(input == 2) {
			setprop("instrumentation/rmu["~me.Instance~"]/topic", "COM UNIT");
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.maintlog);
		}
		if(input == 3) {
			setprop("instrumentation/rmu["~me.Instance~"]/topic", "NAV UNIT");
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.maintlog);
		}
		if(input == 4) {
			setprop("instrumentation/rmu["~me.Instance~"]/topic", "ATC");
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.maintlog);
		}
		if(input == 5) {
			setprop("instrumentation/rmu["~me.Instance~"]/topic", "DME");
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.maintlog);
		}
		if(input == 7) {
			setprop("instrumentation/rmu["~me.Instance~"]/topic", "ADF");
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.maintlog);
		}
		if(input == 8) {
			setprop("instrumentation/rmu["~me.Instance~"]/topic", "RMU");
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.maintlog);
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
