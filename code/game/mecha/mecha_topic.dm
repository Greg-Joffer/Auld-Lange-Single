
////////////////////////////////////
///// Rendering stats window ///////
////////////////////////////////////

/obj/mecha/proc/get_stats_html()
	. = {"<html>
						<head>
						<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
						<title>[name] data</title>
						<style>
						body {color: #00ff00; background: #000000; font-family:"Lucida Console",monospace; font-size: 12px;}
						hr {border: 1px solid #0f0; color: #0f0; background-color: #0f0;}
						a {padding:2px 5px;;color:#0f0;}
						.wr {margin-bottom: 5px;}
						.header {cursor:pointer;}
						.open, .closed {background: #32CD32; color:#000; padding:1px 2px;}
						.links a {margin-bottom: 2px;padding-top:3px;}
						.visible {display: block;}
						.hidden {display: none;}
						</style>
						<script language='javascript' type='text/javascript'>
						[js_byjax]
						[js_dropdowns]
						function SSticker() {
							setInterval(function(){
								window.location='byond://?src=[REF(src)]&update_content=1';
							}, 1000);
						}

						window.onload = function() {
							dropdowns();
							SSticker();
						}
						</script>
						</head>
						<body>
						<div id='content'>
						[src.get_stats_part()]
						</div>
						<div id='eq_list'>
						[src.get_equipment_list()]
						</div>
						<hr>
						<div id='commands'>
						[src.get_commands()]
						</div>
						</body>
						</html>
					"}



/obj/mecha/proc/report_internal_damage()
	. = ""
	var/list/dam_reports = list(
		"[MECHA_INT_FIRE]" = span_userdanger("INTERNAL FIRE"),
		"[MECHA_INT_TEMP_CONTROL]" = span_userdanger("LIFE SUPPORT SYSTEM MALFUNCTION"),
		"[MECHA_INT_TANK_BREACH]" = span_userdanger("GAS TANK BREACH"),
		"[MECHA_INT_CONTROL_LOST]" = "<span class='userdanger'>COORDINATION SYSTEM CALIBRATION FAILURE</span> - <a href='byond://?src=[REF(src)];repair_int_control_lost=1'>Recalibrate</a>",
		"[MECHA_INT_SHORT_CIRCUIT]" = span_userdanger("SHORT CIRCUIT")
								)
	for(var/tflag in dam_reports)
		var/intdamflag = text2num(tflag)
		if(internal_damage & intdamflag)
			. += dam_reports[tflag]
			. += "<br />"
	if(return_pressure() > WARNING_HIGH_PRESSURE)
		. += "<span class='userdanger'>DANGEROUSLY HIGH CABIN PRESSURE</span><br />"



/obj/mecha/proc/get_stats_part()
	var/integrity = obj_integrity/max_integrity*100
	var/cell_charge = get_charge()
	var/datum/gas_mixture/int_tank_air = internal_tank.return_air()
	var/tank_pressure = internal_tank ? round(int_tank_air.return_pressure(),0.01) : "None"
	var/tank_temperature = internal_tank ? int_tank_air.return_temperature() : "Unknown"
	var/cabin_pressure = round(return_pressure(),0.01)
	. = {"[report_internal_damage()]
						[integrity<30?"<span class='userdanger'>DAMAGE LEVEL CRITICAL</span><br>":null]
						<b>Integrity: </b> [integrity]%<br>
						<b>Powercell charge: </b>[isnull(cell_charge)?"No powercell installed":"[cell.percent()]%"]<br>
						<b>Air source: </b>[use_internal_tank?"Internal Airtank":"Environment"]<br>
						<b>Airtank pressure: </b>[tank_pressure]kPa<br>
						<b>Airtank temperature: </b>[tank_temperature]&deg;K|[tank_temperature - T0C]&deg;C<br>
						<b>Cabin pressure: </b>[cabin_pressure>WARNING_HIGH_PRESSURE ? span_danger("[cabin_pressure]"): cabin_pressure]kPa<br>
						<b>Cabin temperature: </b> [return_temperature()]&deg;K|[return_temperature() - T0C]&deg;C<br>
						[dna_lock?"<b>DNA-locked:</b><br> <span style='font-size:10px;letter-spacing:-1px;'>[dna_lock]</span> \[<a href='byond://?src=[REF(src)];reset_dna=1'>Reset</a>\]<br>":""]<br>
						[thrusters_action.owner ? "<b>Thrusters: </b> [thrusters_active ? "Enabled" : "Disabled"]<br>" : ""]
						[defense_action.owner ? "<b>Defense Mode: </b> [defense_mode ? "Enabled" : "Disabled"]<br>" : ""]
						[overload_action.owner ? "<b>Leg Actuators Overload: </b> [leg_overload_mode ? "Enabled" : "Disabled"]<br>" : ""]
						[smoke_action.owner ? "<b>Smoke: </b> [smoke]<br>" : ""]
						[zoom_action.owner ? "<b>Zoom: </b> [zoom_mode ? "Enabled" : "Disabled"]<br>" : ""]
						[switch_damtype_action.owner ? "<b>Damtype: </b> [damtype]<br>" : ""]
						[phasing_action.owner ? "<b>Phase Modulator: </b> [phasing ? "Enabled" : "Disabled"]<br>" : ""]
					"}


/obj/mecha/proc/get_commands()
	. = {"<div class='wr'>
						<div class='header'>Electronics</div>
						<div class='links'>
						<b>Radio settings:</b><br>
						Microphone: <a href='byond://?src=[REF(src)];rmictoggle=1'><span id="rmicstate">[radio.broadcasting?"Engaged":"Disengaged"]</span></a><br>
						Speaker: <a href='byond://?src=[REF(src)];rspktoggle=1'><span id="rspkstate">[radio.listening?"Engaged":"Disengaged"]</span></a><br>
						Frequency:
						<a href='byond://?src=[REF(src)];rfreq=-10'>-</a>
						<a href='byond://?src=[REF(src)];rfreq=-2'>-</a>
						<span id="rfreq">[format_frequency(radio.frequency)]</span>
						<a href='byond://?src=[REF(src)];rfreq=2'>+</a>
						<a href='byond://?src=[REF(src)];rfreq=10'>+</a><br>
						</div>
						</div>
						<div class='wr'>
						<div class='header'>Permissions & Logging</div>
						<div class='links'>
						<a href='byond://?src=[REF(src)];toggle_id_upload=1'><span id='t_id_upload'>[add_req_access?"L":"Unl"]ock ID upload panel</span></a><br>
						<a href='byond://?src=[REF(src)];toggle_maint_access=1'><span id='t_maint_access'>[maint_access?"Forbid":"Permit"] maintenance protocols</span></a><br>
						<a href='byond://?src=[REF(src)];toggle_port_connection=1'><span id='t_port_connection'>[internal_tank.connected_port?"Disconnect from":"Connect to"] gas port</span></a><br>
						<a href='byond://?src=[REF(src)];dna_lock=1'>DNA-lock</a><br>
						<a href='byond://?src=[REF(src)];view_log=1'>View internal log</a><br>
						<a href='byond://?src=[REF(src)];change_name=1'>Change exosuit name</a><br>
						</div>
						</div>
						<div id='equipment_menu'>[get_equipment_menu()]</div>
						"}


/obj/mecha/proc/get_equipment_menu() //outputs mecha html equipment menu
	. = ""
	if(equipment.len)
		. += {"<div class='wr'>
						<div class='header'>Equipment</div>
						<div class='links'>"}
		for(var/X in equipment)
			var/obj/item/mecha_parts/mecha_equipment/W = X
			. += "[W.name] <a href='byond://?src=[REF(W)];detach=1'>Detach</a><br>"
		. += "<b>Available equipment slots:</b> [max_equip-equipment.len]"
		. += "</div></div>"


/obj/mecha/proc/get_equipment_list() //outputs mecha equipment list in html
	if(!equipment.len)
		return
	. = "<b>Equipment:</b><div style=\"margin-left: 15px;\">"
	for(var/obj/item/mecha_parts/mecha_equipment/MT in equipment)
		. += "<div id='[REF(MT)]'>[MT.get_equip_info()]</div>"
	. += "</div>"



/obj/mecha/proc/get_log_html()
	. = "<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>[src.name] Log</title></head><body style='font: 13px 'Courier', monospace;'>"
	for(var/list/entry in log)
		. += {"<div style='font-weight: bold;'>[entry["time"]] [time2text(entry["date"],"MMM DD")] [entry["year"]]</div>
						<div style='margin-left:15px; margin-bottom:10px;'>[entry["message"]]</div>
						"}
	. += "</body></html>"



/obj/mecha/proc/output_access_dialog(obj/item/card/id/id_card, mob/user)
	if(!id_card || !user)
		return
	. = {"<html>
						<head>
						<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
						<style>
						h1 {font-size:15px;margin-bottom:4px;}
						body {color: #00ff00; background: #000000; font-family:"Courier New", Courier, monospace; font-size: 12px;}
						a {color:#0f0;}
						</style>
						</head>
						<body>
						<h1>Following keycodes are present in this system:</h1>"}
	for(var/a in operation_req_access)
		. += "[get_access_desc(a)] - <a href='byond://?src=[REF(src)];del_req_access=[a];user=[REF(user)];id_card=[REF(id_card)]'>Delete</a><br>"
	. += "<hr><h1>Following keycodes were detected on portable device:</h1>"
	for(var/a in id_card.access)
		if(a in operation_req_access)
			continue
		var/a_name = get_access_desc(a)
		if(!a_name)
			continue //there's some strange access without a name
		. += "[a_name] - <a href='byond://?src=[REF(src)];add_req_access=[a];user=[REF(user)];id_card=[REF(id_card)]'>Add</a><br>"
	. += "<hr><a href='byond://?src=[REF(src)];finish_req_access=1;user=[REF(user)]'>Finish</a> "
	. += span_danger("(Warning! The ID upload panel will be locked. It can be unlocked only through Exosuit Interface.)")
	. += "</body></html>"
	user << browse(HTML_SKELETON(.), "window=exosuit_add_access")
	onclose(user, "exosuit_add_access")


/obj/mecha/proc/output_maintenance_dialog(obj/item/card/id/id_card,mob/user)
	if(!id_card || !user)
		return
	. = {"<html>
						<head>
						<meta http-equiv='Content-Type' content='text/html; charset=UTF-8'>
						<style>
						body {color: #00ff00; background: #000000; font-family:"Courier New", Courier, monospace; font-size: 12px;}
						a {padding:2px 5px; background:#32CD32;color:#000;display:block;margin:2px;text-align:center;text-decoration:none;}
						</style>
						</head>
						<body>
						[add_req_access?"<a href='byond://?src=[REF(src)];req_access=1;id_card=[REF(id_card)];user=[REF(user)]'>Edit operation keycodes</a>":null]
						[maint_access?"<a href='byond://?src=[REF(src)];maint_access=1;id_card=[REF(id_card)];user=[REF(user)]'>[(state>0) ? "Terminate" : "Initiate"] maintenance protocol</a>":null]
						[(state>0) ?"<a href='byond://?src=[REF(src)];set_internal_tank_valve=1;user=[REF(user)]'>Set Cabin Air Pressure</a>":null]
						</body>
						</html>"}
	user << browse(HTML_SKELETON(.), "window=exosuit_maint_console")
	onclose(user, "exosuit_maint_console")




/////////////////
///// Topic /////
/////////////////

/obj/mecha/Topic(href, href_list)
	..()
	if(href_list["close"])
		return

	if(usr.incapacitated())
		return

	if(in_range(src, usr))
		var/obj/item/card/id/id_card
		if (href_list["id_card"])
			id_card = locate(href_list["id_card"])
			if (!istype(id_card))
				return

		if(href_list["req_access"] && add_req_access)
			output_access_dialog(id_card, usr)

		if(href_list["maint_access"] && maint_access)
			if(state==0)
				state = 1
				to_chat(usr, "The securing bolts are now exposed.")
			else if(state==1)
				state = 0
				to_chat(usr, "The securing bolts are now hidden.")
			output_maintenance_dialog(id_card, usr)

		if(href_list["set_internal_tank_valve"] && state >=1)
			var/new_pressure = input(usr,"Input new output pressure","Pressure setting",internal_tank_valve) as num
			if(new_pressure)
				internal_tank_valve = new_pressure
				to_chat(usr, "The internal pressure valve has been set to [internal_tank_valve]kPa.")

		if(href_list["add_req_access"] && add_req_access)
			operation_req_access += text2num(href_list["add_req_access"])
			output_access_dialog(id_card, usr)

		if(href_list["del_req_access"] && add_req_access)
			operation_req_access -= text2num(href_list["del_req_access"])
			output_access_dialog(id_card, usr)

		if(href_list["finish_req_access"])
			add_req_access = 0
			usr << browse(null,"window=exosuit_add_access")

	if(usr != occupant)
		return

	if(href_list["update_content"])
		send_byjax(usr,"exosuit.browser","content",src.get_stats_part())

	if(href_list["select_equip"])
		var/obj/item/mecha_parts/mecha_equipment/equip = locate(href_list["select_equip"]) in src
		if(equip && equip.selectable)
			selected = equip
			occupant_message("You switch to [equip]")
			visible_message("[src] raises [equip]")
			send_byjax(usr, "exosuit.browser","eq_list", get_equipment_list())

	if(href_list["rmictoggle"])
		radio.broadcasting = !radio.broadcasting
		send_byjax(usr,"exosuit.browser","rmicstate",(radio.broadcasting?"Engaged":"Disengaged"))

	if(href_list["rspktoggle"])
		radio.listening = !radio.listening
		send_byjax(usr,"exosuit.browser","rspkstate",(radio.listening?"Engaged":"Disengaged"))

	if(href_list["rfreq"])
		var/new_frequency = (radio.frequency + text2num(href_list["rfreq"]))
		if (!radio.freerange || (radio.frequency < MIN_FREE_FREQ || radio.frequency > MAX_FREE_FREQ))
			new_frequency = sanitize_frequency(new_frequency)
		radio.set_frequency(new_frequency)
		send_byjax(usr,"exosuit.browser","rfreq","[format_frequency(radio.frequency)]")

	if (href_list["view_log"])
		src.occupant << browse(HTML_SKELETON(src.get_log_html()), "window=exosuit_log")
		onclose(occupant, "exosuit_log")

	if (href_list["change_name"])
		var/userinput = stripped_input(occupant,"Choose new exosuit name","Rename exosuit","", MAX_NAME_LEN)
		if(!userinput || usr != occupant || usr.incapacitated())
			return
		name = userinput
		return

	if (href_list["toggle_id_upload"])
		add_req_access = !add_req_access
		send_byjax(usr,"exosuit.browser","t_id_upload","[add_req_access?"L":"Unl"]ock ID upload panel")

	if(href_list["toggle_maint_access"])
		if(state)
			occupant_message(span_danger("Maintenance protocols in effect"))
			return
		maint_access = !maint_access
		send_byjax(usr,"exosuit.browser","t_maint_access","[maint_access?"Forbid":"Permit"] maintenance protocols")

	if (href_list["toggle_port_connection"])
		if(internal_tank.connected_port)
			if(internal_tank.disconnect())
				occupant_message("Disconnected from the air system port.")
				mecha_log_message("Disconnected from gas port.")
			else
				occupant_message(span_warning("Unable to disconnect from the air system port!"))
				return
		else
			var/obj/machinery/atmospherics/components/unary/portables_connector/possible_port = locate() in loc
			if(internal_tank.connect(possible_port))
				occupant_message("Connected to the air system port.")
				mecha_log_message("Connected to gas port.")
			else
				occupant_message(span_warning("Unable to connect with air system port!"))
				return
		send_byjax(occupant,"exosuit.browser","t_port_connection","[internal_tank.connected_port?"Disconnect from":"Connect to"] gas port")

	if(href_list["dna_lock"])
		if(!occupant)
			return
		var/mob/living/carbon/C = occupant
		if(!istype(C) || !C.dna)
			to_chat(C, span_danger(" You do not have any DNA!"))
			return
		if(can_be_locked)
			dna_lock = C.dna.unique_enzymes
			occupant_message("You feel a prick as the needle takes your DNA sample.")
		else
			to_chat(C, "<span class='danger'> This exosuit lacks a DNA storage bank!")
			return

	if(href_list["reset_dna"])
		dna_lock = null

	if(href_list["repair_int_control_lost"])
		occupant_message("Recalibrating coordination system...")
		mecha_log_message("Recalibration of coordination system started.")
		var/T = loc
		spawn(100)
			if(T == loc)
				clearInternalDamage(MECHA_INT_CONTROL_LOST)
				occupant_message(span_notice("Recalibration successful."))
				mecha_log_message("Recalibration of coordination system finished with 0 errors.")
			else
				occupant_message(span_warning("Recalibration failed!"))
				mecha_log_message("Recalibration of coordination system failed with 1 error.", color="red")

