##########################################################################################################
# Canvas EICAS
# Daniel Overbeck - 2018
##########################################################################################################

var EicasInstance = {};

var EICAS = {
	new: func(group)
	{
		var m = { parents: [EICAS, Device.new(0)] };

		# create pages
		append(m.Pages, canvas_eicas.new(group.createChild('group'))); #0
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
		var back = SkMenuPageActivateItem.new(0, m, "back1", 0, 0);
		append(m.Menus, SkMenu.new(0, m, "MAIN"));
		append(m.Menus, SkMenu.new(1, m, "SYSTEM 1/3"));
		append(m.Menus, SkMenu.new(2, m, "SYSTEM 2/3"));
		append(m.Menus, SkMenu.new(3, m, "SYSTEM 3/3"));
		append(m.Menus, SkMenu.new(4, m, "REF DATA"));
		append(m.Menus, SkMenu.new(5, m, "T/O SPD"));
		append(m.Menus, SkMenu.new(6, m, "T/O PWR"));
		append(m.Menus, SkMenu.new(7, m, "CRUISE"));
		append(m.Menus, SkMenu.new(8, m, "LANDG"));

		# create softkeys
		var back = SkMenuPageActivateItem.new(0, m, "back1", 0, 0);
		m.Menus[0].AddItem(SkItem.new(0, m, "")); # no back on main page
		m.Menus[0].AddItem(SkMenuActivateItem.new(1, m, "CAPT\nSYSTEM", 1));
		m.Menus[0].AddItem(SkMenuActivateItem.new(2, m, "REF\nDATA", 4));
		m.Menus[0].AddItem(SkItem.new(3, m, "COPY"));
		m.Menus[0].AddItem(SkItem.new(4, m, "AHRS"));
		m.Menus[0].AddItem(SkMenuActivateItem.new(5, m, "F/O\nSYSTEM", 1));
		m.Menus[0].AddItem(SkItem.new(6, m, "MSG"));

		m.Menus[1].AddItem(back);
		m.Menus[1].AddItem(SkPageActivateItem.new(1, m, "FLIGHT\nCONTROL", 1));
		m.Menus[1].AddItem(SkPageActivateItem.new(2, m, "HYDR", 2));
		m.Menus[1].AddItem(SkPageActivateItem.new(3, m, "ENGINE", 3));
		m.Menus[1].AddItem(SkPageActivateItem.new(4, m, "FUEL", 4));
		m.Menus[1].AddItem(SkMenuActivateItem.new(5, m, "NEXT", 2));

		m.Menus[2].AddItem(back);
		m.Menus[2].AddItem(SkPageActivateItem.new(1, m, "ELECTR", 5));
		m.Menus[2].AddItem(SkPageActivateItem.new(2, m, "ECS", 6));
		m.Menus[2].AddItem(SkPageActivateItem.new(3, m, "ICE\nPROTECT", 7));
		m.Menus[2].AddItem(SkPageActivateItem.new(4, m, "APU", 8));
		m.Menus[2].AddItem(SkMenuActivateItem.new(5, m, "NEXT", 3));

		m.Menus[3].AddItem(back);
		m.Menus[3].AddItem(SkPageActivateItem.new(1, m, "CPCS/\nOXYGEN", 9));
		m.Menus[3].AddItem(SkPageActivateItem.new(2, m, "DOORS", 10));
		m.Menus[3].AddItem(SkPageActivateItem.new(3, m, "SYS\nMAINT", 11));
		m.Menus[3].AddItem(SkItem.new(4, m, "SENSOR\nDATA"));
		m.Menus[3].AddItem(SkMenuActivateItem.new(5, m, "NEXT", 1));

		m.Menus[4].AddItem(back);
		m.Menus[4].AddItem(SkMenuActivateItem.new(1, m, "T/O\nSPD", 5));
		m.Menus[4].AddItem(SkMenuActivateItem.new(2, m, "T/O\nPWR", 6));
		m.Menus[4].AddItem(SkMenuActivateItem.new(3, m, "CRUISE", 7));
		m.Menus[4].AddItem(SkMenuActivateItem.new(4, m, "LANDG", 8));
		m.Menus[4].AddItem(SkItem.new(5, m, "SINGLE\nENGINE"));
		m.Menus[4].AddItem(SkItem.new(6, m, "MSG"));

		m.Menus[5].AddItem(SkMenuActivateItem.new(0, m, "", 4)); # back
		m.Menus[5].AddItem(SkItem.new(1, m, "FLAPS\n12", 1));
		m.Menus[5].AddItem(SkMutableItem.new(2, m, "instrumentation/fmc/vspeeds/V1", "V1\n%d", 1));
		m.Menus[5].AddItem(SkMutableItem.new(3, m, "instrumentation/fmc/vspeeds/VR", "VR\n%d", 1));
		m.Menus[5].AddItem(SkMutableItem.new(4, m, "instrumentation/fmc/vspeeds/V2", "V2\n%d", 1));
		m.Menus[5].AddItem(SkItem.new(5, m, "VSEC\n184"));
		m.Menus[5].AddItem(SkItem.new(6, m, "MSG"));

		m.Menus[6].AddItem(SkMenuActivateItem.new(0, m, "", 4)); # back
		m.Menus[6].AddItem(SkItem.new(6, m, "MSG"));

		m.Menus[7].AddItem(SkMenuActivateItem.new(0, m, "", 4)); # back
		m.Menus[7].AddItem(SkItem.new(1, m, "VC\n239", 1));
		m.Menus[7].AddItem(SkItem.new(3, m, "VSTD\n180", 1));
		m.Menus[7].AddItem(SkItem.new(4, m, "L 80.7\nR 80.7", 1));
		m.Menus[7].AddItem(SkItem.new(6, m, "MSG"));

		m.Menus[8].AddItem(SkMenuActivateItem.new(0, m, "", 4)); # back
		m.Menus[8].AddItem(SkItem.new(1, m, "FLAPS\n32", 1));
		m.Menus[8].AddItem(SkItem.new(2, m, "VFL0\n170", 1));
		m.Menus[8].AddItem(SkMutableItem.new(3, m, "instrumentation/fmc/vspeeds/Vref", "VREF\n%d", 1));
		m.Menus[8].AddItem(SkItem.new(4, m, "L100.0\nR100.0", 1));
		m.Menus[8].AddItem(SkItem.new(6, m, "MSG"));

		m.ActivatePage(0, 0);
		m.ActivateMenu(0);
		return m;
	}
};

var eicasBtClick = func(input = -1) {
	EicasInstance.BtClick(input);
}

var eicasListener = setlistener("/sim/signals/fdm-initialized", func () {

	var eicasCanvas = canvas.new({
		"name": "EICAS",
		"size": [1024, 1024],
		"view": [800, 950],
		"mipmapping": 1
	});
	eicasCanvas.addPlacement({"node": "EICAS_Screen"});
	EicasInstance = EICAS.new(eicasCanvas.createGroup());

	removelistener(eicasListener);
});
