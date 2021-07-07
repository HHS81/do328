var canvas_engine = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_engine] };
		m.group = canvasGroup;
		m.n = 0;

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};

		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/engineProp.svg", {'font-mapper': font_mapper});

		var svg_keys = ["readout_tq1","readout_tq2","readout_np1","readout_np2",
				"readout_itt1","readout_itt2","readout_nh1","readout_nh2",
				"readout_nl1","readout_nl2","readout_ff1","readout_ff2",
				"readout_oilTemp1","readout_oilTemp2","readout_oilPrss1","readout_oilPrss2",
				"arrowOilTemp1","arrowOilTemp2","arrowOilPrss1","arrowOilPrss2",
				"oilTempLow1","oilTempLow2","oilTempHigh1","oilTempHigh2",
				"oilPrssLow1","oilPrssLow2","hideme",
				"readout_oat","readout_ft"];

		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.hideme.hide();
		m.timer = maketimer(0.1, m, m.update);
		return m;
	},
	update: func()
	{
		for(me.n = 0; me.n<2; me.n+=1) {
			me["readout_tq"~(me.n+1)].setText(sprintf("%3.01f", 
				getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/trq-percent") or 0));

			me["readout_np"~(me.n+1)].setText(sprintf("%3.01f",
				(getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/propeller-rpm") or 0)/13));

			me["readout_itt"~(me.n+1)].setText(sprintf("%3.0f",
				getprop("/fdm/jsbsim/propulsion/engine["~me.n~"]/itt-c") or 0));

			me["readout_nh"~(me.n+1)].setText(sprintf("%3.01f", getprop("engines/engine["~me.n~"]/n1") or 0));

			me["readout_nl"~(me.n+1)].setText(sprintf("%3.01f", getprop("engines/engine["~me.n~"]/n2") or 0));

			# oil pressure
			me.tmp = getprop("engines/engine["~me.n~"]/oil-pressure-psi") or 0;
			me["readout_oilPrss"~(me.n+1)].setText(sprintf("%3.01f", me.tmp));
			me["arrowOilPrss"~(me.n+1)].setTranslation(me.tmp*3.375, 0); #135/40
			if(me.tmp < 20) {
				me["oilPrssLow"~(me.n+1)].show();
				me["arrowOilPrss"~(me.n+1)].setColorFill(1, 0, 0);
			}
			else {
				me["oilPrssLow"~(me.n+1)].hide();
				me["arrowOilPrss"~(me.n+1)].setColorFill(1, 1, 1);
			}

			# oil temperature
			me.tmp = getprop("engines/engine["~me.n~"]/oil-temperature-degf") or 0;
			me["readout_oilTemp"~(me.n+1)].setText(sprintf("%3.01f", me.tmp));
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
		me.readout_oat.setText(sprintf("%3.01f", getprop("environment/temperature-degc") or 0));
		me.readout_ft.setText(sprintf("%3.0f", getprop("instrumentation/altimeter/indicated-altitude-ft") or 0));
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
