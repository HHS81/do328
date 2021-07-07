### Canvas CDU ###
### C. Le Moigne (clm76) - 2017 ###
setprop("controls/lighting/cdu",0.8);

var altDestApt = "autopilot/route-manager/alternate/airport";
var altDestRwy = "autopilot/route-manager/alternate/runway";
var altFlag = "autopilot/route-manager/alternate/set-flag";
var altClosed = "autopilot/route-manager/alternate/closed";
var cduInput = "instrumentation/cdu/input";
var currWp = "autopilot/route-manager/current-wp";
var dep_apt = "autopilot/route-manager/departure/airport";
var dep_rwy = "autopilot/route-manager/departure/runway";
var dest_apt = "autopilot/route-manager/destination/airport";
var dest_rwy = "autopilot/route-manager/destination/runway";	
var direct = "instrumentation/cdu/direct";
var direct_to = "instrumentation/cdu/direct-to";
var display = "instrumentation/cdu/display";
var fp_active = "autopilot/route-manager/active";
var fp_saved = "autopilot/route-manager/flight-plan";
var lighting = "controls/lighting/cdu";
var num = "autopilot/route-manager/route/num";
var nbPage = "instrumentation/cdu/nbpage";
var pos_init = "instrumentation/cdu/pos-init";
var posit = "instrumentation/irs/positionned";
var spd = "instrumentation/cdu/speed";

var destApt = nil;
var dist = nil;
var g_speed = nil;
var FuelEstWp = nil;
var FuelEstDest = nil;
var Est_time = nil;
var ETA = nil;
var ETE = nil;
var fp_size = nil;
var my_lat = nil;
var my_lon = nil;
var n = nil;
var navSel = nil;
var navWp = nil;
var navRwy = nil;
var Nav_type = nil;
var Nav1_id = nil;
var Nav1_freq = nil;
var Nav2_id = nil;
var Nav2_freq = nil;
var p = nil;
var xfile = nil;

var cduDsp = {
	new: func () {
		var m = {parents:[cduDsp]};
		m.canvas = canvas.new({
			"name": "CDU-L", 
			"size": [1024, 1024],
			"view": [1024, 750],
			"mipmapping": 1 
		});
		m.canvas.addPlacement({"node": "CDU-screen"});
		m.group = m.canvas.createGroup();
		var font_mapper = func(family, weight)
		{
			return "BoeingCDU-Fixed.ttf";
		};
		canvas.parsesvg(m.group, "Aircraft/do328/Models/Instruments/CDU/CDU.svg", {'font-mapper': font_mapper});
		m.line = {};
		m.line_val = ["title","l1","l2","l2r","l3","l4","l4r","l5","l6","l7",
                  "r1","r2l","r2r","r3","r4l","r4r",
                  "r5","r6l","r6r","r7","scrpad"];
		foreach(var i;m.line_val) {
			m.line[i] = m.group.getElementById(i);
		}    
    m.arrow = m.group.createChild("path")
      .moveTo(520,275)
      .horiz(-100)
      .line(40,15)
      .line(-20,-15)
      .moveTo(420,275)
      .line(40,-15)
      .line(-20,15)
      .setStrokeLineWidth(8)
      .setStrokeLineJoin("round");
   
    m.curr_wp = nil;

    return m;

  }, # end of new

  Listen : func {
		setlistener(display, func(n) {
      if (n.getValue() == "PRG-PAGE[1]") {
        if (!me.timer.isRunning) {me.timer.start()}
      }else {me.timer.stop()}
      me.Display();
		},0,1);

    setlistener(cduInput, func(n) {  ### Scratchpad
      me.line.scrpad.setText(n.getValue());
    },0,1);

    setlistener(lighting,func { ### Luminosity
      me.Base_colors();
      me.Display()
      },0,0);

		setlistener(pos_init,func(n) {
      if (n.getValue()) {me.line.scrpad.setText("* POSITIONNING *")}
    },0,0);

		setlistener(posit, func(n) {
      if (n.getValue()) {
        me.line.scrpad.setText("");
        me.Pos_init2();
      }
    },0,0);

    setlistener(num, func(n) {
      if (n.getValue() > 1 and left(getprop(display),8) == "FLT-PLAN") {
        me.Flp1();
      }
    },0,0);

    setlistener(dep_apt, func {
      me.Flp0();
    },0,0);

    setlistener(fp_saved, func {
      me.Flp1();
    },0,0);

    setlistener(fp_active, func {
      me.Flp1();
    },0,0);

    setlistener(spd, func(n) {
      setprop("instrumentation/cdu/speed",n.getValue());
      me.Flp1();
    },0,1);

    setlistener(currWp, func(n) {
      if (left(getprop(display),3) == "POS" or left(getprop(display),3) == "FLT") {
				me.curr_wp = n.getValue();
          ### automatic page change during flight ###
        var page = int(me.curr_wp/3)+1;
        setprop(display,"FLT-PLAN["~page~"]");
        me.Flp1();
      }
    },0,1);

    setlistener(direct,func(n) {
      if (n.getValue() and left(getprop(display),8) == "FLT-PLAN" or left(getprop(display),8) == "ALT-PAGE") {
        me.line.l1.setText("---- DIRECT").setColor(me.amber);
      }
      else{
        me.line.l1.setText(" ORIGIN / ETD").setColor(me.white);
      }
    },0,0);

  }, # end of listen

  Display : func {
	  if (left(getprop(display),8) == "NAVIDENT") {me.Nav_ident()}
		if (left(getprop(display),8) == "POS-INIT") {
      getprop(posit) ? me.Pos_init2() : me.Pos_init1()}
		if (left(getprop(display),8) == "FLT-LIST") {me.Flp_list()}
		if (getprop(display) == "FLT-PLAN[0]") {me.Flp0()}
    else if(left(getprop(display),8) == "FLT-PLAN") {me.Flp1()}
		if (left(getprop(display),8) == "FLT-ARRV") {me.Arrv()}
		if (left(getprop(display),8) == "FLT-ARWY") {me.Arwy()}
		if (left(getprop(display),8) == "FLT-DEPT") {me.Dept()}
		if (left(getprop(display),8) == "FLT-SIDS") {me.Sid()}
		if (left(getprop(display),8) == "FLT-STAR") {me.Star()}
  	if (left(getprop(display),8) == "FLT-APPR") {me.Appr()}
    if (left(getprop(display),8) == "ALT-PAGE") {me.Alternate()}
  	if (left(getprop(display),8) == "PRF-PAGE") {me.Prf()}
  	if (left(getprop(display),8) == "NAV-PAGE") {me.Nav()}
  	if (left(getprop(display),8) == "NAV-LIST") {me.Nav_list()}
  	if (left(getprop(display),8) == "NAV-SELT") {me.Nav_sel()}
    if (left(getprop(display),8) == "NAV-ACTV") {me.Nav_activ()}
    if (left(getprop(display),8) == "PRG-PAGE") {me.Progress()}

  },
    
  Nav_ident : func {
	  var my_day = getprop("sim/time/real/day");
	  var my_month = getprop("sim/time/real/month");
	  var my_year = getprop("sim/time/real/year");
    var date = sprintf("%.2i-%.2i-%i", my_day, my_month, my_year);
	  var my_hour = getprop("sim/time/real/hour");
	  var my_minute = getprop("sim/time/real/minute");
    var time = sprintf("%.2i:%.2i", my_hour, my_minute);
    me.Raz_lines();
    me.line.title.setText("NAV IDENT  1/1");
    me.line.l1.setText("DATE");
    me.line.l2.setText(date);
    me.line.l3.setText("TIME");
    me.line.l4.setText(time);
    me.line.l5.setText("SW");
    me.line.l6.setText("NZ5.4");
    me.line.l7.setText("< MAINTENANCE");
    me.line.r1.setText("ACTIVE NDB").setColor(me.white);
    me.line.r2r.setText("01 JAN - 31 DEC").setColor(me.green);
    me.line.r3.setText("");
    me.line.r4r.setText("01 JAN - 31 DEC").setColor(me.green);
    me.line.r5.setText("NDB V4.00").setColor(me.white);
    me.line.r6r.setText("WORLD 2-01").setColor(me.green);
    me.line.r7.setText("POS INIT >");
  }, # end of Nav_ident

  Pos_init1 : func {
    me.Raz_lines();
    me.line.title.setText("POSITION INIT    1/2");
    me.line.l1.setText("LAST POS");
    me.line.l3.setText("REF WPT");
    me.line.l5.setText("GPS 1 POS");
    me.line.r2r.setText("LOAD").setColor(me.green);
    me.line.r3.setText("");
    me.line.r4r.setText("LOAD").setColor(me.green);
    me.line.r6r.setText("LOAD").setColor(me.green);
  }, # end of Pos_init1

  Pos_init2 : func {
	  my_lat = getprop("position/latitude-string");
	  my_lon = getprop("position/longitude-string");	
	  if (size(my_lat)==11) {
	    my_lat = right(my_lat,1)~left(my_lat,7);
	  }	else {
  	  my_lat = right(my_lat,1)~left(my_lat,8);
	  }
	  if (size(my_lon)==11) {
  	  my_lon = right(my_lon,1)~left(my_lon,7);
	  }	else {
  	  my_lon = right(my_lon,1)~left(my_lon,8);
	  }
    me.line.title.setText("POSITION INIT    2/2");
    me.line.l2.setText(my_lat~"  "~my_lon);
    me.line.l3.setText(getprop(dep_apt)~"-"~getprop(dep_rwy)~"   REF WPT");
    me.line.l4.setText("---*--.-  ---*--.-");
    me.line.l5.setText("GPS 1 POS");
    me.line.l6.setText(my_lat~"  "~my_lon);
    me.line.r1.setText("(LOADED)").setColor(me.white);
    me.line.r2r.setText("");
    me.line.r3.setText("(LOADED)").setColor(me.white);
    me.line.r4r.setText("");
    me.line.r5.setText("(LOADED)").setColor(me.white);
    me.line.r6r.setText("");
    me.line.r7.setText("FLT PLAN >");
  }, # end of Pos_init2

  Flp0 : func {
    me.Raz_lines();
    me.line.title.setText("ACTIVE FLT PLAN 1/1");
    me.line.l1.setText("ORIGIN / ETD");
    me.apt = getprop(dep_apt) != "" ? getprop(dep_apt) : "----";
    me.rwy = getprop(dep_rwy) != "" ? "-"~getprop(dep_rwy) : "";
    me.line.l2.setText(me.apt~me.rwy);    
    me.line.l3.setText("< LOAD FPL");
    me.line.l7.setText("< FPL LIST");
    me.line.r3.setText("DEST").setColor(me.white);
    me.line.r4r.setText("----").setColor(me.green);
    me.line.r7.setText("PERF INIT >");
  }, # end of Flp0
   
  Flp_list : func {
	  var path = getprop("/sim/fg-home")~"/aircraft-data/FlightPlans/";
    var airport = getprop("autopilot/route-manager/departure/airport");
	  var files = subvec(directory(path),2);
    xfile  = [];      
	  p = 0;
	  forindex(var ind;files) {		
		  if (left(files[ind],4) == airport) {
        append(xfile,(left(files[ind],size(files[ind])-4)));
      }
    }
	  cdu.cduMain.nb_pages(size(xfile),6);				
    me.nrPage = size(getprop(display))<12 ? substr(getprop(display),9,1) : substr(getprop(display),9,2); 
	  if (size(xfile) == 0) {
		  setprop("instrumentation/cdu/input","*NO FILE*");		
		  displayPage = 0;
	  }
    me.Raz_lines();
	  me.line.title.setText("FLIGHT PLAN LIST  "~me.nrPage~" / "~getprop(nbPage));			
    me.line.l7.setText("< FLT PLAN");
    me.Dsp_files(xfile);

  }, # end of Flp_list
  
  Flp_main : func {
    me.nrPage = size(getprop(display)) < 12 ? substr(getprop(display),9,1) : substr(getprop(display),9,2);
    if (me.nrPage > getprop(nbPage)) {me.nrPage = getprop(nbPage)}
#    me.fp = flightplan();
    fp_size = me.fp.getPlanSize();
    p = 0;
	  for(var i=0;i<fp_size;i+=1) {		
			  n = p-(3*(me.nrPage-1));	
			  if(n==0) {
          me.line.l1.setText(sprintf(" %3i    %.1f",me.fp.getWP(i).leg_bearing,me.fp.getWP(i).leg_distance));
          if (left(me.fp.getWP(i).wp_name,4) != me.dest_apt or me.fp_closed) {
            me.line.l2.setText(me.fp.getWP(i).wp_name);
          }   
          me.line.r2l.setText(me.fp.getWP(i).speed_cstr ? sprintf("%i",me.fp.getWP(i).speed_cstr)~" /" : "--- /");
          if (me.fp.getWP(i).alt_cstr > 0 and me.fp.getWP(i).alt_cstr < 10000) {
            me.line.r2r.setText(sprintf("%i",me.fp.getWP(i).alt_cstr));
          } else if (me.fp.getWP(i).alt_cstr >= 10000){
            me.line.r2r.setText(sprintf("FL%i",me.fp.getWP(i).alt_cstr/100));
          } else if (i == fp_size-1 and me.fp_closed) {
             me.line.r2l.setText("");me.line.r2r.setText("");
             me.line.r4l.setText("");me.line.r4r.setText("");
             me.line.r6l.setText("");me.line.r6r.setText("");
          } else {me.line.r2r.setText("-----")}
          me.Arrow(n,i);
        }

			  if(n==1) {
          me.line.l3.setText(sprintf(" %3i    %.1f",me.fp.getWP(i).leg_bearing,me.fp.getWP(i).leg_distance));
          if (left(me.fp.getWP(i).wp_name,4) != me.dest_apt or me.fp_closed) {
            me.line.l4.setText(me.fp.getWP(i).wp_name);
          }   
          me.line.r4l.setText(me.fp.getWP(i).speed_cstr ? sprintf("%i",me.fp.getWP(i).speed_cstr)~" /" : "--- /");
          if (me.fp.getWP(i).alt_cstr > 0 and me.fp.getWP(i).alt_cstr < 10000) {
            me.line.r4r.setText(sprintf("%i",me.fp.getWP(i).alt_cstr));
          } else if (me.fp.getWP(i).alt_cstr >= 10000){
            me.line.r4r.setText(sprintf("FL%i",me.fp.getWP(i).alt_cstr/100));
          } else if (i == fp_size-1 and me.fp_closed) {
             me.line.r4l.setText("");me.line.r4r.setText("");
             me.line.r6l.setText("");me.line.r6r.setText("");
          } else {me.line.r4r.setText("-----")}
          me.Arrow(n,i);
       }

			  if(n==2) {
          me.line.l5.setText(sprintf(" %3i    %.1f",me.fp.getWP(i).leg_bearing,me.fp.getWP(i).leg_distance));
          if (left(me.fp.getWP(i).wp_name,4) != me.dest_apt or me.fp_closed) {
            me.line.l6.setText(me.fp.getWP(i).wp_name);
            setprop("instrumentation/cdu/l6",me.fp.getWP(i).wp_name);
          }
          me.line.r5.setText("");
          me.line.r6l.setText(me.fp.getWP(i).speed_cstr ? sprintf("%i",me.fp.getWP(i).speed_cstr)~" /" : "--- /");
          me.line.r6r.setColor(me.blue);
          if (me.fp.getWP(i).alt_cstr > 0 and me.fp.getWP(i).alt_cstr < 10000) {
            me.line.r6r.setText(sprintf("%i",me.fp.getWP(i).alt_cstr));
          } else if (me.fp.getWP(i).alt_cstr >= 10000){
            me.line.r6r.setText(sprintf("FL%i",me.fp.getWP(i).alt_cstr/100));
          } else if (i == fp_size-1 and me.fp_closed) {
             me.line.r6l.setText("");me.line.r6r.setText("");
          } else {me.line.r6r.setText("-----")}
          me.Arrow(n,i);
        }
			  p+=1;
	  }
 
  }, ### end of Flp_main

  Flp1 : func {
    me.fp = flightplan();
    me.dest_apt = getprop(dest_apt);
    me.fp_closed = getprop(fp_active);
    me.Raz_lines();
		me.line.l1.setText("VIA TO");
		me.line.l2.setText("----");
		me.line.l3.setText("VIA TO");
		me.line.l4.setText("----");
		me.line.l5.setText("VIA TO");
		me.line.l6.setText("----");
		me.line.l7.setText("< DEPARTURE");
    me.line.r2l.setText("--- /");
    me.line.r2r.setText("-----");
    me.line.r4l.setText("--- /");
    me.line.r4r.setText("-----");
    me.line.r6l.setText("--- /");
    me.line.r6r.setText("-----");
		me.line.r7.setText("ARRIVAL >");

    me.Flp_main();
    me.line.title.setText("ACTIVE FLT PLAN  "~me.nrPage~" / "~getprop(nbPage));

    if (me.nrPage == 1) {
      me.line.l1.setText("ORIGIN / ETD");
      me.line.r1.setText("SPD  /  CMD ");me.line.r1.setColor(me.white);
      me.line.r2l.setText("");me.line.r2r.setText("");
    }
    if (me.nrPage <= getprop(nbPage)) {
       if (n != nil and n < 3 ) {
        me.line.r5.setText("DEST");me.line.r5.setColor(me.white);
        me.line.r6l.setText("");
        me.line.r6r.setText(getprop(dest_apt)~" "~getprop(dest_rwy))
                   .setColor(me.green);
        setprop("instrumentation/cdu/r5","DEST");
        setprop("instrumentation/cdu/r6",getprop(dest_apt));
      }
    }
    if (me.nrPage == getprop(nbPage) and getprop(fp_active)) {
      me.Raz_lines();
      me.line.title.setText("ACTIVE FLT PLAN  "~me.nrPage~" / "~getprop(nbPage));
      me.line.l4.setText("      SAVE FLP TO").setColor(me.amber);
      me.line.l7.setText("< PERF INIT");
      if (getprop(fp_saved)) {
		    me.line.l4.setText("        SAVED").setColor(me.amber);
        me.line.r4r.setText(getprop(fp_saved)~"  ");
      } else {me.line.r4r.setText(getprop(dep_apt)~"-"~getprop(dest_apt)~"--")}
      me.line.r4r.setColor(me.green);
			if (getprop(fp_active)) {
				me.line.r7.setText("ALTERNATE >");
			} else {me.line.r7.setText("")}
    }
  }, # end of Flp1

  Dept : func {
		var dep_rwy = airportinfo(getprop(dep_apt)).runways;
	  cdu.cduMain.nb_pages(size(dep_rwy),6);				
    me.nrPage = size(getprop(display))<12 ? substr(getprop(display),9,1) : substr(getprop(display),9,2); 
	  if (size(dep_rwy) == 0) {setprop("instrumentation/cdu/input","*NO FILE*")}
    me.Raz_lines();
	  me.line.title.setText(getprop(dep_apt)~" RUNWAYS "~me.nrPage~" / "~getprop(nbPage));			
    me.line.l7.setText("< SIDs");
    xfile = [];
	  foreach(var ind;keys(dep_rwy)) {append(xfile,ind)} # transfer hash->vector
    me.Dsp_files(xfile);
  }, # end of Dept

  Sid : func {
		var depArpt = procedures.fmsDB.new(getprop(dep_apt));
		xfile = [];
		append(xfile,"DEFAULT");
		if (depArpt !=nil) {
		  if (getprop(dep_rwy) != "") {		
			  var Sidlist = depArpt.getSIDList(getprop(dep_rwy));
		  } else {
				  var Sidlist = depArpt.getAllSIDList();
		  }		
  		foreach(var sid; Sidlist) {append(xfile, sid.wp_name)}
    }
	  if (size(xfile) == 0) {setprop("instrumentation/cdu/input","*NO FILE*")}
    me.Raz_lines();
	  cdu.cduMain.nb_pages(size(xfile),6);				
    me.nrPage = size(getprop(display))<12 ? substr(getprop(display),9,1) : substr(getprop(display),9,2); 
    me.line.title.setText(getprop(dep_apt)~" SID "~(me.nrPage)~" / "~getprop(nbPage));
    me.line.l7.setText("< FLT PLAN");
    me.Dsp_files(xfile);
  }, # end of Sid

  Arrv : func {
    me.Raz_lines();
    me.line.title.setText("ARRIVAL     1 / 1");
	  me.line.l1.setText("< RUNWAY");
	  me.line.l3.setText("< STAR");
	  me.line.l5.setText("< APPROACH");
	  me.line.l7.setText("< FLT-PLAN");
	  me.line.r1.setText("AIRPORT ");me.line.r1.setColor(me.white);
	  me.line.r2r.setText(getprop(dest_apt));me.line.r2r.setColor(me.green);
  }, # end of Arrv

  Arwy : func {
    me.Raz_lines();
    if (getprop(altFlag)) {
		  var apt_rwy = airportinfo(getprop(altDestApt)).runways;
      me.line.l7.setText("< ALTERNATE FPL");
      destApt = getprop(altDestApt);      
    } else {
      var apt_rwy = airportinfo(getprop(dest_apt)).runways;
      destApt = getprop(dest_apt);      
      me.line.l7.setText("< ARRIVAL");
    }
	  cdu.cduMain.nb_pages(size(apt_rwy),6);				
    me.nrPage = size(getprop(display))<12 ? substr(getprop(display),9,1) : substr(getprop(display),9,2); 
	  if (size(apt_rwy) == 0) {setprop("instrumentation/cdu/input","*NO FILE*")}
	  me.line.title.setText(destApt~" RUNWAYS "~me.nrPage~" / "~getprop(nbPage));			
    xfile = [];
	  foreach(var ind;keys(apt_rwy)) {append(xfile,ind)} # transfer hash->vector
    me.Dsp_files(xfile);
  }, # end of Arwy

  Star : func {
		xfile = [];
		var DestARPT = procedures.fmsDB.new(getprop(dest_apt));
		if (DestARPT !=nil) {
			if (getprop(dest_rwy) != "") {		
				var Starlist = DestARPT.getSTARList(getprop(dest_rwy));
			} else {
					var Starlist = DestARPT.getAllSTARList();
			}		
			foreach(var star; Starlist) {append(xfile, star.wp_name)}
		}
	  if (size(xfile) == 0) {setprop("instrumentation/cdu/input","*NO FILE*")}
    me.Raz_lines();
	  cdu.cduMain.nb_pages(size(xfile),6);				
    me.nrPage = size(getprop(display))<12 ? substr(getprop(display),9,1) : substr(getprop(display),9,2); 
    me.line.title.setText(getprop(dest_apt)~" STAR "~(me.nrPage)~" / "~getprop(nbPage));
    me.line.l7.setText("< ARRIVAL");
    me.line.r7.setText("RUNWAY >");
    me.Dsp_files(xfile);
  }, # end of Star

  Appr : func {
		var DestARPT = procedures.fmsDB.new(getprop(dest_apt));
		xfile = [];
    append(xfile,"DEFAULT");
		if (DestARPT !=nil) {
			if (getprop(dest_rwy) != "") {		
				var Apprlist = DestARPT.getApproachList(getprop(dest_rwy));
			} else {
					var Apprlist = DestARPT.getAllApproachList();
			}		
			foreach(var appr; Apprlist) {append(xfile, appr.wp_name)}
		}
	  if (size(xfile) == 0) {setprop("instrumentation/cdu/input","*NO FILE*")}
    me.Raz_lines();
	  cdu.cduMain.nb_pages(size(xfile),6);				
    me.nrPage = size(getprop(display))<12 ? substr(getprop(display),9,1) : substr(getprop(display),9,2); 
    me.line.title.setText(getprop(dest_apt)~" APPROACH "~me.nrPage~" / "~getprop(nbPage));
    me.line.l7.setText("< ARRIVAL");
    me.line.r7.setText("RUNWAY >");
    me.Dsp_files(xfile);
  }, # end of Appr

  ### Alternate Flightplan ###
  Alternate : func {
    me.nrPage = size(getprop(display)) < 12 ? substr(getprop(display),9,1) : substr(getprop(display),9,2);

    if (me.nrPage > getprop(nbPage)) {me.nrPage = getprop(nbPage)}
    me.dest_apt = getprop(altDestApt);
    me.fp_closed = getprop(altClosed);

    if (me.nrPage == 0) {
      me.Raz_lines();
      me.line.title.setText("ALTERNATE FPL 1 / 1");
      me.line.l1.setText("ORIGIN");
      me.line.l2.setText(getprop(dep_apt)~"-"~getprop(dep_rwy));
		  me.line.r3.setText("ALTN ").setColor(me.white);
      if (getprop(altDestApt)) {
    	  me.line.r4r.setText(getprop(altDestApt))
               .setColor(me.green);    
        me.line.r7.setText("RUNWAY >");
      } else {me.line.r4r.setText("----").setColor(me.green)}
      if (getprop(altDestRwy)) {
        me.line.l3.setText("VIA TO");
    		me.line.l4.setText("----");
    		me.line.r3.setText("");
    		me.line.r4r.setText("");
  		  me.line.r5.setText("ALTN ").setColor(me.white);
    	  me.line.r6r.setText(getprop(altDestApt)~"-"~getprop(altDestRwy))
               .setColor(me.green);    
        me.line.r7.setText("");
      }
    } else {
        me.Raz_lines();
		    me.line.l1.setText("VIA TO");
		    me.line.l2.setText("----");
        me.line.l3.setText("VIA TO");
	      me.line.l4.setText("----");
        me.line.l5.setText("VIA TO");
        me.line.l6.setText("----");
        me.line.r2l.setText("--- /");
        me.line.r2r.setText("-----");
        me.line.r4l.setText("--- /");
        me.line.r4r.setText("-----");
        me.line.r6l.setText("--- /");
        me.line.r6r.setText("-----");

        me.fp = cdu.cduMain.alt_flp();
        me.Flp_main();
        me.line.title.setText("ALTERNATE FPL "~me.nrPage~" / "~getprop(nbPage));
      if (me.nrPage == 1) {
        me.line.l1.setText("ORIGIN / ETD");
        me.line.l2.setText(getprop(dep_apt)~"-"~getprop(dep_rwy));
        me.line.r1.setText("SPD  /  CMD ");me.line.r1.setColor(me.white);
        me.line.r2l.setText("");me.line.r2r.setText("");
      }
      if (me.nrPage <= getprop(nbPage)) {
         if (n != nil and n < 3 ) {
          me.line.r5.setText("ALTN");me.line.r5.setColor(me.white);
          me.line.r6l.setText("");
          me.line.r6r.setText(getprop(altDestApt)~"-"~getprop(altDestRwy))
                     .setColor(me.green);
        }
        if (n == 3) {me.line.r7.setText("NEXT PAGE >")}
        me.line.l7.setText("< FLT PLAN");
      }
    }
  },

  ### Performances Pages ###
  Prf : func {
    me.nrPage = substr(getprop(display),9,1);
    if (me.nrPage > getprop(nbPage)) {me.nrPage = getprop(nbPage)}
    if (me.nrPage == 1) {
      me.Raz_lines();
      me.line.title.setText("PERFORMANCE INIT "~me.nrPage~" / "~getprop(nbPage));
		  me.line.l3.setText("  ACFT TYPE");
		  me.line.l4.setText(string.uc(getprop("sim/description")));
		  me.line.l7.setText("< FLT PLAN");
      me.line.r3.setText("TAIL #").setColor(me.white);
      me.line.r4r.setText(string.uc(getprop("sim/multiplay/callsign")))
                 .setColor(me.green);
		  me.line.r7.setText("NEXT PAGE >");
    }
    if (me.nrPage == 2) {
		  var ClimbSpeed_kt = sprintf("%.0f",getprop("autopilot/settings/climb-speed-kt"));
		  var ClimbSpeed_mc = sprintf("%.2f",getprop("autopilot/settings/climb-speed-mc"));
		  var DescSpeed_kt = getprop("autopilot/settings/descent-speed-kt");
		  var DescSpeed_mc = sprintf("%.2f",getprop("autopilot/settings/descent-speed-mc"));
		  var DescAngle = sprintf("%.1f",getprop("autopilot/settings/descent-angle"));
		  var CruiseSpeed_kt = getprop("autopilot/settings/cruise-speed-kt");
		  var CruiseSpeed_mc = sprintf("%.2f",getprop("autopilot/settings/cruise-speed-mc"));
		  var Cruise_alt = getprop("autopilot/settings/target-altitude-ft");
      me.Raz_lines();
      me.line.title.setText("PERFORMANCE INIT "~me.nrPage~" / "~getprop(nbPage));
      me.line.l1.setText(" CLIMB");
      me.line.l2.setText(ClimbSpeed_kt~" / "~ClimbSpeed_mc);
      me.line.l3.setText(" CRUISE");
      me.line.l4.setText(CruiseSpeed_kt~" / "~CruiseSpeed_mc);
      me.line.l5.setText(" DESCENT");
      me.line.l6.setText(DescSpeed_kt~" / "~DescSpeed_mc~" / "~DescAngle);
			me.line.l7.setText("< DEP/APP SPD");
			me.line.r3.setText("<------>  ALTITUDE").setColor(me.white);
			me.line.r4r.setText("FL "~Cruise_alt).setColor(me.green);
    }
    if (me.nrPage == 3) {
		  var dep_spd = sprintf("%i",getprop("autopilot/settings/dep-speed-kt"));
		  var Agl = sprintf("%i",getprop("autopilot/settings/dep-agl-limit-ft"));
		  var Nm = sprintf("%.1f",getprop("autopilot/settings/dep-limit-nm"));
      me.Raz_lines();
      me.line.title.setText("DEPARTURE SPEED 1 / 1");
      me.line.l1.setText(" SPEED LIMIT");
      me.line.l2.setText(dep_spd);
      me.line.l3.setText(" AGL  <------LIMIT ------> NM");
      me.line.l4.setText(Agl);
			me.line.l7.setText("< APP SPD");
			me.line.r4r.setText(Nm).setColor(me.green);
		  me.line.r7.setText("RETURN >");
    }
    if (me.nrPage == 4) {
		  var AppSpeed5 = sprintf("%i",getprop("autopilot/settings/app5-speed-kt"));
		  var AppSpeed15 = sprintf("%i",getprop("autopilot/settings/app15-speed-kt"));
		  var AppSpeed35 = sprintf("%i",getprop("autopilot/settings/app35-speed-kt"));
      me.Raz_lines();
      me.line.title.setText("APPROACH SPEED 1 / 1");
      me.line.l1.setText(" FLAPS 12");
      me.line.l2.setText(AppSpeed5);
      me.line.l3.setText(" FLAPS 20");
      me.line.l4.setText(AppSpeed15);
      me.line.l5.setText(" FLAPS 32");
      me.line.l6.setText(AppSpeed35);
			me.line.l7.setText("< NEXT PAGE");
		  me.line.r7.setText("RETURN >");
    }
    if (me.nrPage == 5) {
		  var Wfuel = sprintf("%3i", math.ceil(getprop("consumables/fuel/total-fuel-lbs")));
		  var Wcrew = getprop("sim/weight[0]/weight-lb");
		  var Wpass = getprop("sim/weight[1]/weight-lb");
		  var Wcarg = getprop("sim/weight[2]/weight-lb");
      me.Raz_lines();
      me.line.title.setText("PERFORMANCE INIT "~me.nrPage~" / "~getprop(nbPage));
      me.line.l1.setText(" BOW");
      me.line.l2.setText("21700");
      me.line.l3.setText(" FUEL");
      me.line.l4.setText(Wfuel);
      me.line.l5.setText(" CARGO");
      me.line.l6.setText(Wcarg);
      me.line.r1.setText("PASS/CREW LBS  ").setColor(me.white);
      me.line.r2r.setText(" "~int(Wpass/170)~" / 2  "~" 170  ")
                 .setColor(me.green);
      me.line.r3.setText("PASS WT  ").setColor(me.white);
      me.line.r4r.setText(sprintf("%3i",Wpass + Wcrew)~"  ").setColor(me.green);
      me.line.r5.setText("GROSS WT  ").setColor(me.white);
      me.line.r6r.setText(sprintf("%3i",21700 + Wfuel + Wcrew + Wpass + Wcarg)~"  ")
                 .setColor(me.green);
		  me.line.r7.setText("RETURN >");
    }
  }, # end of Prf

  ##### Nav Pages #####
  Nav : func {
    me.nrPage = substr(getprop(display),9,1);
    if (me.nrPage > getprop(nbPage)) {me.nrPage = getprop(nbPage)}
    if (me.nrPage == 1) {
      me.Raz_lines();
      me.line.title.setText("NAV INDEX "~me.nrPage~" / "~getprop(nbPage));
		  me.line.l1.setText("< FPL LIST");
    }
  }, #end of Nav

  Nav_list : func {
    me.Flp_list();
    me.line.l7.setText("");
	  me.line.r7.setText("FPL SEL >");
  }, # end of Nav_list

  Nav_sel : func {
    me.nrPage = substr(getprop(display),9,1);
    cdu_ret = cdu.cduMain.nav_var();
    navSel = cdu_ret[0];
    if (me.nrPage == 1 ) {
      me.Raz_lines();
	    var flp_sel = getprop("instrumentation/cdu/input");
      me.line.title.setText("FLT PLAN LIST 1 / 1");
		  me.line.l1.setText("< SHOW FPL");
		  me.line.l2.setText(navSel);
		  me.line.r1.setText("ORG / DEST ").setColor(me.white);
      if (flp_sel) {
        me.line.r2r.setText(left(flp_sel,4)~" / "~substr(flp_sel,5,4)).setColor(me.green);
      }
		  me.line.r7.setText("FPL SEL >");
    }
    if (me.nrPage == 2 ) {
      cdu_ret = cdu.cduMain.nav_var();
      navWp = cdu_ret[1];
      navRwy = cdu_ret[2];
      dist = cdu_ret[3];
      g_speed = cdu_ret[4];
      me.Raz_lines();
	    var ete_h = int(dist/g_speed);
	    var ete_mn = int((dist/g_speed-ete_h)*60);
      var line4 = line5 = line6 = "";
      me.line.title.setText(navSel~" 1 / 1");
      me.line.l1.setText(" ORGIN");
      me.line.l2.setText(navWp.vector[0]~" "~navRwy.vector[0]);
      me.line.r1.setText("DIST / ETE    GS ").setColor(me.white);
      me.line.r2r.setText(sprintf("%.0f",dist)~" / "~sprintf("%02d",ete_h)~"+"~sprintf("%02d",ete_mn)~" @ "~g_speed).setColor(me.green);
      me.line.l3.setText(" VIA TO").setColor(me.white);
      me.line.r3.setText("DEST  ").setColor(me.white);;
			for (var i=1;i<size(navWp.vector)-1;i+=1) {
				if (i < 6) {line4 = line4 != "" ? line4~" "~navWp.vector[i] : navWp.vector[i]}
				else if (i<11) {line5 = line5 != "" ? line5~" "~navWp.vector[i] : navWp.vector[i]}
				else if (i<16) {line6 = line6 != "" ? line6~" "~navWp.vector[i] : navWp.vector[i]}
			}
			me.line.l4.setText(line4);
		  me.line.l5.setText(line5);me.line.l5.setColor(me.green);
		  me.line.l6.setText(line6);
      me.line.l7.setText("< FPL LIST");
      me.line.r4r.setText(navWp.vector[size(navWp.vector)-1]~" "~navRwy.vector[1]).setColor(me.green);
      me.line.r7.setText("FPL SEL >");
    }
    if (me.nrPage == 3 ) {
      me.Raz_lines();
      me.line.title.setText("FLT PLAN SELECT 1 / 1");
		  me.line.l1.setText(" FLT PLAN");
		  me.line.l2.setText(navSel);
      me.line.l7.setText("< FPL LIST");
      me.line.r2r.setText("ACTIVATE >").setColor(me.white);
      me.line.r4r.setText("INVERT/ACTIVATE >").setColor(me.white);
      me.line.r6r.setText("STORED FPL PERF >").setColor(me.white);
    }
  }, # end of Nav_sel

  Nav_activ : func {
    me.Raz_lines();
    me.line.title.setText("FLT PLAN SELECT 1 / 1");
    me.line.l4.setText("     CONFIRM  REPLACING").setColor(me.amber);
    me.line.l5.setText("     ACTIVE FLIGHT PLAN").setColor(me.amber);
    me.line.l7.setText("< NO");
    me.line.r7.setText("YES >");
  },

  ##### Prog Pages #####
  Progress : func {
    me.nrPage = substr(getprop(display),9,1);
    me.Raz_lines();
    if (me.nrPage == 1 ) {
      me.line.title.setText("PROGRESS     1 / 1");
      me.line.l1.setText(" TO     DIST");
      me.line.l3.setText("DEST");
      me.line.l7.setText("< NAV 1");
      me.line.r1.setText("ETE     FUEL ").setColor(me.white);
      me.line.r7.setText("NAV 2 >");
    } else {
        if (me.nrPage == 2) {me.line.title.setText("NAV 1")}
        if (me.nrPage == 3) {me.line.title.setText("NAV 2")}
        var navs = findNavaidsWithinRange(60,'ils');
        p = 0;
		    foreach(var ind;navs) {
			    if (ind != "") {		
		        if(p==0) {
              me.line.l1.setText(ind.name).setFontSize(44);
              me.line.l2.setText("< "~ind.id~" "~sprintf("%.2f",ind.frequency/100));
            }
		        if(p==1) {
              me.line.l3.setText(ind.name).setFontSize(44);
              me.line.l4.setText("< "~ind.id~" "~sprintf("%.2f",ind.frequency/100));
            }
		        if(p==2) {
              me.line.l5.setText(ind.name).setFontSize(44);
              me.line.l6.setText("< "~ind.id~" "~sprintf("%.2f",ind.frequency/100));
            }
		        if(p==3) {
              me.line.r1.setText(ind.name).setFontSize(44).setColor(me.white);
              me.line.r2r.setText(ind.id~" "~sprintf("%.2f",ind.frequency/100)~" >")
                         .setColor(me.green);
            }
		        if(p==4) {
              me.line.r3.setText(ind.name).setFontSize(44).setColor(me.white);
              me.line.r4r.setText(ind.id~" "~sprintf("%.2f",ind.frequency/100)~" >")
                         .setColor(me.green);
            }
		        if(p==5) {
              me.line.r5.setText(ind.name).setFontSize(44).setColor(me.white);
              me.line.r6r.setText(ind.id~" "~sprintf("%.2f",ind.frequency/100)~" >")
                         .setColor(me.green);
            }
            setprop("instrumentation/cdu/l"~(p+1),sprintf("%.2f",ind.frequency/100));
		        p+=1;
          }
	      }
      me.line.l7.setText("< PROGRESS");
    }
  }, # end of Progress

  Prog_timer : func {
		me.timer = maketimer(0.1,func() {
		if(getprop("/velocities/groundspeed-kt") > 30){
		  FuelEstWp = int((getprop("/autopilot/internal/nav-distance")/getprop("/velocities/groundspeed-kt"))*(getprop("/engines/engine[0]/fuel-flow_pph")+getprop("/engines/engine[1]/fuel-flow_pph")));
		  FuelEstDest = int((getprop("/autopilot/route-manager/distance-remaining-nm")/getprop("/velocities/groundspeed-kt"))*(getprop("/engines/engine[0]/fuel-flow_pph")+getprop("/engines/engine[1]/fuel-flow_pph")));
		}
		else {
		  FuelEstWp = 0;
		  FuelEstDest = 0;
		}

      nav_id = getprop("autopilot/internal/nav-id");
		  ETA = getprop("autopilot/route-manager/wp/eta");
		  if (!ETA) {ETA = "0+00"}
      else {
        me.vec_eta = split(":",ETA);
        me.h_eta = int(me.vec_eta[0]);
        me.mn_eta = me.vec_eta[1];
        ETA = me.h_eta~"+"~sprintf("%02i",me.mn_eta);
      } 
		  ETE = getprop("/autopilot/internal/nav-ttw");
		  if (!ETE or size(ETE) > 10) {ETE = "0+00"}
		  else {
        me.vec_ete = split(":",ETE);
        me.vec_ete = split("ETE ",me.vec_ete[0]);
        me.h_ete = int(me.vec_ete[1]/60);
        me.mn_ete = me.vec_ete[1]-me.h_ete*60;
        ETE = me.h_ete~"+"~sprintf("%02i",me.mn_ete);
      }
		  Nav_type = getprop("/autopilot/internal/nav-type");
		  Nav1_id = getprop("/instrumentation/nav/nav-id");
		  Nav1_freq = getprop("/instrumentation/nav/frequencies/selected-mhz-fmt");
		  Nav2_id = getprop("/instrumentation/nav[1]/nav-id");
		  Nav2_freq = getprop("/instrumentation/nav[1]/frequencies/selected-mhz-fmt");

		  me.line.l2.setText(nav_id);
      me.line.l2r.setText(sprintf("%3i",getprop("/autopilot/internal/nav-distance")));
      me.line.l4.setText(getprop(dest_apt));
      me.line.l4r.setText(sprintf("%3i",getprop("autopilot/route-manager/distance-remaining-nm")));
      me.line.l6.setText("   "~Nav1_id~" "~Nav1_freq);
      me.line.r2l.setText(ETA~"   ").setColor(me.green);
      me.line.r2r.setText(FuelEstWp~" ").setColor(me.green);
      me.line.r4l.setText(ETE~"   ").setColor(me.green);
      me.line.r4r.setText(FuelEstDest~" ").setColor(me.green);

		  if (Nav_type == "VOR1" or Nav_type == "FMS1") { 
			  me.line.l5.setText("     " ~Nav_type~" <---");
        me.line.r5.setText(left(Nav_type,3)~"2    ").setColor(me.white);
		  } else {
			  #me.line.l5.setText("     " ~left(Nav_type,3)~"1");
			  me.line.l5.setText("     " ~Nav_type~"1");
        me.line.r5.setText("---> "~Nav_type~"    ").setColor(me.white)}
      me.line.r6r.setText(Nav2_id~" "~Nav2_freq~" ").setColor(me.green);
    });
 }, # end of Prog_timer

  ###### Common Functions ######

  Dsp_files : func(xfile) {
    p = 0;
    for (i=1;i<7;i+=1) {setprop("instrumentation/cdu/l"~i,"")} # raz
		foreach(var file;xfile) {
			n = p-(6*(me.nrPage-1));		
	    if(n==0) {me.line.l2.setText(file)}
	    if(n==1) {me.line.l4.setText(file)}
	    if(n==2) {me.line.l6.setText(file)}
	    if(n==3) {me.line.r2r.setText(file).setColor(me.green)}
	    if(n==4) {me.line.r4r.setText(file).setColor(me.green)}
	    if(n==5) {me.line.r6r.setText(file).setColor(me.green)}
	    p+=1;
      if (n >= 0 and n < 6) {
        setprop("instrumentation/cdu/l"~(n+1),file)
      }
	  }
  }, # end of Dsp_files

  Raz_lines : func {
    foreach(var element;me.line_val) {
      me.line[element].setText("");
    }
    me.arrow.hide();
    me.Base_colors();
  }, # end of Raz_lines

  Base_colors : func {
    me.white = [1,1,1,getprop(lighting)];
    me.yellow = [1,1,0,getprop(lighting)];
    me.amber = [0.9,0.5,0,getprop(lighting)];
    me.green = [0,1,0,getprop(lighting)];
    me.blue = [0,0.8,1,getprop(lighting)];
    me.magenta = [0.9,0,0.9,getprop(lighting)];

    me.l_color = [me.white,me.white,me.green,me.green,    # title,l1,l2,l2r
                  me.white,me.green,me.green,me.white,    # l3,l4,l4r,l5
                  me.green,me.magenta,me.green,me.blue,   # l6,l7,r1,r2l  
                  me.blue,me.green,me.blue,me.blue,       # r2r,r3,r4l,r4r
                  me.green,me.blue,me.blue, me.magenta,   # r5,r6l,r6r,r7
                  me.yellow];                             # scrpad
    var ind = 0;
    foreach(var i;me.line_val) {    
      me.line[i].setColor(me.l_color[ind]);
      ind+=1;
    }
    me.arrow.setColor(me.green);
    me.arrow.setColorFill(me.green);
  }, # end of Base_colors

  Arrow : func(n,i) {
    if (left(getprop(display),8) == "FLT-PLAN") {
      if (i == me.curr_wp) {
        me.arrow.show();
        me.arrow.setTranslation(0,145*n);
        if (i == getprop(direct_to)) {
          if (n == 0) {me.line.l2.setColor(me.amber)}
          if (n == 1) {me.line.l4.setColor(me.amber)}
          if (n == 2) {me.line.l6.setColor(me.amber)}
          me.arrow.setColor(me.amber);
        }
      }
    }
    else {
      me.line.l2.setColor(me.green);
      me.line.l4.setColor(me.green);
      me.line.l6.setColor(me.green);
    }
  }, # end of Arrow

}; # end of cduDsp
  
##### Main #####
var cdu_Dsp = cduDsp.new();
var cdu_setl = setlistener("sim/signals/fdm-initialized", func {
  settimer(run_cdu_Dsp,2);
  removelistener(cdu_setl);
});

var run_cdu_Dsp = func {
  cdu_Dsp.Listen();
  cdu_Dsp.Nav_ident();
  cdu_Dsp.Prog_timer();
}
