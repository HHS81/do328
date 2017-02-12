var canvas_atctcas = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_atctcas], fltid_data:{} };
		m.group = canvasGroup;
		m.Instance = instance;

		var font_mapper = func(family, weight)
		{
			return "honeywellfont.ttf";
		};
		canvas.parsesvg(canvasGroup, "Aircraft/do328/Models/Instruments/RMU/atctcas.svg", {'font-mapper': font_mapper});

		var svg_keys = ["fltid_text","fltid_ptr"];
		foreach(var key; svg_keys) {
			m[key] = canvasGroup.getElementById(key);
		}

		m.fltid_text.setText("");
		m.fltid_size = 0;
		m.fltid_index = 0;
		return m;
	},
	BtClick: func(input = -1) {
		if(input == 10) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.frequencies);
		}
		if(input == 17) {
			setprop("instrumentation/rmu["~me.Instance~"]/page", PageEnum.pagemenu);
		}
	},
	Knob: func(index = -1, input = -1) {
		if(index == 0) {
			# outer wheel
			if(input > 0) {
				if(me.fltid_index < me.fltid_size) {
					if(me.fltid_index < 7) {
						me.fltid_index = me.fltid_index+1;
					}
				}
			}
			else {
				if(me.fltid_index > 0) {
					me.fltid_index = me.fltid_index-1;
				}
			}
			me.fltid_ptr.setTranslation(me.fltid_index*9, 0);
		}
		else {
			# inner wheel
			var character = me.fltid_data[me.fltid_index] or 32;
			var output = "";

			if(input > 0) {
				# right turn
				if(character == 32) {
					# space -> 0
					character = 48;
				}
				else if(character == 57) {
					# 9 -> A
					character = 65;
				}
				else if(character == 90) {
					# Z -> back to 0 or space if last char
					if(me.fltid_index == me.fltid_size-1) {
						character = 32;
						me.fltid_size = me.fltid_size-1;
					}
					else {
						character = 48;
					}
				}
				else {
					# normal increase
					character = character+1;
				}
			}
			else {
				# left turn
				if(character == 32) {
					# space -> Z
					character = 90;
				}
				else if(character == 65) {
					# A -> 9
					character = 57;
				}
				else if(character == 48) {
					# 0 -> back to Z or space if last char
					if(me.fltid_index == me.fltid_size-1) {
						character = 32;
						me.fltid_size = me.fltid_size-1;
					}
					else {
						character = 90;
					}
				}
				else {
					# normal decrease
					character = character-1;
				}
			}

			me.fltid_data[me.fltid_index] = character;

			# increase buffer if new position
			if(me.fltid_index == me.fltid_size) {
				if(me.fltid_data[me.fltid_size] != 32) {
					me.fltid_size = me.fltid_size+1;
					me.fltid_data[me.fltid_size+1] = 32;
				}
			}

			for(var i=0; i<me.fltid_size; i=i+1) {
				output=output~chr(me.fltid_data[i]);
			}

			me.fltid_text.setText(output);
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
