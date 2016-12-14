var ndlayers = [{name:'APT',visible:1,style:{scale_factor:0.6,font:"honeywellfont.ttf",label_font_color:[1,1,1],color_default:[1,1,1],line_width:4}},
		{name:'DME',visible:1,style:{scale_factor:0.6,font:"honeywellfont.ttf",color_default:[0,1,0],line_width:4}},
		{name:'WPT',visible:1,style:{scale_factor:0.6,font:"honeywellfont.ttf",line_width:4}},
		{name:'RTE',visible:0,style:{scale_factor:0.6,color:[0,1,0],line_width:3}}];

var hdg = props.globals.getNode("orientation/heading-magnetic-deg");
var lon = props.globals.getNode("position/longitude-deg");
var lat = props.globals.getNode("position/latitude-deg");

var do328_controller = {
	parents: [canvas.Map.Controller],

	new: func(map) {
		var m = { parents: [do328_controller],map:map };
		m.timer = maketimer(0.1, m, m.update_layers);
		m.timer.start();

		# this check is missing in RTE.lcontroller
		setlistener("/autopilot/route-manager/active", func {
			if(getprop("/autopilot/route-manager/active")) {
				m.map.getLayer("RTE").setVisible(1);
			}
		}, 1);
		return m;
	},

	update_layers: func() {
		me.map.setPos(lat.getValue(),lon.getValue(),hdg.getValue());
		me.map.update();
	},

	del: func() {print("cleaning up nd controller");}
};

var canvas_nd = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_nd] };
		m.group = canvasGroup;
		m.map = canvasGroup.createChild('map');

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};

		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/MFD/nd.svg", {'font-mapper': font_mapper});

		var svg_keys = ["compass","hdg"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		### NavDisplay ###
		m.map.setRange(20);
		m.map.setTranslation(283,310);
		m.map.setPos(lat.getValue(),lon.getValue(),hdg.getValue());
		m.map.setController(do328_controller);

		foreach(var layer; ndlayers) {
			m.map.addLayer(
				factory: canvas.SymbolLayer,
				type_arg: layer.name,
				visible: layer.visible,
				style: layer.style,
				priority: layer['z-index']
			);
		}

		m.active = 0;
		return m;
	},
	update: func()
	{
		var heading = hdg.getValue();

		if(heading != nil) {
			me.hdg.setText(sprintf("%3.0f",heading));
			me.compass.setRotation(-heading*math.pi/180);
		}

		if(me.active == 1) {
			settimer(func me.update(), 0.1);
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
