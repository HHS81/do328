var canvas_displaydim = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_displaydim], rects:{} };
		m.group = canvasGroup;
		m.Instance = instance;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/displaydim.svg", {'font-mapper': font_mapper});

		return m;
	},
	BtClick: func(input = -1) {
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
