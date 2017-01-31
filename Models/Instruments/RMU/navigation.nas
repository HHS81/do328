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

		var svg_keys = ["compass","hdg","navFreq","adfFreq","crs","crsPtr","dme","crsNeedle",
				"circle","circNeedle", "circIndicator",
				"rhombus","rhombNeedle", "rhombIndicator"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		var svg_rects = ["crsRect","navRect","adfRect"];
		for(i=0; i<size(svg_rects); i=i+1) {
			m.rects[i] = canvasGroup.getElementById(svg_rects[i]);
		}

		m.compass.set("clip", "rect(0, 350, 220, 0)");# top,right,bottom,left
		m.crsNeedle.set("clip", "rect(0, 250, 350, 100)");# top,right,bottom,left

		m.ActivateRect(0);
		m.active = 0;
		return m;
	},
	ActivateRect: func(input = -1) {
		for(i=0; i<size(me.rects); i=i+1) {
			if(input == i) {
				me.rects[i].show();
			}
			else {
				me.rects[i].hide();
			}
		}
		me.ActiveRect = input;
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

		me.navFreq.setText(sprintf("%.2f",getprop("instrumentation/nav["~me.Instance~"]/frequencies/selected-mhz")));
		me.adfFreq.setText(sprintf("%.1f",getprop("instrumentation/adf["~me.Instance~"]/frequencies/selected-khz")));
		me.crs.setText(sprintf("%3.0f",getprop("instrumentation/nav["~me.Instance~"]/radials/selected-deg")));

	 	if(getprop("instrumentation/nav["~me.Instance~"]/dme-in-range")) {
			me.dme.setText(sprintf("%3.1f", 0.0000621*getprop("instrumentation/nav["~me.Instance~"]/nav-distance")));
			me.dme.setColor(green);
		}
		else {
			me.dme.setText("---");
			me.dme.setColor(amber);
		}

		if(getprop("instrumentation/nav["~me.Instance~"]/in-range")) {
			var vorDeg = getprop("instrumentation/nav["~me.Instance~"]/radials/reciprocal-radial-deg");
			me.circIndicator.setText(sprintf("%d°", vorDeg));
			me.circNeedle.setRotation(vorDeg*D2R);
			me.circle.show();
			me.circNeedle.show();
		}
		else {
			me.circle.hide();
			me.circNeedle.hide();
		}

		if(getprop("instrumentation/adf["~me.Instance~"]/in-range")) {
			var adfDeg = getprop("instrumentation/adf["~me.Instance~"]/indicated-bearing-deg")+heading;
			if(adfDeg > 360) adfDeg = adfDeg - 360;
			if(adfDeg < 0) adfDeg = adfDeg + 360;
			me.rhombIndicator.setText(sprintf("%d°", adfDeg));
			me.rhombNeedle.setRotation(adfDeg*D2R);
			me.rhombus.show();
			me.rhombNeedle.show();
		}
		else {
			me.rhombus.hide();
			me.rhombNeedle.hide();
		}

		var quality = getprop("instrumentation/nav["~me.Instance~"]/signal-quality-norm") or 0;
		if(quality > 0.95) {
			var deflection = getprop("instrumentation/nav/heading-needle-deflection-norm");
			me.crsPtr.setTranslation(deflection*95, 0);
		}
		else {
			me.crsPtr.setTranslation(0, 0);
		}

		if(me.active == 1) {
			settimer(func me.update(), 0.1);
		}
	},
	BtClick: func(input = -1) {
		if(input == 0) {
			me.ActivateRect(1);
		}
		if(input == 1) {
			me.ActivateRect(2);
		}
		if(input == 10) {
			me.ActivateRect(0);
		}
		if(input == 17) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.pagemenu);
		}
	},
	Knob: func(index = -1, input = -1) {
		var step = 1;

		if(me.ActiveRect == 0) {
			if(index == 0) {
				step = 10;
			}
			var crs = getprop("instrumentation/nav["~me.Instance~"]/radials/selected-deg");
			if(input > 0) {
				crs = crs + step;
			}
			else {
				crs = crs - step;
			}
			if(crs >= 360) crs = crs-360;
			if(crs < 0) crs = crs+360;

			setprop("instrumentation/nav["~me.Instance~"]/radials/selected-deg", crs);
		}
		if(me.ActiveRect == 1) {
			if(index == 1) {
				#step = 0.025;#wide
				step = 0.05;#narrow
			}
			var freq = getprop("instrumentation/nav["~me.Instance~"]/frequencies/selected-mhz");
			if(input > 0) {
				freq = freq + step;
			}
			else {
				freq = freq - step;
			}
			if(freq >= 108 and freq <= 117.95) {
				setprop("instrumentation/nav["~me.Instance~"]/frequencies/selected-mhz", freq);
			}
		}
		if(me.ActiveRect == 2) {
			if(index == 0) {
				step = 100;
			}
			var freq = getprop("instrumentation/adf["~me.Instance~"]/frequencies/selected-khz");
			if(input > 0) {
				freq = freq + step;
			}
			else {
				freq = freq - step;
			}
			if(freq >= 180 and freq <= 1750) {
				setprop("instrumentation/adf["~me.Instance~"]/frequencies/selected-khz", freq);
			}
		}
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
