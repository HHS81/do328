var canvas_electr = {
	new: func(canvasGroup)
	{
		var m = { parents: [canvas_electr] };
		m.group = canvasGroup;
		m.tmp = 0;

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'" and weight == "normal") {
				return "honeywellfont.ttf";
			}
		};

		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/EFIS/electr.svg", {'font-mapper': font_mapper});

		var svg_keys = ["VDC1","VDC2","VAC1","VAC2","VINV1H","VINV1L","VINV2L","VINV2H",
				"NonEss1A","NonEss1G","NonEss2A","NonEss2G","AGenLH","AAPU","AGenRH",
				"FailBatt1","FailBatt2","DCTie"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.NonEss1A.hide();
		m.NonEss2A.hide();

		m.timer = maketimer(0.1, m, m.update);
		return m;
	},
	update: func()
	{
		if(getprop("systems/electrical/outputs/nonEssBus2") > 0) {
			me.NonEss2G.show();
			me.NonEss2A.hide();
		}
		else {
			me.NonEss2A.show();
			me.NonEss2G.hide();
		}

		if(getprop("systems/electrical/DCTie/Connected")) {
			me.DCTie.show();
		}
		else {
			me.DCTie.hide();
		}

		if(getprop("systems/electrical/Battery1/Connected")) {
			me.FailBatt1.hide();
		}
		else {
			me.FailBatt1.show();
		}

		if(getprop("systems/electrical/Battery2/Connected")) {
			me.FailBatt2.hide();
		}
		else {
			me.FailBatt2.show();
		}

		me.tmp = sprintf("%2.01f", getprop("systems/electrical/DCBus1/Voltage") or 0);
		me.VDC1.setText(me.tmp);
		me.VINV1L.setText(me.tmp);

		me.tmp = sprintf("%2.01f", getprop("systems/electrical/DCBus2/Voltage") or 0);
		me.VDC2.setText(me.tmp);
		me.VINV2L.setText(me.tmp);

		me.tmp = sprintf("%d", getprop("systems/electrical/ACBus1/Voltage") or 0);
		me.VAC1.setText(me.tmp);
		me.VINV1H.setText(me.tmp);

		me.tmp = sprintf("%d", getprop("systems/electrical/ACBus2/Voltage") or 0);
		me.VAC2.setText(me.tmp);
		me.VINV2H.setText(me.tmp);

		me.AAPU.setText(sprintf("%3.0f", getprop("systems/electrical/APU/Current") or 0));
		me.AGenLH.setText(sprintf("%3.0f", getprop("systems/electrical/Generator1/Current") or 0));
		me.AGenRH.setText(sprintf("%3.0f", getprop("systems/electrical/Generator2/Current") or 0));
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
