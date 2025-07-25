/obj/item/transfer_valve
	icon = 'icons/obj/assemblies.dmi'
	name = "tank transfer valve"
	icon_state = "valve_1"
	item_state = "ttv"
	lefthand_file = 'icons/mob/inhands/weapons/bombs_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/bombs_righthand.dmi'
	desc = "Regulates the transfer of air between two tanks."
	w_class = WEIGHT_CLASS_BULKY
	var/obj/item/tank/tank_one
	var/obj/item/tank/tank_two
	var/obj/item/assembly/attached_device
	var/mob/attacher = null
	var/valve_open = FALSE
	var/toggle = 1
	var/ui_x = 310
	var/ui_y = 320

/obj/item/transfer_valve/Initialize()
	. = ..()
	
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/transfer_valve/IsAssemblyHolder()
	return TRUE

/obj/item/transfer_valve/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/tank))
		if(tank_one && tank_two)
			to_chat(user, span_warning("There are already two tanks attached, remove one first!"))
			return

		if(!tank_one)
			if(!user.transferItemToLoc(item, src))
				return
			tank_one = item
			to_chat(user, span_notice("You attach the tank to the transfer valve."))
		else if(!tank_two)
			if(!user.transferItemToLoc(item, src))
				return
			tank_two = item
			to_chat(user, span_notice("You attach the tank to the transfer valve."))

		update_icon()
//TODO: Have this take an assemblyholder
	else if(isassembly(item))
		var/obj/item/assembly/A = item
		if(A.secured)
			to_chat(user, span_notice("The device is secured."))
			return
		if(attached_device)
			to_chat(user, span_warning("There is already a device attached to the valve, remove it first!"))
			return
		if(!user.transferItemToLoc(item, src))
			return
		attached_device = A
		to_chat(user, span_notice("You attach the [item] to the valve controls and secure it."))
		A.holder = src
		A.toggle_secure()	//this calls update_icon(), which calls update_icon() on the holder (i.e. the bomb).

		GLOB.bombers += "[key_name(user)] attached a [item] to a transfer valve."
		message_admins("[ADMIN_LOOKUPFLW(user)] attached a [item] to a transfer valve.")
		log_game("[key_name(user)] attached a [item] to a transfer valve.")
		attacher = user
	return

//Attached device memes
/obj/item/transfer_valve/Move()
	. = ..()
	if(attached_device)
		attached_device.holder_movement()

/obj/item/transfer_valve/dropped(mob/user)
	. = ..()
	if(attached_device)
		attached_device.dropped(user)

/obj/item/transfer_valve/on_found(mob/finder)
	if(attached_device)
		attached_device.on_found(finder)

/obj/item/transfer_valve/proc/on_entered(atom/movable/AM as mob|obj)
	SIGNAL_HANDLER
	if(attached_device)
		INVOKE_ASYNC(attached_device, PROC_REF(on_entered), AM)

/obj/item/transfer_valve/on_attack_hand()//Triggers mousetraps
	. = ..()
	if(.)
		return
	if(attached_device)
		attached_device.attack_hand()

//These keep attached devices synced up, for example a TTV with a mouse trap being found in a bag so it's triggered, or moving the TTV with an infrared beam sensor to update the beam's direction.


/obj/item/transfer_valve/attack_self(mob/user)
	user.set_machine(src)
	var/dat = {"<B> Valve properties: </B>
	<BR> <B> Attachment one:</B> [tank_one] [tank_one ? "<A href='byond://?src=[REF(src)];tankone=1'>Remove</A>" : ""]
	<BR> <B> Attachment two:</B> [tank_two] [tank_two ? "<A href='byond://?src=[REF(src)];tanktwo=1'>Remove</A>" : ""]
	<BR> <B> Valve attachment:</B> [attached_device ? "<A href='byond://?src=[REF(src)];device=1'>[attached_device]</A>" : "None"] [attached_device ? "<A href='byond://?src=[REF(src)];rem_device=1'>Remove</A>" : ""]
	<BR> <B> Valve status: </B> [ valve_open ? "<A href='byond://?src=[REF(src)];open=1'>Closed</A> <B>Open</B>" : "<B>Closed</B> <A href='byond://?src=[REF(src)];open=1'>Open</A>"]"}

	var/datum/browser/popup = new(user, "trans_valve", name)
	popup.set_content(dat)
	popup.open()
	return

/obj/item/transfer_valve/Topic(href, href_list)
	..()
	if(!usr.canUseTopic(src))
		return
	if(tank_one && href_list["tankone"])
		split_gases()
		valve_open = FALSE
		tank_one.forceMove(drop_location())
		tank_one = null
		update_icon()
	else if(tank_two && href_list["tanktwo"])
		split_gases()
		valve_open = FALSE
		tank_two.forceMove(drop_location())
		tank_two = null
		update_icon()
	else if(href_list["open"])
		toggle_valve()
	else if(attached_device)
		if(href_list["rem_device"])
			attached_device.on_detach()
			attached_device = null
			update_icon()
		if(href_list["device"])
			attached_device.attack_self(usr)

	attack_self(usr)
	add_fingerprint(usr)

/obj/item/transfer_valve/proc/process_activation(obj/item/D)
	if(toggle)
		toggle = FALSE
		toggle_valve()
		addtimer(CALLBACK(src, PROC_REF(toggle_off)), 5)	//To stop a signal being spammed from a proxy sensor constantly going off or whatever

/obj/item/transfer_valve/proc/toggle_off()
	toggle = TRUE

/obj/item/transfer_valve/update_icon()
	cut_overlays()
	underlays = null

	if(!tank_one && !tank_two && !attached_device)
		icon_state = "valve_1"
		return
	icon_state = "valve"

	if(tank_one)
		add_overlay("[tank_one.icon_state]")
	if(tank_two)
		var/icon/J = new(icon, icon_state = "[tank_two.icon_state]")
		J.Shift(WEST, 13)
		underlays += J
	if(attached_device)
		add_overlay("device")
		if(istype(attached_device, /obj/item/assembly/infra))
			var/obj/item/assembly/infra/sensor = attached_device
			if(sensor.on && sensor.visible)
				add_overlay("proxy_beam")

/obj/item/transfer_valve/proc/merge_gases(datum/gas_mixture/target, change_volume = TRUE)
	var/target_self = FALSE
	if(!target || (target == tank_one.air_contents))
		target = tank_two.air_contents
	if(target == tank_two.air_contents)
		target_self = TRUE
	if(change_volume)
		if(!target_self)
			target.set_volume(target.return_volume() + tank_two.volume)
		target.set_volume(target.return_volume() + tank_one.air_contents.return_volume())
	tank_one.air_contents.transfer_ratio_to(target, 1)
	if(!target_self)
		tank_two.air_contents.transfer_ratio_to(target, 1)

/obj/item/transfer_valve/proc/split_gases()
	if (!valve_open || !tank_one || !tank_two)
		return
	var/ratio1 = tank_one.air_contents.return_volume()/tank_two.air_contents.return_volume()
	tank_two.air_contents.transfer_ratio_to(tank_one.air_contents, ratio1)
	tank_two.air_contents.set_volume(tank_two.air_contents.return_volume() - tank_one.air_contents.return_volume())

/*
	Exadv1: I know this isn't how it's going to work, but this was just to check
	it explodes properly when it gets a signal (and it does).
*/
/obj/item/transfer_valve/proc/toggle_valve()
	if(!valve_open && tank_one && tank_two)
		valve_open = TRUE
		var/turf/bombturf = get_turf(src)

		var/attachment
		if(attached_device)
			if(istype(attached_device, /obj/item/assembly/signaler))
				attachment = "<A href='byond://?_src_=holder;[HrefToken()];secrets=list_signalers'>[attached_device]</A>"
			else
				attachment = attached_device

		var/admin_attachment_message
		var/attachment_message
		if(attachment)
			admin_attachment_message = " with [attachment] attached by [attacher ? ADMIN_LOOKUPFLW(attacher) : "Unknown"]"
			attachment_message = " with [attachment] attached by [attacher ? key_name_admin(attacher) : "Unknown"]"

		var/mob/bomber = get_mob_by_key(fingerprintslast)
		var/admin_bomber_message
		var/bomber_message
		if(bomber)
			admin_bomber_message = " - Last touched by: [ADMIN_LOOKUPFLW(bomber)]"
			bomber_message = " - Last touched by: [key_name_admin(bomber)]"


		var/admin_bomb_message = "Bomb valve opened in [ADMIN_VERBOSEJMP(bombturf)][admin_attachment_message][admin_bomber_message]"
		GLOB.bombers += admin_bomb_message
		message_admins(admin_bomb_message, 0, 1)
		log_game("Bomb valve opened in [AREACOORD(bombturf)][attachment_message][bomber_message]")

		merge_gases()
		for(var/i in 1 to 6)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/, update_icon)), 20 + (i - 1) * 10)

	else if(valve_open && tank_one && tank_two)
		split_gases()
		valve_open = FALSE
		update_icon()

/*
	This doesn't do anything but the timer etc. expects it to be here
	eventually maybe have it update icon to show state (timer, prox etc.) like old bombs
*/
/obj/item/transfer_valve/proc/c_state()
	return

/obj/item/transfer_valve/ui_state(mob/user)
	return GLOB.hands_state

/obj/item/transfer_valve/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TransferValve", name)
		ui.open()

/obj/item/transfer_valve/ui_data(mob/user)
	var/list/data = list()
	data["tank_one"] = tank_one
	data["tank_two"] = tank_two
	data["attached_device"] = attached_device
	data["valve"] = valve_open
	return data

/obj/item/transfer_valve/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("tankone")
			if(tank_one)
				split_gases()
				valve_open = FALSE
				tank_one.forceMove(drop_location())
				tank_one = null
				. = TRUE
		if("tanktwo")
			if(tank_two)
				split_gases()
				valve_open = FALSE
				tank_two.forceMove(drop_location())
				tank_two = null
				. = TRUE
		if("toggle")
			toggle_valve()
			. = TRUE
		if("device")
			if(attached_device)
				attached_device.attack_self(usr)
				. = TRUE
		if("remove_device")
			if(attached_device)
				attached_device.on_detach()
				attached_device = null
				. = TRUE

	update_icon()

/**
 * Returns if this is ready to be detonated. Checks if both tanks are in place.
 */
/obj/item/transfer_valve/proc/ready()
	return tank_one && tank_two
