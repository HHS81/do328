var canvas_maintlog = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_maintlog] };
		m.group = canvasGroup;
		m.Instance = instance;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/maintlog.svg", {'font-mapper': font_mapper});

		var svg_keys = ["title","linel"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		return m;
	},
	BtClick: func(input = -1) {
		if(input == 10) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.frequencies);
		}
		if(input == 11 or input == 17) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.maintlogmenu);
		}
	},
	Knob: func(index = -1, input = -1) {
	},
	show: func()
	{
		var topic = getprop("instrumentation/rmu["~me.Instance~"]/topic");
		
		if(size(topic) > 3) {
			me.linel.show();
		}
		else {
			me.linel.hide();
		}

		me.title.setText(sprintf("%s %d MAINTENANCE LOG", topic, me.Instance+1));
		me.group.show();
	},
	hide: func()
	{
		me.group.hide();
	}
};
