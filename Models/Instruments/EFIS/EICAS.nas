# by xcvb85

var EicasInstance = {};
var EicasSoftkeys = [["MAIN","CAPT\nSYSTEM","REF\nDATA","COPY","AHRS","F/O\nSYSTEM","MSG"], #0
		["SYSTEM 1/3","FLIGHT\nCONTROL","HYDR","ENGINE","FUEL","NEXT",""], #1
		["SYSTEM 2/3","ELECTR","ECS","ICE\nPROTECT","APU","NEXT",""], #2
		["SYSTEM 3/3","CPCS/\nOXYGEN","DOORS","SYS\nMAINT","SENSOR\nDATA","NEXT",""], #3
		["REF DATA","T/O","CLIMB","CRUISE","LANDG","SINGLE\nENGINE","MSG"], #4
		["T/O","FLAPS\n12","V1\n102","VR\n108","V2\n113","T/O TQ","MSG"], #5
		["CLIMB","VCL\n200","","","L 84.6\nR 84.6","","MSG"], #6
		["CRUISE","VC\n239","","VSTD\n180","L 80.7\nR 80.7","","MSG"], #7
		["LANDG","FLAPS\n32","VFL0\n170","VREF\n110","L100.0\nR100.0","","MSG"], #8
		["T/O TQ","TEMP °C\n18","TEMP °F\n64","","L100.0\nR100.0","","MSG"], #9
		["MAINT","TREND","EXCEED","FAULT","GNDMNT","","RNG"]]; #10

var EICAS = {
	new: func(group)
	{
		var m = { parents: [EICAS], Pages:{}, SkInstance:{} };

		m.ShownSkPage = 0; # indicates which page (softkeys) is shown
		m.SelectedSkPage = 0; # indicates which softkey gets a frame (page)
		m.SelectedSk = -1; # indicates which softkey gets a frame (softkey number)

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

		m.SkInstance = canvas_softkeys.new(group.createChild('group'));
		m.SkInstance.setSoftkeys(EicasSoftkeys[0]);
		m.ActivatePage(0);

		return m;
	},
	ActivatePage: func(input = -1)
	{
		for(i=0; i<size(me.Pages); i+=1) {
			if(i == input) {
				me.Pages[i].show();
			}
			else {
				me.Pages[i].hide();
			}
		}
	},
	# input: 0=back, 1=sk1...5=sk5
	BtClick: func(input = -1) {

		if(getprop("systems/electrical/outputs/efis") < 1) {
			return;
		}
		if(input == 0) {
			# back button pressed
			if(me.ShownSkPage > 4) {
				# go back to "REF DATA"
				me.SkInstance.setSoftkeys(EicasSoftkeys[4]);
				me.ShownSkPage = 4;
			}
			else {
				# go back to main menu
				me.SkInstance.setSoftkeys(EicasSoftkeys[0]);
				me.ActivatePage(0);
				me.ShownSkPage = 0;
				me.SelectedSkPage = 0;
				me.SelectedSk = -1;
			}
		}
		else {
			# softkey pressed
			if(me.ShownSkPage == 0) {
				# main menu
				if(input == 1 or input == 5) {
					# activate "CAPT SYSTEM" or "F/O SYSTEM" page
					me.SkInstance.setSoftkeys(EicasSoftkeys[1]);
					me.ShownSkPage = 1;
				}
				else if(input == 2) {
					# activate "REF DATA" page
					me.SkInstance.setSoftkeys(EicasSoftkeys[4]);
					me.ShownSkPage = 4;
				}
			}
			else if(me.ShownSkPage == 1) {
				# "SYSTEM 1/3" page
				if(input == 1) {
					# activate "FLIGHT CONTROL" page
					me.ActivatePage(1);
					me.SelectedSkPage = 1;
					me.SelectedSk = 0;
				}
				else if(input == 4) {
					# activate "FUEL" page
					me.ActivatePage(4);
					me.SelectedSkPage = 1;
					me.SelectedSk = 3;
				}
				else if(input == 5) {
					# activate "SYSTEM 2/3" page
					me.SkInstance.setSoftkeys(EicasSoftkeys[2]);
					me.ShownSkPage = 2;
				}
			}
			else if(me.ShownSkPage == 2) {
				# "SYSTEM 2/3" page
				if(input == 1) {
					# activate "ELECTR" page
					me.ActivatePage(5);
					me.SelectedSkPage = 2;
					me.SelectedSk = 0;
				}
				else if(input == 2) {
					# activate "ECS" page
					me.ActivatePage(6);
					me.SelectedSkPage = 2;
					me.SelectedSk = 1;
				}
				else if(input == 3) {
					# activate "ICE" page
					me.ActivatePage(7);
					me.SelectedSkPage = 2;
					me.SelectedSk = 2;
				}
				else if(input == 4) {
					# activate "APU" page
					me.ActivatePage(8);
					me.SelectedSkPage = 2;
					me.SelectedSk = 3;
				}
				else if(input == 5) {
					# activate "SYSTEM 3/3" page
					me.SkInstance.setSoftkeys(EicasSoftkeys[3]);
					me.ShownSkPage = 3;
				}
			}
			else if(me.ShownSkPage == 3) {
				# "SYSTEM 3/3" page
				if(input == 1) {
					# activate "CPCS" page
					me.ActivatePage(9);
					me.SelectedSkPage = 3;
					me.SelectedSk = 0;
				}
				else if(input == 2) {
					# activate "DOORS" page
					me.ActivatePage(10);
					me.SelectedSkPage = 3;
					me.SelectedSk = 1;
				}
				else if(input == 5) {
					# activate "SYSTEM 1/3" page
					me.SkInstance.setSoftkeys(EicasSoftkeys[1]);
					me.ShownSkPage = 1;
				}
			}
			else if(me.ShownSkPage == 4) {
				# "REF DATA" page
				if(input == 1) {
					# activate "T/O"
					setprop("instrumentation/fmc/phase-name", "T/O");
					EicasSoftkeys[5][2] = sprintf("V1\n%3.0f",getprop("/instrumentation/fmc/vspeeds/V1"));
					EicasSoftkeys[5][3] = sprintf("VR\n%3.0f",getprop("/instrumentation/fmc/vspeeds/VR"));
					EicasSoftkeys[5][4] = sprintf("V2\n%3.0f",getprop("/instrumentation/fmc/vspeeds/V2"));
					me.SkInstance.setSoftkeys(EicasSoftkeys[5]);
					me.SkInstance.drawFrames([1,1,1,1,0]);
					me.ShownSkPage = 5;
					me.SelectedSkPage = 4;
					me.SelectedSk = 0;
				}
				else if(input == 2) {
					# activate "CLIMB"
					setprop("instrumentation/fmc/phase-name", "CLIMB");
					me.SkInstance.setSoftkeys(EicasSoftkeys[6]);
					me.SkInstance.drawFrames([0,0,0,1,0]);
					me.ShownSkPage = 6;
					me.SelectedSkPage = 4;
					me.SelectedSk = 1;
				}
				else if(input == 3) {
					# activate "CRUISE"
					setprop("instrumentation/fmc/phase-name", "CRUISE");
					me.SkInstance.setSoftkeys(EicasSoftkeys[7]);
					me.SkInstance.drawFrames([1,0,1,1,0]);
					me.ShownSkPage = 7;
					me.SelectedSkPage = 4;
					me.SelectedSk = 2;
				}
				else if(input == 4) {
					# activate "LANDG"
					setprop("instrumentation/fmc/phase-name", "LANDG");
					EicasSoftkeys[8][3] = sprintf("VREF\n%3.0f",getprop("/instrumentation/fmc/vspeeds/Vref"));
					me.SkInstance.setSoftkeys(EicasSoftkeys[8]);
					me.SkInstance.drawFrames([1,1,1,1,0]);
					me.ShownSkPage = 8;
					me.SelectedSkPage = 4;
					me.SelectedSk = 3;
				}
			}
		}

		# check if you selected the page where the selected softkey is located
		if(me.ShownSkPage == me.SelectedSkPage and me.ShownSkPage > 0) {

			if(me.SelectedSk >= 0) {
				var softkeyFrames = [0,0,0,0,0];
				softkeyFrames[me.SelectedSk] = 1;
				me.SkInstance.drawFrames(softkeyFrames);
			}
		}
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
