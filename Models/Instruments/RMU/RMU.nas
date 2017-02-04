### Canvas RMU ###
### clm76 - 2016 ###
### xcvb - 2017 ###

var RMU1Instance = {};
var RMU2Instance = {};

# colors:
var amber = [1,0.93,0];
var cyan = [0.33,0.73,0.93];
var green = [0,1,0];
var magenta = [0.93,0.05,0.35];
var white = [1,1,1];

var PageEnum = {frequencies:0,
	pagemenu:1,
	memorycom:2,
	navigation:3,
	engine1:4,
	atctcas:5,
	maintenance:6,
	strapsmenu:7,
	straps:8,
	software:9,
	maintlogmenu:10,
	maintlog:11,
	rmusetup:12
};

### RMU ###
var RMU = {
	new: func(group, instance) {
		var m = {parents:[RMU], Pages:{}};
		m.Instance = instance;
		m.knob = 0;
		m.knob1 = 0;

		canvas.parsesvg(group.createChild('group'), "Aircraft/do328/Models/Instruments/RMU/background.svg");
		m.Pages[PageEnum.frequencies] = canvas_frequencies.new(group.createChild('group'), instance);
		m.Pages[PageEnum.pagemenu] = canvas_pagemenu.new(group.createChild('group'), instance);
		m.Pages[PageEnum.memorycom] = canvas_memorycom.new(group.createChild('group'), instance);
		m.Pages[PageEnum.navigation] = canvas_navigation.new(group.createChild('group'), instance);
		m.Pages[PageEnum.engine1] = canvas_engine1.new(group.createChild('group'), instance);
		m.Pages[PageEnum.atctcas] = canvas_atctcas.new(group.createChild('group'), instance);
		m.Pages[PageEnum.maintenance] = canvas_maintenance.new(group.createChild('group'), instance);
		m.Pages[PageEnum.strapsmenu] = canvas_strapsmenu.new(group.createChild('group'), instance);
		m.Pages[PageEnum.straps] = canvas_straps.new(group.createChild('group'), instance);
		m.Pages[PageEnum.software] = canvas_software.new(group.createChild('group'), instance);
		m.Pages[PageEnum.maintlogmenu] = canvas_maintlogmenu.new(group.createChild('group'), instance);
		m.Pages[PageEnum.maintlog] = canvas_maintlog.new(group.createChild('group'), instance);
		m.Pages[PageEnum.rmusetup] = canvas_rmusetup.new(group.createChild('group'), instance);
		m.DisplayDim = canvas_displaydim.new(group.createChild('group'), instance);
		m.DisplayDim.hide();
		m.DimActive = 0;
		canvas.parsesvg(group.createChild('group'), "Aircraft/do328/Models/Instruments/RMU/mask.svg");

		setlistener("instrumentation/rmu["~m.Instance~"]/page", func {
			var page = getprop("instrumentation/rmu["~m.Instance~"]/page");
			m.ActivatePage(page);
		}, 1);

		m.ActivatePage(PageEnum.frequencies);
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

var frequencyStorage = func() {
	# initialize property tree in case that xml file is not available
	var node = "/instrumentation/rmu";
	var path = getprop("/sim/fg-home")~"/aircraft-data/do328-RMU.xml";

	var tree = {
		"memory": {
			"comm": {
				"mem": [0, 0, 0, 0, 0, 0,
					0, 0, 0, 0, 0, 0]
			},
			"nav": {
				"mem": [0, 0, 0, 0, 0, 0,
					0, 0, 0, 0, 0, 0]
			}
		}
	};
	props.globals.getNode("/instrumentation/rmu").setValues(tree);

	# read data from xml file
	io.read_properties(path, node~"/memory");

	# store data
	setlistener("/sim/signals/save", func () {
		io.write_properties(path, props.globals.getNode(node~"/memory"));
	});
}

###### Main #####
var setl = setlistener("/sim/signals/fdm-initialized", func () {

	setprop("instrumentation/rmu[0]/lighting", 1);
	setprop("instrumentation/rmu[1]/lighting", 1);
	setprop("instrumentation/rmu[0]/offside", 0);
	setprop("instrumentation/rmu[1]/offside", 0);
	setprop("instrumentation/rmu[0]/atcId", 0);
	setprop("instrumentation/rmu[1]/atcId", 0);
	setprop("instrumentation/rmu[0]/tcasDisplay", 1);
	setprop("instrumentation/rmu[1]/tcasDisplay", 1);
	setprop("instrumentation/rmu[0]/tcasRange", 1);
	setprop("instrumentation/rmu[1]/tcasRange", 1);

	frequencyStorage();

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
