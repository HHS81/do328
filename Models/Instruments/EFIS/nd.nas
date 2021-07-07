var ndlayers = [{name:'APT_do',style:{scale_factor:0.6,label_font_color:[1,1,1],color_default:[1,1,1],line_width:4}},
		{name:'DME_do',style:{scale_factor:0.6,color_default:[0,1,0],line_width:4}},
		{name:'WPT_do',style:{scale_factor:0.6,line_width:4}},
		{name:'WXR_do',style:{scale_factor:0.6,line_width:4}},
		{name:'RTE',style:{scale_factor:0.6,color:[0,1,0],line_width:3}}];

var hdg = props.globals.getNode("orientation/heading-magnetic-deg");
var hdgBug = props.globals.getNode("autopilot/settings/heading-bug-deg");
var lon = props.globals.getNode("position/longitude-deg");
var lat = props.globals.getNode("position/latitude-deg");
var index = 0;
var scales = [2.5,5,12.5,25,50,100]; # zoom scales

var do328_controller = {
	parents: [canvas.Map.Controller],

	new: func(map) {
		var m = { parents: [do328_controller],
			map: map,
			apt: map.getLayer('APT_do'),
			dme: map.getLayer('DME_do'),
			wxr: map.getLayer('WXR_do')
			};
		m.index = index;
		m.apt.hide();
		m.dme.hide();
		m.wxr.hide();

		setlistener("instrumentation/efis/trigger_nd"~index, func{
			m.map.setRange(1.2*scales[Range[m.index]]);
			m.map.setPos(lat.getValue(), lon.getValue(), hdg.getValue());
			m.map.update();
		});

		setlistener("instrumentation/efis/wptIdent"~index, func{
			m.map.update();
		});

		setlistener("instrumentation/efis/wxGmap"~index, func{
			if(getprop("instrumentation/efis/wxGmap"~m.index)) {
				m.wxr.show();
			}
			else {
				m.wxr.hide();
			}
			m.map.update();
		});

		setlistener("instrumentation/efis/navaid"~index, func{
			if(getprop("instrumentation/efis/navaid"~m.index)) {
				m.apt.show();
				m.dme.show();
			}
			else {
				m.apt.hide();
				m.dme.hide();
			}
			m.map.update();
		});
		return m;
	}
};

var canvas_nd = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_nd] };
		m.group = canvasGroup;
		m.map = canvasGroup.createChild('map');
		m.index = index;
		m.Tmp = 0;
		m.oldHeading = 0;
		m.range = Range[0];

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};

		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/nd.svg", {'font-mapper': font_mapper});

		var svg_keys = ["compass","hdg","hdgBug","arrowL","arrowR","range1","range2",
				"hdgText","satText","tasText","gsText","wpBearingText",
				"wpDistText","wpIdText","eteText","navMode"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		### NavDisplay ###
		m.map.setRange(Range[0]);
		m.map.setTranslation(400,440);
		m.map.setPos(lat.getValue(),lon.getValue(),hdg.getValue());

		foreach(var layer; ndlayers) {
			m.map.addLayer(
				factory: canvas.SymbolLayer,
				type_arg: layer.name,
				visible: 1,
				style: layer.style,
				priority: layer['z-index']
			);
		}
		m.map.setController(do328_controller);
		index+=1;

		m.timer = maketimer(0.2, m, m.update);
		return m;
	},
	update: func()
	{
		me.Tmp = hdg.getValue() or 0;
		me.hdg.setText(sprintf("%3.0f", me.Tmp));
		me.compass.setRotation(-me.Tmp*D2R);
		me.oldHeading = me.Tmp;

		me.Tmp = hdgBug.getValue() - me.Tmp;
		if(me.Tmp < -180) me.Tmp = me.Tmp + 360;
		if(me.Tmp < 50 and me.Tmp > -50) {
			me.hdgBug.setRotation(me.Tmp * D2R);
			me.hdgBug.show();
			me.arrowL.hide();
			me.arrowR.hide();
		}
		else {
			me.hdgBug.hide();

			if(me.Tmp < 180 and me.Tmp > 0) {
				me.arrowR.show();
				me.arrowL.hide();
			}
			else {
				me.arrowL.show();
				me.arrowR.hide();
			}
		}

		setprop("instrumentation/efis/trigger_nd"~me.index, 1);
		me.range = Range[me.index];
		if(me.range == 0 or me.range == 2) {
			me.range1.setText(sprintf("%2.1f", scales[me.range]));
			me.range2.setText(sprintf("%2.1f", scales[me.range]));
		}
		else {
			me.range1.setText(sprintf("%d", scales[me.range]));
			me.range2.setText(sprintf("%d", scales[me.range]));
		}

		me.Tmp = getprop("autopilot/route-manager/wp/dist") or 0;

		if(me.Tmp < 10) {
			me.wpDistText.setText(sprintf("%2.1f", me.Tmp));
		}
		else {
			me.wpDistText.setText(sprintf("%d", me.Tmp));
		}

		me.navMode.setText(getprop("autopilot/settings/nav-mode"));
		me.wpBearingText.setText(sprintf("%03d", getprop("autopilot/route-manager/wp/bearing-deg") or 0));
		me.wpIdText.setText(getprop("autopilot/route-manager/wp/id"));
		me.hdgText.setText(sprintf("%03d", getprop("autopilot/settings/heading-bug-deg")));
		me.satText.setText(sprintf("%03d", getprop("environment/temperature-degc")));
		me.tasText.setText(sprintf("%03d", getprop("instrumentation/airspeed-indicator/true-speed-kt")));
		me.gsText.setText(sprintf("%03d", getprop("velocities/groundspeed-kt")));
		me.eteText.setText(sprintf("%s", getprop("autopilot/route-manager/wp/eta") or "0:00"));
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
