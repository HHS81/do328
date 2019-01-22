var canvas_navigation = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_navigation], rects:{} };
		m.Group = canvasGroup;
		m.Instance = instance;
		m.Hdg = 0;
		m.VorDeg = 0;
		m.Tmp = 0;

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
		m.Timer = maketimer(0.1, m, m.update);
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
		me.Hdg = getprop("orientation/heading-magnetic-deg") or 0;
		me.hdg.setText(sprintf("%3.0f", me.Hdg));
		me.compass.setRotation(-me.Hdg*D2R);
		me.crsNeedle.setRotation((getprop("instrumentation/nav["~me.Instance~"]/radials/selected-deg")-me.Hdg)*D2R);

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
			me.VorDeg = getprop("instrumentation/nav["~me.Instance~"]/radials/reciprocal-radial-deg");

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
				me.Tmp = me.VorDeg - me.Hdg;

				if(me.Tmp < -180) me.Tmp = me.Tmp + 360;
				if(me.Tmp > 180) me.Tmp = me.Tmp - 360;

				if(me.Tmp > 40 and me.Tmp < 140) {
					me.arrowCL.hide();
					me.arrowCR.show();
				}
				else if(me.Tmp < -40 and me.Tmp > -140) {
					me.arrowCL.show();
					me.arrowCR.hide();
				}
				else {
					me.arrowCL.hide();
					me.arrowCR.hide();
				}
				me.circNeedle.setRotation(me.Tmp*D2R);
				me.circNeedle.show();

				me.Tmp = abs(getprop("instrumentation/nav["~me.Instance~"]/radials/selected-deg")-me.VorDeg);
				if(me.Tmp > 360) {
					diff = diff - 360;
				}
				if(me.Tmp < 80 or me.Tmp > 280) {
					me.vorDirection.setText("TO");
					me.vorDirection.show();
				}
				else if(me.Tmp > 100 and me.Tmp < 260) {
					me.vorDirection.setText("FROM");
					me.vorDirection.show();
				}
				else {
					me.vorDirection.hide();
				}

				me.circIndicator.setText(sprintf("%d°", me.VorDeg));
				me.circle.show();
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
			var adfDeg = getprop("instrumentation/adf["~me.Instance~"]/indicated-bearing-deg")+me.Hdg;
			if(adfDeg > 360) adfDeg = adfDeg - 360;
			if(adfDeg < 0) adfDeg = adfDeg + 360;
			var rhombDeg = adfDeg - me.Hdg;

			if(rhombDeg < -180) rhombDeg += 360;
			if(rhombDeg > 180) rhombDeg -= 360;

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

		if((getprop("instrumentation/nav["~me.Instance~"]/signal-quality-norm") or 0) > 0.95) {
			me.crsPtr.setTranslation(getprop("instrumentation/nav/heading-needle-deflection-norm")*95, 0);
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
			me.Tmp = getprop("instrumentation/nav["~me.Instance~"]/radials/selected-deg");
			if(input > 0) {
				me.Tmp += step;
			}
			else {
				me.Tmp -= step;
			}
			if(me.Tmp >= 360) me.Tmp -= 360;
			if(me.Tmp < 0) me.Tmp += 360;
			setprop("instrumentation/nav["~me.Instance~"]/radials/selected-deg", me.Tmp);
		}
		if(me.ActiveRect == 1) {
			if(index == 1) {
				#step = 0.025; #wide
				step = 0.05; #narrow
			}
			me.Tmp = getprop("instrumentation/nav["~me.Instance~"]/frequencies/selected-mhz");
			if(input > 0) {
				me.Tmp += step;
			}
			else {
				me.Tmp -= step;
			}
			if(me.Tmp >= 108 and me.Tmp <= 117.95) {
				setprop("instrumentation/nav["~me.Instance~"]/frequencies/selected-mhz", me.Tmp);
			}
		}
		if(me.ActiveRect == 2) {
			if(index == 0) {
				step = 100;
			}
			me.Tmp = getprop("instrumentation/adf["~me.Instance~"]/frequencies/selected-khz");
			if(input > 0) {
				me.Tmp += step;
			}
			else {
				me.Tmp -= step;
			}
			if(me.Tmp >= 180 and me.Tmp <= 1750) {
				setprop("instrumentation/adf["~me.Instance~"]/frequencies/selected-khz", me.Tmp);
			}
		}
	},
	show: func()
	{
		me.update();
		me.Timer.start();
		me.Group.show();
	},
	hide: func()
	{
		me.Timer.stop();
		me.Group.hide();
	}
};
