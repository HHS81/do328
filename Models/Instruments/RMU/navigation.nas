var hdg = props.globals.getNode("orientation/heading-magnetic-deg");

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

		var svg_keys = ["compass","hdg","navFreq","adfFreq","crs","crsPtr","dme","dmeNA",
				"crsNeedle","vorDirection","markerBeacon","arrowCL","arrowRL","arrowRR",
				"arrowCR","circle","circNeedle", "circIndicator","gsScale","gsPtr",
				"rhombus","rhombNeedle", "rhombIndicator"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		var svg_rects = ["crsRect","navRect","adfRect"];
		for(i=0; i<size(svg_rects); i=i+1) {
			m.rects[i] = canvasGroup.getElementById(svg_rects[i]);
		}

		m.compass.set("clip", "rect(0, 350, 190, 0)");# top,right,bottom,left
		m.crsNeedle.set("clip", "rect(0, 250, 350, 100)");# top,right,bottom,left

		m.ActivateRect(0);
		m.timer = maketimer(0.1, m, m.update);
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
		var crs = getprop("instrumentation/nav["~me.Instance~"]/radials/selected-deg");

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
			me.dme.show();
			me.dmeNA.hide();
		}
		else {
			me.dme.hide();
			me.dmeNA.show();
		}

		if(getprop("instrumentation/nav["~me.Instance~"]/in-range")) {
			var vorDeg = getprop("instrumentation/nav["~me.Instance~"]/radials/reciprocal-radial-deg");

			if(getprop("instrumentation/nav["~me.Instance~"]/has-gs")) {
				# ILS Mode
				if(getprop("instrumentation/nav["~me.Instance~"]/gs-in-range")) {
					me.gsPtr.setTranslation(0,-getprop("instrumentation/nav/gs-needle-deflection-norm")*50);
					me.gsPtr.show();
				}
				else {
					me.gsPtr.hide();
				}

				me.gsScale.show();
				me.vorDirection.hide();
				me.circle.hide();
				me.circNeedle.hide();
				me.arrowCL.hide();
				me.arrowCR.hide();
			}
			else {
				# VOR Mode
				var circDeg = vorDeg - heading;

				if(circDeg < -180) circDeg = circDeg + 360;
				if(circDeg > 180) circDeg = circDeg - 360;

				if(circDeg > 40 and circDeg < 140) {
					me.arrowCL.hide();
					me.arrowCR.show();
				}
				else if(circDeg < -40 and circDeg > -140) {
					me.arrowCL.show();
					me.arrowCR.hide();
				}
				else {
					me.arrowCL.hide();
					me.arrowCR.hide();
				}

				var direction = abs(crs-vorDeg);
				if(direction > 360) {
					diff = diff - 360;
				}
				if(direction < 80 or direction > 280) {
					me.vorDirection.setText("TO");
					me.vorDirection.show();
				}
				else if(direction > 100 and direction < 260) {
					me.vorDirection.setText("FROM");
					me.vorDirection.show();
				}
				else {
					me.vorDirection.hide();
				}

				me.circIndicator.setText(sprintf("%d°", vorDeg));
				me.circNeedle.setRotation(circDeg*D2R);
				me.circle.show();
				me.circNeedle.show();
				me.gsScale.hide();
			}

		}
		else {
			me.circle.hide();
			me.circNeedle.hide();
			me.vorDirection.hide();
			me.arrowCL.hide();
			me.arrowCR.hide();
			me.gsScale.hide();
		}

		if(getprop("instrumentation/adf["~me.Instance~"]/in-range")) {
			var adfDeg = getprop("instrumentation/adf["~me.Instance~"]/indicated-bearing-deg")+heading;
			if(adfDeg > 360) adfDeg = adfDeg - 360;
			if(adfDeg < 0) adfDeg = adfDeg + 360;
			var rhombDeg = adfDeg - heading;

			if(rhombDeg < -180) rhombDeg = rhombDeg + 360;
			if(rhombDeg > 180) rhombDeg = rhombDeg - 360;

			if(rhombDeg > 40 and rhombDeg < 140) {
				me.arrowRL.hide();
				me.arrowRR.show();
			}
			else if(rhombDeg < -40 and rhombDeg > -140) {
				me.arrowRL.show();
				me.arrowRR.hide();
			}
			else {
				me.arrowRL.hide();
				me.arrowRR.hide();
			}

			me.rhombIndicator.setText(sprintf("%d°", adfDeg));
			me.rhombNeedle.setRotation(rhombDeg*D2R);
			me.rhombus.show();
			me.rhombNeedle.show();
		}
		else {
			me.rhombus.hide();
			me.rhombNeedle.hide();
			me.arrowRL.hide();
			me.arrowRR.hide();
		}

		var quality = getprop("instrumentation/nav["~me.Instance~"]/signal-quality-norm") or 0;
		if(quality > 0.95) {
			var deflection = getprop("instrumentation/nav/heading-needle-deflection-norm");
			me.crsPtr.setTranslation(deflection*95, 0);
		}
		else {
			me.crsPtr.setTranslation(0, 0);
		}

		if (getprop("instrumentation/marker-beacon/outer")) {
			me.markerBeacon.show();
			me.markerBeacon.setText("OM");
		} elsif (getprop("instrumentation/marker-beacon/middle")) {
			me.markerBeacon.show();
			me.markerBeacon.setText("MM");
		} elsif (getprop("instrumentation/marker-beacon/inner")) {
			me.markerBeacon.show();
			me.markerBeacon.setText("IM");
		} else {
			me.markerBeacon.hide();
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
		me.update();
		me.timer.start();
		me.group.show();
	},
	hide: func()
	{
		me.timer.stop();
		me.group.hide();
	}
};
