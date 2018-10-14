var canvas_memorynav = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_memorynav] };
		m.group = canvasGroup;
		m.Instance = instance;
		m.Counter = 0;
		m.ActiveRect = 0;
		m.Offset = 0;
		m.Step = 0;
		m.Tmp = 0;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/memorycom.svg", {'font-mapper': font_mapper});

		for(m.Counter = 0; m.Counter < 6; m.Counter += 1) {
			m["rect"~(m.Counter)] = canvasGroup.getElementById("rect"~(m.Counter+1));
			m["mem"~(m.Counter)] = canvasGroup.getElementById("mem"~(m.Counter+1));
			m["n"~(m.Counter)] = canvasGroup.getElementById("n"~(m.Counter+1));

			m.Tmp = getprop("instrumentation/rmu/memory/nav/mem["~m.Counter~"]") or 0;
			if(m.Tmp > 100) {
				m["mem"~m.Counter].setText(sprintf("%.2f", m.Tmp));
			}
			else {
				m["mem"~m.Counter].setText("");
			}
		}
		m.comFreq = canvasGroup.getElementById("comFreq");

		setlistener("instrumentation/nav["~instance~"]/frequencies/selected-mhz", func{ m.update(); });
		m.update();

		m.ActivateRect(m.ActiveRect);
		return m;
	},
	ActivateRect: func(input = -1) {
		for(me.Counter = 0; me.Counter < 6; me.Counter += 1) {
			if(input == me.Counter) {
				me["rect"~me.Counter].show();
			}
			else {
				me["rect"~me.Counter].hide();
			}
		}
		me.ActiveRect = input;
	},
	update: func() {
		me.comFreq.setText(sprintf("%.2f", getprop("instrumentation/nav["~me.Instance~"]/frequencies/selected-mhz")));
	},
	BtClick: func(input = -1) {
		if(input == 0) {
			# load
			me.Tmp = getprop("instrumentation/rmu/memory/nav/mem["~(me.ActiveRect + me.Offset)~"]") or 0;

			if(me.Tmp > 100) {
				setprop("instrumentation/nav["~me.Instance~"]/frequencies/selected-mhz", me.Tmp);
			}
		}
		if(input < 8) {
			if(input == 2) {
				me.ActiveRect = 0;
			}
			if(input == 4) {
				me.ActiveRect = 1;
			}
			if(input == 6) {
				me.ActiveRect = 2;
			}
			if(input == 3) {
				me.ActiveRect = 3;
			}
			if(input == 5) {
				me.ActiveRect = 4;
			}
			if(input == 7) {
				me.ActiveRect = 5;
			}
			me.ActivateRect(me.ActiveRect);
		}
		if(input == 8) {
			# more
			if(me.Offset == 0) {
				me.Offset = 6;
			}
			else {
				me.Offset = 0;
			}

			for(me.Counter = 0; me.Counter < 6; me.Counter += 1)
			{
				me["n"~me.Counter].setText(sprintf("%d", me.Counter + me.Offset + 1));

				me.Tmp = getprop("instrumentation/rmu/memory/nav/mem["~(me.Counter + me.Offset)~"]") or 0;
				if(me.Tmp > 100) {
					me["mem"~me.Counter].setText(sprintf("%.2f", me.Tmp));
				}
				else {
					me["mem"~me.Counter].setText("");
				}
			}
		}
		if(input == 9) {
			# insert
			me.Tmp = getprop("instrumentation/nav["~me.Instance~"]/frequencies/selected-mhz") or 0;
			me["mem"~me.ActiveRect].setText(sprintf("%.2f", me.Tmp));
			setprop("instrumentation/rmu/memory/nav/mem["~(me.ActiveRect + me.Offset)~"]", me.Tmp);
		}
		if(input == 10) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.frequencies);
		}
		if(input == 11) {
			# delete
			me["mem"~me.ActiveRect].setText("");
			setprop("instrumentation/rmu/memory/nav/mem["~(me.ActiveRect + me.Offset)~"]", 0);
		}
		if(input == 17) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.pagemenu);
		}
	},
	Knob: func(index = -1, input = -1) {
		me.Step = 1;
		me.Tmp = getprop("instrumentation/rmu/memory/nav/mem["~(me.ActiveRect + me.Offset)~"]") or 0;

		if(me.Tmp > 100) {
			if(index == 1) {
				#step = 0.025;#wide
				me.Step = 0.05;#narrow
			}
			me.Tmp += me.Step * input;

			if(me.Tmp >= 108 and me.Tmp <= 117.95) {
				me["mem"~me.ActiveRect].setText(sprintf("%.2f", me.Tmp));
				setprop("instrumentation/rmu/memory/nav/mem["~(me.ActiveRect + me.Offset)~"]", me.Tmp);
			}
		}
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
