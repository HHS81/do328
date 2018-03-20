# by xcvb85
#WxGmap: props.globals.initNode("/instrumentation/efis/wxGmap" ~ instance, 0, "BOOL"),
#Sector: props.globals.initNode("/instrumentation/efis/sector" ~ instance, 0, "BOOL"),
#TGT: props.globals.initNode("/instrumentation/efis/tgt" ~ instance, 0, "BOOL"),
#WptIdent: props.globals.initNode("/instrumentation/efis/wptIdent" ~ instance, 0, "BOOL"),
#Navaid: props.globals.initNode("/instrumentation/efis/navaid" ~ instance, 0, "BOOL"),

var Mfd1Instance = {};
var Mfd2Instance = {};

var Range=[0,0];
var TestActive=0;
var mfdListener=0;

var testVar = "RNG";

var MFD = {
	new: func(group, instance)
	{
		var m = { parents: [MFD],
			Pages: {},
			SkInstance: {},
			Menus: [],
			SoftkeyFrames: [0,0,0,0,0],
			Softkeys: ["","","","","","",""],
			activeMenu: 0, # to know where button clicks must go
			skFrameMenu: 0,
			Cnt: 0,
			Tmp: 0,
			};

		m.KnobMode = 1; # knob can have different functionalities

		# create pages
		m.Pages[0] = canvas_nd.new(group.createChild('group'));
		m.Pages[1] = canvas_flightctrl.new(group.createChild('group'));
		m.Pages[2] = canvas_hydr.new(group.createChild('group'));
		m.Pages[3] = canvas_engine.new(group.createChild('group'));
		m.Pages[4] = canvas_fuel.new(group.createChild('group'));

		m.Pages[5] = canvas_electr.new(group.createChild('group'));
		m.Pages[6] = canvas_ecs.new(group.createChild('group'));
		m.Pages[7] = canvas_ice.new(group.createChild('group'));
		m.Pages[8] = canvas_apu.new(group.createChild('group'));

		m.Pages[9] = canvas_cpcs.new(group.createChild('group'));
		m.Pages[10] = canvas_doors.new(group.createChild('group'));
		m.Pages[11] = canvas_maint.new(group.createChild('group'));

		m.Pages[12] = canvas_exceedance.new(group.createChild('group'));

		m.SkInstance = canvas_softkeys.new(group.createChild('group'));

		# create menus
		var back = SkMenuPageActivateItem.new(0, m, "back1", 0, 0);
		append(m.Menus, SkMenu.new(0, m, "MAIN 1/2"));
		append(m.Menus, SkMenu.new(1, m, "MAIN 2/2"));
		append(m.Menus, SkMenu.new(2, m, "DISPLAY"));
		append(m.Menus, SkMenu.new(3, m, "RADAR"));
		append(m.Menus, SkMenu.new(4, m, "SYSTEM 1/3"));
		append(m.Menus, SkMenu.new(5, m, "SYSTEM 2/3"));
		append(m.Menus, SkMenu.new(6, m, "SYSTEM 3/3"));
		append(m.Menus, SkMenu.new(7, m, "FMS"));
		append(m.Menus, SkMenu.new(8, m, "MFD FORMAT"));
		append(m.Menus, SkMenu.new(9, m, "TEST"));
		append(m.Menus, SkMenu.new(10, m, "MAINT"));
		append(m.Menus, SkMenu.new(11, m, "RADAR SUB"));

		# create softkeys
		m.Menus[0].SetItem(0, SkMenuActivateItem.new(0, m, "back2", 1));
		m.Menus[0].SetItem(1, SkMenuActivateItem.new(1, m, "DISPLAY", 2));
		m.Menus[0].SetItem(2, SkMenuActivateItem.new(2, m, "RADAR", 3));
		m.Menus[0].SetItem(3, SkMenuActivateItem.new(3, m, "SYSTEM", 4));
		m.Menus[0].SetItem(4, SkMenuActivateItem.new(4, m, "FMS", 7));
		m.Menus[0].SetItem(5, SkMenuActivateItem.new(5, m, "MFD\nFORMAT", 8));
		m.Menus[0].SetItem(6, SkMutableItem.new(6, m, testVar));

		m.Menus[1].SetItem(0, back);
		m.Menus[1].SetItem(1, SkMenuActivateItem.new(1, m, "TEST", 9));
		m.Menus[1].SetItem(3, SkMenuActivateItem.new(3, m, "MFD\nMAINT", 10));
		m.Menus[1].SetItem(6, SkMutableItem.new(6, m, testVar));

		m.Menus[2].SetItem(0, back);
		m.Menus[2].SetItem(1, SkItem.new(1, m, "IF\nYOU"));
		m.Menus[2].SetItem(2, SkItem.new(2, m, "KNOW\nTHIS"));
		m.Menus[2].SetItem(3, SkItem.new(3, m, "CONTENT\nPLEASE"));
		m.Menus[2].SetItem(4, SkItem.new(4, m, "LET\nME"));
		m.Menus[2].SetItem(5, SkItem.new(5, m, "KNOW"));
		m.Menus[2].SetItem(6, SkMutableItem.new(6, m, testVar));

		m.Menus[3].SetItem(0, back);
		m.Menus[3].SetItem(1, SkItem.new(1, m, "STBY\nTEST"));
		m.Menus[3].SetItem(2, SkItem.new(2, m, "WX\nGMAP"));
		m.Menus[3].SetItem(3, SkItem.new(3, m, "SECTOR"));
		m.Menus[3].SetItem(4, SkItem.new(4, m, "TGT\n"));
		m.Menus[3].SetItem(5, SkMenuActivateItem.new(5, m, "RADAR\nSUB", 11));
		m.Menus[3].SetItem(6, SkMutableItem.new(6, m, testVar));

		m.Menus[4].SetItem(0, back);
		m.Menus[4].SetItem(1, SkPageActivateItem.new(1, m, "FLIGHT\nCONTROL", 1));
		m.Menus[4].SetItem(2, SkPageActivateItem.new(2, m, "HYDR", 2));
		m.Menus[4].SetItem(3, SkPageActivateItem.new(3, m, "ENGINE", 3));
		m.Menus[4].SetItem(4, SkPageActivateItem.new(4, m, "FUEL", 4));
		m.Menus[4].SetItem(5, SkMenuActivateItem.new(5, m, "NEXT", 5));

		m.Menus[5].SetItem(0, back);
		m.Menus[5].SetItem(1, SkPageActivateItem.new(1, m, "ELECTR", 5));
		m.Menus[5].SetItem(2, SkPageActivateItem.new(2, m, "ECS", 6));
		m.Menus[5].SetItem(3, SkPageActivateItem.new(3, m, "ICE\nPROTECT", 7));
		m.Menus[5].SetItem(4, SkPageActivateItem.new(4, m, "APU", 8));
		m.Menus[5].SetItem(5, SkMenuActivateItem.new(5, m, "NEXT", 6));

		m.Menus[6].SetItem(0, back);
		m.Menus[6].SetItem(1, SkPageActivateItem.new(1, m, "CPCS/\nOXYGEN", 9));
		m.Menus[6].SetItem(2, SkPageActivateItem.new(2, m, "DOORS", 10));
		m.Menus[6].SetItem(3, SkItem.new(3, m, "SYS\nMAINT"));
		m.Menus[6].SetItem(4, SkItem.new(4, m, "SENSOR\nDATA"));
		m.Menus[6].SetItem(5, SkMenuActivateItem.new(5, m, "NEXT", 4));

		m.Menus[7].SetItem(0, back);
		m.Menus[7].SetItem(1, SkItem.new(1, m, "WAYPNT\nIDENT"));
		m.Menus[7].SetItem(2, SkItem.new(2, m, "NAVAID\nAIRPRT"));
		m.Menus[7].SetItem(5, SkItem.new(5, m, "CURSOR"));
		m.Menus[7].SetItem(6, SkMutableItem.new(6, m, testVar));

		m.Menus[8].SetItem(0, back);
		m.Menus[8].SetItem(1, SkItem.new(1, m, "IF\nYOU"));
		m.Menus[8].SetItem(2, SkItem.new(2, m, "KNOW\nTHIS"));
		m.Menus[8].SetItem(3, SkItem.new(3, m, "CONTENT\nPLEASE"));
		m.Menus[8].SetItem(4, SkItem.new(4, m, "LET\nME"));
		m.Menus[8].SetItem(5, SkItem.new(5, m, "KNOW"));
		m.Menus[8].SetItem(6, SkMutableItem.new(6, m, testVar));

		m.Menus[9].SetItem(0, back);
		m.Menus[9].SetItem(1, SkItem.new(1, m, "RAD ALT"));
		m.Menus[9].SetItem(2, SkItem.new(2, m, "ATC\nEICAS"));
		m.Menus[9].SetItem(3, SkItem.new(3, m, "TCAS"));
		m.Menus[9].SetItem(4, SkItem.new(4, m, "EFIS\nEICAS"));
		m.Menus[9].SetItem(5, SkItem.new(5, m, "EGPWS"));
		m.Menus[9].SetItem(6, SkMutableItem.new(6, m, testVar));

		m.Menus[10].SetItem(0, back);
		m.Menus[10].SetItem(1, SkItem.new(1, m, "TREND"));
		m.Menus[10].SetItem(2, SkPageActivateItem.new(2, m, "EXCEED", 12));
		m.Menus[10].SetItem(3, SkItem.new(3, m, "FAULT"));
		m.Menus[10].SetItem(4, SkItem.new(4, m, "GNDMNT"));

		m.Menus[11].SetItem(0, SkMenuActivateItem.new(0, m, "", 3));
		m.Menus[11].SetItem(1, SkItem.new(1, m, "GAIN\nPRE VAR"));
		m.Menus[11].SetItem(2, SkItem.new(2, m, "RNG"));
		m.Menus[11].SetItem(3, SkItem.new(3, m, "TILT"));
		m.Menus[11].SetItem(4, SkItem.new(4, m, "RCT"));
		m.Menus[11].SetItem(6, SkMutableItem.new(6, m, testVar));

		m.i = 0;
		m.Instance = instance;
		m.ActivatePage(0, 0);
		m.ActivateMenu(0);
		return m;
	},
	ActivateMenu: func(id) {
		me.activeMenu = id;
		me.Softkeys[0] = me.Menus[id].GetTitle();

		# copy sk names to array
		for(me.Cnt = 1; me.Cnt < 7; me.Cnt+=1) {
			me.Tmp = me.Menus[id].GetItem(me.Cnt);
			if(me.Tmp != nil) {
				me.Softkeys[me.Cnt] = me.Tmp.GetTitle();
				if(me.Cnt < 6) {
					me.SoftkeyFrames[me.Cnt-1] = me.Tmp.GetDecoration();
				}
			}
			else {
				me.Softkeys[me.Cnt] = "";
			}
		}

		me.SkInstance.setSoftkeys(me.Softkeys);
		me.SkInstance.drawFrames(me.SoftkeyFrames);
	},
	ActivatePage: func(page, softkey) {
		me.Menus[me.skFrameMenu].ResetDecoration();
		me.skFrameMenu = me.activeMenu;
		me.Menus[me.skFrameMenu].SetDecoration(softkey);

		# update decorations
		for(me.Cnt = 1; me.Cnt < 6; me.Cnt+=1) {
			me.Tmp = me.Menus[me.skFrameMenu].GetItem(me.Cnt);
			if(me.Tmp != nil) {
				me.SoftkeyFrames[me.Cnt-1] = me.Tmp.GetDecoration();
			}
		}

		me.SkInstance.setSoftkeys(me.Softkeys);
		me.SkInstance.drawFrames(me.SoftkeyFrames);
		for(me.i=0; me.i < size(me.Pages); me.i+=1) {
			if(me.i == page) {
				me.Pages[me.i].show();
			}
			else {
				me.Pages[me.i].hide();
			}
		}
	},
	# input: 0=back, 1=sk1...5=sk5
	BtClick: func(input = -1) {
		me.Menus[me.activeMenu].ActivateItem(input);
	},
	GetKnobMode: func()
	{
		return me.KnobMode;
	}
};

var mfd1BtClick = func(input = -1) {
	Mfd1Instance.BtClick(input);
}

var mfd2BtClick = func(input = -1) {
	Mfd2Instance.BtClick(input);
}

var mfd1Knob = func(input = 0) {
	if(Mfd1Instance.GetKnobMode()) {
		Range[0] += input;
		if(Range[0] > 5) Range[0]=5;
		if(Range[0] < 0) Range[0]=0;
	}
}

var mfd2Knob = func(input = 0) {
	if(Mfd2Instance.GetKnobMode()) {
		Range[1] += input;
		if(Range[1] > 5) Range[1]=5;
		if(Range[1] < 0) Range[1]=0;
	}
}

mfdListener = setlistener("/sim/signals/fdm-initialized", func () {

	var mfd1Canvas = canvas.new({
		"name": "MFD1",
		"size": [1024, 1024],
		"view": [800, 950],
		"mipmapping": 1
	});
	mfd1Canvas.addPlacement({"node": "MFD1_Screen"});
	Mfd1Instance = MFD.new(mfd1Canvas.createGroup(), 0);

	var mfd2Canvas = canvas.new({
		"name": "MFD2",
		"size": [1024, 1024],
		"view": [800, 950],
		"mipmapping": 1
	});
	mfd2Canvas.addPlacement({"node": "MFD2_Screen"});
	Mfd2Instance = MFD.new(mfd2Canvas.createGroup(), 1);

	removelistener(mfdListener);
});
