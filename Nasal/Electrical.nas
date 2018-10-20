##########################################################################################################
# Electrical Systems (battery class based on battery class from tu154b)
# Daniel Overbeck - 2017
##########################################################################################################

# global definces
var ELNode = "systems/electrical/";
var Refresh = 0.05;

# generate blink signals
var strobe_switch = props.globals.getNode("controls/lighting/strobe", 1);
aircraft.light.new("controls/lighting/strobe-state", [0.015, 1.30], strobe_switch);
var beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
aircraft.light.new("controls/lighting/beacon-state", [0.015, 1.0], beacon_switch);
var essential = 0;

##########################################################################################################
var APU = {
    new: func(name, source, refVoltage) {
        obj = { parents: [APU],
            Connected: props.globals.initNode(ELNode ~ name ~ "/Connected", 0, "BOOL"),
            Current: props.globals.initNode(ELNode ~ name ~ "/Current", 0, "DOUBLE"), #A
            Voltage: props.globals.initNode(ELNode ~ name ~ "/Voltage", 0, "DOUBLE"), #V
            IndicatorGenerator: props.globals.initNode(ELNode ~ name ~ "/IndicatorGenerator", 0, "INT"),
            IndicatorMaster: props.globals.initNode(ELNode ~ name ~ "/IndicatorMaster", 0, "INT"),
            IndicatorStart: props.globals.initNode(ELNode ~ name ~ "/IndicatorStart", 0, "INT"),
            Source: props.globals.getNode(source, 1),
            Running: 0,
            RefVoltage: refVoltage, #V
            Tmp: 0
        };
        return obj;
    },
    getCurrent: func {
        if(!me.Connected.getValue() or !me.Running) {
            return 0;
        }
        return -1; #negative value -> producer
    },
    getVoltage: func {
        me.Tmp = 0;

        if(me.Running) {
            me.Voltage.setValue(me.RefVoltage);

            if(me.Connected.getValue()) {
                me.Tmp = me.RefVoltage;
            }
        }
        else {
            me.Voltage.setValue(0);
        }
        return me.Tmp;
    },
    setConnected: func(connected) {
        me.Connected.setValue(connected);
    },
    setCurrent: func(current) {
        me.Running = me.Source.getValue() or 0;

        if(!essential) {
            me.IndicatorGenerator.setValue(0);
            me.IndicatorMaster.setValue(0);
            me.IndicatorStart.setValue(0);
            me.Current.setValue(0);

            if(me.Running) {
                stop_apu();
            }
            return;
        }

        # generator
        if(me.Running) {
            if(me.Connected.getValue()) {
                # on
                me.IndicatorGenerator.setValue(1);
                me.Current.setValue(current);
            }
            else {
                # avail
                me.IndicatorGenerator.setValue(11);
                me.Current.setValue(0);
            }
        }
        else {
            # black
            me.IndicatorGenerator.setValue(0);
            me.Current.setValue(0);
        }

        # master and start
        if(getprop("systems/electrical/APU/btnMaster")) {
            # master on
            me.IndicatorMaster.setValue(1);

            if(me.Running) {
                # starter ready
                me.IndicatorStart.setValue(1);
            }
            else {
                if(getprop("controls/engines/engine[2]/starter")) {
                    # starter black
                    me.IndicatorStart.setValue(0);
                }
                else {
                    # starter start
                    me.IndicatorStart.setValue(3);
                }

                if(getprop("systems/electrical/APU/btnStart")) {
                    setprop("controls/engines/engine[2]/starter", 1);
                }
            }
        }
        else {
            # black
            me.IndicatorMaster.setValue(0);
            me.IndicatorStart.setValue(0);

            if(me.Running) {
                stop_apu();
            }
        }
    },
    setVoltage: func(volts) {
    }
};

##########################################################################################################
# From ATA 24.41: "Two identical nickel cadmium batteries (BAT) 24 V/40 Ah are installed in the aircraft."
var Battery = {
    new: func(name) {
        obj = { parents: [Battery],
            Connected: props.globals.initNode(ELNode ~ name ~ "/Connected", 0, "BOOL"),
            Current: props.globals.initNode(ELNode ~ name ~ "/Current", 0, "DOUBLE"), #A
            Voltage: props.globals.initNode(ELNode ~ name ~ "/Voltage", 24, "DOUBLE"), #V
            Indicator: props.globals.initNode(ELNode ~ name ~ "/Indicator", 0, "INT"),
            Running: 0,
            RefVoltage: 24, #V
            Capacity: 40, #Ah
            Charge: 1, #%
            DCharge: 0,
            Tmp: 0
        };
        return obj;
    },
    getCurrent: func {
        if(!me.Connected.getValue() or !me.Running) {
            return 0;
        }
        return -1; #negative value -> producer
    },
    getVoltage: func {
        if(!me.Connected.getValue()) {
            return 0;
        }
        return me.Voltage.getValue();
    },
    setConnected: func(connected) {
        me.Connected.setValue(connected);
    },
    setCurrent: func(current) {
        if(me.Connected.getValue() and me.Running) {
            me.Tmp = (current * Refresh) / 3600.0; # used amp hrs
            me.DCharge = me.Tmp / me.Capacity;
            me.Charge -= me.DCharge;

            if(me.Charge < 0.0) {
                me.Charge = 0.0;
            } elsif (me.Charge > 1.0) {
                me.Charge = 1.0;
            }
            me.Current.setValue(current);
        }
        else {
            me.Current.setValue(0);
        }
    },
    setVoltage: func(volts) {
        # deactivate if voltage smaller than external
        me.Tmp = (1.0 - me.Charge) / 10;

        if((volts-me.DCharge) > (me.RefVoltage - me.Tmp)) {
            me.Running = 0;
        }
        else {
            me.Running = 1;
        }
        me.Voltage.setValue(me.RefVoltage - me.Tmp);

        if(me.Connected.getValue()) {
            me.Indicator.setValue(0);
        }
        else {
            if(essential) {
                me.Indicator.setValue(1);
            }
            else {
                me.Indicator.setValue(0);
            }
        }
    }
};

##########################################################################################################
var Bus = {
    new: func(name) {
        obj = { parents: [Bus],
            Devices: [],
            Voltage: props.globals.initNode(ELNode ~ "/" ~ name ~ "/Voltage", 0, "DOUBLE"),
            Current: props.globals.initNode(ELNode ~ "/" ~ name ~ "/Current", 0, "DOUBLE"),
            Device: 0,
            Max: 0,
            Tmp: 0,
            Producers: 0
        };
        return obj;
    },
    append: func(device) {
	append(me.Devices, device);
    },
    getCurrent: func {
        return me.Current.getValue();
    },
    getProducers: func {
        return me.Producers;
    },
    getVoltage: func {
        return me.Voltage.getValue();
    },
    setCurrent: func(current) {
        me.Current.setValue(current);
    },
    setProducers: func(producers) {
        me.Producers = producers;
    },
    setVoltage: func(voltage) {
        me.Voltage.setValue(voltage);
    },
    update: func {
        # values can be manipulated by bus tie
        me.updateCurrent();
        me.updateVoltage();
    },
    updateCurrent: func {
        # set old current
        me.Tmp = me.Current.getValue();

        foreach(me.Device; me.Devices) {
            if(me.Producers > 0) {
                me.Device.setCurrent(me.Tmp / me.Producers);
            }
            else {
                me.Device.setCurrent(0);
            }
        }

        # get new current
        me.Max = 0;
        me.Producers = 0;
        foreach(me.Device; me.Devices) {
            me.Tmp = me.Device.getCurrent();

            if(me.Tmp < 0) {
                me.Producers += 1; # Producer
            }
            else {
                me.Max += me.Tmp; # Consumer
            }
        }
        me.Current.setValue(me.Max);
    },
    updateVoltage: func {
        me.Max = 0;

        foreach(me.Device; me.Devices) {
            # set old voltage
            me.Device.setVoltage(me.Voltage.getValue());

            # get new voltage
            me.Tmp = me.Device.getVoltage();
            if(me.Tmp > me.Max) {
                me.Max = me.Tmp;
            }
        }
        me.Voltage.setValue(me.Max);
    }
};

##########################################################################################################
var Consumer = {
    new: func(name, current, minVoltage) {
        obj = { parents : [Consumer],
            Devices: [],
            Connected: props.globals.initNode("instrumentation/" ~ name ~ "/serviceable", 0, "BOOL"),
            Running: props.globals.initNode(ELNode ~ "outputs/" ~ name, 0, "DOUBLE"),
            Current: current,
            MinVoltage: minVoltage,
            Tmp: 0,
            i: 0
        };
        return obj;
    },
    append: func(device) {
        me.Tmp = size(me.Devices);
        setsize(me.Devices, me.Tmp+1);
        me.Devices[me.Tmp] = device;
    },
    getCurrent: func {
        if(me.Running.getValue() < 24 or !me.Connected.getValue()) {
            return 0;
        }

	me.Tmp = me.Current;
	for(me.i=0; me.i<size(me.Devices); me.i+=1) {
		me.Tmp += me.Devices[me.i].getCurrent();
	}
        return me.Tmp;
    },
    getVoltage: func {
        return 0;
    },
    setCurrent: func(current) {
    },
    setVoltage: func(voltage) {
        if(me.Connected.getValue()) {
            if(voltage < me.MinVoltage) {
                me.Running.setValue(0);
                for(me.i=0; me.i<size(me.Devices); me.i+=1) {
                    me.Devices[me.i].setVoltage(0);
                }
            }
            else {
                me.Running.setValue(24);
                for(me.i=0; me.i<size(me.Devices); me.i+=1) {
                    me.Devices[me.i].setVoltage(voltage);
                }
            }
        }
        else {
            me.Running.setValue(0);
            for(me.i=0; me.i<size(me.Devices); me.i+=1) {
                me.Devices[me.i].setVoltage(0);
            }
        }
    }
};

##########################################################################################################
# Essential Bus: Power supply for essential equipment, always connected
# Essential Equipment: COM and NAV Radios, RMU, basic Instruments, intercom
# Gets power from DC Bus 1 and DC Bus 2
# In case of generator failure also from AC-BUS (DC-TRU, not simulated here)
var EssBus = {
    new: func(name, a, b) {
        obj = { parents: [EssBus],
            Devices: [],
            Voltage: props.globals.initNode(ELNode ~ "/" ~ name ~ "/Voltage", 0, "DOUBLE"),
            Current: props.globals.initNode(ELNode ~ "/" ~ name ~ "/Current", 0, "DOUBLE"),
            Bus1: a,
            Bus2: b,
            Producers: 0,
            Tmp: 0
        };
        return obj;
    },
    append: func(device) {
        me.Tmp = size(me.Devices);
        setsize(me.Devices, me.Tmp+1);
        me.Devices[me.Tmp] = device;
    },
    getCurrent: func {
        me.Tmp = 0;
        for(me.i=0; me.i<size(me.Devices); me.i+=1) {
            me.Tmp += me.Devices[me.i].getCurrent();
        }
        me.Current.setValue(me.Tmp);
        return me.Tmp;
    },
    getVoltage: func {
        return me.Voltage.getValue();
    },
    update: func {
        me.Tmp = me.Bus2.getVoltage();
        
        if(me.Tmp > me.Bus1.getVoltage()) {
            # BUS2 higher voltage -> get power from BUS2
            me.Voltage.setValue(me.Tmp);
            me.Tmp = me.Bus1.getCurrent();
            me.Bus1.setCurrent(me.Tmp + me.getCurrent());
        }
        else {
            # BUS1 higher voltage -> get power from BUS1
            me.Tmp = me.Bus1.getVoltage();
            me.Voltage.setValue(me.Tmp);
            me.Tmp = me.Bus1.getCurrent();
            me.Bus1.setCurrent(me.Tmp + me.getCurrent());
        }

        essential = me.getVoltage() > 0;

        me.Tmp = me.getVoltage();
        for(me.i=0; me.i<size(me.Devices); me.i+=1) {
            me.Devices[me.i].setVoltage(me.Tmp);
        }
    }
};

##########################################################################################################
# From ATA 24.25: "The starter/generator system, with each of its two starter/generators (S/G), provides a
# separate DC MAIN BUS with 28.5 VDC."
var Generator = {
    new: func(name, source, refVoltage) {
        obj = { parents: [Generator],
            Connected: props.globals.initNode(ELNode ~ name ~ "/Connected", 0, "BOOL"),
            Current: props.globals.initNode(ELNode ~ name ~ "/Current", 0, "DOUBLE"), #A
            Voltage: props.globals.initNode(ELNode ~ name ~ "/Voltage", 0, "DOUBLE"), #V
            Indicator: props.globals.initNode(ELNode ~ name ~ "/Indicator", 0, "INT"),
            Source: props.globals.getNode(source, 1),
            Running: 0,
            RefVoltage: refVoltage, #V
            Tmp: 0
        };
        return obj;
    },
    getCurrent: func {
        if(!me.Connected.getValue() or !me.Running) {
            return 0;
        }
        return -1; #negative value -> producer
    },
    getVoltage: func {
        me.Tmp = 0;

        me.Running = me.Source.getValue() or 0;

        if(me.Running) {
            me.Voltage.setValue(me.RefVoltage);

            if(me.Connected.getValue()) {
                me.Tmp = me.RefVoltage;
            }
        }
        else {
            me.Voltage.setValue(0);
        }
        return me.Tmp;
    },
    setConnected: func(connected) {
        me.Connected.setValue(connected);
    },
    setCurrent: func(current) {
        if(!essential) {
            me.Indicator.setValue(0);
            me.Current.setValue(0);
            return;
        }

        if(me.Connected.getValue()) {
            if(me.Running) {
                # black
                me.Indicator.setValue(0);
                me.Current.setValue(current);
            }
            else {
                # fail
                me.Indicator.setValue(12);
                me.Current.setValue(0);
            }
        }
        else {
            # off
            me.Indicator.setValue(1);
            me.Current.setValue(0);
        }
    },
    setVoltage: func(volts) {
    }
};

##########################################################################################################
var Tie = {
    new: func(name, a, b) {
        obj = { parents: [Tie],
            Connected: props.globals.initNode(ELNode ~ name ~ "/Connected", 0, "BOOL"),
            Switched: props.globals.initNode(ELNode ~ name ~ "/Switched", 0, "BOOL"),
            Voltage: 0,
            Current: 0,
            Bus1: a,
            Bus2: b,
            Producers: 0,
            Tmp: 0
        };
        return obj;
    },
    setConnected: func(connected) {
            me.Switched.setValue(connected);
    },
    update: func {
        if(me.Switched.getValue()) {
            if(me.Bus1.getVoltage() > 25 or me.Bus2.getVoltage() > 25) {
                me.Connected.setValue(1);
                me.updateCurrent();
                me.updateVoltage();
	    }
            else {
                me.Connected.setValue(0);
            }
        }
        else {
            me.Connected.setValue(0);
        }
    },
    updateCurrent: func {
        me.Current = me.Bus1.getCurrent();
        me.Current += me.Bus2.getCurrent();
        me.Bus1.setCurrent(me.Current);
        me.Bus2.setCurrent(me.Current);

        me.Producers = me.Bus1.getProducers();
        me.Producers += me.Bus2.getProducers();
        me.Bus1.setProducers(me.Producers);
        me.Bus2.setProducers(me.Producers);
    },
    updateVoltage: func {
        me.Voltage = me.Bus1.getVoltage();
        me.Tmp = me.Bus2.getVoltage();
        
        if(me.Tmp > me.Voltage) {
            me.Voltage = me.Tmp;
        }
        me.Bus1.setVoltage(me.Voltage);
        me.Bus2.setVoltage(me.Voltage);
    }
};

##########################################################################################################
# buses
var acBus1 = Bus.new("ACBus1");
var acBus2 = Bus.new("ACBus2");
var dcBus1 = Bus.new("DCBus1");
var dcBus2 = Bus.new("DCBus2");
var essBus = EssBus.new("EssBus", dcBus1, dcBus2);
var nonEssBus1 = Consumer.new("nonEssBus1", 0, 25);
var nonEssBus2 = Consumer.new("nonEssBus2", 0, 25);

# ties
var dctie = Tie.new("DCTie", dcBus1, dcBus2);

# producers
var alternator1 = Generator.new("Alternator1", "/engines/engine[0]/running", 115);
var alternator2 = Generator.new("Alternator2", "/engines/engine[1]/running", 115);
var battery1 = Battery.new("Battery1");
var battery2 = Battery.new("Battery2");
var generator1 = Generator.new("Generator1", "/engines/engine[0]/running", 28.5);
var generator2 = Generator.new("Generator2", "/engines/engine[1]/running", 28.5);
var apu = APU.new("APU", "/engines/engine[2]/running", 28.5);
acBus1.append(alternator1);
acBus2.append(alternator2);
dcBus1.append(battery1);
dcBus1.append(generator1);
dcBus1.append(nonEssBus1);
dcBus2.append(battery2);
dcBus2.append(generator2);
dcBus2.append(apu);
dcBus2.append(nonEssBus2);

# consumers ac
var LL = Consumer.new("logo-lights", 2, 100);
var WL = Consumer.new("wing-lights", 2, 100);
var BL = Consumer.new("beacon", 2, 100);
var SL = Consumer.new("strobe", 2, 100);
var LaL = Consumer.new("landing-lights", 4, 100);
var TL = Consumer.new("taxi-lights", 4, 100);
var NL = Consumer.new("nav-lights", 2, 100);
acBus1.append(LL);
acBus1.append(WL);
acBus1.append(BL);
acBus1.append(SL);
acBus1.append(LaL);
acBus1.append(TL);
acBus1.append(NL);

# consumers ess
var rmu = Consumer.new("rmu", 3, 17.99);
var comm = Consumer.new("comm", 1, 18);
var comm1 = Consumer.new("comm[1]", 1, 18);
var nav = Consumer.new("nav", 1, 18);
var adf = Consumer.new("adf", 1, 18);
var dme = Consumer.new("dme", 1, 18);
var transponder = Consumer.new("transponder", 1, 18);
var efis = Consumer.new("efis", 10, 18.01); # name, amps, required volts
var cdu = Consumer.new("cdu", 2, 18);
var mkviii = Consumer.new("mk-viii", 1, 18);
var gps = Consumer.new("gps", 1, 18);
var turn = Consumer.new("turn-coordinator", 1, 18);
essBus.append(rmu);
essBus.append(comm);
essBus.append(comm1);
essBus.append(nav);
essBus.append(adf);
essBus.append(dme);
essBus.append(transponder);
essBus.append(efis);
essBus.append(cdu);
essBus.append(mkviii);
essBus.append(gps);
essBus.append(turn);

# consumers non-ess

# no separate switch
setprop("instrumentation/efis/serviceable", 1);
setprop("instrumentation/rmu/serviceable", 1);
setprop("instrumentation/cdu/serviceable", 1);
setprop("instrumentation/nonEssBus1/serviceable",1);
setprop("instrumentation/nonEssBus2/serviceable",1);

update_electrical = func {
    acBus1.update();
    acBus2.update();
    dcBus1.update();
    dcBus2.update();
    essBus.update();
    dctie.update();
}
var electrical_timer = maketimer(Refresh, update_electrical);
electrical_timer.start();
