# do328 pressurization system by xcvb

var cabin_altitude = props.globals.initNode("systems/pressurization/cabin-altitude-ft",0,"DOUBLE");
var cabin_rate = props.globals.initNode("systems/pressurization/cabin-rate-fpm",500,"DOUBLE");
var cabin_alt_old = 0;

var update_pressure = func {
	var airport_alt = airportinfo().elevation*3;
	var position_alt = getprop("position/altitude-ft") or 0;
	var pressure_alt = getprop("instrumentation/altimeter/pressure-alt-ft") or 0;
	var diff = pressure_alt-position_alt;

	airport_alt = airport_alt+diff; # airport_alt influenced by weather
	pressure_alt = pressure_alt-airport_alt;

	var cabin_alt = airport_alt + pressure_alt*0.25;
	cabin_altitude.setValue(cabin_alt);

	cabin_rate.setValue(math.floor((cabin_alt-cabin_alt_old)*6)*10);

	cabin_alt_old = cabin_alt;
	settimer(update_pressure, 1);
}
var _list = setlistener("sim/signals/fdm-initialized", func {
	update_pressure();

	removelistener(_list); # run ONCE
});
