/obj/machinery/power/am_control_unit
	name = "reactor control unit"
	desc = "A General Atomics reactor control unit. Controls exposure of a fuel rod inserted into it.  Wrench the device to set it up."
	icon = 'icons/obj/machines/antimatter.dmi'
	icon_state = "control"
	anchored = FALSE
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = 100
	active_power_usage = 1000

	interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND | INTERACT_ATOM_UI_INTERACT | INTERACT_ATOM_REQUIRES_ANCHORED

	var/list/obj/machinery/am_shielding/linked_shielding
	var/list/obj/machinery/am_shielding/linked_cores
	var/obj/item/am_containment/fueljar
	var/update_shield_icons = 0
	var/stability = 100
	var/exploding = 0

	var/active = 0//On or not
	var/fuel_injection = 2//How much fuel to inject
	var/shield_icon_delay = 0//delays resetting for a short time
	var/reported_core_efficiency = 0

	var/power_cycle = 0
	var/power_cycle_delay = 4//How many ticks till produce_power is called
	var/stored_core_stability = 0
	var/stored_core_stability_delay = 0

	var/stored_power = 0//Power to deploy per tick
	var/datum/looping_sound/supermatter/soundloop //fortuna edit. adds reactor sounds

/obj/machinery/power/am_control_unit/Initialize()
	. = ..()
	linked_shielding = list()
	linked_cores = list()
	soundloop = new(list(src), TRUE) //fortuna edit

/obj/machinery/power/am_control_unit/Destroy()//Perhaps damage and run stability checks rather than just del on the others
	for(var/obj/machinery/am_shielding/AMS in linked_shielding)
		AMS.control_unit = null
		qdel(AMS)
	QDEL_NULL(fueljar)
	QDEL_NULL(soundloop)
	return ..()

/obj/machinery/power/am_control_unit/process()
	if(exploding)
		explosion(get_turf(src),8,12,18,12)
		if(src)
			qdel(src)

	if(update_shield_icons && !shield_icon_delay)
		check_shield_icons()
		update_shield_icons = 0

	if(stat & (NOPOWER|BROKEN) || !active)//can update the icons even without power
		return

	if(!fueljar)//No fuel but we are on, shutdown
		toggle_power()
		playsound(src.loc, 'sound/machines/buzz-two.ogg', 50, 0)
		return

	add_avail(stored_power)

	power_cycle++
	if(power_cycle >= power_cycle_delay)
		produce_power()
		power_cycle = 0

	return

/obj/machinery/power/am_control_unit/proc/produce_power()
	soundloop.mid_sounds = list('sound/machines/sm/loops/calm.ogg' = 1) //fortuna edit
	//playsound(src.loc, 'sound/effects/bang.ogg', 25, 1) //fortuna edit
	var/core_power = reported_core_efficiency//Effectively how much fuel we can safely deal with
	if(core_power <= 0)
		return 0//Something is wrong
	var/core_damage = 0
	var/fuel = fueljar.usefuel(fuel_injection)
	soundloop.volume = clamp((50 + (core_power / 50)), 50, 100) //fortuna edit
	stored_power = (fuel/core_power)*fuel*200000
	//Now check if the cores could deal with it safely, this is done after so you can overload for more power if needed, still a bad idea
	if(fuel > (2*core_power))//More fuel has been put in than the current cores can deal with
		if(prob(50))
			core_damage = 1//Small chance of damage
		if((fuel-core_power) > 5)
			core_damage = 5//Now its really starting to overload the cores
		if((fuel-core_power) > 10)
			core_damage = 20//Welp now you did it, they wont stand much of this
		if(core_damage == 0)
			return
		for(var/obj/machinery/am_shielding/AMS in linked_cores)
			AMS.stability -= core_damage
			AMS.check_stability(1)
		//playsound(src.loc, 'sound/effects/bang.ogg', 50, 1) //fortuna edit
	CHECK_TICK

	return


/obj/machinery/power/am_control_unit/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(active)
		toggle_power()
	stability -= rand(round(severity/5),round(severity/3))

/obj/machinery/power/am_control_unit/blob_act()
	stability -= 20
	if(prob(100-stability))//Might infect the rest of the machine
		for(var/obj/machinery/am_shielding/AMS in linked_shielding)
			AMS.blob_act()
		qdel(src)
		return
	check_stability()
	return

/obj/machinery/power/am_control_unit/ex_act(severity, target)
	stability -= (80 - (severity * 20))
	check_stability()
	return

/obj/machinery/power/am_control_unit/bullet_act(obj/item/projectile/Proj)
	. = ..()
	if(Proj.flag != "bullet")
		stability -= Proj.force
		check_stability()

/obj/machinery/power/am_control_unit/power_change()
	..()
	if(stat & NOPOWER)
		if(active)
			toggle_power(1)
		else
			use_power = NO_POWER_USE

	else if(!stat && anchored)
		use_power = IDLE_POWER_USE

	return

/obj/machinery/power/am_control_unit/update_icon_state()
	if(active)
		icon_state = "control_on"
	else
		icon_state = "control"
	//No other icons for it atm

/obj/machinery/power/am_control_unit/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/wrench))
		if(!anchored)
			W.play_tool_sound(src, 75)
			user.visible_message("[user.name] secures the [src.name] to the floor.", \
				span_notice("You secure the anchor bolts to the floor."), \
				span_italic("You hear a ratchet."))
			src.anchored = TRUE
			connect_to_network()
		else if(!linked_shielding.len > 0)
			W.play_tool_sound(src, 75)
			user.visible_message("[user.name] unsecures the [src.name].", \
				span_notice("You remove the anchor bolts."), \
				span_italic("You hear a ratchet."))
			src.anchored = FALSE
			disconnect_from_network()
		else
			to_chat(user, span_warning("Once bolted and linked to a shielding unit it the [src.name] is unable to be moved!"))

	else if(istype(W, /obj/item/am_containment))
		if(fueljar)
			to_chat(user, span_warning("There is already a [fueljar] inside!"))
			return

		if(!user.transferItemToLoc(W, src))
			return
		fueljar = W
		user.visible_message("[user.name] loads an [W.name] into the [src.name].", \
				span_notice("You load an [W.name]."), \
				span_italic("You hear a thunk."))
	else
		return ..()

/obj/machinery/power/am_control_unit/take_damage(damage, damage_type = BRUTE, sound_effect = 1, atom/attacked_by)
	switch(damage_type)
		if(BRUTE)
			if(sound_effect)
				if(damage)
					playsound(loc, 'sound/weapons/smash.ogg', 50, 1)
				else
					playsound(loc, 'sound/weapons/tap.ogg', 50, 1)
		if(BURN)
			if(sound_effect)
				playsound(src.loc, 'sound/items/welder.ogg', 100, 1)
		else
			return
	if(damage >= 20)
		stability -= damage/2
		check_stability()

/obj/machinery/power/am_control_unit/proc/add_shielding(obj/machinery/am_shielding/AMS, AMS_linking = 0)
	if(!istype(AMS))
		return 0
	if(!anchored)
		return 0
	if(!AMS_linking && !AMS.link_control(src))
		return 0
	linked_shielding.Add(AMS)
	update_shield_icons = 1
	return 1

/obj/machinery/power/am_control_unit/proc/remove_shielding(obj/machinery/am_shielding/AMS)
	if(!istype(AMS))
		return 0
	linked_shielding.Remove(AMS)
	update_shield_icons = 2
	if(active)
		toggle_power()
	return 1

/obj/machinery/power/am_control_unit/proc/check_stability()//TODO: make it break when low also might want to add a way to fix it like a part or such that can be replaced
	if(stability <= 0)
		qdel(src)
	return

/obj/machinery/power/am_control_unit/proc/toggle_power(powerfail = 0)
	active = !active
	if(active)
		use_power = ACTIVE_POWER_USE
		visible_message("The [src.name] starts up.")
	else
		use_power = !powerfail
		visible_message("The [src.name] shuts down.")
	update_icon()
	return

/obj/machinery/power/am_control_unit/proc/check_shield_icons()//Forces icon_update for all shields
	if(shield_icon_delay)
		return
	shield_icon_delay = 1
	if(update_shield_icons == 2)//2 means to clear everything and rebuild
		for(var/obj/machinery/am_shielding/AMS in linked_shielding)
			if(AMS.processing)
				AMS.shutdown_core()
			AMS.control_unit = null
			addtimer(CALLBACK(AMS, TYPE_PROC_REF(/obj/machinery/am_shielding, controllerscan)), 10)
		linked_shielding = list()
	else
		for(var/obj/machinery/am_shielding/AMS in linked_shielding)
			AMS.update_icon()
	addtimer(CALLBACK(src, PROC_REF(reset_shield_icon_delay)), 20)

/obj/machinery/power/am_control_unit/proc/reset_shield_icon_delay()
	shield_icon_delay = 0

/obj/machinery/power/am_control_unit/proc/check_core_stability()
	if(stored_core_stability_delay || linked_cores.len <= 0)
		return
	stored_core_stability_delay = 1
	stored_core_stability = 0
	for(var/obj/machinery/am_shielding/AMS in linked_cores)
		stored_core_stability += AMS.stability
	stored_core_stability/=linked_cores.len
	addtimer(CALLBACK(src, PROC_REF(reset_stored_core_stability_delay)), 40)

/obj/machinery/power/am_control_unit/proc/reset_stored_core_stability_delay()
	stored_core_stability_delay = 0

/obj/machinery/power/am_control_unit/ui_interact(mob/user)
	if (!(user.skill_check(SKILL_SCIENCE, REGULAR_CHECK) || user.skill_check(SKILL_REPAIR, REGULAR_CHECK)))
		to_chat(user, span_warning("You don't even know where to start with that."))
		return
	. = ..()
	if((get_dist(src, user) > 1) || (stat & (BROKEN|NOPOWER)))
		if(!isAI(user))
			user.unset_machine()
			user << browse(null, "window=AMcontrol")
			return

	var/dat = ""
	dat += "Fission Control Panel<BR>"
	dat += "<A href='byond://?src=[REF(src)];close=1'>Close</A><BR>"
	dat += "<A href='byond://?src=[REF(src)];refresh=1'>Refresh</A><BR>"
	dat += "<A href='byond://?src=[REF(src)];refreshicons=1'>Force Shielding Update</A><BR><BR>"
	dat += "Status: [(active?"Injecting":"Standby")] <BR>"
	dat += "<A href='byond://?src=[REF(src)];togglestatus=1'>Toggle Status</A><BR>"

	dat += "Stability: [stability]%<BR>"
	dat += "Reactor parts: [linked_shielding.len]<BR>"//TODO: perhaps add some sort of stability check
	dat += "Cores: [linked_cores.len]<BR><BR>"
	dat += "-Current Efficiency: [reported_core_efficiency]<BR>"
	dat += "-Average Stability: [stored_core_stability] <A href='byond://?src=[REF(src)];refreshstability=1'>(update)</A><BR>"
	dat += "Last Produced: [DisplayPower(stored_power)]<BR>"

	dat += "Fuel: "
	if(!fueljar)
		dat += "<BR>No fuel rod detected."
	else
		dat += "<A href='byond://?src=[REF(src)];ejectjar=1'>Eject</A><BR>"
		dat += "- [fueljar.fuel]/[fueljar.fuel_max] Units<BR>"

		dat += "- Fuel Rod Exposure: [fuel_injection]<BR>"
		dat += "- <A href='byond://?src=[REF(src)];strengthdown=1'>--</A>|<A href='byond://?src=[REF(src)];strengthup=1'>++</A><BR><BR>"


	user << browse(HTML_SKELETON(dat), "window=AMcontrol;size=420x500")
	onclose(user, "AMcontrol")
	return


/obj/machinery/power/am_control_unit/Topic(href, href_list)
	if(..())
		return

	if(href_list["close"])
		usr << browse(null, "window=AMcontrol")
		usr.unset_machine()
		return

	if(href_list["togglestatus"])
		toggle_power()

	if(href_list["refreshicons"])
		update_shield_icons = 1

	if(href_list["ejectjar"])
		if(fueljar)
			fueljar.forceMove(drop_location())
			fueljar = null
			//fueljar.control_unit = null currently it does not care where it is
			//update_icon() when we have the icon for it

	if(href_list["strengthup"])
		fuel_injection++
		var/message = "[key_name(usr)] has changed the fuel injection to [fuel_injection] for the AM."
		log_game(message)
		log_admin(message)
		message_admins(message)

	if(href_list["strengthdown"])
		fuel_injection--
		if(fuel_injection < 0)
			fuel_injection = 0
		var/message = "[key_name(usr)] has changed the fuel injection to [fuel_injection] for the AM."
		log_game(message)
		log_admin(message)
		message_admins(message)


	if(href_list["refreshstability"])
		check_core_stability()

	updateDialog()
	return
