var ndlayers = [{name:'APT',style:{scale_factor:0.6,label_font_color:[1,1,1],color_default:[1,1,1],line_width:4}},
		{name:'DME',style:{scale_factor:0.6,color_default:[0,1,0],line_width:4}},
		{name:'WPT',style:{scale_factor:0.6,color_default:[0,1,0],line_width:4}}];

var hdg = props.globals.getNode("orientation/heading-magnetic-deg");
var lon = props.globals.getNode("position/longitude-deg");
var lat = props.globals.getNode("position/latitude-deg");

var do328_controller = {
	parents: [canvas.Map.Controller],

	new: func(map) {
		var m = { parents: [do328_controller],map:map };
		m.timer = maketimer(0.1, m, m.update_layers);
		m.timer.start();
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
				return "LiberationFonts/LiberationSans-Regular.ttf";
			}
		};

		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EICAS/nd.svg", {'font-mapper': font_mapper});

		var svg_keys = ["compass","hdg"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		### NavDisplay ###
		m.map.setRange(20);
		m.map.setTranslation(283,310);
		m.map.setPos(lat.getValue(),lon.getValue(),hdg.getValue());

		#var controller = do328_controller.new(m.map);
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
