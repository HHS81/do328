var canvas_frequencies = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_frequencies], rects:{} };
		m.group = canvasGroup;
		m.Instance = instance;
		m.Id = instance;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/frequencies.svg", {'font-mapper': font_mapper});

		var svg_keys = ["comFreq","navFreq","comStby", "navStby",
				"trspCode","trspMode","trspNum","adfFreq",
				"memCom","memNav",
				"com","comNum","nav","navNum",
				"atc","adf1","adfNum",
				"tcas","tcasNum"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		var svg_rects = ["comStbyRect","navStbyRect","trspCodeRect",
				"adfRect","trspModeRect"];
		for(i=0; i<size(svg_rects); i=i+1) {
			m.rects[i] = canvasGroup.getElementById(svg_rects[i]);
		}

		m.ActivateRect(0);
		m.listen();
		m.update();
		return m;
	},
	listen : func {
		# listen to all properties for cross side mode
		setlistener("instrumentation/rmu[0]/offside", func{ me.update() });
		setlistener("instrumentation/rmu[1]/offside", func{ me.update() });
		setlistener("instrumentation/comm[0]/frequencies/selected-mhz", func{ me.update() });
		setlistener("instrumentation/comm[1]/frequencies/selected-mhz", func{ me.update() });
		setlistener("instrumentation/comm[0]/frequencies/standby-mhz", func{ me.update() });
		setlistener("instrumentation/comm[1]/frequencies/standby-mhz", func{ me.update() });
		setlistener("instrumentation/nav[0]/frequencies/selected-mhz", func{ me.update() });
		setlistener("instrumentation/nav[1]/frequencies/selected-mhz", func{ me.update() });
		setlistener("instrumentation/nav[0]/frequencies/standby-mhz", func{ me.update() });
		setlistener("instrumentation/nav[1]/frequencies/standby-mhz", func{ me.update() });
		setlistener("instrumentation/adf[0]/frequencies/selected-khz", func{ me.update() });
		setlistener("instrumentation/adf[1]/frequencies/selected-khz", func{ me.update() });
	},
	ActivateRect: func(input = -1) {
		for(i=0; i<size(me.rects); i=i+1) {
			if(input == i) {
				me.rects[i].show();
			}
			else {
				me.rects[i].hide();
			}
		}
		me.ActiveRect = input;
	},
	update: func() {
		me.Id = me.Instance;
		var offsideId = 0;
		if(me.Id == 0) {
			offsideId = 1;
		}

		if(getprop("instrumentation/rmu["~me.Instance~"]/offside")) {
			# this rmu controlls offside system
			me.com.setColor(magenta);
			me.comNum.setColor(magenta);
			me.nav.setColor(magenta);
			me.navNum.setColor(magenta);
			me.comFreq.setColor(amber);
			me.comStby.setColor(amber);
			me.navFreq.setColor(white);
			me.navStby.setColor(cyan);
			me.memCom.setColor(amber);
			me.memNav.setColor(cyan);

			me.atc.setColor(magenta);
			me.adf1.setColor(magenta);
			me.adfNum.setColor(magenta);
			me.trspCode.setColor(amber);
			me.adfFreq.setColor(white);
			me.tcas.setColor(magenta);
			me.tcasNum.setColor(magenta);

			me.Id = offsideId;
		}
		else {
			# normal mode
			me.com.setColor(white);
			me.comNum.setColor(white);
			me.nav.setColor(white);
			me.navNum.setColor(white);
			me.comFreq.setColor(white);
			me.comStby.setColor(cyan);
			me.navFreq.setColor(white);
			me.navStby.setColor(cyan);
			me.memNav.setColor(cyan);
			me.memCom.setColor(cyan);

			me.atc.setColor(white);
			me.adf1.setColor(white);
			me.adfNum.setColor(white);
			me.trspCode.setColor(white);
			me.adfFreq.setColor(white);
			me.tcas.setColor(white);
			me.tcasNum.setColor(white);
		}

		me.comNum.setText(sprintf("%d",me.Id+1));
		me.navNum.setText(sprintf("%d",me.Id+1));
		me.adfNum.setText(sprintf("%d",me.Id+1));
		me.tcasNum.setText(sprintf("%d",me.Id+1));
		me.trspNum.setText("1");
		me.memCom.setText("MEMORY-1");
		me.memNav.setText("MEMORY-1");

		me.comFreq.setText(sprintf("%.2f",getprop("instrumentation/comm["~me.Id~"]/frequencies/selected-mhz")));
		me.comStby.setText(sprintf("%.2f",getprop("instrumentation/comm["~me.Id~"]/frequencies/standby-mhz")));
		me.navFreq.setText(sprintf("%.2f",getprop("instrumentation/nav["~me.Id~"]/frequencies/selected-mhz")));
		me.navStby.setText(sprintf("%.2f",getprop("instrumentation/nav["~me.Id~"]/frequencies/standby-mhz")));
		me.adfFreq.setText(sprintf("%d",getprop("instrumentation/adf["~me.Id~"]/frequencies/selected-khz")));
	},
	BtClick: func(input = -1) {
		if(input == 0) {
			var sel = getprop("instrumentation/comm["~me.Id~"]/frequencies/selected-mhz");
			var stby = getprop("instrumentation/comm["~me.Id~"]/frequencies/standby-mhz");
			setprop("instrumentation/comm["~me.Id~"]/frequencies/selected-mhz", stby);
			setprop("instrumentation/comm["~me.Id~"]/frequencies/standby-mhz", sel);
		}
		if(input == 1) {
			var sel = getprop("instrumentation/nav["~me.Id~"]/frequencies/selected-mhz");
			var stby = getprop("instrumentation/nav["~me.Id~"]/frequencies/standby-mhz");
			setprop("instrumentation/nav["~me.Id~"]/frequencies/selected-mhz", stby);
			setprop("instrumentation/nav["~me.Id~"]/frequencies/standby-mhz", sel);
		}
		if(input == 2) {
			me.ActivateRect(0);
		}
		if(input == 3) {
			me.ActivateRect(1);
		}
		if(input == 4) {
			me.ActivateRect(2);
		}
		if(input == 5) {
			me.ActivateRect(3);
		}
		if(input == 14) {
			var offside = getprop("instrumentation/rmu["~me.Instance~"]/offside");
			if(offside) {
				setprop("instrumentation/rmu["~me.Instance~"]/offside", 0);
			}
			else {
				setprop("instrumentation/rmu["~me.Instance~"]/offside", 1);
			}
		}
		if(input == 17) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.pagemenu);
		}
		me.update();
	},
	Knob: func(index = -1, input = -1) {
		var step = 1;

		if(me.ActiveRect == 0) {
			if(index == 1) {
				#step = 0.025;#wide
				step = 0.05;#narrow
			}
			var freq = getprop("instrumentation/comm["~me.Id~"]/frequencies/standby-mhz");
			if(input > 0) {
				freq = freq + step;
			}
			else {
				freq = freq - step;
			}
			if(freq >= 117.975 and freq <= 137) {
				setprop("instrumentation/comm["~me.Id~"]/frequencies/standby-mhz", freq);
			}
		}
		if(me.ActiveRect == 1) {
			if(index == 1) {
				step = 0.05;
			}
			var freq = getprop("instrumentation/nav["~me.Id~"]/frequencies/standby-mhz");
			if(input > 0) {
				freq = freq + step;
			}
			else {
				freq = freq - step;
			}
			if(freq >= 108 and freq <= 117.95) {
				setprop("instrumentation/nav["~me.Id~"]/frequencies/standby-mhz", freq);
			}
		}
		if(me.ActiveRect == 3) {
			if(index == 0) {
				step = 100;
			}
			var freq = getprop("instrumentation/adf["~me.Id~"]/frequencies/selected-khz");
			if(input > 0) {
				freq = freq + step;
			}
			else {
				freq = freq - step;
			}
			if(freq >= 180 and freq <= 1750) {
				setprop("instrumentation/adf["~me.Id~"]/frequencies/selected-khz", freq);
			}
		}
		me.update();
	},
	show: func()
	{
		me.group.show();
	},
	hide: func()
	{
		me.group.hide();
	}
};
