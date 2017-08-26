##########################################################################################################
# by xcvb85, battery class based on battery class from tu154b
##########################################################################################################

var ELNode = "systems/electrical/";
var Refresh = 0.1;

##########################################################################################################
# From ATA 24.41: "Two identical nickel cadmium batteries (BAT) 24 V/40 Ah are installed in the aircraft."
var Battery = {
    new: func(name) {
        obj = { parents: [Battery],
            Active: 0,
            Connected: props.globals.initNode(ELNode ~ name ~ "/Connected", 0, "BOOL"),
            Current: props.globals.initNode(ELNode ~ name ~ "/Current", 0, "DOUBLE"), #A
            Voltage: props.globals.initNode(ELNode ~ name ~ "/Voltage", 24, "DOUBLE"), #V
            RefVoltage: 24, #V
            Capacity: 40, #Ah
            Charge: 1, #%
            DCharge: 0,
            Tmp: 0
        };
        return obj;
    },
    getCurrent: func {
        if(!me.Connected.getValue() or !me.Active) {
            return 0;
        }
        return -1; #negative value -> producer
    },
    getVoltage: func {
        if(!me.Connected.getValue() or !me.Active) {
            return 0;
        }
        return me.Voltage.getValue();
    },
    setConnected: func(connected) {
        me.Connected.setValue(connected);
    },
    setCurrent: func(current) {
        if(me.Connected.getValue()) {
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
            me.Active = 0;
        }
        else {
            me.Active = 1;
        }
        me.Voltage.setValue(me.RefVoltage - me.Tmp);
    }
};

##########################################################################################################
var Bus = {
    new: func(name) {
        obj = { parents: [Bus],
            Voltage: props.globals.initNode(ELNode ~ "/" ~ name ~ "/Voltage", 0, "DOUBLE"),
            Current: props.globals.initNode(ELNode ~ "/" ~ name ~ "/Current", 0, "DOUBLE"),
            Cnt: 0,
            Max: 0,
            Tmp: 0,
            Producers: 0,
            Devices: {}
        };
        return obj;
    },
    append: func(device) {
        me.Tmp = size(me.Devices);
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
            Active: props.globals.initNode(ELNode ~ "Consumers/" ~ name, 0, "BOOL"),
            Current: current,
            MinVoltage: minVoltage
        };
        return obj;
    },
    getCurrent: func {
        if(!me.Active.getValue()) {
            return 0;
        }
        return me.Current;
    },
    getVoltage: func {
        return 0;
    },
    setCurrent: func(current) {
    },
    setVoltage: func(voltage) {
        if(voltage < me.MinVoltage) {
            me.Active.setValue(0);
        }
        else {
            me.Active.setValue(1);
        }
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
var battery1 = Battery.new("Battery1");
var battery2 = Battery.new("Battery2");
var dc1 = Bus.new("DCBus1");
var dc2 = Bus.new("DCBus2");
var efis = Consumer.new("EFIS", 10, 18.01); # name, amps, required volts
var rmu = Consumer.new("RMU", 3, 17.99);
var cdu = Consumer.new("CDU", 2, 18);
var dctie = Tie.new("DCTie", dc1, dc2);

dc1.append(battery1);
dc2.append(battery2);

# TODO: which consumer on which bus?
dc1.append(efis);
dc1.append(cdu);
dc1.append(rmu);

update_electrical = func {
    dc1.update();
    dc2.update();
    dctie.update();
    settimer(update_electrical, Refresh);
}
update_electrical();
