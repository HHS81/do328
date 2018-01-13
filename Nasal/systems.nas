aircraft.livery.init("Aircraft/do328/Models/do328prop_liveries");

var gear_toggle = func(dir){
    if(dir==-1){
        dir=0;
        if(getprop("controls/gear/gear-down")){
            if(getprop("gear/gear[1]/wow"))dir=1;
            if(getprop("controls/gear/gear-lock"))dir=1;
        }
    }
    setprop("controls/gear/gear-down", dir);
}
