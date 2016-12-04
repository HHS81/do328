### Canvas MFD ###
### C. Le Moigne (clm76) - 2016 ###

var com_num1 = props.globals.getNode("instrumentation/rmu/unit/com-num");
var nav_num1 = props.globals.getNode("instrumentation/rmu/unit/nav-num");
var adf_num1 = props.globals.getNode("instrumentation/rmu/unit/adf-num");
var mls_num1 = props.globals.getNode("instrumentation/rmu/unit/mls-num");
var com_freq1 = props.globals.getNode("instrumentation/comm/frequencies/selected-mhz");
var com_stby1 = props.globals.getNode("instrumentation/comm/frequencies/standby-mhz");
var com_mem1 = props.globals.getNode("instrumentation/rmu/unit/mem-com");
var nav_freq1 = props.globals.getNode("instrumentation/nav/frequencies/selected-mhz");
var nav_stby1 = props.globals.getNode("instrumentation/nav/frequencies/standby-mhz");
var nav_mem1 = props.globals.getNode("instrumentation/rmu/unit/mem-nav");
var trsp_code1 = props.globals.getNode("instrumentation/transponder/id-code");
var trsp_mode1 = props.globals.getNode("instrumentation/transponder/inputs/display-mode");
var trsp_num1 = props.globals.getNode("instrumentation/rmu/trsp-num");
var adf_freq1 = props.globals.getNode("instrumentation/adf/frequencies/selected-khz");

	### Create Memories if not exist ###
var mem_path = getprop("/sim/fg-home")~"/aircraft-data/";
var name = mem_path~"do328-RMUmem1.xml";
var xfile = subvec(directory(mem_path),2);
var v = std.Vector.new(xfile);
if (!v.contains("do328-RMUmem1.xml")) {
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
var com1 = {};
var com_mem1 = ["comMem1","comMem2","comMem3","comMem4",
							"comMem5","comMem6","comMem7","comMem8",
							"comMem9","comMem10","comMem11","comMem12"];
var mem_path = getprop("/sim/fg-home")~"/aircraft-data/do328-RMUmem1.xml";
var data = io.read_properties(mem_path);
foreach(var i;com_mem1) {
	com1[i] = data.getValue(i);
}

	### Load nav memories ###
var nav1 = {};
var nav_mem1 = ["navMem1","navMem2","navMem3","navMem4",
							"navMem5","navMem6","navMem7","navMem8",
							"navMem9","navMem10","navMem11","navMem12"];
var mem_path = getprop("/sim/fg-home")~"/aircraft-data/do328-RMUmem1.xml";
var data = io.read_properties(mem_path);
foreach(var i;nav_mem1) {
	nav1[i] = data.getValue(i);
}


	### RMU ###
var RMU1_canvas = {
	new: func() {
		var obj = {parents:[RMU1_canvas]};
		obj.canvas = canvas.new({
			"name": "RMU1", 
			"size": [1024, 1024],
			"view": [800, 1024],
			"mipmapping": 1 
		});
		obj.canvas.addPlacement({"node": "RMU.screenL"});
		obj.mfd1 = obj.canvas.createGroup();
		canvas.parsesvg(obj.mfd1, "Aircraft/do328/Models/Instruments/RMU/RMU.svg");

		obj.text = {};
		obj.text_val = ["comFreq","navFreq","comStby", "navStby",
										"trspCode","trspMode","trspNum","adfFreq",
										"memCom","memNav","comNum","navNum","adfNum","mlsNum"];
		foreach(var i;obj.text_val) {
			obj.text[i] = obj.mfd1.getElementById(i);
		}

		obj.rect = {};
		obj.cdr = ["comStbyRect","navStbyRect","trspCodeRect",
							"adfRect","trspModeRect"];
		foreach(var i;obj.cdr) {
			obj.rect[i] = obj.mfd1.getElementById(i);
		}
		
		foreach(var i;keys (obj.rect))	obj.rect[i].hide();
		obj.rect.comStbyRect.show();

		obj.text.comFreq.setText(sprintf("%.3f",com_freq1.getValue()));
		obj.text.comNum.setText(sprintf("%d",com_num1.getValue()));
		obj.text.navFreq.setText(sprintf("%.3f",nav_freq1.getValue()));
		obj.text.navNum.setText(sprintf("%d",nav_num1.getValue()));
		obj.text.adfNum.setText(sprintf("%d",adf_num1.getValue()));
		obj.text.adfFreq.setText(sprintf("%d",adf_freq1.getValue()));
		obj.text.mlsNum.setText(sprintf("%d",mls_num1.getValue()));
		obj.text.trspNum.setText("1");
		obj.text.comStby.setText(sprintf("%07.3f",com1.comMem1));
		com_stby1.setValue(com1.comMem1);
		obj.text.memCom.setText("MEMORY-1");
		obj.text.navStby.setText(sprintf("%07.3f",nav1.navMem1));
		nav_stby1.setValue(nav1.navMem1);
		obj.text.memNav.setText("MEMORY-1");
		#obj.text.trspCode.setText(sprintf("%04d",trsp_code1.getValue()));
		#obj.text.trspMode.setText(trsp_mode1.getValue());

		return obj;
	},

	listen : func {
		setlistener("instrumentation/rmu/unit/selected",func {
			var select1 = getprop("instrumentation/rmu/unit/selected");
			var index = 0;
			foreach(var i;me.cdr) {
				if (getprop("instrumentation/rmu/unit/selected")== index) {
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
			me.text.trspNum.setText(trsp_num1.getValue());
		});	

		setlistener("instrumentation/rmu/unit/swp1", func {
			if (getprop("instrumentation/rmu/unit/swp1")) {
				me.text.comFreq.setText(sprintf("%.3f",com_freq1.getValue()));
			}
		});

		setlistener("instrumentation/rmu/unit/swp2", func {
			if (getprop("instrumentation/rmu/unit/swp2")) {
				me.text.navFreq.setText(sprintf("%.3f",nav_freq1.getValue()));
			}
		});

		### Comm ###
		setlistener("instrumentation/comm/frequencies/standby-mhz", func {
			me.text.comStby.setText(sprintf("%.3f",com_stby1.getValue()));
			for (var i=0;i<12;i+=1) {
				if (sprintf("%.3f",com1[com_mem1[i]]) == sprintf("%.3f",com_stby1.getValue())) {
					me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));							
					break;
				}	else {
					me.text.memCom.setText("TEMP-"~sprintf("%d",i+1));
					if (com1[com_mem1[i]] == 0) {
						break;
					}					
				}
			}
		});

		setlistener("instrumentation/rmu/unit/mem-com", func {
			var i = getprop("instrumentation/rmu/unit/mem-com");
			if (com1[com_mem1[0]] == 0) {
					me.text.comStby.setText(sprintf("%.3f",com_stby1.getValue()));
			}
			if (com1[com_mem1[i]] != 0) {
				me.text.comStby.setText(sprintf("%07.3f",com1[com_mem1[i]]));
				me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));
			}	else {
				setprop("instrumentation/rmu/unit/mem-com",0);
				me.text.comStby.setText(sprintf("%07.3f",com1[com_mem1[0]]));
				me.text.memCom.setText("MEMORY-"~sprintf("%d",1));
			}
		});

		### Nav ###
		setlistener("instrumentation/nav/frequencies/standby-mhz", func {
			me.text.navStby.setText(sprintf("%.3f",nav_stby1.getValue()));
			for (var i=0;i<12;i+=1) {
				if (sprintf("%.3f",nav1[nav_mem1[i]]) == sprintf("%.3f",nav_stby1.getValue())) {
					me.text.memNav.setText("MEMORY-"~sprintf("%d",i+1));							
					break;
				}	else {
					me.text.memNav.setText("TEMP-"~sprintf("%d",i+1));
					if (nav1[nav_mem1[i]] == 0) {
						break;
					}					
				}
			}
		});

		setlistener("instrumentation/rmu/unit/mem-nav", func {
			var i = getprop("instrumentation/rmu/unit/mem-nav");
			if (nav1[nav_mem1[0]] == 0) {
					me.text.navStby.setText(sprintf("%.3f",nav_stby1.getValue()));
			}
			if (nav1[nav_mem1[i]] != 0) {
				me.text.navStby.setText(sprintf("%07.3f",nav1[nav_mem1[i]]));
				me.text.memNav.setText("MEMORY-"~sprintf("%d",i+1));
			}	else {
				setprop("instrumentation/rmu/unit/mem-nav",0);
				me.text.navStby.setText(sprintf("%07.3f",nav1[nav_mem1[0]]));
				me.text.memNav.setText("MEMORY-"~sprintf("%d",1));
			}
		});

	### Storage memories Com & Nav ###
		setlistener("instrumentation/rmu/unit/sto", func {	
			if (getprop("instrumentation/rmu/unit/sto")) {
				if (getprop("instrumentation/rmu/unit/selected") == 0) {
					if (com1[com_mem1[0]] == 0) {
						com1[com_mem1[0]] = com_stby1.getValue();
						var name = data.getChild(com_mem[0]);
						name.setDoubleValue(sprintf("%07.3f",com1[com_mem1[0]]));
						io.write_properties(mem_path,data);
						me.text.memCom.setText("MEMORY-1");
					} else if (com1[com_mem1[0]] != com_stby1.getValue()) {
						for (var i=0;i<12;i+=1) {
							if (com1[com_mem1[i]] == 0) {
								com1[com_mem1[i]] = com_stby1.getValue();
								var name = data.getChild(com_mem[i]);
								name.setDoubleValue(com1[com_mem1[i]]);
								io.write_properties(mem_path,data);
								me.text.memCom.setText("MEMORY-"~sprintf("%d",i+1));
								break;
							}
						}
					}
				}
				if (getprop("instrumentation/rmu/unit/selected") == 1) {
					if (nav1[nav_mem1[0]] == 0) {
						nav1[nav_mem1[0]] = nav_stby1.getValue();
						var name = data.getChild(nav_mem[0]);
						name.setDoubleValue(sprintf("%07.3f",nav1[nav_mem1[0]]));
						io.write_properties(mem_path,data);
						me.text.memNav.setText("MEMORY-1");
					} else if (nav1[nav_mem1[0]] != nav_stby1.getValue()) {
						for (var i=0;i<12;i+=1) {
							if (nav1[nav_mem1[i]] == 0) {
								nav1[nav_mem1[i]] = nav_stby1.getValue();
								var name = data.getChild(nav_mem[i]);
								name.setDoubleValue(nav1[nav_mem1[i]]);
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
		setlistener("instrumentation/adf/frequencies/selected-khz", func {	
			me.text.adfFreq.setText(sprintf("%d",adf_freq1.getValue()));
		});

	### Transponder ###
		setlistener("instrumentation/transponder/id-code", func {	
			me.text.trspCode.setText(sprintf("%04d",trsp_code1.getValue()));
		});

		setlistener("instrumentation/transponder/inputs/display-mode", func {	
			if (trsp_num1.getValue() == "2") {
				me.text.trspMode.setText("STANDBY");
			} else {
				me.text.trspMode.setText(trsp_mode1.getValue());
			}
		});

		setlistener("instrumentation/rmu/trsp-num", func {	
			if (trsp_num1.getValue() == "2") {
				me.text.trspMode.setText("STANDBY");
			} else {
				me.text.trspMode.setText(trsp_mode1.getValue());
			}			
		});

	}, # end of listen
};


###### Main #####
var setl = setlistener("/sim/signals/fdm-initialized", func () {	
#	create_mem1();
	var rmu1 = RMU1_canvas.new();
	rmu1.listen();
removelistener(setl);
});

