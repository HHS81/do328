### Canvas MFD ###
### C. Le Moigne (clm76) - 2016 ###

var RMU1Instance = {};
var RMU2Instance = {};

### RMU ###
var RMU = {
	new: func(group, instance) {
		var m = {parents:[RMU], Pages:{}};
		m.Instance = instance;
		m.knob = 0;
		m.knob1 = 0;

		canvas.parsesvg(group.createChild('group'), "Aircraft/do328/Models/Instruments/RMU/background.svg");
		m.Pages[0] = canvas_frequencies.new(group.createChild('group'), instance);
		m.Pages[1] = canvas_pagemenu.new(group.createChild('group'), instance);
		m.Pages[2] = canvas_memorycom.new(group.createChild('group'), instance);
		m.Pages[3] = canvas_memorycom.new(group.createChild('group'), instance);
		m.Pages[4] = canvas_navigation.new(group.createChild('group'), instance);
		m.Pages[5] = canvas_maintenance.new(group.createChild('group'), instance);
		m.Pages[6] = canvas_maintenance.new(group.createChild('group'), instance);
		m.DisplayDim = canvas_displaydim.new(group.createChild('group'), instance);
		m.DisplayDim.hide();
		m.DimActive = 0;
		canvas.parsesvg(group.createChild('group'), "Aircraft/do328/Models/Instruments/RMU/mask.svg");

		setlistener("instrumentation/rmu["~m.Instance~"]/page", func {
			var page = getprop("instrumentation/rmu["~m.Instance~"]/page");
			m.ActivatePage(page);
		}, 1);

		m.ActivatePage(0);
		return m;
	},
	ActivatePage: func(input = -1)
	{
		for(var i=0; i<size(me.Pages); i=i+1) {
			if(i == input) {
				me.Pages[i].show();
				me.activePage = i;
			}
			else {
				me.Pages[i].hide();
			}
		}
	},
	BtClick: func(input = -1) {
		me.DisplayDim.hide();

		if(input == 13) {
			if(me.DimActive) {
				me.DisplayDim.hide();
				me.DimActive = 0;
			}
			else {
				me.DisplayDim.show();
				me.DimActive = 1;
			}
		}
		else {
			if(me.DimActive) {
				me.DisplayDim.hide();
				me.DimActive = 0;
			}
			else {
				me.Pages[me.activePage].BtClick(input);
				me.DimActive = 0;
			}
		}
	},
	Knob: func(input = -1) {
		var value = 0;

		if(input == 0) {
			var knob = getprop("instrumentation/rmu["~me.Instance~"]/knob");
			value = knob - me.knob;
			me.knob = knob;
		}
		else {
			var knob1 = getprop("instrumentation/rmu["~me.Instance~"]/knob1");
			value = knob1 - me.knob1;
			me.knob1 = knob1;
		}

		if(me.DimActive) {
			me.DisplayDim.Knob(input, value);
		}
		else {
			me.Pages[me.activePage].Knob(input, value);
		}
	}
};

var rmu1BtClick = func(input = -1) {
	RMU1Instance.BtClick(input);
}

var rmu1Knob = func(input = -1) {
	RMU1Instance.Knob(input);
}

var rmu2BtClick = func(input = -1) {
	RMU2Instance.BtClick(input);
}

var rmu2Knob = func(input = -1) {
	RMU2Instance.Knob(input);
}

###### Main #####
var setl = setlistener("/sim/signals/fdm-initialized", func () {

	setprop("instrumentation/rmu[0]/offside", 0);
	setprop("instrumentation/rmu[1]/offside", 0);

	var rmu1Canvas = canvas.new({
		"name": "RMU1", 
		"size": [512, 512],
		"view": [350, 400],
		"mipmapping": 1 
	});
	rmu1Canvas.addPlacement({"node": "RMU1.screen"});
	RMU1Instance = RMU.new(rmu1Canvas.createGroup(), 0);

	var rmu2Canvas = canvas.new({
		"name": "RMU1", 
		"size": [512, 512],
		"view": [350, 400],
		"mipmapping": 1 
	});
	rmu2Canvas.addPlacement({"node": "RMU2.screen"});
	RMU2Instance = RMU.new(rmu2Canvas.createGroup(), 1);

	removelistener(setl);
});
