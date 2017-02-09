var canvas_memorycom = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_memorycom] };
		m.group = canvasGroup;
		m.Instance = instance;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/memorycom.svg", {'font-mapper': font_mapper});

		var svg_keys = ["rect1","rect2","rect3","rect4","rect5","rect6"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.ActivateRect(1);
		return m;
	},
	ActivateRect: func(input = -1) {
		for(i=1; i<=6; i=i+1) {
			if(input == i) {
				me["rect"~i].show();
			}
			else {
				me["rect"~i].hide();
			}
		}
		me.ActiveRect = input;
	},
	BtClick: func(input = -1) {
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
