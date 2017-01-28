var canvas_straps = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_straps], rects:{} };
		m.group = canvasGroup;
		m.Instance = instance;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/straps.svg", {'font-mapper': font_mapper});

		return m;
	},
	BtClick: func(input = -1) {
		if(input == 10) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.frequencies);
		}
		if(input == 11 or input == 17) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.strapsmenu);
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
