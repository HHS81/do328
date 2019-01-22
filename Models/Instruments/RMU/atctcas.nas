var canvas_atctcas = {
	new: func(canvasGroup, instance)
	{
		var m = { parents: [canvas_atctcas], fltid_data:{} };
		m.group = canvasGroup;
		m.Instance = instance;
		m.Text = 0;
		m.Tmp1 = 0;
		m.Tmp2 = 0;

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
	GetTranslation: func(input = -1) {
		me.Tmp2 = 0; # character have different width (should be fixed)
		for(me.Tmp1=0; me.Tmp1 < input; me.Tmp1+=1) {
			if(me.fltid_data[me.Tmp1] < 65) {
				me.Tmp2 += 9; # 0-9
			}
			elsif(me.fltid_data[me.Tmp1] == 73) {
				me.Tmp2 += 8; # I
			}
			elsif(me.fltid_data[me.Tmp1] == 87) {
				me.Tmp2 += 13; # W
			}
			elsif(	me.fltid_data[me.Tmp1] == 77 or
					me.fltid_data[me.Tmp1] == 88 or
					me.fltid_data[me.Tmp1] == 89) {
				me.Tmp2 += 12; # M,X,Y
			}
			else {
				me.Tmp2 += 11;
			}
		}
		return me.Tmp2;
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
						me.fltid_index += 1;
					}
				}
			}
			else {
				if(me.fltid_index > 0) {
					me.fltid_index -= 1;
				}
			}
			me.fltid_ptr.setTranslation(me.GetTranslation(me.fltid_index), 0);
		}
		else {
			# inner wheel
			me.Tmp1 = me.fltid_data[me.fltid_index] or 32;
			me.Text = "";

			if(input > 0) {
				# right turn
				if(me.Tmp1 == 32) {
					# space -> 0
					me.Tmp1 = 48;
				}
				else if(me.Tmp1 == 57) {
					# 9 -> A
					me.Tmp1 = 65;
				}
				else if(me.Tmp1 == 90) {
					# Z -> back to 0 or space if last char
					if(me.fltid_index == me.fltid_size-1) {
						me.Tmp1 = 32;
						me.fltid_size = me.fltid_size-1;
					}
					else {
						me.Tmp1 = 48;
					}
				}
				else {
					# normal increase
					me.Tmp1 = me.Tmp1+1;
				}
			}
			else {
				# left turn
				if(me.Tmp1 == 32) {
					# space -> Z
					me.Tmp1 = 90;
				}
				else if(me.Tmp1 == 65) {
					# A -> 9
					me.Tmp1 = 57;
				}
				else if(me.Tmp1 == 48) {
					# 0 -> back to Z or space if last char
					if(me.fltid_index == me.fltid_size-1) {
						me.Tmp1 = 32;
						me.fltid_size = me.fltid_size-1;
					}
					else {
						me.Tmp1 = 90;
					}
				}
				else {
					# normal decrease
					me.Tmp1 = me.Tmp1-1;
				}
			}

			me.fltid_data[me.fltid_index] = me.Tmp1;

			# increase buffer if new position
			if(me.fltid_index == me.fltid_size) {
				if(me.fltid_data[me.fltid_size] != 32) {
					me.fltid_size = me.fltid_size+1;
					me.fltid_data[me.fltid_size+1] = 32;
				}
			}

			for(me.Tmp1=0; me.Tmp1 < me.fltid_size; me.Tmp1+=1) {
				me.Text=me.Text~chr(me.fltid_data[me.Tmp1]);
			}
			me.fltid_text.setText(me.Text);
			setprop("sim/multiplay/callsign", me.Text);
		}
	},
	show: func()
	{
		me.Text = string.uc(getprop("sim/multiplay/callsign"));
		me.fltid_text.setText(me.Text);
		me.fltid_size = size(me.Text);
		#me.fltid_index = me.fltid_size;
		for(me.Tmp1=0; me.Tmp1 < me.fltid_size; me.Tmp1+=1) {
			me.Tmp2 = me.Text[me.Tmp1];
			me.fltid_data[me.Tmp1] = me.Tmp2;
		}

		me.group.show();
	},
	hide: func()
	{
		me.group.hide();
	}
};
