var Radio = gui.Dialog.new("/sim/gui/dialogs/radios/dialog",
        "Aircraft/do328/Systems/tranceivers.xml");
var ap_settings = gui.Dialog.new("/sim/gui/dialogs/autopilot/dialog",
        "Aircraft/do328/Systems/autopilot-dlg.xml");
#var options = gui.Dialog.new("/sim/gui/dialogs/options/dialog",
#        "Aircraft/do328/Systems/options.xml");
var tiller_steering = gui.Dialog.new("/sim/gui/dialogs/tiller_steering/dialog",
		"Aircraft/do328/Systems/tiller_steering.xml");

gui.menuBind("radio", "dialogs.Radio.open()");
gui.menuBind("autopilot-settings", "dialogs.ap_settings.open()");
