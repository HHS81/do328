##########################################################################################################
# EFIS Framework
# Daniel Overbeck - 2018
##########################################################################################################

var NUM_SOFTKEYS = 7;

# base class
var SkItem = {
	new: func(id, device, title, decoration=0) {
		var m = {parents: [SkItem]};
		m.Id = id;
		m.Device = device;
		m.Title = title;
		m.Decoration = decoration;
		return m;
	},
	Activate: func {
	},
	GetId: func {
		return me.Id;
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

# item with dynamic content
var SkMutableItem = {
	new: func(id, device, path, format="%s", decoration=0) {
		var m = {parents: [SkMutableItem, SkItem.new(id, device, "", decoration)]};
		m.Node = props.globals.getNode(path, 1);
		m.Format = format;
		return m;
	},
	GetTitle: func {
		return sprintf(me.Format, me.Node.getValue());
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
			me.Active = 0;
		}
		else {
			me.Active = 1;
		}
		me.Node.setValue(me.Active);
		me.Device.UpdateMenu();
	},
	GetDecoration: func {
		return me.Active;
	}
};

# advanced switch item with manual frame coordinates
var SkAdvSwitchItem = {
	new: func(id, device, title, path, coordinates1, coordinates2) {
		var m = {parents: [SkAdvSwitchItem, SkItem.new(id, device, title)]};
		m.Coordinates1 = coordinates1;
		m.Coordinates2 = coordinates2;
		m.Node = props.globals.initNode(path, 0, "BOOL");
		m.Active = 0;
		return m;
	},
	Activate: func {
		if(me.Active) {
			me.Active = 0;
		}
		else {
			me.Active = 1;
		}
		me.Node.setValue(me.Active);
		me.Device.UpdateMenu();
	},
	GetDecoration: func {
		return -1;
	},
	GetFrameCoordinates: func {
		if(me.Active) {
			return me.Coordinates1;
		}
		return me.Coordinates2;
	}
};

# item which is active for a limited time
var SkTimerItem = {
	new: func(id, device, title, path, timeout) {
		var m = {parents: [SkTimerItem, SkItem.new(id, device, title)]};
		m.Node = props.globals.initNode(path, 0, "BOOL");
		m.Active = 0;
		m.Timeout = timeout;
		return m;
	},
	Activate: func {
		me.Node.setValue(1);
		me.Decoration = 1;
		me.Device.UpdateMenu();
		me.Device.SetLock(1);

		# use listener to remove frame if button released
		settimer(func () {
			me.Node.setValue(0);
			me.Decoration = 0;
			me.Device.UpdateMenu();
			me.Device.SetLock(0);
		}, me.Timeout);
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
	},
	AddItem: func(item) {
		var index = item.GetId();
		if(index >= 0 and index < NUM_SOFTKEYS) {
			me.Items[index] = item;
		}
	}
};

var Device = {
	new: func(instance) {
		var m = { parents: [Device],
			SkInstance: {},
			Pages: [],
			Menus: [],
			Softkeys: [],
			SoftkeyFrames: [],
			ActiveMenu: 0, # to know where button clicks must go
			SkFrameMenu: 0,
			InstanceId: instance,
			KnobMode: 1, # knob can have different functionalities
			Lock: 0, # ignore button click
			Tmp: 0,
			};

		for(m.i=0; m.i < NUM_SOFTKEYS; m.i+=1) {
			append(m.Softkeys, "");
			append(m.SoftkeyFrames, 0);
		}

		return m;
	},
	ActivateMenu: func(id) {
		me.ActiveMenu = id;
		me.Softkeys[0] = me.Menus[id].GetTitle();
		me.UpdateMenu();
	},
	ActivatePage: func(page, softkey) {
		me.Menus[me.SkFrameMenu].ResetDecoration();
		me.SkFrameMenu = me.ActiveMenu;
		me.Menus[me.SkFrameMenu].SetDecoration(softkey);

		me.UpdateMenu();

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
		if(!me.Lock) {
			me.Menus[me.ActiveMenu].ActivateItem(input);
		}
	},
	GetKnobMode: func()
	{
		return me.KnobMode;
	},
	UpdateMenu: func() {
		me.SkInstance.resetFrames();

		# copy sk names to array
		for(me.i = 1; me.i < NUM_SOFTKEYS; me.i+=1) {
			me.Tmp = me.Menus[me.ActiveMenu].GetItem(me.i);
			if(me.Tmp != nil) {
				me.Softkeys[me.i] = me.Tmp.GetTitle();
				if(me.i < 6) {
					if(me.Tmp.GetDecoration() >= 0) {
						me.SoftkeyFrames[me.i-1] = me.Tmp.GetDecoration();
					}
					else {
						me.SoftkeyFrames[me.i-1] = 0;
						me.SkInstance.drawRect(me.Tmp.GetFrameCoordinates());
					}
				}
			}
			else {
				me.Softkeys[me.i] = "";
				if(me.i < NUM_SOFTKEYS-1) {
					me.SoftkeyFrames[me.i-1] = 0;
				}
			}
		}
		me.SkInstance.setSoftkeys(me.Softkeys, me.SoftkeyFrames);
	},
	SetLock: func(lock)
	{
		me.Lock = lock;
	}
};
