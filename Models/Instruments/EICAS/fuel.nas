var canvas_group = {};

var canvas_fuel = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_fuel] };
		
		var font_mapper = func(family, weight)
		{
			if(family == "Liberation Sans" and weight == "normal") {
				return "LiberationFonts/LiberationSans-Regular.ttf";
			}
		};
		
		canvas.parsesvg(canvas_group, "Aircraft/do328/Models/Instruments/EICAS/fuel.svg", {'font-mapper': font_mapper});
		
		var sk = canvas_group.createChild('group');
		var skInstance = canvas_softkeys.new(sk);
		skInstance.setSoftkeys(["SYSTEM 1/3","CONTROL","HYDR","ENGINE","FUEL","NEXT"]);

		return m;
	}
};
