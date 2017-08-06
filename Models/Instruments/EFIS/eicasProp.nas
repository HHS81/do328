var canvas_eicas = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_eicas] };
		m.group = canvasGroup;
		m.frameCounter = 0;
		m.tmp = 0;
		m.flaps = 0;
		m.trim = 0;

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};
		
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/eicasProp.svg", {'font-mapper': font_mapper});
		
		var svg_keys = ["msgMemo","msgWarning","msgCaution","msgAdvisory",
				"readout_tq1","readout_tq2","dial_tq1","dial_tq2",
				"readout_np1","readout_np2","dial_np1","dial_np2",
				"readout_itt1","readout_itt2","dial_itt1","dial_itt2",
				"readout_nh1","readout_nh2","dial_nh1","dial_nh2",
				"readout_ft","readout_fpm","oilPrssLow1","oilPrssLow2",
				"arrowOilTemp1","arrowOilTemp2","arrowOilPrss1","arrowOilPrss2",
				"oilTempLow1","oilTempLow2","oilTempHigh1","oilTempHigh2",
				"readout_tl","readout_tr","readout_ff1","readout_ff2",
				"indicator_flaps1","indicator_flaps2","readout_flaps1","readout_flaps2",
				"indicator_spoilers","trim_aileron","trim_rudder","trim_pitch",
				"trim_to", "flaps_to","flaps_landg"];

		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		var center = {};
		center = m.indicator_flaps1.getCenter();
		m.indicator_flaps1.createTransform().setTranslation(-center[0], -center[1]);
		m.indicator_flaps1_scale = m.indicator_flaps1.createTransform();
		m.indicator_flaps1.createTransform().setTranslation(center[0], center[1]);
		m.indicator_flaps1_scale.setScale(1,0);
		center = m.indicator_flaps2.getCenter();
		m.indicator_flaps2.createTransform().setTranslation(-center[0], -center[1]);
		m.indicator_flaps2_scale = m.indicator_flaps2.createTransform();
		m.indicator_flaps2.createTransform().setTranslation(center[0], center[1]);
		m.indicator_flaps2_scale.setScale(1,0);

		m.msgMemo.setText("");
		m.msgWarning.setText("");
		m.msgCaution.setText("");
		m.msgAdvisory.setText("");

		m.active = 0;
		return m;
	},
	update: func()
	{
		me.updateFast();

		me.frameCounter += 1;
		if(me.frameCounter > 3) {
			me.frameCounter = 0;
			me.updateSlow();
		}

		if(me.active == 1) {
			settimer(func me.update(), 0.1);
		}
	},
	updateFast: func()
	{
		for(me.n = 0; me.n<2; me.n+=1) {
			# engine dials
			me["dial_tq"~(me.n+1)].setRotation((270/100) * D2R *
					(getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/trq-percent") or 0));

			me["dial_np"~(me.n+1)].setRotation((270/1300) * D2R *
					(getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/propeller-rpm") or 0));

			me["dial_itt"~(me.n+1)].setRotation((270/730) * D2R *
					(getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/itt-c") or 0));

			me["dial_nh"~(me.n+1)].setRotation((270/100) * D2R *
					(getprop("engines/engine[0]/n1") or 0));

			# oil pressure
			me.tmp = getprop("engines/engine["~me.n~"]/oil-pressure-psi") or 0;
			me["arrowOilPrss"~(me.n+1)].setTranslation(me.tmp*3.375, 0); #135/40
			if(me.tmp < 20) {
				me["oilPrssLow"~(me.n+1)].show();
				me["arrowOilPrss"~(me.n+1)].setColorFill(1, 0, 0);
			}
			else {
				me["oilPrssLow"~(me.n+1)].hide();
				me["arrowOilPrss"~(me.n+1)].setColorFill(1, 1, 1);
			}
		}

		# flaps
		me.flaps = getprop("surface-positions/flap-pos-norm") or 0;
		me.readout_flaps1.setText(sprintf("%2.0f",32*me.flaps));
		me.readout_flaps2.setText(sprintf("%2.0f",32*me.flaps));
		if(me.flaps < 0.04) {
			me.flaps = 0.04; # bar at least 2px
		}
		me.indicator_flaps1_scale.setScale(1,me.flaps);
		me.indicator_flaps2_scale.setScale(1,me.flaps);

		# trim
		me.trim = getprop("controls/flight/elevator-trim") or 0;
		if(me.trim < 0) {
			me.trim_pitch.setTranslation(0, me.trim*84);
		}
		else {
			if(me.trim > 0.65) {
				me.trim = 0.65;
			}
			me.trim_pitch.setTranslation(0, me.trim*37); #24/0.65
		}
	},
	updateSlow: func()
	{
		for(me.n = 0; me.n<2; me.n+=1) {
			# engine texts
			me["readout_tq"~(me.n+1)].setText(sprintf("%3.01f", 
				getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/trq-percent") or 0));

			me["readout_np"~(me.n+1)].setText(sprintf("%3.01f",
				(getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/propeller-rpm") or 0)/13));

			me["readout_itt"~(me.n+1)].setText(sprintf("%3.0f",
				getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/itt-c") or 0));

			me["readout_nh"~(me.n+1)].setText(sprintf("%3.01f", getprop("engines/engine[0]/n1") or 0));

			# oil temperature
			me.tmp = getprop("engines/engine["~me.n~"]/oil-temperature-degf") or 0;
			me["arrowOilTemp"~(me.n+1)].setTranslation(me.tmp*0.675, 0); #135/200
			if(me.tmp < 95) {
				me["oilTempLow"~(me.n+1)].show();
				me["oilTempHigh"~(me.n+1)].hide();
				me["arrowOilTemp"~(me.n+1)].setColorFill(1, 0.75, 0);
			}
			else if(me.tmp > 195) {
				me["oilTempLow"~(me.n+1)].hide();
				me["oilTempHigh"~(me.n+1)].show();
				me["arrowOilTemp"~(me.n+1)].setColorFill(1, 0, 0);
			}
			else {
				me["oilTempLow"~(me.n+1)].hide();
				me["oilTempHigh"~(me.n+1)].hide();
				me["arrowOilTemp"~(me.n+1)].setColorFill(1, 1, 1);
			}
			me["readout_ff"~(me.n+1)].setText(sprintf("%3.0f",(getprop("engines/engine["~me.n~"]/fuel-flow_pph") or 0)));
		}

		# tanks
		me.tmp = 0;
		for(me.n=0; me.n<3; me.n+=1) {
			me.tmp += getprop("consumables/fuel/tank["~me.n~"]/level-lbs") or 0;
		}
		me.readout_tl.setText(sprintf("%3.0f", me.tmp));
		me.tmp = 0;
		for(me.n=3; me.n<6; me.n+=1) {
			me.tmp += getprop("consumables/fuel/tank["~me.n~"]/level-lbs") or 0;
		}
		me.readout_tr.setText(sprintf("%3.0f", me.tmp));

		# pressurization
		me.readout_ft.setText(sprintf("%3.0f", getprop("systems/pressurization/cabin-altitude-ft") or 0));
		me.readout_fpm.setText(sprintf("%3.0f", getprop("systems/pressurization/cabin-rate-fpm") or 0));

		# spoiler
		if((getprop("controls/flight/spoilers") or 0) > 0) {
			me.indicator_spoilers.show();
		}
		else {
			me.indicator_spoilers.hide();
		}

		# T/O mode
		if(getprop("instrumentation/fmc/phase-name") == "T/O") {
			# green if correctly trimmed
			if(me.trim < -0.3 and me.trim > -0.75) {
				me.trim_pitch.setColorFill(0,1,0);
			}
			else {
				me.trim_pitch.setColorFill(1,1,1);
			}

			# amber if wrong flaps
			if(me.flaps == 0.375) {
				me.readout_flaps1.setColor(1,1,1);
				me.readout_flaps2.setColor(1,1,1);
				me.flaps_to.setColor(1,1,1);
			}
			else {
				me.readout_flaps1.setColor(1,0.75,0);
				me.readout_flaps2.setColor(1,0.75,0);
				me.flaps_to.setColor(1,0.75,0);
			}
			me.trim_to.show();
			me.flaps_to.show();
			me.flaps_landg.hide();
		}
		else if(getprop("instrumentation/fmc/phase-name") == "LANDG") {
			# amber if wrong flaps
			if(me.flaps == 1) {
				me.readout_flaps1.setColor(1,1,1);
				me.readout_flaps2.setColor(1,1,1);
				me.flaps_landg.setColor(1,1,1);
			}
			else {
				me.readout_flaps1.setColor(1,0.75,0);
				me.readout_flaps2.setColor(1,0.75,0);
				me.flaps_landg.setColor(1,0.75,0);
			}
			me.trim_pitch.setColorFill(1,1,1);
			me.trim_to.hide();
			me.flaps_to.hide();
			me.flaps_landg.show();
		}
		else {
			me.trim_pitch.setColorFill(1,1,1);
			me.readout_flaps1.setColor(1,1,1);
			me.readout_flaps2.setColor(1,1,1);
			me.trim_to.hide();
			me.flaps_to.hide();
			me.flaps_landg.hide();
		}

		#me.msgWarning.setText(getprop("instrumentation/eicas/msg/warning"));
		#me.msgCaution.setText(getprop("instrumentation/eicas/msg/caution"));
		#me.msgAdvisory.setText(getprop("instrumentation/eicas/msg/advisory"));
		#me.msgMemo.setText(getprop("instrumentation/eicas/msg/memo"));
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
