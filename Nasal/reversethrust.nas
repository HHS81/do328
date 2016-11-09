# DO328 Turboprop
# reversethrust, originally by Ryan M. aka Skyop
#######################


# minimum condition value for engines to run; for YASim this is 0.1%
#var condition_cutoff = 0.001;
#var condition_min = 0.4;

var engine =
 {
 new: func(no)
  {
  var m =
   {
   parents: [engine]
   };
  m.number = no;

  #m.condition = props.globals.getNode("controls/engines/engine[" ~ no ~ "]/condition", 1);
  #m.condition.setValue(0);
  #m.condition_lever = props.globals.getNode("controls/engines/engine[" ~ no ~ "]/condition-lever", 1);
  #m.condition_lever.setValue(0);
  #m.cutoff = props.globals.getNode("controls/engines/engine[" ~ no ~ "]/cutoff", 1);
  #m.cutoff.setBoolValue(0);
  #m.n1 = props.globals.getNode("engines/engine[" ~ no ~ "]/n1", 1);
  #m.n1.setValue(0);
  #m.n2 = props.globals.getNode("engines/engine[" ~ no ~ "]/n2", 1);
  #m.n2.setValue(0);
  #m.on_fire = props.globals.getNode("engines/engine[" ~ no ~ "]/on-fire", 1);
  #m.on_fire.setBoolValue(0);
  #m.out_of_fuel = props.globals.getNode("engines/engine[" ~ no ~ "]/out-of-fuel", 1);
  #m.out_of_fuel.setBoolValue(0);
  #m.propeller_feather = props.globals.getNode("controls/engines/engine[" ~ no ~ "]/propeller-feather", 1);
  #m.propeller_feather.setBoolValue(0);
  m.reverser = props.globals.getNode("controls/engines/engine[" ~ no ~ "]/reverser", 1);
  m.reverser.setBoolValue(0);
  m.reverser_cmd_norm = props.globals.getNode("controls/engines/engine[" ~ no ~ "]/reverser-cmd-norm", 1);
  m.reverser_cmd_norm.setValue(0);
  #m.serviceable = props.globals.getNode("sim/failure-manager/engines/engine[" ~ no ~ "]/serviceable", 1);
  #m.serviceable.setBoolValue(1);
  #m.starter = props.globals.getNode("controls/engines/engine[" ~ no ~ "]/starter", 1);
  #m.starter.setBoolValue(0);
  m.throttle = props.globals.getNode("controls/engines/engine[" ~ no ~ "]/throttle", 1);
  m.throttle.setValue(0);
  m.throttle_lever = props.globals.getNode("controls/engines/engine[" ~ no ~ "]/throttle-lever", 1);
  m.throttle_lever.setValue(0);

  return m;
  },
  
 reverser_update: func
  {   
  if (me.reverser.getBoolValue())
   {
   me.throttle_lever.setValue(0);
   me.reverser_cmd_norm.setValue(me.throttle.getValue());
   }
  else
   {
   me.throttle_lever.setValue(me.throttle.getValue());
   me.reverser_cmd_norm.setValue(0);
   }
  },

reverse_thrust: func
  {
  if (me.throttle.getValue() == 0)
   {
   if (me.reverser.getBoolValue())
    {
    me.reverser.setBoolValue(0);
    }
   else
    {
    me.reverser.setBoolValue(1);
    }
   }
  },
   
 };
var engine1 = engine.new(0);
var engine2 = engine.new(1);

var engine1_init_listener = setlistener("/sim/signals/fdm-initialized", func {
	removelistener(engine1_init_listener);
	settimer(update_engine1,0);
	print("Reversethrust1 ... check");
});

var engine2_init_listener = setlistener("/sim/signals/fdm-initialized", func {
	removelistener(engine2_init_listener);
	settimer(update_engine2,0);
	print("Reversethrust2 ... check");
});

var update_engine1 = func {
	engine1.reverser_update();
#	engine1.reverse_thrust();
	settimer(update_engine1, 0);
}

var update_engine2 = func {
	engine2.reverser_update();
#	engine2.reverse_thrust();
	settimer(update_engine2, 0);
}
