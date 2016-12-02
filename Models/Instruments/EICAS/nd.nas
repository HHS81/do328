var canvasGroup = {};

var canvas_nd = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_nd] };
		var ndmap = canvasGroup.createChild('map');
		var ndsvg = canvasGroup.createChild('group');
		m["group"] = canvasGroup;

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "LiberationFonts/LiberationSans-Regular.ttf";
			}
		};

		canvas.parsesvg(ndsvg, "Aircraft/do328/Models/Instruments/EICAS/nd.svg", {'font-mapper': font_mapper});

		var svg_keys = ["compass","hdg"];
		foreach(var key; svg_keys) {
			m[key] = ndsvg.getElementById(key);
		}

		### NavDisplay ###
		ndmap.setController("Aircraft position");
		ndmap.setRange(20);
		ndmap.setTranslation(264,334);

		var r = func(name,vis=1,zindex=nil) return caller(0)[0];

		var type = r('APT');
		var style_apt = {
		    scale_factor:0.6,
		    color:[1,1,1],
		    line_width:4
		};
		ndmap.addLayer(factory: canvas.SymbolLayer, type_arg: type.name, visible: type.vis, priority: type.zindex, style: style_apt);

		type = r('DME');
		var style_vor = {
		    scale_factor:0.6,
		    color:[0,0,1],
		    line_width:4
		};
		ndmap.addLayer(factory: canvas.SymbolLayer, type_arg: type.name, visible: type.vis, priority: type.zindex, style: style_vor);

		m["active"] = 0;
		return m;
	},
	fast_update: func()
	{
		var heading = getprop("orientation/heading-magnetic-deg");

		if(heading != nil){
			me["hdg"].setText(sprintf("%3.0f",heading));
			me["compass"].setRotation(-heading*math.pi/180);
		}

		if(me["active"] == 1) {
			settimer(func me.fast_update(), 0.1);
		}
	},
	show: func()
	{
		me["active"] = 1;
		me.fast_update();
		me["group"].show();
	},
	hide: func()
	{
		me["active"] = 0;
		me["group"].hide();
	}
};
