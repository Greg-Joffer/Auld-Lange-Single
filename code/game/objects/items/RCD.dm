#define GLOW_MODE 3
#define LIGHT_MODE 2
#define REMOVE_MODE 1

/*
CONTAINS:
RCD
ARCD
RLD
*/

/obj/item/construction
	name = "not for ingame use"
	desc = "A device used to rapidly build and deconstruct. Reload with metal, plasteel, glass or compressed matter cartridges."
	opacity = 0
	density = FALSE
	anchored = FALSE
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	force = 0
	throwforce = 10
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=100000)
	req_access_txt = "11"
	armor = ARMOR_VALUE_GENERIC_ITEM
	resistance_flags = FIRE_PROOF
	var/datum/effect_system/spark_spread/spark_system
	var/matter = 0
	var/max_matter = 100
	var/sheetmultiplier	= 4 //Controls the amount of matter added for each glass/metal sheet, triple for plasteel
	var/plasteelmultiplier = 3 //Plasteel is worth 3 times more than glass or metal
	var/plasmarglassmultiplier = 2 //50% less plasma than in plasteel
	var/rglassmultiplier = 1.5 //One metal sheet, half a glass sheet
	var/no_ammo_message = span_warning("The \'Low Ammo\' light on the device blinks yellow.")
	var/has_ammobar = FALSE	//controls whether or not does update_icon apply ammo indicator overlays
	var/ammo_sections = 10	//amount of divisions in the ammo indicator overlay/number of ammo indicator states
	var/custom_range = 7
	var/upgrade = FALSE

/obj/item/construction/Initialize()
	. = ..()
	spark_system = new /datum/effect_system/spark_spread
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/construction/examine(mob/user)
	. = ..()
	. += "It currently holds [matter]/[max_matter] matter-units."
	if(upgrade & RCD_UPGRADE_FRAMES)
		. += "It contains the design for machine frames, computer frames and deconstruction."
	if(upgrade & RCD_UPGRADE_SIMPLE_CIRCUITS)
		. += "It contains the design for firelock, air alarm, fire alarm, apc circuits and crap power cells."

/obj/item/construction/Destroy()
	QDEL_NULL(spark_system)
	. = ..()

/obj/item/construction/attackby(obj/item/W, mob/user, params)
	if(iscyborg(user))
		return
	var/loaded = 0
	if(istype(W, /obj/item/rcd_ammo))
		var/obj/item/rcd_ammo/R = W
		var/load = min(R.ammoamt, max_matter - matter)
		if(load <= 0)
			to_chat(user, span_warning("[src] can't hold any more matter-units!"))
			return
		R.ammoamt -= load
		if(R.ammoamt <= 0)
			qdel(R)
		matter += load
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		loaded = 1
	else if(istype(W, /obj/item/stack/sheet/metal) || istype(W, /obj/item/stack/sheet/glass))
		loaded = loadwithsheets(W, sheetmultiplier, user)
	else if(istype(W, /obj/item/stack/sheet/plasteel))
		loaded = loadwithsheets(W, plasteelmultiplier*sheetmultiplier, user) //12 matter for 1 plasteel sheet
	else if(istype(W, /obj/item/stack/sheet/plasmarglass))
		loaded = loadwithsheets(W, plasmarglassmultiplier*sheetmultiplier, user) //8 matter for one plasma rglass sheet
	else if(istype(W, /obj/item/stack/sheet/rglass))
		loaded = loadwithsheets(W, rglassmultiplier*sheetmultiplier, user) //6 matter for one rglass sheet
	else if(istype(W, /obj/item/stack/rods))
		loaded = loadwithsheets(W, sheetmultiplier * 0.5, user) // 2 matter for 1 rod, as 2 rods are produced from 1 metal
	else if(istype(W, /obj/item/stack/tile/plasteel))
		loaded = loadwithsheets(W, sheetmultiplier * 0.25, user) // 1 matter for 1 floortile, as 4 tiles are produced from 1 metal
	if(loaded)
		to_chat(user, span_notice("[src] now holds [matter]/[max_matter] matter-units."))
	else if(istype(W, /obj/item/rcd_upgrade))
		to_chat(user, span_notice("You upgrade the RCD with the [W]!"))
		var/obj/item/rcd_upgrade/rcd_up = W
		if(!(upgrade & rcd_up.upgrade))
			upgrade |= rcd_up.upgrade
			playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
			qdel(W)
	else
		return ..()
	update_icon()	//ensures that ammo counters (if present) get updated

/obj/item/construction/proc/loadwithsheets(obj/item/stack/sheet/S, value, mob/user)
	var/maxsheets = round((max_matter-matter)/value)    //calculate the max number of sheets that will fit in RCD
	if(maxsheets > 0)
		var/amount_to_use = min(S.amount, maxsheets)
		S.use(amount_to_use)
		matter += value*amount_to_use
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, span_notice("You insert [amount_to_use] [S.name] sheets into [src]. "))
		return 1
	to_chat(user, span_warning("You can't insert any more [S.name] sheets into [src]!"))
	return 0

/obj/item/construction/proc/activate()
	playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)

/obj/item/construction/attack_self(mob/user)
	playsound(src.loc, 'sound/effects/pop.ogg', 50, 0)
	if(prob(20))
		spark_system.start()

/obj/item/construction/proc/useResource(amount, mob/user)
	if(matter < amount)
		if(user)
			to_chat(user, no_ammo_message)
		return FALSE
	matter -= amount
	update_icon()
	return TRUE

/obj/item/construction/proc/checkResource(amount, mob/user)
	. = matter >= amount
	if(!. && user)
		to_chat(user, no_ammo_message)
		if(has_ammobar)
			flick("[icon_state]_empty", src)	//somewhat hacky thing to make RCDs with ammo counters actually have a blinking yellow light
	return .


/obj/item/construction/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated() || !user.Adjacent(src))
		return FALSE
	return TRUE

/obj/item/construction/proc/range_check(atom/A, mob/user)
	if(!(A in range(custom_range, get_turf(user))))
		to_chat(user, span_warning("The \'Out of Range\' light on [src] blinks red."))
		return FALSE
	var/view_range = user.client ? user.client.view : world.view
	//if user can't be seen from A (only checks surroundings' opaqueness) and can't see A.
	//jarring, but it should stop people from targetting atoms they can't see...
	//excluding darkness, to allow RLD to be used to light pitch black dark areas.
	if(!((user in view(view_range, A)) || (user in fov_viewers(view_range, A))))
		to_chat(user, span_warning("You focus, pointing \the [src] at whatever outside your field of vision in that direction... to no avail."))
		return FALSE
	return TRUE

/obj/item/construction/rcd
	name = "rapid-construction-device (RCD)"
	icon = 'icons/obj/tools.dmi'
	icon_state = "rcd"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_price = PRICE_ABOVE_EXPENSIVE
	custom_premium_price = PRICE_ALMOST_ONE_GRAND
	max_matter = 160
	item_flags = NO_MAT_REDEMPTION | NOBLUDGEON
	has_ammobar = TRUE
	var/mode = 1
	var/ranged = FALSE
	var/computer_dir = 1
	var/airlock_type = /obj/machinery/door/airlock
	var/airlock_glass = FALSE // So the floor's rcd_act knows how much ammo to use
	var/window_type = /obj/structure/window/fulltile
	var/advanced_airlock_setting = 1 //Set to 1 if you want more paintjobs available
	var/list/conf_access = null
	var/use_one_access = 0 //If the airlock should require ALL or only ONE of the listed accesses.
	var/delay_mod = 1
	var/canRturf = FALSE //Variable for R walls to deconstruct them

/obj/item/construction/rcd/suicide_act(mob/user)
	user.visible_message(span_suicide("[user] sets the RCD to 'Wall' and points it down [user.p_their()] throat! It looks like [user.p_theyre()] trying to commit suicide.."))
	return (BRUTELOSS)

/obj/item/construction/rcd/verb/toggle_window_type_verb()
	set name = "RCD : Toggle Window Type"
	set category = "Object"
	set src in view(1)

	if(!usr.canUseTopic(src, BE_CLOSE))
		return

	toggle_window_type(usr)

/obj/item/construction/rcd/proc/toggle_window_type(mob/user)
	var/window_type_name
	if (window_type == /obj/structure/window/fulltile)
		window_type = /obj/structure/window/reinforced/fulltile
		window_type_name = "reinforced glass"
	else
		window_type = /obj/structure/window/fulltile
		window_type_name = "glass"

	to_chat(user, span_notice("You change \the [src]'s window mode to [window_type_name]."))

/obj/item/construction/rcd/verb/change_airlock_access(mob/user)

	if (!ishuman(user) && !user.silicon_privileges)
		return

	var/t1 = ""


	if(use_one_access)
		t1 += "Restriction Type: <a href='byond://?src=[REF(src)];access=one'>At least one access required</a><br>"
	else
		t1 += "Restriction Type: <a href='byond://?src=[REF(src)];access=one'>All accesses required</a><br>"

	t1 += "<a href='byond://?src=[REF(src)];access=all'>Remove All</a><br>"

	var/accesses = ""
	accesses += "<div align='center'><b>Access</b></div>"
	accesses += "<table style='width:100%'>"
	accesses += "<tr>"
	for(var/i = 1; i <= 7; i++)
		accesses += "<td style='width:14%'><b>[get_region_accesses_name(i)]:</b></td>"
	accesses += "</tr><tr>"
	for(var/i = 1; i <= 7; i++)
		accesses += "<td style='width:14%' valign='top'>"
		for(var/A in get_region_accesses(i))
			if(A in conf_access)
				accesses += "<a href='byond://?src=[REF(src)];access=[A]'><font color=\"red\">[replacetext(get_access_desc(A), " ", "&nbsp")]</font></a> "
			else
				accesses += "<a href='byond://?src=[REF(src)];access=[A]'>[replacetext(get_access_desc(A), " ", "&nbsp")]</a> "
			accesses += "<br>"
		accesses += "</td>"
	accesses += "</tr></table>"
	t1 += "<tt>[accesses]</tt>"

	t1 += "<p><a href='byond://?src=[REF(src)];close=1'>Close</a></p>\n"

	var/datum/browser/popup = new(user, "rcd_access", "Access Control", 900, 500, src)
	popup.set_content(t1)
	popup.open()

/obj/item/construction/rcd/Topic(href, href_list)
	..()
	if (usr.stat || usr.restrained())
		return
	if (href_list["close"])
		usr << browse(null, "window=rcd_access")
		return

	if (href_list["access"])
		toggle_access(href_list["access"])
		change_airlock_access(usr)

/obj/item/construction/rcd/proc/toggle_access(acc)
	if (acc == "all")
		conf_access = null
	else if(acc == "one")
		use_one_access = !use_one_access
	else
		var/req = text2num(acc)

		if (conf_access == null)
			conf_access = list()

		if (!(req in conf_access))
			conf_access += req
		else
			conf_access -= req
			if (!conf_access.len)
				conf_access = null

/obj/item/construction/rcd/proc/get_airlock_image(airlock_type)
	var/obj/machinery/door/airlock/proto = airlock_type
	var/ic = initial(proto.icon)
	var/mutable_appearance/MA = mutable_appearance(ic, "closed")
	if(!initial(proto.glass))
		MA.overlays += "fill_closed"
	//Not scaling these down to button size because they look horrible then, instead just bumping up radius.
	return MA

/obj/item/construction/rcd/proc/change_computer_dir(mob/user)
	if(!user)
		return
	var/list/computer_dirs = list(
		"NORTH" = image(icon = 'icons/mob/radial.dmi', icon_state = "cnorth"),
		"EAST" = image(icon = 'icons/mob/radial.dmi', icon_state = "ceast"),
		"SOUTH" = image(icon = 'icons/mob/radial.dmi', icon_state = "csouth"),
		"WEST" = image(icon = 'icons/mob/radial.dmi', icon_state = "cwest")
		)
	var/computerdirs = show_radial_menu(user, src, computer_dirs, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return
	switch(computerdirs)
		if("NORTH")
			computer_dir = 1
		if("EAST")
			computer_dir = 4
		if("SOUTH")
			computer_dir = 2
		if("WEST")
			computer_dir = 8

/obj/item/construction/rcd/proc/change_airlock_setting(mob/user)
	if(!user)
		return

	var/list/solid_or_glass_choices = list(
		"Solid" = get_airlock_image(/obj/machinery/door/airlock),
		"Glass" = get_airlock_image(/obj/machinery/door/airlock/glass)
	)

	var/list/solid_choices = list(
		"Standard" = get_airlock_image(/obj/machinery/door/airlock),
		"Public" = get_airlock_image(/obj/machinery/door/airlock/public),
		"Engineering" = get_airlock_image(/obj/machinery/door/airlock/engineering),
		"Atmospherics" = get_airlock_image(/obj/machinery/door/airlock/atmos),
		"Security" = get_airlock_image(/obj/machinery/door/airlock/security),
		"Command" = get_airlock_image(/obj/machinery/door/airlock/command),
		"Medical" = get_airlock_image(/obj/machinery/door/airlock/medical),
		"Research" = get_airlock_image(/obj/machinery/door/airlock/research),
		"Freezer" = get_airlock_image(/obj/machinery/door/airlock/freezer),
		"Science" = get_airlock_image(/obj/machinery/door/airlock/science),
		"Virology" = get_airlock_image(/obj/machinery/door/airlock/virology),
		"Mining" = get_airlock_image(/obj/machinery/door/airlock/mining),
		"Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance),
		"External" = get_airlock_image(/obj/machinery/door/airlock/external),
		"External Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance/external),
		"Airtight Hatch" = get_airlock_image(/obj/machinery/door/airlock/hatch),
		"Maintenance Hatch" = get_airlock_image(/obj/machinery/door/airlock/maintenance_hatch)
	)

	var/list/glass_choices = list(
		"Standard" = get_airlock_image(/obj/machinery/door/airlock/glass),
		"Public" = get_airlock_image(/obj/machinery/door/airlock/public/glass),
		"Engineering" = get_airlock_image(/obj/machinery/door/airlock/engineering/glass),
		"Atmospherics" = get_airlock_image(/obj/machinery/door/airlock/atmos/glass),
		"Security" = get_airlock_image(/obj/machinery/door/airlock/security/glass),
		"Command" = get_airlock_image(/obj/machinery/door/airlock/command/glass),
		"Medical" = get_airlock_image(/obj/machinery/door/airlock/medical/glass),
		"Research" = get_airlock_image(/obj/machinery/door/airlock/research/glass),
		"Science" = get_airlock_image(/obj/machinery/door/airlock/science/glass),
		"Virology" = get_airlock_image(/obj/machinery/door/airlock/virology/glass),
		"Mining" = get_airlock_image(/obj/machinery/door/airlock/mining/glass),
		"Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance/glass),
		"External" = get_airlock_image(/obj/machinery/door/airlock/external/glass),
		"External Maintenance" = get_airlock_image(/obj/machinery/door/airlock/maintenance/external/glass)
	)

	var/airlockcat = show_radial_menu(user, src, solid_or_glass_choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE)
	if(!check_menu(user))
		return
	switch(airlockcat)
		if("Solid")
			if(advanced_airlock_setting == 1)
				var/airlockpaint = show_radial_menu(user, src, solid_choices, radius = 42, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE)
				if(!check_menu(user))
					return
				switch(airlockpaint)
					if("Standard")
						airlock_type = /obj/machinery/door/airlock
					if("Public")
						airlock_type = /obj/machinery/door/airlock/public
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/engineering
					if("Atmospherics")
						airlock_type = /obj/machinery/door/airlock/atmos
					if("Security")
						airlock_type = /obj/machinery/door/airlock/security
					if("Command")
						airlock_type = /obj/machinery/door/airlock/command
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/medical
					if("Research")
						airlock_type = /obj/machinery/door/airlock/research
					if("Freezer")
						airlock_type = /obj/machinery/door/airlock/freezer
					if("Science")
						airlock_type = /obj/machinery/door/airlock/science
					if("Virology")
						airlock_type = /obj/machinery/door/airlock/virology
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/mining
					if("Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance
					if("External")
						airlock_type = /obj/machinery/door/airlock/external
					if("External Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance/external
					if("Airtight Hatch")
						airlock_type = /obj/machinery/door/airlock/hatch
					if("Maintenance Hatch")
						airlock_type = /obj/machinery/door/airlock/maintenance_hatch
				airlock_glass = FALSE
			else
				airlock_type = /obj/machinery/door/airlock
				airlock_glass = FALSE

		if("Glass")
			if(advanced_airlock_setting == 1)
				var/airlockpaint = show_radial_menu(user, src , glass_choices, radius = 42, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE)
				if(!check_menu(user))
					return
				switch(airlockpaint)
					if("Standard")
						airlock_type = /obj/machinery/door/airlock/glass
					if("Public")
						airlock_type = /obj/machinery/door/airlock/public/glass
					if("Engineering")
						airlock_type = /obj/machinery/door/airlock/engineering/glass
					if("Atmospherics")
						airlock_type = /obj/machinery/door/airlock/atmos/glass
					if("Security")
						airlock_type = /obj/machinery/door/airlock/security/glass
					if("Command")
						airlock_type = /obj/machinery/door/airlock/command/glass
					if("Medical")
						airlock_type = /obj/machinery/door/airlock/medical/glass
					if("Research")
						airlock_type = /obj/machinery/door/airlock/research/glass
					if("Science")
						airlock_type = /obj/machinery/door/airlock/science/glass
					if("Virology")
						airlock_type = /obj/machinery/door/airlock/virology/glass
					if("Mining")
						airlock_type = /obj/machinery/door/airlock/mining/glass
					if("Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance/glass
					if("External")
						airlock_type = /obj/machinery/door/airlock/external/glass
					if("External Maintenance")
						airlock_type = /obj/machinery/door/airlock/maintenance/external/glass
				airlock_glass = TRUE
			else
				airlock_type = /obj/machinery/door/airlock/glass
				airlock_glass = TRUE
		else
			airlock_type = /obj/machinery/door/airlock
			airlock_glass = FALSE


/obj/item/construction/rcd/proc/rcd_create(atom/A, mob/user)
	var/list/rcd_results = A.rcd_vals(user, src)
	if(!rcd_results)
		return FALSE
	var/delay = rcd_results["delay"] * delay_mod
	var/obj/effect/constructing_effect/rcd_effect = new(get_turf(A), delay, src.mode)
	var/turf/the_turf = get_turf(A)
	var/turf_coords = "[COORD(the_turf)]"
	investigate_log("[user] is attempting to use [src] on [A] (loc [turf_coords] at [the_turf]) with cost [rcd_results["cost"]], delay [rcd_results["delay"]], mode [rcd_results["mode"]].", INVESTIGATE_RCD)
	if(do_after(user, delay, target = A))
		if(checkResource(rcd_results["cost"], user))
			var/atom/cached = A
			if(A.rcd_act(user, src, rcd_results["mode"]))
				rcd_effect.end_animation()
				useResource(rcd_results["cost"], user)
				activate()
				investigate_log("[user] used [src] on [cached] (loc [turf_coords] at [the_turf]) with cost [rcd_results["cost"]], delay [rcd_results["delay"]], mode [rcd_results["mode"]].", INVESTIGATE_RCD)
				playsound(src, 'sound/machines/click.ogg', 50, 1)
				return TRUE
	qdel(rcd_effect)

/obj/item/construction/rcd/Initialize()
	. = ..()
	GLOB.rcd_list += src

/obj/item/construction/rcd/Destroy()
	GLOB.rcd_list -= src
	. = ..()

/obj/item/construction/rcd/attack_self(mob/user)
	..()
	var/list/choices = list(
		"Airlock" = image(icon = 'icons/mob/radial.dmi', icon_state = "airlock"),
		"Grilles & Windows" = image(icon = 'icons/mob/radial.dmi', icon_state = "grillewindow"),
		"Floors & Walls" = image(icon = 'icons/mob/radial.dmi', icon_state = "wallfloor")
	)
	if(upgrade & RCD_UPGRADE_FRAMES)
		choices += list(
		"Deconstruct" = image(icon= 'icons/mob/radial.dmi', icon_state = "delete"),
		"Machine Frames" = image(icon = 'icons/mob/radial.dmi', icon_state = "machine"),
		"Computer Frames" = image(icon = 'icons/mob/radial.dmi', icon_state = "computer_dir"),
		)
	if(mode == RCD_AIRLOCK)
		choices += list(
		"Change Access" = image(icon = 'icons/mob/radial.dmi', icon_state = "access"),
		"Change Airlock Type" = image(icon = 'icons/mob/radial.dmi', icon_state = "airlocktype")
		)
	else if(mode == RCD_WINDOWGRILLE)
		choices += list(
			"Change Window Type" = image(icon = 'icons/mob/radial.dmi', icon_state = "windowtype")
		)
	var/choice = show_radial_menu(user,src,choices, custom_check = CALLBACK(src,PROC_REF(check_menu),user))
	if(!check_menu(user))
		return
	switch(choice)
		if("Floors & Walls")
			mode = RCD_FLOORWALL
		if("Airlock")
			mode = RCD_AIRLOCK
		if("Deconstruct")
			mode = RCD_DECONSTRUCT
		if("Grilles & Windows")
			mode = RCD_WINDOWGRILLE
		if("Machine Frames")
			mode = RCD_MACHINE
		if("Computer Frames")
			mode = RCD_COMPUTER
			change_computer_dir(user)
			return
		if("Change Access")
			change_airlock_access(user)
			return
		if("Change Airlock Type")
			change_airlock_setting(user)
			return
		if("Change Window Type")
			toggle_window_type(user)
			return
		else
			return
	playsound(src, 'sound/effects/pop.ogg', 50, 0)
	to_chat(user, span_notice("You change RCD's mode to '[choice]'."))

/obj/item/construction/rcd/proc/target_check(atom/A, mob/user) // only returns true for stuff the device can actually work with
	if((isturf(A) && A.density && mode==RCD_DECONSTRUCT) || (isturf(A) && !A.density) || (istype(A, /obj/machinery/door/airlock) && mode==RCD_DECONSTRUCT) || istype(A, /obj/structure/grille) || (istype(A, /obj/structure/window) && mode==RCD_DECONSTRUCT) || istype(A, /obj/structure/girder))
		return TRUE
	else
		return FALSE

/obj/item/construction/rcd/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		if(!ranged || !range_check(A,user)) //early return not-in-range sanity.
			return
		if(target_check(A,user))
			user.Beam(A,icon_state="rped_upgrade",time=30)
		rcd_create(A,user)
		return
	rcd_create(A, user)

/obj/item/construction/rcd/proc/detonate_pulse()
	audible_message("<span class='danger'><b>[src] begins to vibrate and \
		buzz loudly!</b></span>","<span class='danger'><b>[src] begins \
		vibrating violently!</b></span>")
	// 5 seconds to get rid of it
	addtimer(CALLBACK(src, PROC_REF(detonate_pulse_explode)), 50)

/obj/item/construction/rcd/proc/detonate_pulse_explode()
	explosion(src, 0, 0, 3, 1, flame_range = 1)
	qdel(src)

/obj/item/construction/rcd/update_overlays()
	. = ..()
	if(has_ammobar)
		var/ratio = CEILING((matter / max_matter) * ammo_sections, 1)
		cut_overlays()	//To prevent infinite stacking of overlays
		add_overlay("[icon_state]_charge[ratio]")

/obj/item/construction/rcd/Initialize()
	. = ..()
	update_icon()

/obj/item/construction/rcd/borg
	no_ammo_message = span_warning("Insufficient charge.")
	desc = "A device used to rapidly build walls and floors."
	canRturf = TRUE
	upgrade = TRUE
	var/energyfactor = 72


/obj/item/construction/rcd/borg/useResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.use(amount * energyfactor) //borgs get 1.3x the use of their RCDs
	if(!. && user)
		to_chat(user, no_ammo_message)
	return .

/obj/item/construction/rcd/borg/checkResource(amount, mob/user)
	if(!iscyborg(user))
		return 0
	var/mob/living/silicon/robot/borgy = user
	if(!borgy.cell)
		if(user)
			to_chat(user, no_ammo_message)
		return 0
	. = borgy.cell.charge >= (amount * energyfactor)
	if(!. && user)
		to_chat(user, no_ammo_message)
	return .

/obj/item/construction/rcd/borg/syndicate
	icon_state = "ircd"
	item_state = "ircd"
	energyfactor = 66

/obj/item/construction/rcd/loaded
	custom_materials = list(/datum/material/iron = 48000, /datum/material/glass = 32000)
	matter = 160

/obj/item/construction/rcd/loaded/upgraded
	upgrade = TRUE

/obj/item/construction/rcd/combat
	name = "Combat RCD"
	desc = "A device used to rapidly build and deconstruct. Reload with metal, plasteel, glass or compressed matter cartridges. This RCD has been upgraded to be able to remove Rwalls!"
	icon_state = "ircd"
	item_state = "ircd"
	max_matter = 500
	matter = 500
	canRturf = TRUE

/obj/item/construction/rcd/industrial
	name = "industrial RCD"
	icon_state = "ircd"
	item_state = "ircd"
	max_matter = 500
	matter = 500
	delay_mod = 0.6
	sheetmultiplier	= 8

/obj/item/rcd_ammo
	name = "compressed matter cartridge"
	desc = "Highly compressed matter for the RCD."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "rcd"
	item_state = "rcdammo"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	custom_materials = list(/datum/material/iron=12000, /datum/material/glass=8000)
	var/ammoamt = 40

/obj/item/rcd_ammo/large
	name = "large compressed matter cartridge"
	desc = "Highly compressed matter for the RCD. Has four times the matter packed into the same space as a normal cartridge."
	custom_materials = list(/datum/material/iron=48000, /datum/material/glass=32000)
	ammoamt = 160


/obj/item/construction/rcd/combat/admin
	name = "admin RCD"
	max_matter = INFINITY
	matter = INFINITY
	upgrade = TRUE
	ranged = TRUE

// Ranged RCD


/obj/item/construction/rcd/arcd
	name = "advanced rapid-construction-device (ARCD)"
	desc = "A prototype RCD with ranged capability and extended capacity. Reload with metal, plasteel, glass or compressed matter cartridges."
	max_matter = 300
	matter = 300
	delay_mod = 0.6
	ranged = TRUE
	icon_state = "arcd"
	item_state = "oldrcd"
	has_ammobar = FALSE


// RAPID LIGHTING DEVICE


/obj/item/construction/rld
	name = "rapid-light-device (RLD)"
	desc = "A device used to rapidly provide lighting sources to an area. Reload with metal, plasteel, glass or compressed matter cartridges."
	icon = 'icons/obj/tools.dmi'
	icon_state = "rld"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	matter = 200
	max_matter = 200
	sheetmultiplier = 5
	var/mode = LIGHT_MODE
	actions_types = list(/datum/action/item_action/pick_color)
	ammo_sections = 5
	has_ammobar = TRUE

	var/wallcost = 20
	var/floorcost = 25
	var/launchcost = 10
	var/deconcost = 20

	var/walldelay = 10
	var/floordelay = 10
	var/decondelay = 10

	var/color_choice = null


/obj/item/construction/rld/Initialize()
	. = ..()
	update_icon()

/obj/item/construction/rld/ui_action_click(mob/user, datum/action/A)
	if(istype(A, /datum/action/item_action/pick_color))
		color_choice = input(user,"","Choose Color",color_choice) as color
	else
		..()

/obj/item/construction/rld/update_overlays()
	. = ..()
	var/ratio = CEILING((matter / max_matter) * ammo_sections, 1)
	. += "rld_light[ratio]"

/obj/item/construction/rld/attack_self(mob/user)
	..()
	switch(mode)
		if(REMOVE_MODE)
			mode = LIGHT_MODE
			to_chat(user, span_notice("You change RLD's mode to 'Permanent Light Construction'."))
		if(LIGHT_MODE)
			mode = GLOW_MODE
			to_chat(user, span_notice("You change RLD's mode to 'Light Launcher'."))
		if(GLOW_MODE)
			mode = REMOVE_MODE
			to_chat(user, span_notice("You change RLD's mode to 'Deconstruct'."))


/obj/item/construction/rld/proc/checkdupes(target)
	. = list()
	var/turf/checking = get_turf(target)
	for(var/obj/machinery/light/dupe in checking)
		if(istype(dupe, /obj/machinery/light))
			. |= dupe


/obj/item/construction/rld/afterattack(atom/A, mob/user)
	. = ..()
	if(!range_check(A,user))
		return
	var/turf/start = get_turf(src)
	switch(mode)
		if(REMOVE_MODE)
			if(istype(A, /obj/machinery/light/))
				if(checkResource(deconcost, user))
					to_chat(user, span_notice("You start deconstructing [A]..."))
					user.Beam(A,icon_state="light_beam",time=15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					if(do_after(user, decondelay, target = A))
						if(!useResource(deconcost, user))
							return 0
						activate()
						qdel(A)
						return TRUE
				return FALSE
		if(LIGHT_MODE)
			if(iswallturf(A))
				var/turf/closed/wall/W = A
				if(checkResource(floorcost, user))
					to_chat(user, span_notice("You start building a wall light..."))
					user.Beam(A,icon_state="light_beam",time=15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					playsound(src.loc, 'sound/effects/light_flicker.ogg', 50, 0)
					if(do_after(user, floordelay, target = A))
						if(!istype(W))
							return FALSE
						var/list/candidates = list()
						var/turf/open/winner = null
						var/winning_dist = null
						for(var/direction in GLOB.cardinals)
							var/turf/C = get_step(W, direction)
							var/list/dupes = checkdupes(C)
							if(start.CanAtmosPass(C) && !dupes.len)
								candidates += C
						if(!candidates.len)
							to_chat(user, span_warning("Valid target not found..."))
							playsound(src.loc, 'sound/misc/compiler-failure.ogg', 30, 1)
							return FALSE
						for(var/turf/open/O in candidates)
							if(istype(O))
								var/x0 = O.x
								var/y0 = O.y
								var/contender = cheap_hypotenuse(start.x, start.y, x0, y0)
								if(!winner)
									winner = O
									winning_dist = contender
								else
									if(contender < winning_dist) // lower is better
										winner = O
										winning_dist = contender
						activate()
						if(!useResource(wallcost, user))
							return FALSE
						var/light = get_turf(winner)
						var/align = get_dir(winner, A)
						var/obj/machinery/light/L = new /obj/machinery/light(light)
						L.setDir(align)
						L.color = color_choice
						L.light_color = L.color
						return TRUE
				return FALSE

			if(isfloorturf(A))
				var/turf/open/floor/F = A
				if(checkResource(floorcost, user))
					to_chat(user, span_notice("You start building a floor light..."))
					user.Beam(A,icon_state="light_beam",time=15)
					playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
					playsound(src.loc, 'sound/effects/light_flicker.ogg', 50, 1)
					if(do_after(user, floordelay, target = A))
						if(!istype(F))
							return 0
						if(!useResource(floorcost, user))
							return 0
						activate()
						var/destination = get_turf(A)
						var/obj/machinery/light/floor/FL = new /obj/machinery/light/floor(destination)
						FL.color = color_choice
						FL.light_color = FL.color
						return TRUE
				return FALSE

		if(GLOW_MODE)
			if(useResource(launchcost, user))
				activate()
				to_chat(user, span_notice("You fire a glowstick!"))
				var/obj/item/flashlight/glowstick/G  = new /obj/item/flashlight/glowstick(start)
				G.color = color_choice
				G.light_color = G.color
				G.throw_at(A, 9, 3, user)
				G.on = TRUE
				G.update_brightness()
				return TRUE
			return FALSE

/obj/item/construction/rld/mini
	name = "mini-rapid-light-device (MRLD)"
	desc = "A device used to rapidly provide lighting sources to an area. Reload with metal, plasteel, glass or compressed matter cartridges."
	matter = 100
	max_matter = 100

/obj/item/rcd_upgrade
	name = "RCD advanced design disk"
	desc = "It seems to be empty."
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk3"
	var/upgrade

/obj/item/rcd_upgrade/frames
	desc = "It contains the design for machine frames, computer frames and deconstruction."
	upgrade = RCD_UPGRADE_FRAMES

/obj/item/rcd_upgrade/simple_circuits
	desc = "It contains the design for firelock, air alarm, fire alarm, apc circuits and crap power cells."
	upgrade = RCD_UPGRADE_SIMPLE_CIRCUITS

/obj/item/construction/plumbing
	name = "Plumbing Constructor"
	desc = "An expertly modified RCD outfitted to construct plumbing machinery. Reload with compressed matter cartridges."
	icon = 'icons/obj/tools.dmi'
	icon_state = "arcd"
	item_state = "oldrcd"
	has_ammobar = FALSE
	matter = 200
	max_matter = 200

	///type of the plumbing machine
	var/blueprint = null
	///index, used in the attack self to get the type. stored here since it doesnt change
	var/list/choices = list()
	///index, used in the attack self to get the type. stored here since it doesnt change
	var/list/name_to_type = list()
	///
	var/list/machinery_data = list("cost" = list(), "delay" = list())

/obj/item/construction/plumbing/attack_self(mob/user)
	..()
	if(!choices.len)
		for(var/A in subtypesof(/obj/machinery/plumbing))
			var/obj/machinery/plumbing/M = A
			if(initial(M.rcd_constructable))
				choices += list(initial(M.name) = image(icon = initial(M.icon), icon_state = initial(M.icon_state)))
				name_to_type[initial(M.name)] = M
				machinery_data["cost"][A] = initial(M.rcd_cost)
				machinery_data["delay"][A] = initial(M.rcd_delay)

	var/choice = show_radial_menu(user, src, choices, custom_check = CALLBACK(src, PROC_REF(check_menu), user), require_near = TRUE, tooltips = TRUE)
	if(!check_menu(user))
		return

	blueprint = name_to_type[choice]
	playsound(src, 'sound/effects/pop.ogg', 50, FALSE)
	to_chat(user, span_notice("You change [name]s blueprint to '[choice]'."))

///pretty much rcd_create, but named differently to make myself feel less bad for copypasting from a sibling-type
/obj/item/construction/plumbing/proc/create_machine(atom/A, mob/user)
	if(!machinery_data || !isopenturf(A))
		return FALSE

	if(checkResource(machinery_data["cost"][blueprint], user) && blueprint)
		if(do_after(user, machinery_data["delay"][blueprint], target = A))
			if(checkResource(machinery_data["cost"][blueprint], user) && canPlace(A))
				useResource(machinery_data["cost"][blueprint], user)
				activate()
				playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
				new blueprint (A, FALSE, FALSE)
				return TRUE

/obj/item/construction/plumbing/proc/canPlace(turf/T)
	if(!isopenturf(T))
		return FALSE
	. = TRUE
	for(var/obj/O in T.contents)
		if(O.density) //let's not built ontop of dense stuff, like big machines and other obstacles, it kills my immershion
			return FALSE

/obj/item/construction/plumbing/afterattack(atom/A, mob/user)
	. = ..()
	if(!range_check(A, user))
		return
	if(istype(A, /obj/machinery/plumbing))
		var/obj/machinery/plumbing/P = A
		if(P.anchored)
			to_chat(user, span_warning("The [P.name] needs to be unanchored!"))
			return
		if(do_after(user, 20, target = P))
			P.deconstruct() //Let's not substract matter
			playsound(get_turf(src), 'sound/machines/click.ogg', 50, TRUE) //this is just such a great sound effect
	else
		create_machine(A, user)


#undef GLOW_MODE
#undef LIGHT_MODE
#undef REMOVE_MODE

