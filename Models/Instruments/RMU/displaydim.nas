var canvas_displaydim = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_displaydim] };
		m.group = canvasGroup;
		m.Instance = instance;
		m.Dim = 1;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/displaydim.svg", {'font-mapper': font_mapper});

		var svg_keys = ["indicator_dim"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}
		var center = m.indicator_dim.getCenter();
		m.indicator_dim.createTransform().setTranslation(-center[0], -center[1]);
		m.indicator_dim_scale = m.indicator_dim.createTransform();
		m.indicator_dim.createTransform().setTranslation(center[0], center[1]);
		m.indicator_dim_scale.setScale(1,1);

		return m;
	},
	BtClick: func(input = -1) {
	},
	Knob: func(index = -1, input = -1) {
		me.Dim += 0.05*input;

		if(me.Dim > 1) {
			me.Dim = 1;
		}
		if(me.Dim < 0) {
			me.Dim = 0;
		}
		me.indicator_dim_scale.setScale(me.Dim,1);

		if(0.6*me.Dim > 0.5) {
			setprop("instrumentation/rmu["~me.Instance~"]/lighting", 1);
		}
		else {
			setprop("instrumentation/rmu["~me.Instance~"]/lighting", 0.6*me.Dim);
		}
	},
	show: func()
	{
		setprop("instrumentation/rmu["~me.Instance~"]/autoBright", 0);
		me.group.show();
	},
	hide: func()
	{
		me.group.hide();
	}
};
