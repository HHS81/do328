### Canvas RCU ###
### C. Le Moigne (clm76) - 2017 ###

var com_freq1 = props.globals.getNode("instrumentation/comm/frequencies/selected-mhz");
var nav_freq1 = props.globals.getNode("instrumentation/nav/frequencies/selected-mhz");
var com_freq2 = props.globals.getNode("instrumentation/comm[1]/frequencies/selected-mhz");
var nav_freq2 = props.globals.getNode("instrumentation/nav[1]/frequencies/selected-mhz");
var selected = props.globals.getNode("instrumentation/rcu/selected");
var mode = props.globals.getNode("instrumentation/rcu/mode");
var sq = props.globals.getNode("instrumentation/rcu/squelch");
var navAud = props.globals.getNode("instrumentation/rcu/nav-audio");
var tx1 = props.globals.getNode("instrumentation/comm/ptt");
var tx2 = props.globals.getNode("instrumentation/comm[1]/ptt");
var emrg = props.globals.getNode("instrumentation/rcu/emrg");

var RCU = {
	new: func() {
		var m = {parents:[RCU]};
		m.canvas = canvas.new({
			"name": "RCU", 
			"size": [1024, 1024],
			"view": [600,256],
			"mipmapping": 1 
		});

		var font_mapper = func(family, weight)
		{
			if(family == "'Liberation Sans'") {
				return "7-Segment.ttf";
			}
		};

		m.canvas.addPlacement({"node": "RCU.screen"});
		m.rcu = m.canvas.createGroup();
		canvas.parsesvg(m.rcu,"Aircraft/do328/Models/Instruments/RCU/RCU.svg", {'font-mapper': font_mapper});
		m.text = {};
		m.text_val = ["comFreq","navFreq","navAudio","sq","tx",
									"comInd","navInd","emrg"];
		foreach(var i;m.text_val) {
			m.text[i] = m.rcu.getElementById(i);
		}

		m.rcu.setVisible(1);

	### Display init ###
		m.text.comFreq.setText(sprintf("%.3f",com_freq1.getValue()));
		m.text.navFreq.setText(sprintf("%.3f",nav_freq1.getValue()));
		m.text.comInd.show();
		m.text.navInd.hide();
		m.text.navAudio.hide();
		m.text.sq.show();
		m.text.tx.hide();
		m.text.emrg.hide();
		return m
	},

	### Listeners ###
	listen : func {

		setlistener("instrumentation/comm/frequencies/selected-mhz", func {
			if (!mode.getValue()) {
				me.text.comFreq.setText(sprintf("%.3f",com_freq1.getValue()));
			}
		});
		setlistener("instrumentation/comm[1]/frequencies/selected-mhz", func {
			if (mode.getValue()) {
				me.text.comFreq.setText(sprintf("%.3f",com_freq2.getValue()));
			}
		});

		setlistener("instrumentation/nav/frequencies/selected-mhz", func {
			if (!mode.getValue()) {
				me.text.navFreq.setText(sprintf("%.3f",nav_freq1.getValue()));
			}
		});
		setlistener("instrumentation/nav[1]/frequencies/selected-mhz", func {
			if (mode.getValue()) {
				me.text.navFreq.setText(sprintf("%.3f",nav_freq2.getValue()));
			}
		});

		setlistener("instrumentation/rcu/selected", func {
			if (selected.getValue() == "COM") {
				me.text.comInd.show();				
				me.text.navInd.hide();
			} else {
				me.text.comInd.hide();				
				me.text.navInd.show();
			}
		});

		setlistener("instrumentation/rcu/mode", func {
			if (!mode.getValue()) {
				me.text.comFreq.setText(sprintf("%.3f",com_freq1.getValue()));
				me.text.navFreq.setText(sprintf("%.3f",nav_freq1.getValue()));
			} else {
				me.text.comFreq.setText(sprintf("%.3f",com_freq2.getValue()));
				me.text.navFreq.setText(sprintf("%.3f",nav_freq2.getValue()));
			}
		});

		setlistener("instrumentation/rcu/squelch", func {
			if (!sq.getValue()) {
				me.text.sq.show();				
			} else {
				me.text.sq.hide();				
			}
		});

		setlistener("instrumentation/rcu/nav-audio", func {
			if (navAud.getValue()) {
				me.text.navAudio.show();				
			} else {
				me.text.navAudio.hide();				
			}
		});

		setlistener("instrumentation/comm/ptt", func {
			if (tx1.getValue()) {
				me.text.tx.show();				
			} else {
				me.text.tx.hide();				
			}
		});

		setlistener("instrumentation/comm[1]/ptt", func {
			if (tx2.getValue()) {
				me.text.tx.show();				
			} else {
				me.text.tx.hide();				
			}
		});

		setlistener("instrumentation/rcu/emrg", func {
			if (emrg.getValue()) {me.text.emrg.show()}
			else {me.text.emrg.hide()}
		});

	}, # end of listen
}; # end of RCU

#### Main ####
var setl = setlistener("/sim/signals/fdm-initialized", func () {
	var init = RCU.new();
	init.listen();
removelistener(setl);
});

