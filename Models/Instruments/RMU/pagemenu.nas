var canvas_pagemenu = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_pagemenu], rects:{} };
		m.group = canvasGroup;
		m.Instance = instance;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/pagemenu.svg", {'font-mapper': font_mapper});

		var svg_keys = ["title"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}
		m.title.setText(sprintf("SYSTEM %d PAGE MENU", m.Instance+1));

		return m;
	},
	BtClick: func(input = -1) {
		if(input == 0) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.frequencies);
		}
		if(input == 2) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.memorycom);
		}
		if(input == 3) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.navigation);
		}
		if(input == 4) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.memorycom);
		}
		if(input == 5) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.engine1);
		}
		if(input == 11) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.maintenance);
		}
		if(input == 10 or input == 17) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.frequencies);
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
