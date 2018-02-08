var input_land_elevation = props.globals.initNode("systems/pressurization/land_elevation", 0, "DOUBLE");
var output_cabin_altitude = props.globals.initNode("systems/pressurization/cabin-altitude-ft", 0, "DOUBLE");
var output_cabin_rate = props.globals.initNode("systems/pressurization/cabin-rate-fpm", 0, "DOUBLE");
var output_diff_pressure = props.globals.initNode("systems/pressurization/diff-pressure", 0, "DOUBLE");

var pressure_altitude = 0;
var cabin_altitude = 0;
var cabin_altitude_old = 0;
var cabin_rate = 0;
var start_elevation = 0;
var land_elevation = 0;

var update_pressure = func {
	pressure_altitude = getprop("instrumentation/altimeter/pressure-alt-ft") or 0;
	land_elevation = input_land_elevation.getValue();

	if(getprop("gear/gear[1]/wow")) start_elevation=pressure_altitude;

	if(cabin_altitude < cabin_altitude_old) {
		# decending
		cabin_altitude = ((pressure_altitude - land_elevation)*0.25) + land_elevation;

		if(cabin_altitude < land_elevation) {
			cabin_altitude = cabin_altitude_old;
		}
	}
	else {
		# climbing
		cabin_altitude = ((pressure_altitude - start_elevation)*0.25) + start_elevation;

		if(cabin_altitude < start_elevation) {
			cabin_altitude = cabin_altitude_old;
		}
	}

	cabin_rate = cabin_altitude - cabin_altitude_old;

	# limit cabin rate to 10ft/s = 600ft/min
	if(cabin_rate > 10) cabin_rate = 10;
	if(cabin_rate < -10) cabin_rate = -10;

	cabin_altitude = cabin_altitude_old + cabin_rate;

	output_cabin_altitude.setValue(cabin_altitude);
	output_cabin_rate.setValue(math.floor(cabin_rate*6)*10);
	output_diff_pressure.setValue(	14.7*math.exp((-0.284*cabin_altitude)/2400) -
					14.7*math.exp((-0.284*pressure_altitude)/2400));

	cabin_altitude_old = cabin_altitude;
}

var pressure_timer = maketimer(1, update_pressure);
var _list = setlistener("sim/signals/fdm-initialized", func {
	pressure_timer.start();
	removelistener(_list); # run ONCE
});
