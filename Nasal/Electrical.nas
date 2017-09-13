##########################################################################################################
# by xcvb85, battery class based on battery class from tu154b
##########################################################################################################

# global definces
var ELNode = "systems/electrical/";
var Refresh = 0.1;

# generate blink signals
var strobe_switch = props.globals.getNode("controls/lighting/strobe", 1);
aircraft.light.new("controls/lighting/strobe-state", [0.015, 1.30], strobe_switch);
var beacon_switch = props.globals.getNode("controls/lighting/beacon", 1);
aircraft.light.new("controls/lighting/beacon-state", [0.015, 1.0], beacon_switch);

##########################################################################################################
var Alternator = {
    new: func(name, source) {
        obj = { parents: [Alternator],
            Connected: props.globals.initNode(ELNode ~ name ~ "/Connected", 0, "BOOL"),
            Current: props.globals.initNode(ELNode ~ name ~ "/Current", 0, "DOUBLE"), #A
            Voltage: props.globals.initNode(ELNode ~ name ~ "/Voltage", 0, "DOUBLE"), #V
            Source: props.globals.getNode(source, 1),
            Running: 0,
            RefVoltage: 115, #V
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

        if(me.Connected.getValue() and me.Running) {
            me.Current.setValue(current);
        }
        else {
            me.Current.setValue(0);
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
    }
};

##########################################################################################################
var Bus = {
    new: func(name) {
        obj = { parents: [Bus],
            Devices: [],
            Voltage: props.globals.initNode(ELNode ~ "/" ~ name ~ "/Voltage", 0, "DOUBLE"),
            Current: props.globals.initNode(ELNode ~ "/" ~ name ~ "/Current", 0, "DOUBLE"),
            Cnt: 0,
            Max: 0,
            Tmp: 0,
            Producers: 0
        };
        return obj;
    },
    append: func(device) {
        me.Tmp = size(me.Devices);
        setsize(me.Devices, me.Tmp+1);
        me.Devices[me.Tmp] = device;
    },
    getCurrent: func {
        return me.Current.getValue();
    },
    getVoltage: func {
        return me.Voltage.getValue();
    },
    getProducers: func {
        return me.Producers;
    },
    setCurrent: func(current) {
        me.Current.setValue(current);
    },
    setVoltage: func(voltage) {
        me.Voltage.setValue(voltage);
    },
    update: func {
        #first set old values, then get new values
        #old values can be manipulated by bus tie
        me.updateCurrent();
        me.updateVoltage();
    },
    updateCurrent: func {
        #set old current
        me.Tmp = me.Current.getValue();
        for(me.Cnt=0; me.Cnt < size(me.Devices); me.Cnt+=1) {
            if(me.Producers > 0) {
                me.Devices[me.Cnt].setCurrent(me.Tmp / me.Producers);
            }
            else {
                me.Devices[me.Cnt].setCurrent(0);
            }
        }

        #get new current
        me.Max = 0;
        me.Producers = 0;
        for(me.Cnt=0; me.Cnt < size(me.Devices); me.Cnt+=1) {
            me.Tmp = me.Devices[me.Cnt].getCurrent();

            if(me.Tmp < 0) {
                me.Producers += 1; #Producer
            }
            else {
                me.Max += me.Tmp; #Consumer
            }
        }
        me.Current.setValue(me.Max);
    },
    updateVoltage: func {
        me.Max = 0;

        for(me.Cnt=0; me.Cnt < size(me.Devices); me.Cnt+=1) {
            #set old voltage
            me.Devices[me.Cnt].setVoltage(me.Voltage.getValue());

            #get new voltage
            me.Tmp = me.Devices[me.Cnt].getVoltage();
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
            Connected: props.globals.initNode(ELNode ~ "Consumers/" ~ name ~ "_Connected", 0, "BOOL"),
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
    new: func(name, source) {
        obj = { parents: [Generator],
            Connected: props.globals.initNode(ELNode ~ name ~ "/Connected", 0, "BOOL"),
            Current: props.globals.initNode(ELNode ~ name ~ "/Current", 0, "DOUBLE"), #A
            Voltage: props.globals.initNode(ELNode ~ name ~ "/Voltage", 0, "DOUBLE"), #V
            Source: props.globals.getNode(source, 1),
            Running: 0,
            RefVoltage: 28.5, #V
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

        if(me.Connected.getValue() and me.Running) {
            me.Current.setValue(current);
        }
        else {
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
        me.Connected.setValue(connected);
    },
    update: func {
        if(me.Connected.getValue()) {
            me.updateCurrent();
            me.updateVoltage();
        }
    },
    updateCurrent: func {
        me.Current = me.Bus1.getCurrent();
        me.Current += me.Bus2.getCurrent();
        me.Producers = me.Bus1.getProducers();
        me.Producers += me.Bus2.getProducers();

        if(me.Producers > 0) {
            me.Current /= me.Producers;
            me.Bus1.setCurrent(me.Current);
            me.Bus2.setCurrent(me.Current);
        }
        else {
            me.Bus1.setCurrent(0);
            me.Bus2.setCurrent(0);
        }
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
var nonEssBus1 = Consumer.new("NonEssBus1", 0, 17);
var nonEssBus2 = Consumer.new("NonEssBus2", 0, 17);

# ties
var dctie = Tie.new("DCTie", dcBus1, dcBus2);

# producers
var alternator1 = Alternator.new("Alternator1", "/engines/engine[0]/generator-power");
var battery1 = Battery.new("Battery1");
var battery2 = Battery.new("Battery2");
var generator1 = Generator.new("Generator1", "/engines/engine[0]/generator-power");
var generator2 = Generator.new("Generator2", "/engines/engine[1]/generator-power");
acBus1.append(alternator1);
dcBus1.append(battery1);
dcBus1.append(generator1);
dcBus1.append(nonEssBus1);
dcBus2.append(battery2);
dcBus2.append(generator2);
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
var rmu = Consumer.new("RMU", 3, 17.99);
var comm = Consumer.new("comm", 1, 18);
var comm1 = Consumer.new("comm[1]", 1, 18);
var nav = Consumer.new("nav", 1, 18);
var adf = Consumer.new("adf", 1, 18);
var dme = Consumer.new("dme", 1, 18);
var transponder = Consumer.new("transponder", 1, 18);
essBus.append(rmu);
essBus.append(comm);
essBus.append(comm1);
essBus.append(nav);
essBus.append(adf);
essBus.append(dme);
essBus.append(transponder);

# consumers non-ess
var efis = Consumer.new("EFIS", 10, 18.01); # name, amps, required volts
var cdu = Consumer.new("CDU", 2, 18);
var mkviii = Consumer.new("mk-viii", 1, 18);
var gps = Consumer.new("gps", 1, 18);
var dg = Consumer.new("DG", 1, 18);
var turn = Consumer.new("turn-coordinator", 1, 18);
nonEssBus1.append(efis);
nonEssBus1.append(cdu);
nonEssBus1.append(mkviii);
nonEssBus1.append(gps);
nonEssBus1.append(dg);
nonEssBus1.append(turn);

# no separate switch
setprop("/systems/electrical/Alternator1/Connected", 1);
setprop("/systems/electrical/Consumers/EFIS_Connected", 1);
setprop("/systems/electrical/Consumers/RMU_Connected", 1);
setprop("/systems/electrical/Consumers/CDU_Connected", 1);
setprop("/systems/electrical/Consumers/mk-viii_Connected", 1);
setprop("/systems/electrical/Consumers/gps_Connected", 1);
setprop("/systems/electrical/Consumers/comm_Connected", 1);
setprop("/systems/electrical/Consumers/comm[1]_Connected", 1);
setprop("/systems/electrical/Consumers/nav_Connected", 1);
setprop("/systems/electrical/Consumers/adf_Connected", 1);
setprop("/systems/electrical/Consumers/dme_Connected", 1);
setprop("/systems/electrical/Consumers/transponder_Connected", 1);
setprop("/systems/electrical/Consumers/DG_Connected", 1);
setprop("/systems/electrical/Consumers/turn-coordinator_Connected", 1);

update_electrical = func {
    acBus1.update();
    acBus2.update();
    dcBus1.update();
    dcBus2.update();
    dctie.update();
    essBus.update();
    settimer(update_electrical, Refresh);
}
update_electrical();
