var canvas_software = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_software] };
		m.group = canvasGroup;
		m.Instance = instance;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/software.svg", {'font-mapper': font_mapper});

		var svg_keys = ["fgversion","osgversion","glversion", "glslversion"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.fgversion.setText(getprop("sim/version/flightgear"));
		m.osgversion.setText(getprop("sim/version/openscenegraph"));
		m.glversion.setText(getprop("sim/rendering/gl-version"));
		m.glslversion.setText(getprop("sim/rendering/gl-shading-language-version"));

		return m;
	},
	BtClick: func(input = -1) {
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
