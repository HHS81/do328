# ==============================================================================
# Boeing 747-400 pfd by Gijs de Rooy
# ==============================================================================

var roundToNearest = func(n, m) {
	var x = int(n/m)*m;
	if((math.mod(n,m)) > (m/2))
			x = x + m;
	return x;
}

var pfd1_canvas = nil;
var pfd1_display = nil;

var canvas_PFD = {
	new: func(canvas_group)
	{
		var m = { parents: [canvas_PFD] };
		m["frameCounter"] = 0;
		var pfd = canvas_group;
		var font_mapper = func(family, weight)
		{
			if( family == "'Liberation Sans'" and weight == "normal" )
				return "honeywellfont.ttf";
		};
		
		canvas.parsesvg(pfd, "Aircraft/do328/Models/Instruments/PFD/pfd.svg", {'font-mapper': font_mapper});
		
		var svg_keys = ["altTape","altText","altMeters","atMode","bankPointer","baroSet","compass","curAlt1","curAlt2","curAlt3","curAltBox","curSpd","curSpdTen","fdX","fdY","gpwsAlert","gsPtr","gsScale","horizon","locPtr","locScale","machText","markerBeacon","markerBeaconText","maxSpdInd","minSpdInd","pitchMode","rollMode","selHdgText","spdTape","spdTrend","speedText","tenThousand","v1","v2","vertSpd","vr","vref","vsiNeedle"];
		foreach(var key; svg_keys) {
			m[key] = pfd.getElementById(key);
		}
		debug.dump(m["horizon"].getCenter());
		m.h_trans = m["horizon"].createTransform();
		m.h_rot = m["horizon"].createTransform();
		
		var c1 = m["spdTrend"].getCenter();
		m["spdTrend"].createTransform().setTranslation(-c1[0], -c1[1]);
		m["spdTrend_scale"] = m["spdTrend"].createTransform();
		m["spdTrend"].createTransform().setTranslation(c1[0], c1[1]);
		
		m["horizon"].set("clip", "rect(115, 550, 490, 210)");# top,right,bottom,left
		m["minSpdInd"].set("clip", "rect(156, 1024, 829, 0)");
		m["maxSpdInd"].set("clip", "rect(156, 1024, 829, 0)");
		m["spdTape"].set("clip", "rect(110, 800, 510, 0)");
		m["altTape"].set("clip", "rect(110, 800, 510, 0)");
		m["vsiNeedle"].set("clip", "rect(633, 791, 917, 678)");
		m["compass"].set("clip", "rect(0, 800, 900, 0)");
		m["curAlt3"].set("clip", "rect(270, 800, 330, 0)");
		m["curSpdTen"].set("clip", "rect(263, 800, 355, 0)");
		
		setlistener("autopilot/locks/passive-mode",            func { m.update_ap_modes() } );
		setlistener("autopilot/locks/altitude",                func { m.update_ap_modes() } );
		setlistener("autopilot/locks/heading",                 func { m.update_ap_modes() } );
		setlistener("autopilot/locks/speed",                   func { m.update_ap_modes() } );
		m.update_ap_modes();

		return m;
	},
	update: func()
	{
		var radioAlt = getprop("instrumentation/radar-altimeter/radar-altitude-ft") or 0;
		var alt = getprop("instrumentation/altimeter/indicated-altitude-ft");
		if (alt < 0)
			alt = 0;
		var ias = getprop("velocities/airspeed-kt");
		if (ias < 30)
			ias = 30;
		var pitch = getprop("orientation/pitch-deg");
		var roll =  getprop("orientation/roll-deg");
		var hdg =  getprop("orientation/heading-deg");
		var vSpd = getprop("/velocities/vertical-speed-fps");
		var wow = getprop("gear/gear/wow");
		var apAlt = getprop("autopilot/settings/target-altitude-ft");
		var apSpd = getprop("autopilot/settings/target-speed-kt");
		
		#10 deg = 105px
		me.h_trans.setTranslation(0,pitch*10.5);
		me.h_rot.setRotation(-roll*D2R,me["horizon"].getCenter());
		
		me["bankPointer"].setRotation(-roll*D2R);
		me["compass"].setRotation(-hdg*D2R);
			
		# Flight director
		if (getprop("autopilot/locks/passive-mode") == 1) {
			if (getprop("autopilot/internal/target-roll-deg") != nil) {
				var fdRoll = (roll-getprop("/autopilot/internal/target-roll-deg"))*10.5;
				if (fdRoll > 200)
					fdRoll = 200;
				elsif (fdRoll < -200)
					fdRoll = -200;
				me["fdX"].setTranslation(-fdRoll,0);
			}
			me["fdX"].show();
			#fdY.show();
		} else {
			me["fdX"].hide();
			me["fdY"].hide();
		}
		
		me["machText"].setText(sprintf("%.2f",getprop("velocities/mach")));
		me["altText"].setText(sprintf("%2.0f",apAlt));
		
		me["altMeters"].setText(sprintf("%5.0f",math.floor(alt/3.048)));
		me["curAlt1"].setText(sprintf("%2.0f",math.floor(alt/1000)));
		me["curAlt2"].setText(sprintf("%1.0f",math.mod(math.floor(alt/100),10)));
		me["curAlt3"].setTranslation(0,(math.mod(alt,100)/20)*26);
		me["curSpd"].setText(sprintf("%2.0f",math.floor(ias/10)));
		me["curSpdTen"].setTranslation(0,math.mod(ias,10)*32);
		
		if (getprop("instrumentation/marker-beacon/outer")) {
			me["markerBeacon"].show();
			me["markerBeaconText"].setText("O");
		} elsif (getprop("instrumentation/marker-beacon/middle")) {
			me["markerBeacon"].show();
			me["markerBeaconText"].setText("M");
		} elsif (getprop("instrumentation/marker-beacon/inner")) {
			me["markerBeacon"].show();
			me["markerBeaconText"].setText("I");
		} else {
			me["markerBeacon"].hide();
		}
		
		if(getprop("instrumentation/nav/signal-quality-norm") or 0 > 0.95) {
			var deflection = getprop("instrumentation/nav/heading-needle-deflection-norm"); # 1 dot = 1 degree, full needle deflection is 10 deg
			if (deflection > 0.3)
				deflection = 0.3;
			if (deflection < -0.3)
				deflection = -0.3;
				
			me["locPtr"].show();
			
			if(abs(deflection) < 0.233) # 2 1/3 dot
				me["locPtr"].setColorFill(0,1,0,1);
			else
				me["locPtr"].setColorFill(0,1,0,0);
			if(abs(deflection) < 0.1) {
				me["locPtr"].setTranslation(deflection*500,0);
				me["locScale"].hide();
			} else {
				me["locPtr"].setTranslation(deflection*250,0);
				me["locScale"].show();
			}
		} else {
			me["locPtr"].hide();
			me["locScale"].hide();
		}
		
		if(getprop("instrumentation/nav/gs-in-range")) {
			me["gsPtr"].show();
			me["gsScale"].show();
			me["gsPtr"].setTranslation(0,-getprop("instrumentation/nav/gs-needle-deflection-norm")*140);
		} else {
			me["gsPtr"].hide();
			me["gsScale"].hide();
		}
		
		if (alt < 10000)
			me["tenThousand"].show();
		else 
			me["tenThousand"].hide();
		if (vSpd != nil) {
			var vertSpd = vSpd*60;
			me["vertSpd"].setText(sprintf("%4.0f",roundToNearest(vertSpd,50)));
			if (getprop("instrumentation/pfd/target-vs") != nil)
				me["vsPointer"].setTranslation(0,-getprop("instrumentation/pfd/target-vs"));
		}
		
		me["spdTape"].setTranslation(0,ias*5.93);
		me["altTape"].setTranslation(0,alt*0.45);
		
		if(var vsiDeg = getprop("instrumentation/pfd/vsi-needle-deg") != nil)
			me["vsiNeedle"].setRotation(vsiDeg*D2R);
		
		me.frameCounter = me.frameCounter + 1;
		if(me.frameCounter > 3) {
			me.frameCounter = 0;
			me.update_slow();
		}
		settimer(func me.update(), 0.15);
	},
	update_ap_modes: func()
	{
		# Modes
		var apSpd = getprop("/autopilot/locks/speed");
		if (apSpd == "speed-with-throttle")
			me["atMode"].setText("SPD");
		elsif (apSpd ==  "speed-with-pitch-trim")
			me["atMode"].setText("THR");
		else
			me["atMode"].setText("");
		var apRoll = getprop("/autopilot/locks/heading");
		if (apRoll == "wing-leveler")
			me["rollMode"].setText("HDG HOLD");
		elsif (apRoll ==  "dg-heading-hold")
			me["rollMode"].setText("HDG SEL");
		elsif (apRoll ==  "nav1-hold")
			me["rollMode"].setText("LNAV");
		else
			me["rollMode"].setText("");
		var apPitch = getprop("/autopilot/locks/altitude");
		if (apPitch == "vertical-speed-hold") {
			me["pitchMode"].setText("V/S");
		} elsif (apPitch ==  "altitude-hold")
			me["pitchMode"].setText("ALT");
		elsif (apPitch ==  "gs1-hold")
			me["pitchMode"].setText("G/S");
		elsif (apPitch ==  "speed-with-pitch-trim")
			me["pitchMode"].setText("FLCH SPD");
		else
			me["pitchMode"].setText("");
	},
	update_slow: func()
	{
		var wow = getprop("gear/gear/wow");
		var flaps = getprop("/controls/flight/flaps");
		var alt = getprop("instrumentation/altimeter/indicated-altitude-ft");
		var apSpd = getprop("autopilot/settings/target-speed-kt");
		var dh = getprop("instrumentation/mk-viii/inputs/arinc429/decision-height");
		
		var v1 = getprop("instrumentation/fmc/speeds/v1-kt") or 0;
		if (v1 > 0) {
			if (wow) {
				me["v1"].show();
				me["v1"].setTranslation(0,-getprop("instrumentation/fmc/speeds/v1-kt")*5.63915);
				me["vr"].show();
				me["vr"].setTranslation(0,-getprop("instrumentation/fmc/speeds/vr-kt")*5.63915);
			} else {
				me["v1"].hide();
				me["vr"].hide();
			}
			me["v2"].setTranslation(0,-getprop("instrumentation/fmc/speeds/v2-kt")*5.63915);
		} else {
			me["v1"].hide();
			me["vr"].hide();
		}

		
		if (getprop("instrumentation/fmc/phase-name") == "APPROACH") {
			if (flaps == 1)
				var vref = getprop("instrumentation/pfd/flaps-30-kt");
			else
				var vref = getprop("instrumentation/pfd/flaps-25-kt");
			me["vref"].show();
			me["vref"].setTranslation(0,-vref*5.63915);
		} else
			me["vref"].hide();
		
		if (getprop("instrumentation/weu/state/stall-speed") != nil)
			me["minSpdInd"].setTranslation(0,-getprop("instrumentation/weu/state/stall-speed")*5.63915);
		if (getprop("instrumentation/pfd/overspeed-kt") != nil)
			me["maxSpdInd"].setTranslation(0,-getprop("instrumentation/pfd/overspeed-kt")*5.63915);
		
		if(wow) {
			me["minSpdInd"].hide();
			me["maxSpdInd"].hide();
		} else {
			me["minSpdInd"].show();
			me["maxSpdInd"].show();
		}
		me["baroSet"].setText(sprintf("%4.0f",getprop("instrumentation/altimeter/setting-hpa")));
		me["selHdgText"].setText(sprintf("%3.0f",getprop("autopilot/settings/true-heading-deg")));
		me["speedText"].setText(sprintf("%3.0f",apSpd));
	},
};

setlistener("sim/signals/fdm-initialized", func() {
	var group = {};

	pfd1_display = canvas.new({
		"name": "PFD1",
		"size": [1024, 1024],
		"view": [800, 950],
		"mipmapping": 1
	});
	pfd1_display.addPlacement({"node": "PFD1_Screen"});
	group = pfd1_display.createGroup();
	pfd1_canvas = canvas_PFD.new(group);
	pfd1_canvas.update();

	pfd2_display = canvas.new({
		"name": "PFD2",
		"size": [1024, 1024],
		"view": [800, 950],
		"mipmapping": 1
	});
	pfd2_display.addPlacement({"node": "PFD2_Screen"});
	group = pfd2_display.createGroup();
	pfd2_canvas = canvas_PFD.new(group);
	pfd2_canvas.update();
});

setlistener("sim/signals/reinit", func pfd1_display.del());
setlistener("sim/signals/reinit", func pfd2_display.del());
