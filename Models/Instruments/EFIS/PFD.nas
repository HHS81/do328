# ==============================================================================
# Boeing 747-400 pfd by Gijs de Rooy
# ==============================================================================

var roundToNearest = func(n, m) {
	var x = int(n/m)*m;
	if((math.mod(n,m)) > (m/2))
			x = x + m;
	return x;
}

var canvas_PFD = {
	new: func(canvas_group, instance)
	{
		var m = { parents: [canvas_PFD] };
		m["frameCounter"] = 0;
		var pfd = canvas_group;
		var font_mapper = func(family, weight)
		{
			if( family == "'Liberation Sans'" and weight == "normal" )
				return "honeywellfont.ttf";
		};
		
		canvas.parsesvg(pfd, "Aircraft/do328/Models/Instruments/EFIS/pfd.svg", {'font-mapper': font_mapper});
		
		var svg_keys = ["altTape","altText","altMeters","bankPointer","baroSet","circIndicator","circNeedle",
				"circSource","compass","curAlt1","curAlt2","curAlt3","curAltBox","curSpd","curSpdTen",
				"fdX","fdY","gpwsAlert","ground","gsPtr","gsScale","horizon","locPtr","locScale",
				"machText","markerBeacon","markerBeaconText","maxSpdInd","minSpdInd","pitchMode",
				"rhombIndicator","rhombNeedle","rhombSource","rollMode","selHdgText","spdTape",
				"spdTrend","speedText","tenThousand","v1","v2","vc","vcl","vertSpd","vr","vref",
				"vsiNeedle"];
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
		m["vsiNeedle"].set("clip", "rect(633, 750, 917, 648)");
		m["compass"].set("clip", "rect(0, 800, 900, 0)");
		m["curAlt3"].set("clip", "rect(270, 800, 330, 0)");
		m["curSpdTen"].set("clip", "rect(263, 800, 355, 0)");
		
		var center = m["ground"].getCenter();
		m["ground"].createTransform().setTranslation(-center[0], -center[1]);
		m["ground_scale"] = m["ground"].createTransform();
		m["ground"].createTransform().setTranslation(center[0], center[1]);
		m["ground_scale"].setScale(1,0);

		setlistener("autopilot/locks/passive-mode",            func { m.update_ap_modes() } );
		setlistener("autopilot/locks/altitude",                func { m.update_ap_modes() } );
		setlistener("autopilot/locks/heading",                 func { m.update_ap_modes() } );
		setlistener("autopilot/locks/speed",                   func { m.update_ap_modes() } );

		m.Instance = instance;
		m.update_ap_modes();
		m.update_slow();
		m.update();
		return m;
	},
	update: func()
	{
		var radioAlt = getprop("instrumentation/radar-altimeter/radar-altitude-ft") or 0;
		if(radioAlt > 460) {
			me.ground_scale.setScale(1,0);
		} else {
			me.ground_scale.setScale(1,1-(radioAlt/460));
		}

		var alt = getprop("instrumentation/altimeter/indicated-altitude-ft");
		if (alt < 0) {
			alt = 0;
		}

		var ias = getprop("velocities/airspeed-kt");
		if(ias < 30) {
			ias = 30;
		}

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
		if(getprop("autopilot/locks/passive-mode") == 1) {
			if (getprop("autopilot/internal/target-roll-deg") != nil) {
				var fdRoll = (roll-getprop("/autopilot/internal/target-roll-deg"))*10.5;
				if (fdRoll > 200)
					fdRoll = 200;
				elsif (fdRoll < -200)
					fdRoll = -200;
				me.fdX.setTranslation(-fdRoll,0);
			}
			me.fdX.show();
			me.fdY.show();
		} else {
			me.fdX.hide();
			me.fdY.hide();
		}
		
		me["machText"].setText(sprintf("%.2f",getprop("velocities/mach")));
		me["altText"].setText(sprintf("%2.0f",apAlt));
		
		me["altMeters"].setText(sprintf("%5.0f",math.floor(alt/3.048)));
		me["curAlt1"].setText(sprintf("%2.0f",math.floor(alt/1000)));
		me["curAlt2"].setText(sprintf("%1.0f",math.mod(math.floor(alt/100),10)));
		me["curAlt3"].setTranslation(0,(math.mod(alt,100)/20)*26);
		me["curSpd"].setText(sprintf("%2.0f",math.floor(ias/10)));
		me["curSpdTen"].setTranslation(0,math.mod(ias,10)*32.4);
		
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

		var quality = getprop("instrumentation/nav/signal-quality-norm") or 0;
		if(quality > 0.95) {
			var deflection = getprop("instrumentation/nav/heading-needle-deflection-norm"); # 1 dot = 1 degree, full needle deflection is 10 deg
			if (deflection > 0.3)
				deflection = 0.3;
			if (deflection < -0.3)
				deflection = -0.3;
				
			me["locPtr"].show();
			me["locScale"].show();
			
			if(abs(deflection) < 0.1) {
				me["locPtr"].setTranslation(deflection*500,0);
			} else {
				me["locPtr"].setTranslation(deflection*250,0);
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
			vSpd = vSpd * 60;
			var vsiDeg = vSpd*0.014;
			if(vSpd > 1000) {
				var vsiDeg = vSpd*0.00775+7.33;
			}
			if(vSpd < -1000) {
				var vsiDeg = vSpd*0.00775-7.33;
			}
			me["vertSpd"].setText(sprintf("%4.0f",roundToNearest(vSpd,50)));
			me["vsiNeedle"].setRotation(vsiDeg * D2R);
		}

		if (getprop("instrumentation/pfd/speed-trend-up") != nil)
			me["spdTrend_scale"].setScale(1, (getprop("instrumentation/pfd/speed-lookahead")-ias)/20);

		me["spdTape"].setTranslation(0,ias*5.93);
		me["altTape"].setTranslation(0,alt*0.45);

		me.frameCounter = me.frameCounter + 1;
		if(me.frameCounter > 3) {
			me.frameCounter = 0;
			me.update_slow();
		}
		settimer(func me.update(), 0.1);
	},
	update_ap_modes: func()
	{
		# Modes
		var apRoll = getprop("/autopilot/locks/heading");
		if (apRoll == "wing-leveler")
			me["rollMode"].setText("ROLL");
		elsif (apRoll ==  "dg-heading-hold")
			me["rollMode"].setText("HDG");
		elsif (apRoll ==  "nav1-hold")
			me["rollMode"].setText("NAV");
		else
			me["rollMode"].setText("ROLL");

		var apPitch = getprop("/autopilot/locks/altitude");
		if (apPitch == "vertical-speed-hold") {
			me["pitchMode"].setText("VS");
		} elsif (apPitch ==  "altitude-hold")
			me["pitchMode"].setText("ALT");
		elsif (apPitch ==  "gs1-hold")
			me["pitchMode"].setText("GS");
		elsif (apPitch ==  "speed-with-pitch-trim")
			me["pitchMode"].setText("FLC");
		else
			me["pitchMode"].setText("PTCH");
	},
	update_slow: func()
	{
		var wow = getprop("gear/gear/wow");
		var flaps = getprop("/controls/flight/flaps");
		var alt = getprop("instrumentation/altimeter/indicated-altitude-ft");
		var apSpd = getprop("autopilot/settings/target-speed-kt");
		var dh = getprop("instrumentation/mk-viii/inputs/arinc429/decision-height");
		var pfdCircle = getprop("instrumentation/efis/PFD"~(me.Instance+1)~"_Circle");
		var pfdRhombus = getprop("instrumentation/efis/PFD"~(me.Instance+1)~"_Rhombus");

		if(pfdCircle != nil) {
			if(pfdCircle == "") {
				me.circIndicator.hide();
				me.circNeedle.hide();
			}
			else {
				me.circSource.setText(pfdCircle);
				me.circIndicator.show();
				if(pfdCircle == "VOR1") {
					if(getprop("instrumentation/nav[0]/in-range")) {
						me.circNeedle.setRotation(getprop("instrumentation/nav[0]/radials/reciprocal-radial-deg")*D2R);
						me.circNeedle.show();
					}
					else {
						me.circNeedle.hide();
					}
				}
				else if(pfdCircle == "ADF1") {
					if(getprop("instrumentation/adf[0]/in-range")) {
						me.circNeedle.setRotation((getprop("instrumentation/adf[0]/indicated-bearing-deg")+
									getprop("orientation/heading-deg"))*D2R);
						me.circNeedle.show();
					}
					else {
						me.circNeedle.hide();
					}
				}
				else {
					me.circNeedle.hide();
				}
			}
		}
		else {
			me.circIndicator.hide();
			me.circNeedle.hide();
		}
		if(pfdRhombus != nil) {
			if(pfdRhombus == "") {
				me.rhombIndicator.hide();
				me.rhombNeedle.hide();
			}
			else {
				me.rhombSource.setText(pfdRhombus);
				me.rhombIndicator.show();
				if(pfdRhombus == "VOR2") {
					if(getprop("instrumentation/nav[1]/in-range")) {
						me.rhombNeedle.setRotation(getprop("instrumentation/nav[1]/radials/reciprocal-radial-deg")*D2R);
						me.rhombNeedle.show();
					}
					else {
						me.rhombNeedle.hide();
					}
				}
				else if(pfdRhombus == "ADF2") {
					if(getprop("instrumentation/adf[1]/in-range")) {
						me.rhombNeedle.setRotation((getprop("instrumentation/adf[1]/indicated-bearing-deg")+
										getprop("orientation/heading-deg"))*D2R);
						me.rhombNeedle.show();
					}
					else {
						me.rhombNeedle.hide();
					}
				}
				else {
					me.rhombNeedle.hide();
				}
			}
		}
		else {
			me.rhombIndicator.hide();
			me.rhombNeedle.hide();
		}

		if(getprop("instrumentation/fmc/phase-name") == "TO") {
			me["v1"].show();
			me["vr"].show();
			me["v2"].show();
			me["v1"].setTranslation(0,-getprop("instrumentation/fmc/vspeeds/V1")*5.93);
			me["vr"].setTranslation(0,-getprop("instrumentation/fmc/vspeeds/VR")*5.93);
			me["v2"].setTranslation(0,-getprop("instrumentation/fmc/vspeeds/V2")*5.93);
		} else {
			me["v1"].hide();
			me["vr"].hide();
			me["v2"].hide();
		}

		if(getprop("instrumentation/fmc/phase-name") == "CLIMB") {
			me["vcl"].show();
			me["vcl"].setTranslation(0,-200*5.93);
		} else {
			me["vcl"].hide();
		}

		if(getprop("instrumentation/fmc/phase-name") == "CRUISE") {
			me["vc"].show();
			me["vc"].setTranslation(0,-239*5.93);
		} else {
			me["vc"].hide();
		}

		if(getprop("instrumentation/fmc/phase-name") == "LANDG") {
			me["vref"].show();
			me["vref"].setTranslation(0,-getprop("instrumentation/fmc/vspeeds/Vref")*5.93);
		} else {
			me["vref"].hide();
		}

		if (getprop("instrumentation/weu/state/stall-speed") != nil)
			me["minSpdInd"].setTranslation(0,-getprop("instrumentation/weu/state/stall-speed")*5.93);
		if (getprop("instrumentation/pfd/overspeed-kt") != nil)
			me["maxSpdInd"].setTranslation(0,-getprop("instrumentation/pfd/overspeed-kt")*5.93);
		
		if(wow) {
			me["minSpdInd"].hide();
			me["maxSpdInd"].hide();
		} else {
			me["minSpdInd"].show();
			me["maxSpdInd"].show();
		}
		me["baroSet"].setText(sprintf("%4.0f",getprop("instrumentation/altimeter/setting-hpa")));
		me["selHdgText"].setText(sprintf("%3.0f",getprop("autopilot/settings/heading-bug-deg")));
		me["speedText"].setText(sprintf("%3.0f",apSpd));
	},
};

setlistener("sim/signals/fdm-initialized", func() {
	var group = {};

	setprop("instrumentation/efis/PFD1_Circle","VOR1");
	setprop("instrumentation/efis/PFD1_Rhombus","VOR2");
	setprop("instrumentation/efis/PFD2_Circle","VOR1");
	setprop("instrumentation/efis/PFD2_Rhombus","VOR2");

	var pfd1_display = canvas.new({
		"name": "PFD1",
		"size": [512, 512],
		"view": [800, 950],
		"mipmapping": 1
	});
	pfd1_display.addPlacement({"node": "PFD1_Screen"});
	group = pfd1_display.createGroup();
	var pfd1_canvas = canvas_PFD.new(group, 0);
	pfd1_canvas.update();

	var pfd2_display = canvas.new({
		"name": "PFD2",
		"size": [512, 512],
		"view": [800, 950],
		"mipmapping": 1
	});
	pfd2_display.addPlacement({"node": "PFD2_Screen"});
	group = pfd2_display.createGroup();
	var pfd2_canvas = canvas_PFD.new(group, 1);
	pfd2_canvas.update();
});

setlistener("sim/signals/reinit", func pfd1_display.del());
setlistener("sim/signals/reinit", func pfd2_display.del());
