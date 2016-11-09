#### this small script handle the intensity of the lightmap effect#

call_lightmap = func {


LL = getprop("/systems/electrical/outputs/logo-lights") or 0;
WL = getprop("/systems/electrical/outputs/wing-lights") or 0;
BL = getprop("/systems/electrical/outputs/beacon") or 0;
LaL = getprop("/systems/electrical/outputs/landing-light[1]") or 0;

SUN_ANGLE = getprop("sim/time/sun-angle-rad");
#INSTR_DIMMER = getprop("controls/lighting/instruments-norm");
#EFIS_DIMMER = getprop("controls/lighting/efis-norm");
#ENG_DIMMER = getprop("controls/lighting/engines-norm");
#PANEL_DIMMER = getprop("controls/lighting/panel-norm");
LOGO = getprop("controls/lighting/logo-lights");
WING = getprop("controls/lighting/wing-lights");
#setprop("systems/electrical/outputs/instrument-lightintensity",(Rbus * INSTR_DIMMER));
#setprop("systems/electrical/outputs/instrument-lights-norm",(0.0416 * (Rbus * INSTR_DIMMER)));
#setprop("systems/electrical/outputs/eng-lights",(Rbus * ENG_DIMMER));
#setprop("systems/electrical/outputs/panel-lights",(Rbus * PANEL_DIMMER));
#setprop("systems/electrical/outputs/efis-lights",(Rbus * EFIS_DIMMER));
setprop("/systems/electrical/outputs/logo-lights-itensity",(SUN_ANGLE * (LL * 0.0416)));
setprop("/systems/electrical/outputs/wing-lights-itensity",(SUN_ANGLE * (WL * 0.0216)));
setprop("/systems/electrical/outputs/beacon-itensity",(SUN_ANGLE * (BL * 0.0416)));
setprop("/systems/electrical/outputs/landing-light-intensity",(LaL * 0.0316));

   settimer(call_lightmap, 0.0);   
}
 
init = func {
   settimer(call_lightmap, 0.0);
}

init();
