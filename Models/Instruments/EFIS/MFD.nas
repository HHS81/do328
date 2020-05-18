##########################################################################################################
# Canvas MFD
# Daniel Overbeck - 2018
##########################################################################################################

var Mfd1Instance = {};
var Mfd2Instance = {};

var Range=[0,0];
var TestActive=0;
var mfdListener=0;

var MFD = {
	new: func(group, instance)
	{
		var m = { parents: [MFD, Device.new(instance)] };

		# create pages
		append(m.Pages, canvas_nd.new(group.createChild('group'))); #0
		append(m.Pages, canvas_flightctrl.new(group.createChild('group'))); #1
		append(m.Pages, canvas_hydr.new(group.createChild('group'))); #2
		append(m.Pages, canvas_engine.new(group.createChild('group'))); #3
		append(m.Pages, canvas_fuel.new(group.createChild('group'))); #4
		append(m.Pages, canvas_electr.new(group.createChild('group'))); #5
		append(m.Pages, canvas_ecs.new(group.createChild('group'))); #6
		append(m.Pages, canvas_ice.new(group.createChild('group'))); #7
		append(m.Pages, canvas_apu.new(group.createChild('group'))); #8
		append(m.Pages, canvas_cpcs.new(group.createChild('group'))); # 9
		append(m.Pages, canvas_doors.new(group.createChild('group'))); #10
		append(m.Pages, canvas_maint.new(group.createChild('group'))); #11
		append(m.Pages, canvas_exceedance.new(group.createChild('group'))); #12

		m.SkInstance = canvas_softkeys.new(group.createChild('group'));

		# create menus
		append(m.Menus, SkMenu.new(0, m, "MAIN 1/2"));
		append(m.Menus, SkMenu.new(1, m, "MAIN 2/2"));
		append(m.Menus, SkMenu.new(2, m, "DISPLAY"));
		append(m.Menus, SkMenu.new(3, m, "RADAR"));
		append(m.Menus, SkMenu.new(4, m, "SYSTEM 1/3"));
		append(m.Menus, SkMenu.new(5, m, "SYSTEM 2/3"));
		append(m.Menus, SkMenu.new(6, m, "SYSTEM 3/3"));
		append(m.Menus, SkMenu.new(7, m, "FMS"));
		append(m.Menus, SkMenu.new(8, m, "TEST"));
		append(m.Menus, SkMenu.new(9, m, "MAINT"));
		append(m.Menus, SkMenu.new(10, m, "RADAR SUB"));
		append(m.Menus, SkMenu.new(11, m, "CURSOR"));

		# create softkeys
		var back = SkMenuPageActivateItem.new(0, m, "back1", 0, 0);
		m.Menus[0].AddItem(SkMenuActivateItem.new(0, m, "back2", 1));
		m.Menus[0].AddItem(SkMenuActivateItem.new(1, m, "DISPLAY", 2));
		m.Menus[0].AddItem(SkMenuActivateItem.new(2, m, "RADAR", 3));
		m.Menus[0].AddItem(SkMenuActivateItem.new(3, m, "SYSTEM", 4));
		m.Menus[0].AddItem(SkMenuActivateItem.new(4, m, "FMS", 7));
		m.Menus[0].AddItem(SkItem.new(5, m, "MFD\nFORMAT")); # TODO: this toggles ND between rose and arc
		m.Menus[0].AddItem(SkItem.new(6, m, "RNG"));

		m.Menus[1].AddItem(back);
		m.Menus[1].AddItem(SkMenuActivateItem.new(1, m, "TEST", 8));
		m.Menus[1].AddItem(SkMenuActivateItem.new(3, m, "GND\nMAINT", 9));
		m.Menus[1].AddItem(SkItem.new(6, m, "RNG"));

		m.Menus[2].AddItem(back);
		m.Menus[2].AddItem(SkItem.new(1, m, "--PFD--\nFD"));
		m.Menus[2].AddItem(SkAdvSwitchItem.new(2, m, "\nSC CP", "instrumentation/efis/sccp" ~ instance, [240,875,275,900], [280,875,315,900]));
		m.Menus[2].AddItem(SkItem.new(3, m, "--MFD--\nRADAR"));
		m.Menus[2].AddItem(SkItem.new(4, m, "\nTCAS"));
		m.Menus[2].AddItem(SkItem.new(6, m, "RNG"));

		m.Menus[3].AddItem(back);
		m.Menus[3].AddItem(SkItem.new(1, m, "STBY\nTEST"));
		m.Menus[3].AddItem(SkSwitchItem.new(2, m, "WX\nGMAP", "instrumentation/efis/wxGmap" ~ instance));
		m.Menus[3].AddItem(SkSwitchItem.new(3, m, "SECTOR", "instrumentation/efis/sector" ~ instance));
		m.Menus[3].AddItem(SkSwitchItem.new(4, m, "TGT\n", "instrumentation/efis/tgt" ~ instance));
		m.Menus[3].AddItem(SkMenuActivateItem.new(5, m, "RADAR\nSUB", 10));
		m.Menus[3].AddItem(SkItem.new(6, m, "RNG"));

		m.Menus[4].AddItem(back);
		m.Menus[4].AddItem(SkPageActivateItem.new(1, m, "FLIGHT\nCONTROL", 1));
		m.Menus[4].AddItem(SkPageActivateItem.new(2, m, "HYDR", 2));
		m.Menus[4].AddItem(SkPageActivateItem.new(3, m, "ENGINE", 3));
		m.Menus[4].AddItem(SkPageActivateItem.new(4, m, "FUEL", 4));
		m.Menus[4].AddItem(SkMenuActivateItem.new(5, m, "NEXT", 5));

		m.Menus[5].AddItem(back);
		m.Menus[5].AddItem(SkPageActivateItem.new(1, m, "ELECTR", 5));
		m.Menus[5].AddItem(SkPageActivateItem.new(2, m, "ECS", 6));
		m.Menus[5].AddItem(SkPageActivateItem.new(3, m, "ICE\nPROTECT", 7));
		m.Menus[5].AddItem(SkPageActivateItem.new(4, m, "APU", 8));
		m.Menus[5].AddItem(SkMenuActivateItem.new(5, m, "NEXT", 6));

		m.Menus[6].AddItem(back);
		m.Menus[6].AddItem(SkPageActivateItem.new(1, m, "CPCS/\nOXYGEN", 9));
		m.Menus[6].AddItem(SkPageActivateItem.new(2, m, "DOORS", 10));
		m.Menus[6].AddItem(SkPageActivateItem.new(3, m, "SYS\nMAINT", 11));
		m.Menus[6].AddItem(SkItem.new(4, m, "SENSOR\nDATA"));
		m.Menus[6].AddItem(SkMenuActivateItem.new(5, m, "NEXT", 4));

		m.Menus[7].AddItem(back);
		m.Menus[7].AddItem(SkSwitchItem.new(1, m, "WAYPNT\nIDENT", "instrumentation/efis/wptIdent" ~ instance));
		m.Menus[7].AddItem(SkSwitchItem.new(2, m, "NAVAID\nAIRPRT", "instrumentation/efis/navaid" ~ instance));
		m.Menus[7].AddItem(SkMenuActivateItem.new(5, m, "CURSOR", 11));
		m.Menus[7].AddItem(SkItem.new(6, m, "RNG"));

		m.Menus[8].AddItem(back);
		m.Menus[8].AddItem(SkItem.new(1, m, "RAD ALT"));
		m.Menus[8].AddItem(SkTimerItem.new(2, m, "ATC\nEICAS", "instrumentation/mk-viii/inputs/discretes/beep", 3));
		m.Menus[8].AddItem(SkTimerItem.new(3, m, "TCAS", "instrumentation/efis/tcas", 2));
		m.Menus[8].AddItem(SkItem.new(4, m, "EFIS\nEICAS"));
		m.Menus[8].AddItem(SkTimerItem.new(5, m, "EGPWS", "instrumentation/mk-viii/inputs/discretes/self-test", 15));
		m.Menus[8].AddItem(SkItem.new(6, m, "RNG"));

		m.Menus[9].AddItem(back);
		m.Menus[9].AddItem(SkItem.new(1, m, "TREND"));
		m.Menus[9].AddItem(SkPageActivateItem.new(2, m, "EXCEED", 12));
		m.Menus[9].AddItem(SkItem.new(3, m, "FAULT"));
		m.Menus[9].AddItem(SkItem.new(4, m, "GNDMNT"));

		m.Menus[10].AddItem(SkMenuActivateItem.new(0, m, "", 3));
		m.Menus[10].AddItem(SkItem.new(1, m, "GAIN\nPRE VAR"));
		m.Menus[10].AddItem(SkItem.new(2, m, "RNG"));
		m.Menus[10].AddItem(SkItem.new(3, m, "TILT"));
		m.Menus[10].AddItem(SkItem.new(4, m, "RCT"));
		m.Menus[10].AddItem(SkItem.new(6, m, "RNG"));

		m.Menus[11].AddItem(SkMenuActivateItem.new(0, m, "", 7));
		m.Menus[11].AddItem(SkItem.new(1, m, "XFER"));
		m.Menus[11].AddItem(SkItem.new(2, m, "CLEAR"));
		m.Menus[11].AddItem(SkItem.new(3, m, "SCROLL\nFORE"));
		m.Menus[11].AddItem(SkItem.new(4, m, "SCROLL\nBACK"));
		m.Menus[11].AddItem(SkItem.new(5, m, "CURSOR\nBRG DIS"));
		m.Menus[11].AddItem(SkItem.new(6, m, "DIS"));

		m.ActivatePage(0, 0);
		m.ActivateMenu(0);
		return m;
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
