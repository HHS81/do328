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
	new: func(id, device, path) {
		var m = {parents: [SkMutableItem]};
		m.Path = path;
		return m;
	},
	Activate: func {
	},
	GetDecoration: func {
		return 1;
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
