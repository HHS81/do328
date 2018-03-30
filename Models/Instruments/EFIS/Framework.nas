var NUM_SOFTKEYS = 7;

# base class
var SkItem = {
	new: func(id, device, title) {
		var m = {parents: [SkItem]};
		m.Id = id;
		m.Device = device;
		m.Title = title;
		m.Decoration = 0;
		return m;
	},
	Activate: func {
	},
	GetDecoration: func {
		return me.Decoration;
	},
	GetTitle: func {
		return me.Title;
	},
	SetDecoration: func(decoration) {
		me.Decoration = decoration;
	}
};

# item which changes menu
var SkMenuActivateItem = {
	new: func(id, device, title, menu) {
		var m = {parents: [SkMenuActivateItem, SkItem.new(id, device, title)]};
		m.Menu = menu;
		return m;
	},
	Activate: func {
		me.Device.ActivateMenu(me.Menu);
	}
};

# item which changes menu and page
var SkMenuPageActivateItem = {
	new: func(id, device, title, menu, page) {
		var m = {parents: [SkMenuPageActivateItem, SkItem.new(id, device, title)]};
		m.Menu = menu;
		m.Page = page;
		return m;
	},
	Activate: func {
		me.Device.ActivateMenu(me.Menu); # run first to reset active menu
		me.Device.ActivatePage(me.Page, me.Id);
	}
};

# item with dynamic content, decoration always visible
var SkMutableItem = {
	new: func(id, device, path) {
		var m = {parents: [SkMutableItem, SkItem.new(id, device, "")]};
		m.Path = path;
		return m;
	},
	Activate: func {
	},
	GetDecoration: func {
		return 1;
	},
	GetTitle: func {
		return me.Path;
	}
};

# item which changes page
var SkPageActivateItem = {
	new: func(id, device, title, page) {
		var m = {parents: [SkPageActivateItem, SkItem.new(id, device, title)]};
		m.Page = page;
		return m;
	},
	Activate: func {
		me.Device.ActivatePage(me.Page, me.Id);
	}
};

# item which acts like a switch
var SkSwitchItem = {
	new: func(id, device, title, path) {
		var m = {parents: [SkSwitchItem, SkItem.new(id, device, title)]};
		m.Node = props.globals.initNode(path, 0, "BOOL");
		m.Active = 0;
		return m;
	},
	Activate: func {
		if(me.Active) {
			me.Node.setValue(0);
			me.Active = 0;
		}
		else {
			me.Node.setValue(1);
			me.Active = 1;
		}
		me.Device.UpdateMenu();
	},
	GetDecoration: func {
		return me.Active;
	}
};

var SkMenu = {
	new: func(id, device, title) {
		var m = { parents: [SkMenu],
			Items: []};
		setsize(m.Items, NUM_SOFTKEYS);
		m.Id = id;
		m.Device = device;
		m.Title = title;
		m.Tmp = 0;
		return m;
	},
	SetItem: func(index, item) {
		if(index >= 0 and index < NUM_SOFTKEYS) {
			me.Items[index] = item;
		}
	},
	ActivateItem: func(index) {
		if(me.Items[index] != nil) {
			me.Items[index].Activate();
		}
	},
	GetItem: func(index) {
		return me.Items[index];
	},
	GetTitle: func {
		return me.Title;
	},
	ResetDecoration: func {
		for(me.Tmp = 0; me.Tmp < NUM_SOFTKEYS; me.Tmp+=1) {
			if(me.Items[me.Tmp] != nil) {
				me.Items[me.Tmp].SetDecoration(0);
			}
		}
	},
	SetDecoration: func(index) {
		for(me.Tmp = 0; me.Tmp < NUM_SOFTKEYS; me.Tmp+=1) {
			if(me.Items[me.Tmp] != nil) {
				if(me.Tmp == index) {
					me.Items[me.Tmp].SetDecoration(1);
				}
				else {
					me.Items[me.Tmp].SetDecoration(0);
				}
			}
		}
	}
};

var Device = {
	new: func(instance) {
		var m = { parents: [Device],
			Pages: {},
			SkInstance: {},
			InstanceId: instance,
			Menus: [],
			Softkeys: [],
			SoftkeyFrames: [],
			activeMenu: 0, # to know where button clicks must go
			skFrameMenu: 0,
			KnobMode: 1, # knob can have different functionalities
			Cnt: 0,
			Tmp: 0,
			};

		for(m.Cnt=0; m.Cnt < NUM_SOFTKEYS; m.Cnt+=1) {
			append(m.Softkeys, "");
			append(m.SoftkeyFrames, 0);
		}

		return m;
	},
	ActivateMenu: func(id) {
		me.activeMenu = id;
		me.Softkeys[0] = me.Menus[id].GetTitle();
		me.UpdateMenu();
	},
	ActivatePage: func(page, softkey) {
		me.Menus[me.skFrameMenu].ResetDecoration();
		me.skFrameMenu = me.activeMenu;
		me.Menus[me.skFrameMenu].SetDecoration(softkey);

		# update decorations
		for(me.Cnt = 1; me.Cnt < 6; me.Cnt+=1) {
			me.Tmp = me.Menus[me.skFrameMenu].GetItem(me.Cnt);
			if(me.Tmp != nil) {
				me.SoftkeyFrames[me.Cnt-1] = me.Tmp.GetDecoration();
			}
		}

		me.SkInstance.setSoftkeys(me.Softkeys);
		me.SkInstance.drawFrames(me.SoftkeyFrames);
		for(me.i=0; me.i < size(me.Pages); me.i+=1) {
			if(me.i == page) {
				me.Pages[me.i].show();
			}
			else {
				me.Pages[me.i].hide();
			}
		}
	},
	# input: 0=back, 1=sk1...5=sk5
	BtClick: func(input = -1) {
		me.Menus[me.activeMenu].ActivateItem(input);
	},
	GetKnobMode: func()
	{
		return me.KnobMode;
	},
	UpdateMenu: func() {
		# copy sk names to array
		for(me.Cnt = 1; me.Cnt < 7; me.Cnt+=1) {
			me.Tmp = me.Menus[me.activeMenu].GetItem(me.Cnt);
			if(me.Tmp != nil) {
				me.Softkeys[me.Cnt] = me.Tmp.GetTitle();
				if(me.Cnt < 6) {
					me.SoftkeyFrames[me.Cnt-1] = me.Tmp.GetDecoration();
				}
			}
			else {
				me.Softkeys[me.Cnt] = "";
			}
		}

		me.SkInstance.setSoftkeys(me.Softkeys);
		me.SkInstance.drawFrames(me.SoftkeyFrames);
	}
};
