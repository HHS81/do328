var RectEnum = {comStbyRect:0,
	navStbyRect:1,
	trspCodeRect:2,
	adfRect:3,
	trspModeRect:4,
	comMemRect:5,
	navMemRect:6
};

var canvas_frequencies = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_frequencies], rects:{} };
		m.group = canvasGroup;
		m.Instance = instance;
		m.Id = instance;
		m.ActiveRect = 0;
		m.NextFreeCom = 0;
		m.NextFreeNav = 0;
		m.MemPosCom = -1;
		m.MemPosNav = -1;
		m.Step = 0;
		m.Tmp1 = 0;
		m.Tmp2 = 0;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/frequencies.svg", {'font-mapper': font_mapper});

		var svg_keys = ["comFreq","navFreq","comStby", "navStby",
				"atc","trspCode","trspMode","atcId","atcOnline",
				"memCom","memNav",
				"com","comNum","nav","navNum",
				"adf1","adfNum","adfFreq",
				"tcas","tcasNum","tcasDsp","tcasRange",
				"mls","mlsNum","mlsDsp"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		var svg_rects = ["comStbyRect","navStbyRect","trspCodeRect",
				"adfRect","trspModeRect","comMemRect","navMemRect"];
		for(i=0; i<size(svg_rects); i+=1) {
			m.rects[i] = canvasGroup.getElementById(svg_rects[i]);
		}

		m.ActivateRect(RectEnum.comStbyRect);
		m.tcasRange.setText("6");
		m.listen();
		m.update();
		return m;
	},
	listen : func {
		# listen to all properties for cross side mode
		setlistener("instrumentation/rmu[0]/offside", func{ me.update() });
		setlistener("instrumentation/rmu[1]/offside", func{ me.update() });
		setlistener("instrumentation/rmu[0]/mlsDsp", func{ me.update() });
		setlistener("instrumentation/rmu[1]/mlsDsp", func{ me.update() });
		setlistener("instrumentation/rmu[0]/atcId", func{ me.update() });
		setlistener("instrumentation/rmu[1]/atcId", func{ me.update() });
		setlistener("instrumentation/rmu[0]/tcasDsp", func{ me.update() });
		setlistener("instrumentation/rmu[1]/tcasDsp", func{ me.update() });
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
		setlistener("instrumentation/transponder/id-code", func{ me.update() });
		setlistener("sim/multiplay/callsign", func{ me.update() });
		setlistener("sim/multiplay/online", func{ me.update() });
	},
	ActivateRect: func(input = -1) {
		for(me.Tmp1=0; me.Tmp1 < size(me.rects); me.Tmp1+=1) {
			if(input == me.Tmp1) {
				me.rects[me.Tmp1].show();
			}
			else {
				me.rects[me.Tmp1].hide();
			}
		}
		me.ActiveRect = input;
	},
	update: func() {
		if(getprop("instrumentation/rmu["~me.Instance~"]/offside")) {
			# this rmu controlls offside system
			if(me.Instance == 0) {
				me.Id = 1;
			}
			else {
				me.Id = 0;
			}
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
			me.mls.setColor(magenta);
			me.mlsNum.setColor(magenta);
		}
		else {
			# normal mode
			me.Id = me.Instance;

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
			me.mls.setColor(white);
			me.mlsNum.setColor(white);
		}

		me.comNum.setText(sprintf("%d",me.Id+1));
		me.navNum.setText(sprintf("%d",me.Id+1));
		me.adfNum.setText(sprintf("%d",me.Id+1));
		me.tcasNum.setText(sprintf("%d",me.Id+1));
		me.mlsNum.setText(sprintf("%d",me.Id+1));

		# get memory locations comm
		me.Tmp1 = getprop("instrumentation/comm["~me.Id~"]/frequencies/standby-mhz");
		me.NextFreeCom = -1;
		for(me.Step = 0; me.Step < 12; me.Step+=1) {
			me.Tmp2 = getprop("instrumentation/rmu/memory/comm/mem["~me.Step~"]") or 0;

			if(me.Tmp2 == me.Tmp1) {
				# get memory location
				me.NextFreeCom = -1; # disable sto button
				me.MemPosCom = me.Step;
				me.memCom.setText(sprintf("MEMORY-%d",me.Step+1));
				break;
			}
			elsif(me.Tmp2 == 0 and me.NextFreeCom == -1) {
				# get next free memory location
				me.NextFreeCom = me.Step;
				me.MemPosCom = me.Step;
				me.memCom.setText(sprintf("TEMP-%d",me.NextFreeCom+1));
			}
		}

		# get memory locations nav
		me.Tmp1 = getprop("instrumentation/nav["~me.Id~"]/frequencies/standby-mhz");
		me.NextFreeNav = -1;
		for(me.Step = 0; me.Step < 12; me.Step+=1) {
			me.Tmp2 = getprop("instrumentation/rmu/memory/nav/mem["~me.Step~"]") or 0;

			if(me.Tmp2 == me.Tmp1) {
				# get memory location
				me.NextFreeNav = -1; # disable sto button
				me.MemPosNav = me.Step;
				me.memNav.setText(sprintf("MEMORY-%d",me.Step+1));
				break;
			}
			elsif(me.Tmp2 == 0 and me.NextFreeNav == -1) {
				# get next free memory location
				me.NextFreeNav = me.Step;
				me.MemPosNav = me.Step;
				me.memNav.setText(sprintf("TEMP-%d",me.NextFreeNav+1));
			}
		}

		me.comFreq.setText(sprintf("%.2f",getprop("instrumentation/comm["~me.Id~"]/frequencies/selected-mhz")));
		me.comStby.setText(sprintf("%.2f",getprop("instrumentation/comm["~me.Id~"]/frequencies/standby-mhz")));
		me.navFreq.setText(sprintf("%.2f",getprop("instrumentation/nav["~me.Id~"]/frequencies/selected-mhz")));
		me.navStby.setText(sprintf("%.2f",getprop("instrumentation/nav["~me.Id~"]/frequencies/standby-mhz")));
		me.adfFreq.setText(sprintf("%d",getprop("instrumentation/adf["~me.Id~"]/frequencies/selected-khz")));
		me.trspCode.setText(sprintf("%04d",getprop("instrumentation/transponder/id-code")));
		if(getprop("instrumentation/rmu["~me.Instance~"]/atcId") or 0) {
			me.atcId.setText(string.uc(getprop("sim/multiplay/callsign")));
			me.atcId.show();
		}
		else {
			me.atcId.hide();
		}

		if(getprop("sim/multiplay/online") or 0) {
			me.atcOnline.show();
		}
		else {
			me.atcOnline.hide();
		}

		if(getprop("instrumentation/rmu["~me.Id~"]/mlsDsp") or 0) {
			me.mlsDsp.show();
		}
		else {
			me.mlsDsp.hide();
		}

		if(getprop("instrumentation/rmu["~me.Id~"]/tcasDsp") or 0) {
			me.tcasDsp.show();
		}
		else {
			me.tcasDsp.hide();
		}
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
			if(me.ActiveRect == RectEnum.comStbyRect) {
				me.ActivateRect(RectEnum.comMemRect);
			}
			else {
				me.ActivateRect(RectEnum.comStbyRect);
			}
		}
		if(input == 3) {
			if(me.ActiveRect == RectEnum.navStbyRect) {
				me.ActivateRect(RectEnum.navMemRect);
			}
			else {
				me.ActivateRect(RectEnum.navStbyRect);
			}
		}
		if(input == 4) {
			me.ActivateRect(RectEnum.trspCodeRect);
		}
		if(input == 5) {
			me.ActivateRect(RectEnum.adfRect);
		}
		if(input == 14) {
			me.Tmp1 = getprop("instrumentation/rmu["~me.Instance~"]/offside") or 0;
			if(me.Tmp1) {
				setprop("instrumentation/rmu["~me.Instance~"]/offside", 0);
			}
			else {
				setprop("instrumentation/rmu["~me.Instance~"]/offside", 1);
			}
		}
		if(input == 15) {
			if((me.ActiveRect == 0 or me.ActiveRect == 5) and me.NextFreeCom > -1) {
				me.Tmp1 = getprop("instrumentation/comm["~me.Id~"]/frequencies/standby-mhz");
				setprop("instrumentation/rmu/memory/comm/mem["~me.NextFreeCom~"]", me.Tmp1);
			}

			if((me.ActiveRect == 1 or me.ActiveRect == 6) and me.NextFreeNav > -1) {
				me.Tmp1 = getprop("instrumentation/nav["~me.Id~"]/frequencies/standby-mhz");
				setprop("instrumentation/rmu/memory/nav/mem["~me.NextFreeNav~"]", me.Tmp1);
			}
		}
		if(input == 17) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.pagemenu);
		}
		me.update();
	},
	Knob: func(index = -1, input = -1) {
		me.Step = 1;

		if(me.ActiveRect == RectEnum.comStbyRect) {
			if(index == 1) {
				me.Step = 0.05;
			}
			me.Tmp1 = getprop("instrumentation/comm["~me.Id~"]/frequencies/standby-mhz");
			me.Tmp1 += me.Step * input;

			if(me.Tmp1 >= 117.975 and me.Tmp1 <= 137) {
				setprop("instrumentation/comm["~me.Id~"]/frequencies/standby-mhz", me.Tmp1);
			}
		}
		elsif(me.ActiveRect == RectEnum.navStbyRect) {
			if(index == 1) {
				me.Step = 0.05;
			}
			me.Tmp1 = getprop("instrumentation/nav["~me.Id~"]/frequencies/standby-mhz");
			me.Tmp1 += me.Step * input;

			if(me.Tmp1 >= 108 and me.Tmp1 <= 117.95) {
				setprop("instrumentation/nav["~me.Id~"]/frequencies/standby-mhz", me.Tmp1);
			}
		}
		elsif(me.ActiveRect == RectEnum.trspCodeRect) {
			if(index == 0) {
				me.Step = 100;
			}
			me.Tmp1 = getprop("instrumentation/transponder/id-code");
			me.Tmp1 += me.Step * input;

			if(me.Tmp1 >= 0 and me.Tmp1 <= 9999) {
				setprop("instrumentation/transponder/id-code", me.Tmp1);
			}
		}
		elsif(me.ActiveRect == RectEnum.adfRect) {
			if(index == 0) {
				me.Step = 100;
			}
			me.Tmp1 = getprop("instrumentation/adf["~me.Id~"]/frequencies/selected-khz");
			me.Tmp1 += me.Step * input;

			if(me.Tmp1 >= 180 and me.Tmp1 <= 1750) {
				setprop("instrumentation/adf["~me.Id~"]/frequencies/selected-khz", me.Tmp1);
			}
		}
		elsif(me.ActiveRect == RectEnum.comMemRect) {
			if(input > 0) {
				if(me.MemPosCom < 0) {
					me.Tmp1 = 0;
				}
				else {
					me.Tmp1 = me.MemPosCom+1;
				}

				for(me.Step = me.Tmp1; me.Step < 12; me.Step+=1) {
					me.Tmp2 = getprop("instrumentation/rmu/memory/comm/mem["~me.Step~"]") or 0;

					if(me.Tmp2 > 0) {
						me.MemPosCom = me.Step;
						setprop("instrumentation/comm["~me.Id~"]/frequencies/standby-mhz", me.Tmp2);
						break;
					}
				}
			}
			else {
				if(me.MemPosCom < 0) {
					me.Tmp1 = 11;
				}
				else {
					me.Tmp1 = me.MemPosCom-1;
				}

				for(me.Step = me.Tmp1; me.Step >= 0; me.Step-=1) {
					me.Tmp2 = getprop("instrumentation/rmu/memory/comm/mem["~me.Step~"]") or 0;

					if(me.Tmp2 > 0) {
						me.MemPosCom = me.Step;
						setprop("instrumentation/comm["~me.Id~"]/frequencies/standby-mhz", me.Tmp2);
						break;
					}
				}
			}
		}
		elsif(me.ActiveRect == RectEnum.navMemRect) {
			if(input > 0) {
				if(me.MemPosNav < 0) {
					me.Tmp1 = 0;
				}
				else {
					me.Tmp1 = me.MemPosNav+1;
				}

				for(me.Step = me.Tmp1; me.Step < 12; me.Step+=1) {
					me.Tmp2 = getprop("instrumentation/rmu/memory/nav/mem["~me.Step~"]") or 0;

					if(me.Tmp2 > 0) {
						me.MemPosNav = me.Step;
						setprop("instrumentation/nav["~me.Id~"]/frequencies/standby-mhz", me.Tmp2);
						break;
					}
				}
			}
			else {
				if(me.MemPosNav < 0) {
					me.Tmp1 = 11;
				}
				else {
					me.Tmp1 = me.MemPosNav-1;
				}

				for(me.Step = me.Tmp1; me.Step >= 0; me.Step-=1) {
					me.Tmp2 = getprop("instrumentation/rmu/memory/nav/mem["~me.Step~"]") or 0;

					if(me.Tmp2 > 0) {
						me.MemPosCom = me.Step;
						setprop("instrumentation/nav["~me.Id~"]/frequencies/standby-mhz", me.Tmp2);
						break;
					}
				}
			}
		}
		me.update();
	},
	show: func()
	{
		me.update();
		me.group.show();
	},
	hide: func()
	{
		me.group.hide();
	}
};
