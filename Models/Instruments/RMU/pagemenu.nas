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

		return m;
	},
	BtClick: func(input = -1) {
		if(input == 0) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", 0);
		}
		if(input == 2) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", 2);
		}
		if(input == 3) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", 4);
		}
		if(input == 4) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", 3);
		}
		if(input == 5) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", 5);
		}
		if(input == 11) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", 6);
		}
		if(input == 10 or input == 17) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", 0);
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
