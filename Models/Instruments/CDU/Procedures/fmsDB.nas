### Parser Navdata ####
### C. Le Moigne (clm76) ###


var fmsDB = {
    new : func(icao) {
        var me = {parents:[fmsDB]};
        me.airport = icao;
        me.wptps   = [];
        

      var tp = fmsTP.new();
      var wp = fmsWP.new();
      var trans = fmsTransition.new();
      var xmlStack = [];

      ############ START ############
      var start = func(name, attr) {
        if (name == "Star") {
          tp.tp_type = "star";
          foreach (var a; keys(attr)) {
            if (a == "Name") {
              tp.wp_name=attr[a];
            }
            if (a == "Runways") {
              tp.runways = split(",",attr[a]);
							 tp.tp_runway=attr[a];
            }
          }
   				##print("- Parse STAR: "~tp.wp_name~" - "~tp.wp_runway);
        }

        if (name == "Sid") {
          tp.tp_type = "sid";
          foreach (var a; keys(attr)) {
            if (a == "Name") {
              tp.wp_name= attr[a];
            }
            if (a == "Runways") {
              tp.runways = split(",",attr[a]);
            }
          }
          ##print("- Parse SID: "~tp.wp_name);         
        }
        if (name == "Sid_Waypoint") {
          ##print("-- Start Sid wp");
          wp = fmsWP.new();
          wp.wp_type = "WP.sid";
          wp.wp_parent_name = tp.wp_name;
        }
        if (name == "Star_Waypoint") {
          ##print("-- Start Star wp");
          wp = fmsWP.new();
          wp.wp_type = "WP.star";
          wp.wp_parent_name = tp.wp_name;
        }
        if (name == "Sid_Transition") {
          trans = fmsTransition.new();
          trans.trans_type = "sid";
          foreach (var a; keys(attr)) {
            if (a == "Name") {
              trans.trans_name= attr[a];
              ##print("trans name: "~trans.trans_name);
            }
          }
          ##print("-- Start Sid Transition for: "~trans.trans_name);
        }
        if (name == "Star_Transition") {
          trans = fmsTransition.new();
          trans.trans_type = "star";
          foreach (var a; keys(attr)) {
            if (a == "Name") {
              trans.trans_name= attr[a];
            }
          }
          ##print("-- Start Star Transition for: "~trans.trans_name);
        }
        if (name == "SidTr_Waypoint" or name == "StarTr_Waypoint") {
          ##print("--- Start Sid Transition wp for: "~trans.trans_name);
          wp = fmsWP.new();
          wp.wp_type = trans.trans_type~"Wp";
          wp.wp_parent_name = trans.trans_name;
        }
        if (name == "RunwayTransition") {
          trans = fmsTransition.new();
          foreach (var a; keys(attr)) {
            if (a == "Name") {
              trans.trans_name = attr[a];
            }
          }
          trans.trans_type = "RWY";
          ##print("-- Start RWY Transition for: "~trans.trans_name);
        }
        if (name == "RwyTr_Waypoint") {
          wp = fmsWP.new();
          wp.wp_type = "RWY";
          foreach (var a; keys(attr)) {
            if (a == "ID") {
              wp.wp_name = attr[a];
            }
          }
          ##print("--- Start RWY Trans WP for trans: "~trans.trans_name);
        }
        if (name == "Approach") {
          ##print("- Parse Approach");
          tp = fmsTP.new();
          tp.tp_type = "Approach";
          foreach (var a; keys(attr)) {
            if (a == "Name") {
              tp.wp_name = attr[a];
           }
          }
					if (right(tp.wp_name,1) == "L" or right(tp.wp_name,1) == "R") {;
            var run = right(tp.wp_name,3);
					} else {
            var run = right(tp.wp_name,2); 
					}
           ##print("   set approach runway: "~run);
            append(tp.runways,run);
        }
        if (name == "App_Waypoint") {
           ##print("--  Start Approach Waypoint for "~tp.wp_name);
           wp = fmsWP.new();
           wp.wp_type = "Approach";        
        }
        if (name == "App_Transition") {
          ##print("-- Start Approach Transition for: "~tp.wp_name);
          trans = fmsTransition.new();
          trans.trans_type = "AppTransition";
          foreach (var a; keys(attr)) {
            if (a == "Name") {
              trans.trans_name = attr[a];
            }
          }
        }
        if (name == "AppTr_Waypoint") {
          ##print("--- Start Approach Transition WP: "~tp.wp_name);
          wp = fmsWP.new();
          wp.wp_type = "AppTransition";  
	      }
      }

      ########## END #############
			var end = func(name) {
				if (name == "Star" or name == "Sid") {
  					##print("- End STAR or SID: "~tp.wp_name);
					if (size(tp.runways) == 0) {
             append(tp.runways, "All");
          }
          append(me.wptps, tp);
          tp = fmsTP.new();
        }
        if (name == "Approach") {
      		##print("- end Approach: "~tp.wp_name);
          append(me.wptps, tp);
        }
        if (name == "Sid_Waypoint" or name == "Star_Waypoint") {
          ##print("--  end Sid/Star Waypoint wp: "~wp.wp_name~");
          append(tp.wpts, wp);
        }
        if (name == "App_Waypoint") {
          ##print("--  end Approach Waypoint wp: "~wp.wp_name);
          append(tp.wpts, wp);
        }
       	if (name == "App_Transition") {
         	##print("-- End Approach Transition for: "~trans.trans_name~", on tp: "~tp.wp_name);
         	append(tp.transitions, trans);
				}
				if (name == "AppTr_Waypoint") {
          ##print("--- End Approach Transition WP for: "~trans.trans_name);
          append(trans.trans_wpts, wp);
        }

        if (name == "Name") {
           ##print("[FMS] do Name");
           var data = pop(xmlStack);
           wp.wp_name = data;
				}

        if (name == "Runways") {
           print("[FMS] do Runways");
           var data = pop(xmlStack);
           wp.wp_runway = data;           
         }

         if (name == "Speed") {
           #print("[FMS] do Speed");
           var data = pop(xmlStack);
           wp.spd_cstr = int(data);
           if (wp.spd_cstr != 0) {
             wp.spd_cstr_ind = 1;
           }
         }
         if (name == "Altitude") {
           #print("[FMS] do Alt");
           var data = pop(xmlStack);
           wp.alt_cstr = int(data);
           if(wp.alt_cstr != 0) {
             wp.alt_cstr_ind = 1;
           }
         }
#         if (name == "AltitudeRestriction") {
#           var data = pop(xmlStack);
#           wp.alt_res = data;
#         }
         if (name == "Latitude") {
           var data = pop(xmlStack);
           wp.wp_lat = data;
         }
         if (name == "Longitude") {
           var data = pop(xmlStack);
           wp.wp_lon = data;
         }
         if (name == "Flytype") {
           var data = pop(xmlStack);
           wp.fly_type = data;
         }
         if (name == "Type") {
           var data = pop(xmlStack);
           if (data == "Normal" and string.match(wp.wp_name, "OM[0-9]*")) {
             wp.wp_type = "Outer Marker";
           } else {
             if (data == "Normal" and string.match(wp.wp_name, "MM[0-9]*")) {
               wp.wp_type = "Middle Marker";
             } else {
               if (data == "Normal" and string.match(wp.wp_name, "FF[0-9]*")) {
                 wp.wp_type = "Final Fix";
               } else {
                 wp.wp_type = data;
               }
             }
           }
         }
         if (name == "Sid_Transition" or name == "Star_Transition") {
           ##print("-- end Sid transition to TP: "~trans.trans_name);
           append(tp.transitions, trans);
           
         }
         if (name == "SidTr_Waypoint" or name == "StarTr_Waypoint") {
         ##print("--- end Sid transition waypoint for: "~trans.trans_name);
          ##var wp = pop(xmlStack);
          append(trans.trans_wpts, wp);
        }
        if (name == "RwyTr_Waypoint") {
          ##print("--- end Rwy Transition WP for: "~trans.trans_name);
          append(trans.trans_wpts, wp);
        }
        if (name == "RunwayTransition") {
          ##print("-- end Rwy Transition for sid: "~tp.wp_name);
          append(tp.transitions, trans);
        }
     }


     ########### DATA ############
      var data = func(data) {
        if (data != nil) {
          data = string.trim(data);
          if (size(data) > 0) {
            append(xmlStack, data);
          }
        }
      }

     ############ constructor ####################
			root = getprop("/sim/fg-aircraft");
			fn = call(func parsexml(root~"/TerraSync/Airports/"~left(icao,1)~"/"~substr(icao,1,1)~"/"~substr(icao,2,1)~ "/"~icao~".procedures.xml", start, end, data),nil,var err = []);


      if (size(err)) {
#         print("[FMS] failed to find SID/STAR database file for: "~icao);
#         foreach(var e; err) {
#           print("[FMS] error: "~e);
#        }
         return nil;  # return nil to the caller, to indicate error.
      }
      return me;
    },

    ##################################
    # getSIDList
    #
    getSIDList : func(runway) {
      var sidList = [];
      foreach(var s; me.wptps) {
        if (s.tp_type == "sid") {
          foreach(var r; s.runways) {
            if (r == runway or r == "All") {
              append(sidList, s);
            }
          }
        }
      }
			return sidList;
    },

    #################################
    # getSTARList
    #
    getSTARList : func(runway) {
      var starList = [];
      foreach(var s; me.wptps) {
        if (s.tp_type == "star") {
          foreach(var r; s.runways) {
            if (r == runway or r == "All") {
							#print(s.wp_name);
              append(starList, s);
            }
          }
        }
      }
			return starList;
    },

    #################################
    # getAllSTARList
    #
    getAllSTARList : func {
      var starList = [];
      foreach(var s; me.wptps) {
        if (s.tp_type == "star") {
							#print(s.wp_name);
              append(starList, s);
        }
      }
			return starList;
    },


    ##############################
    # getApproachList
    #
    getApproachList : func(runway) {
      var appList = [];
      foreach(var s; me.wptps) {
        if (s.tp_type == "Approach") {
          foreach(var r; s.runways) {
						##print("r = "~r);
            if (r == runway or r == "All") {
              append(appList, s);
            }
          }
        }
      }
			return appList;
    },

    #################################
    # getAllApproachList
    #
    getAllApproachList : func {
      var appList = [];
      foreach(var s; me.wptps) {
        if (s.tp_type == "Approach") {
							#print(s.wp_name);
              append(appList, s);
        }
      }
			return appList;
    },



    ##############################
    #  getSid
    #
    getSid : func(name) {
     foreach(var s; me.wptps) {
        if (s.tp_type == "sid" and s.wp_name == name) {
        #print("[SID] wp_name: "~s.wp_name~", type: "~s.tp_type~", ");
         return s;
        }
      }
    },

    ##############################
    #  getSidWpt
    #
    getSidWpt : func(SidName) {
			var wptList = [];
     	foreach(var s; me.wptps) {
        if (s.tp_type == "sid" and s.wp_name == SidName) {
					foreach(var r;s.wpts) {
						##print("wp : "~r.wp_name~" -- "~ r.alt_cstr~" - "~r.alt_res);
#						if (r.alt_res == "ABOVE") {
#							var alt_calc = math.ceil((r.alt_res/100)*100);
#							r.alt_res = alt_calc;
#						}					
#						if (r.alt_res == "BELOW") {
#							var alt_calc = math.floor((r.alt_res/100)*100);
#							r.alt_res = alt_calc;
#						}					
						append(wptList,r);
					}
        }
      }
			return wptList;
    },


    ###############################
    #  getStar
    #
    getStar : func(name) {
      foreach(var s; me.wptps) {
        if (s.tp_type == "star" and s.wp_name == name) {
         return s;
        }
      }
    },

    #############################
    # getApproach
    #
    getIAP : func(name) {
      foreach(var s; me.wptps) {
        if (s.tp_type == "Approach" and s.wp_name == name) {
         return s;
        }
      }
    },
    ###############################
    #  getRunway
    #
    getRunway : func(name) {
      foreach(var s; me.wptps) {
        if (s.wp_name == name) {
         return s.tp_runway;
        }
      }
    },

}
