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
		m.Pages[0] = canvas_eicas.new(group.createChild('group'));
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

		m.SkInstance = canvas_softkeys.new(group.createChild('group'));

		# create menus
		var back = SkMenuPageActivateItem.new(0, m, "back1", 0, 0);
		append(m.Menus, SkMenu.new(0, m, "MAIN"));
		append(m.Menus, SkMenu.new(1, m, "SYSTEM 1/3"));
		append(m.Menus, SkMenu.new(2, m, "SYSTEM 2/3"));
		append(m.Menus, SkMenu.new(3, m, "SYSTEM 3/3"));
		append(m.Menus, SkMenu.new(4, m, "REF DATA"));
		append(m.Menus, SkMenu.new(5, m, "T/O"));
		append(m.Menus, SkMenu.new(6, m, "CLIMB"));
		append(m.Menus, SkMenu.new(7, m, "CRUISE"));
		append(m.Menus, SkMenu.new(8, m, "LANDG"));
		append(m.Menus, SkMenu.new(9, m, "T/O TQ"));

		# create softkeys
		var back = SkMenuPageActivateItem.new(0, m, "back1", 0, 0);
		m.Menus[0].SetItem(0, SkItem.new(0, m, "")); # no back on main page
		m.Menus[0].SetItem(1, SkMenuActivateItem.new(1, m, "CAPT\nSYSTEM", 1));
		m.Menus[0].SetItem(2, SkMenuActivateItem.new(2, m, "REF\nDATA", 4));
		m.Menus[0].SetItem(3, SkItem.new(3, m, "COPY"));
		m.Menus[0].SetItem(4, SkItem.new(4, m, "AHRS"));
		m.Menus[0].SetItem(5, SkMenuActivateItem.new(5, m, "F/O\nSYSTEM", 1));
		m.Menus[0].SetItem(6, SkItem.new(6, m, "MSG"));

		m.Menus[1].SetItem(0, back);
		m.Menus[1].SetItem(1, SkPageActivateItem.new(1, m, "FLIGHT\nCONTROL", 1));
		m.Menus[1].SetItem(2, SkPageActivateItem.new(2, m, "HYDR", 2));
		m.Menus[1].SetItem(3, SkPageActivateItem.new(3, m, "ENGINE", 3));
		m.Menus[1].SetItem(4, SkPageActivateItem.new(4, m, "FUEL", 4));
		m.Menus[1].SetItem(5, SkMenuActivateItem.new(5, m, "NEXT", 2));

		m.Menus[2].SetItem(0, back);
		m.Menus[2].SetItem(1, SkPageActivateItem.new(1, m, "ELECTR", 5));
		m.Menus[2].SetItem(2, SkPageActivateItem.new(2, m, "ECS", 6));
		m.Menus[2].SetItem(3, SkPageActivateItem.new(3, m, "ICE\nPROTECT", 7));
		m.Menus[2].SetItem(4, SkPageActivateItem.new(4, m, "APU", 8));
		m.Menus[2].SetItem(5, SkMenuActivateItem.new(5, m, "NEXT", 3));

		m.Menus[3].SetItem(0, back);
		m.Menus[3].SetItem(1, SkPageActivateItem.new(1, m, "CPCS/\nOXYGEN", 9));
		m.Menus[3].SetItem(2, SkPageActivateItem.new(2, m, "DOORS", 10));
		m.Menus[3].SetItem(3, SkPageActivateItem.new(3, m, "SYS\nMAINT", 11));
		m.Menus[3].SetItem(4, SkItem.new(4, m, "SENSOR\nDATA"));
		m.Menus[3].SetItem(5, SkMenuActivateItem.new(5, m, "NEXT", 1));

		m.Menus[4].SetItem(0, back);
		m.Menus[4].SetItem(1, SkMenuActivateItem.new(1, m, "T/O", 5));
		m.Menus[4].SetItem(2, SkMenuActivateItem.new(2, m, "CLIMB", 6));
		m.Menus[4].SetItem(3, SkMenuActivateItem.new(3, m, "CRUISE", 7));
		m.Menus[4].SetItem(4, SkMenuActivateItem.new(4, m, "LANDG", 8));
		m.Menus[4].SetItem(5, SkItem.new(5, m, "SINGLE\nENGINE"));
		m.Menus[4].SetItem(6, SkItem.new(6, m, "MSG"));

		m.Menus[5].SetItem(0, SkMenuActivateItem.new(1, m, "", 4)); # back
		m.Menus[5].SetItem(1, SkItem.new(1, m, "FLAPS\n12", 1));
		m.Menus[5].SetItem(2, SkMutableItem.new(2, m, "instrumentation/fmc/vspeeds/V1", "V1\n%d", 1));
		m.Menus[5].SetItem(3, SkMutableItem.new(3, m, "instrumentation/fmc/vspeeds/VR", "VR\n%d", 1));
		m.Menus[5].SetItem(4, SkMutableItem.new(4, m, "instrumentation/fmc/vspeeds/V2", "V2\n%d", 1));
		m.Menus[5].SetItem(5, SkMenuActivateItem.new(5, m, "T/O TQ", 9));
		m.Menus[5].SetItem(6, SkItem.new(6, m, "MSG"));

		m.Menus[6].SetItem(0, SkMenuActivateItem.new(1, m, "", 4)); # back
		m.Menus[6].SetItem(1, SkItem.new(1, m, "VCL\n200", 1));
		m.Menus[6].SetItem(4, SkItem.new(4, m, "L 84.6\nR 84.6", 1));
		m.Menus[6].SetItem(6, SkItem.new(6, m, "MSG"));

		m.Menus[7].SetItem(0, SkMenuActivateItem.new(1, m, "", 4)); # back
		m.Menus[7].SetItem(1, SkItem.new(1, m, "VC\n239", 1));
		m.Menus[7].SetItem(3, SkItem.new(3, m, "VSTD\n180", 1));
		m.Menus[7].SetItem(4, SkItem.new(4, m, "L 80.7\nR 80.7", 1));
		m.Menus[7].SetItem(6, SkItem.new(6, m, "MSG"));

		m.Menus[8].SetItem(0, SkMenuActivateItem.new(1, m, "", 4)); # back
		m.Menus[8].SetItem(1, SkItem.new(1, m, "FLAPS\n32", 1));
		m.Menus[8].SetItem(2, SkItem.new(2, m, "VFL0\n170", 1));
		m.Menus[8].SetItem(3, SkItem.new(3, m, "VREF\n110", 1));
		m.Menus[8].SetItem(4, SkItem.new(4, m, "L100.0\nR100.0", 1));
		m.Menus[8].SetItem(6, SkItem.new(6, m, "MSG"));

		m.Menus[9].SetItem(0, SkMenuActivateItem.new(1, m, "", 5)); # back
		m.Menus[9].SetItem(1, SkItem.new(1, m, "TEMP °C\n18", 1));
		m.Menus[9].SetItem(2, SkItem.new(2, m, "TEMP °F\n64", 1));
		m.Menus[9].SetItem(4, SkItem.new(4, m, "L100.0\nR100.0", 1));
		m.Menus[9].SetItem(6, SkItem.new(6, m, "MSG"));

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
