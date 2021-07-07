var canvas_eicas = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_eicas] };
		m.frameCounter = 0;
		m.group = canvasGroup;
		m.n = 0;

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};
		
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/eicasJet.svg", {'font-mapper': font_mapper});

		var svg_keys = ["msgMemo","msgWarning","msgCaution","msgAdvisory",
				"readout_n1_1","readout_n1_2","dial_n1_1","dial_n1_2",
				"readout_itt1","readout_itt2","dial_itt1","dial_itt2",
				"readout_n2_1","readout_n2_2","dial_n2_1","dial_n2_2",
				"arrowOilTemp1","arrowOilTemp2","arrowOilPrss1","arrowOilPrss2",
				"readout_tl","readout_tr","readout_ff1","readout_ff2",
				"indicator_flaps1","indicator_flaps2","readout_flaps1","readout_flaps2",
				"indicator_spoilers","trim_aileron","trim_rudder","trim_pitch",
				"flaps_to","flaps_landg","readout_ft","readout_fpm",
				"trim_to","hideme"];

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

		m.hideme.hide();

		m.timer = maketimer(0.1, m, m.update);
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
	},
	updateFast: func()
	{
		for(me.n = 0; me.n<2; me.n+=1){
			me["dial_n1_"~(me.n+1)].setRotation((270/100) * D2R *
					(getprop("engines/engine["~me.n~"]/n1") or 0));

			me["dial_n2_"~(me.n+1)].setRotation((270/100) * D2R *
					(getprop("engines/engine["~me.n~"]/n1") or 0));

			# oil pressure
			me.tmp = getprop("engines/engine["~me.n~"]/oil-pressure-psi") or 0;
			me["arrowOilPrss"~(me.n+1)].setTranslation(me.tmp*1.8, 0); #135/40
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
		for(me.n = 0; me.n<2; me.n+=1){
			me["readout_n1_"~(me.n+1)].setText(sprintf("%3.01f", getprop("engines/engine["~me.n~"]/n1") or 0));
			me["readout_n2_"~(me.n+1)].setText(sprintf("%3.01f", getprop("engines/engine["~me.n~"]/n1") or 0));

			# oil temperature
			me.tmp = getprop("engines/engine["~me.n~"]/oil-temperature-degf") or 0;
			me["arrowOilTemp"~(me.n+1)].setTranslation(me.tmp*0.675, 0); #135/200

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
		me.readout_ft.setText(sprintf("%d", getprop("systems/pressurization/cabin-altitude-ft") or 0));
		me.readout_fpm.setText(sprintf("%d", getprop("systems/pressurization/cabin-rate-fpm") or 0));

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
				me.readout_flaps1.setColor(1,0.84,0);
				me.readout_flaps2.setColor(1,0.84,0);
				me.flaps_to.setColor(1,0.84,0);
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
				me.readout_flaps1.setColor(1,0.84,0);
				me.readout_flaps2.setColor(1,0.84,0);
				me.flaps_landg.setColor(1,0.84,0);
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
		me.update();
		me.timer.start();
		me.group.show();
	},
	hide: func()
	{
		me.timer.stop();
		me.group.hide();
	}
};
