#### this small script handle the intensity of the lightmap effect#

var LL=0;
var WL=0;
var BL=0;
var BS=0;
var LaL=0;
var SUN_ANGLE=0;

call_lightmap = func {

   LL = getprop("systems/electrical/Consumers/logo-lights_Running") or 0;
   WL = getprop("systems/electrical/Consumers/wing-lights_Running") or 0;
   BL = getprop("systems/electrical/Consumers/beacon_Running") or 0;
   BS = getprop("controls/lighting/beacon-state/state") or 0;
   LaL = getprop("systems/electrical/Consumers/landing-lights_Running") or 0;

   SUN_ANGLE = getprop("sim/time/sun-angle-rad");
   #INSTR_DIMMER = getprop("controls/lighting/instruments-norm");
   #EFIS_DIMMER = getprop("controls/lighting/efis-norm");
   #ENG_DIMMER = getprop("controls/lighting/engines-norm");
   #PANEL_DIMMER = getprop("controls/lighting/panel-norm");
   #LOGO = getprop("controls/lighting/logo-lights");
   #WING = getprop("controls/lighting/wing-lights");
   #setprop("systems/electrical/Consumers/instrument-lightintensity",(Rbus * INSTR_DIMMER));
   #setprop("systems/electrical/Consumers/instrument-lights-norm",(0.0416 * (Rbus * INSTR_DIMMER)));
   #setprop("systems/electrical/Consumers/eng-lights",(Rbus * ENG_DIMMER));
   #setprop("systems/electrical/Consumers/panel-lights",(Rbus * PANEL_DIMMER));
   #setprop("systems/electrical/Consumers/efis-lights",(Rbus * EFIS_DIMMER));
   setprop("systems/electrical/Consumers/logo-lights_Intensity",((SUN_ANGLE) * (LL * 0.7584)));#0.0316*24
   setprop("systems/electrical/Consumers/wing-lights_Intensity",((SUN_ANGLE) * (WL * 0.7584)));
   setprop("systems/electrical/Consumers/beacon_Intensity",((SUN_ANGLE) * (BL * BS * 0.5184)));
   setprop("systems/electrical/Consumers/landing-lights_Intensity",((SUN_ANGLE)*(LaL * 0.7584)));

   settimer(call_lightmap, 0);
}

settimer(call_lightmap, 0);
