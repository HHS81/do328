var ndlayers = [{name:'APT_do',style:{scale_factor:0.6,label_font_color:[1,1,1],color_default:[1,1,1],line_width:4}},
		{name:'DME_do',style:{scale_factor:0.6,color_default:[0,1,0],line_width:4}},
		{name:'WPT_do',style:{scale_factor:0.6,line_width:4}},
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
		var m = { parents: [do328_controller], map:map };
		m.index = index;
		setlistener("instrumentation/efis/trigger_nd"~index, func{ m.update_layers() });
		return m;
	},

	update_layers: func() {
		me.map.setRange(2*scales[Range[me.index]]);
		me.map.setPos(lat.getValue(), lon.getValue(), hdg.getValue());
		me.map.update();
	},
};

var canvas_nd = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_nd] };
		m.group = canvasGroup;
		m.map = canvasGroup.createChild('map');
		m.index = index;
		m.counter = 0;
		m.oldHeading = 0;
		m.range = Range[0];

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};

		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/nd.svg", {'font-mapper': font_mapper});

		var svg_keys = ["compass","hdg","hdgBug","arrowL","arrowR","range1","range2"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		### NavDisplay ###
		m.map.setRange(Range[0]);
		m.map.setTranslation(400,440);
		m.map.setPos(lat.getValue(),lon.getValue(),hdg.getValue());
		m.map.setController(do328_controller);

		foreach(var layer; ndlayers) {
			m.map.addLayer(
				factory: canvas.SymbolLayer,
				type_arg: layer.name,
				visible: 1,
				style: layer.style,
				priority: layer['z-index']
			);
		}
		index+=1;

		m.active = 0;
		return m;
	},
	update: func()
	{
		var heading = hdg.getValue() or 0;

		if(me.counter > 10 or math.abs(heading-me.oldHeading) > 0.3 or Range[me.index]!=me.range) {
			var hdg = hdgBug.getValue()-heading;
			me.hdg.setText(sprintf("%3.0f",heading));
			me.compass.setRotation(-heading*D2R);

			if(hdg < -180) hdg = hdg + 360;
			if(hdg < 50 and hdg > -50) {
				me.hdgBug.setRotation(hdg*D2R);
				me.hdgBug.show();
				me.arrowL.hide();
				me.arrowR.hide();
			}
			else {
				me.hdgBug.hide();

				if(hdg < 180 and hdg > 0) {
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
			me.counter = 0;
			me.oldHeading = heading;
		}
		me.counter+=1;

		if(me.active == 1) {
			settimer(func me.update(), 0.2);
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
