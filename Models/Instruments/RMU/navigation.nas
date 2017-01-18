var hdg = props.globals.getNode("orientation/heading-magnetic-deg");
#instrumentation/nav/heading-needle-deflection

var canvas_navigation = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_navigation], rects:{} };
		m.group = canvasGroup;
		m.Instance = instance;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/navigation.svg", {'font-mapper': font_mapper});

		var svg_keys = ["compass","hdg","navFreq","adfFreq","crs","dme","crsNeedle"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.compass.set("clip", "rect(0, 350, 220, 0)");# top,right,bottom,left
		m.crsNeedle.set("clip", "rect(0, 250, 350, 100)");# top,right,bottom,left

		m.active = 0;
		return m;
	},
	update: func()
	{
		var heading = hdg.getValue();
		var crs = getprop("instrumentation/nav["~me.Instance~"]/radials/selected-deg") or 0;

		if(heading != nil) {
			me.hdg.setText(sprintf("%3.0f",heading));
			me.compass.setRotation(-heading*D2R);
			me.crsNeedle.setRotation((crs-heading)*D2R);
		}

		me.navFreq.setText(sprintf("%.3f",getprop("instrumentation/nav["~me.Instance~"]/frequencies/selected-mhz")));
		me.adfFreq.setText(sprintf("%.3f",getprop("instrumentation/adf["~me.Instance~"]/frequencies/selected-khz")));
		me.crs.setText(sprintf("%3.0f",getprop("instrumentation/nav["~me.Instance~"]/radials/selected-deg")));

	 	if(getprop("instrumentation/nav["~me.Instance~"]/dme-in-range")) {
			me.dme.setText(sprintf("%3.1f", 0.0000621*getprop("instrumentation/nav["~me.Instance~"]/nav-distance")));
		}
		else {
			me.dme.setText("---");
		}

		if(me.active == 1) {
			settimer(func me.update(), 0.1);
		}
	},
	BtClick: func(input = -1) {

		if(input == 17) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", 1);
		}
	},
	Knob: func(index = -1, input = -1) {
		var crs = getprop("instrumentation/nav["~me.Instance~"]/radials/selected-deg") or 0;

		if(index==0) {
			if(input > 0) {
				crs = crs+10;
			}
			else {
				crs = crs-10;
			}
		}
		else {
			if(input > 0) {
				crs = crs+1;
			}
			else {
				crs = crs-1;
			}
		}

		if(crs >= 360) crs = crs-360;
		if(crs < 0) crs = crs+360;

		setprop("instrumentation/nav["~me.Instance~"]/radials/selected-deg", crs);
	},
	show: func()
	{
		me.active = 1;
		me.update();
		me.group.show();
	},
	hide: func()
	{
		me.active = 0;
		me.group.hide();
	}
};
