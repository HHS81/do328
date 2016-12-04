### Canvas MFD ###
### C. Le Moigne (clm76) - 2016 ###

var com_num2 = props.globals.getNode("instrumentation/rmu/unit[1]/com-num");
var nav_num2 = props.globals.getNode("instrumentation/rmu/unit[1]/nav-num");
var adf_num2 = props.globals.getNode("instrumentation/rmu/unit[1]/adf-num");
var mls_num2 = props.globals.getNode("instrumentation/rmu/unit[1]/mls-num");
var com_freq2 = props.globals.getNode("instrumentation/comm[1]/frequencies/selected-mhz");
var com_stby2 = props.globals.getNode("instrumentation/comm[1]/frequencies/standby-mhz");
var com_mem2 = props.globals.getNode("instrumentation/rmu/unit[1]/mem-com");
var nav_freq2 = props.globals.getNode("instrumentation/nav[1]/frequencies/selected-mhz");
var nav_stby2 = props.globals.getNode("instrumentation/nav[1]/frequencies/standby-mhz");
var nav_mem2 = props.globals.getNode("instrumentation/rmu/unit[1]/mem-nav");
var trsp_code2 = props.globals.getNode("instrumentation/transponder/id-code");
var trsp_mode2 = props.globals.getNode("instrumentation/transponder/inputs/display-mode");
var trsp_num2 = props.globals.getNode("instrumentation/rmu/trsp-num");
var adf_freq2 = props.globals.getNode("instrumentation/adf[1]/frequencies/selected-khz");

	### Create Memories if not exist ###
var mem_path = getprop("/sim/fg-home")~"/aircraft-data/";
var name = mem_path~"CitationX-RMUmem2.xml";
var xfile = subvec(directory(mem_path),2);
var v = std.Vector.new(xfile);
if (!v.contains("CitationX-RMUmem2.xml")) {
	var data = props.Node.new({
		comMem1 : 0,comMem2 : 0,comMem3 : 0,comMem4 : 0,comMem5 : 0,
		comMem6 : 0,comMem7 : 0,comMem8 : 0,comMem9 : 0,comMem10 : 0,
		comMem11 : 0,comMem12 : 0,
		navMem1 : 0,navMem2 : 0,navMem3 : 0,navMem4 : 0,navMem5 : 0,
		navMem6 : 0,navMem7 : 0,navMem8 : 0,navMem9 : 0,navMem10 : 0,
		navMem11 : 0,navMem12 : 0
	});		
	io.write_properties(name,data);
} 

	### Load comm memories ###
var com2 = {};
var com_mem2 = ["comMem1","comMem2","comMem3","comMem4",
							"comMem5","comMem6","comMem7","comMem8",
							"comMem9","comMem10","comMem11","comMem12"];
var mem_path = getprop("/sim/fg-home")~"/aircraft-data/CitationX-RMUmem2.xml";
var data = io.read_properties(mem_path);
foreach(var i;com_mem2) {
	com2[i] = data.getValue(i);
}

	### Load nav memories ###
var nav2 = {};
var nav_mem2 = ["navMem1","navMem2","navMem3","navMem4",
							"navMem5","navMem6","navMem7","navMem8",
							"navMem9","navMem10","navMem11","navMem12"];
var mem_path = getprop("/sim/fg-home")~"/aircraft-data/CitationX-RMUmem2.xml";
var data = io.read_properties(mem_path);
foreach(var i;nav_mem2) {
	nav2[i] = data.getValue(i);
}


	### RMU ###
var RMU2_canvas = {
	new: func() {
		var m = {parents:[RMU2_canvas]};
		m.canvas = canvas.new({
			"name": "RMU2", 
			"size": [1024, 1024],
			"view": [800, 1024],
			"mipmapping": 1 
		});
		m.canvas.addPlacement({"node": "RMU.screenR"});
		m.mfd2 = m.canvas.createGroup();
		canvas.parsesvg(m.mfd2, "Aircraft/CitationX/Models/Instruments/RMU/RMU.svg");
		m.text = {};
		m.text_val = ["comFreq","navFreq","comStby", "navStby",
										"trspCode","trspMode","trspNum","adfFreq",
										"memCom","memNav","comNum","navNum","adfNum","mlsNum"];
		foreach(var i;m.text_val) {
			m.text[i] = m.mfd2.getElementById(i);
		}

		m.rect = {};
		m.cdr = ["comStbyRect","navStbyRect","trspCodeRect",
							"adfRect","trspModeRect"];
		foreach(var i;m.cdr) {
			m.rect[i] = m.mfd2.getElementById(i);
		}
		
		foreach(var i;keys (m.rect))	m.rect[i].hide();
		m.rect.comStbyRect.show();

		m.text.comFreq.setText(sprintf("%.3f",com_freq2.getValue()));
		m.text.comNum.setText(sprintf("%d",com_num2.getValue()));
		m.text.navFreq.setText(sprintf("%.3f",nav_freq2.getValue()));
		m.text.navNum.setText(sprintf("%d",nav_num2.getValue()));
		m.text.adfNum.setText(sprintf("%d",adf_num2.getValue()));
		m.text.adfFreq.setText(sprintf("%d",adf_freq2.getValue()));
		m.text.mlsNum.setText(sprintf("%d",mls_num2.getValue()));
		m.text.trspNum.setText("1");
		m.text.comStby.setText(sprintf("%07.3f",com.comMem1));
		com_stby2.setValue(com.comMem1);
		m.text.memCom.setText("MEMORY-1");
		m.text.navStby.setText(sprintf("%07.3f",nav.navMem1));
		nav_stby2.setValue(nav.navMem1);
		m.text.memNav.setText("MEMORY-1");
		m.text.trspCode.setText(sprintf("%04d",trsp_code2.getValue()));
		m.text.trspMode.setText(trsp_mode2.getValue());

		return m;
	},

	listen : func {
		setlistener("instrumentation/rmu/unit[1]/selected",func {
			var select1 = getprop("instrumentation/rmu/unit[1]/selected");
			var index = 0;
			foreach(var i;me.cdr) {
				if (getprop("instrumentation/rmu/unit[1]/selected")== index) {
					me.rect[i].show();
				} else {me.rect[i].hide()}
				index+=1;
			}
		});	

		setlistener("instrumentation/transponder/inputs/knob-mode", func {
			var mode = getprop("instrumentation/transponder/inputs/knob-mode");
			var mode_display = "";
			if (mode == 0) {mode_display = "STANDBY"}
			if (mode == 1) {mode_display = "ATC ON"}
			if (mode == 2) {mode_display = "ATC ALT"}
			if (mode == 3) {mode_display = "TA ONLY"}
			if (mode == 4) {mode_display = "TA/RA"}
			setprop("instrumentation/transponder/inputs/display-mode",mode_display);
		});

		setlistener("instrumentation/rmu/trsp-num", func {
			me.text.trspNum.setText(trsp_num2.getValue());
		});	

		setlistener("instrumentation/rmu/unit[1]/swp1", func {
			if (getprop("instrumentation/rmu/unit[1]/swp1")) {
				me.text.comFreq.setText(sprintf("%.3f",com_freq2.getValue()));
			}
		});

		setlistener("instrumentation/rmu/unit[1]/swp2", func {
			if (getprop("instrumentation/rmu/unit[1]/swp2")) {
				me.text.navFreq.setText(sprintf("%.3f",nav_freq2.getValue()));
			}
		});

		### Comm ###
		setlistener("instrumentation/comm[1]/frequencies/standby-mhz", func {
			me.text.comStby.setText(sprintf("%.3f",com_stby2.getValue()));
			for (var i=0;i<12;i+=1) {
				if (sprintf("%.3f",com2[com_mem2[i]]) == sprintf("%.3f",com_stby2.getValue())) {
					me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));							
					break;
				}	else {
					me.text.memCom.setText("TEMP-"~sprintf("%d",i+1));
					if (com2[com_mem2[i]] == 0) {
						break;
					}					
				}
			}
		});

		setlistener("instrumentation/rmu/unit[1]/mem-com", func {
			var i = getprop("instrumentation/rmu/unit[1]/mem-com");
			if (com2[com_mem2[0]] == 0) {
					me.text.comStby.setText(sprintf("%.3f",com_stby2.getValue()));
			}
			if (com2[com_mem2[i]] != 0) {
				me.text.comStby.setText(sprintf("%07.3f",com2[com_mem2[i]]));
				me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));
			}	else {
				setprop("instrumentation/rmu/unit[1]/mem-com",0);
				me.text.comStby.setText(sprintf("%07.3f",com2[com_mem2[0]]));
				me.text.memCom.setText("MEMORY-"~sprintf("%d",1));
			}
		});

		### Nav ###
		setlistener("instrumentation/nav[1]/frequencies/standby-mhz", func {
			me.text.navStby.setText(sprintf("%.3f",nav_stby2.getValue()));
			for (var i=0;i<12;i+=1) {
				if (sprintf("%.3f",nav2[nav_mem2[i]]) == sprintf("%.3f",nav_stby2.getValue())) {
					me.text.memNav.setText("MEMORY-"~sprintf("%d",i+1));							
					break;
				}	else {
					me.text.memNav.setText("TEMP-"~sprintf("%d",i+1));
					if (nav2[nav_mem2[i]] == 0) {
						break;
					}					
				}
			}
		});

		setlistener("instrumentation/rmu/unit[1]/mem-nav", func {
			var i = getprop("instrumentation/rmu/unit[1]/mem-nav");
			if (nav2[nav_mem2[0]] == 0) {
					me.text.navStby.setText(sprintf("%.3f",nav_stby2.getValue()));
			}
			if (nav2[nav_mem2[i]] != 0) {
				me.text.navStby.setText(sprintf("%07.3f",nav2[nav_mem2[i]]));
				me.text.memNav.setText("MEMORY-"~sprintf("%d",i+1));
			}	else {
				setprop("instrumentation/rmu/unit[1]/mem-nav",0);
				me.text.navStby.setText(sprintf("%07.3f",nav2[nav_mem2[0]]));
				me.text.memNav.setText("MEMORY-"~sprintf("%d",1));
			}
		});

	### Storage memories Com & Nav ###
		setlistener("instrumentation/rmu/unit[1]/sto", func {	
			if (getprop("instrumentation/rmu/unit[1]/sto")) {
				if (getprop("instrumentation/rmu/unit[1]/selected") == 0) {
					if (com2[com_mem2[0]] == 0) {
						com2[com_mem2[0]] = com_stby2.getValue();
						var name = data.getChild(com_mem[0]);
						name.setDoubleValue(sprintf("%07.3f",com2[com_mem2[0]]));
						io.write_properties(mem_path,data);
						me.text.memCom.setText("MEMORY-1");
					} else if (com2[com_mem2[0]] != com_stby2.getValue()) {
						for (var i=0;i<12;i+=1) {
							if (com2[com_mem2[i]] == 0) {
								com2[com_mem2[i]] = com_stby2.getValue();
								var name = data.getChild(com_mem[i]);
								name.setDoubleValue(com2[com_mem2[i]]);
								io.write_properties(mem_path,data);
								me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));
								break;
							}
						}
					}
				}
				if (getprop("instrumentation/rmu/unit[1]/selected") == 1) {
					if (nav2[nav_mem2[0]] == 0) {
						nav2[nav_mem2[0]] = nav_stby2.getValue();
						var name = data.getChild(nav_mem[0]);
						name.setDoubleValue(sprintf("%07.3f",nav2[nav_mem2[0]]));
						io.write_properties(mem_path,data);
						me.text.memNav.setText("MEMORY-1");
					} else if (nav2[nav_mem2[0]] != nav_stby2.getValue()) {
						for (var i=0;i<12;i+=1) {
							if (nav2[nav_mem2[i]] == 0) {
								nav2[nav_mem2[i]] = nav_stby2.getValue();
								var name = data.getChild(nav_mem[i]);
								name.setDoubleValue(nav2[nav_mem2[i]]);
								io.write_properties(mem_path,data);
								me.text.memNav.setText("MEMORY-"~sprintf("%d",i+1));
								break;
							}
						}
					}
				}

			}
		});

	### ADF ###
		setlistener("instrumentation/adf[1]/frequencies/selected-khz", func {	
			me.text.adfFreq.setText(sprintf("%d",adf_freq2.getValue()));
		});

	### Transponder ###
		setlistener("instrumentation/transponder/id-code", func {	
			me.text.trspCode.setText(sprintf("%04d",trsp_code2.getValue()));
		});

		setlistener("instrumentation/transponder/inputs/display-mode", func {	
			if (trsp_num2.getValue() == "2") {
				me.text.trspMode.setText("STANDBY");
			} else {
				me.text.trspMode.setText(trsp_mode2.getValue());
			}
		});

		setlistener("instrumentation/rmu/trsp-num", func {	
			if (trsp_num2.getValue() == "2") {
				me.text.trspMode.setText("STANDBY");
			} else {
				me.text.trspMode.setText(trsp_mode2.getValue());
			}			
		});

	}, # end of listen
};


###### Main #####
var setl = setlistener("/sim/signals/fdm-initialized", func () {	
	var rmu2 = RMU2_canvas.new();
	rmu2.listen();
removelistener(setl);
});

