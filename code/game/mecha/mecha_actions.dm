//////////////////////////////////////// Action Buttons ///////////////////////////////////////////////

/obj/mecha/proc/GrantActions(mob/living/user, human_occupant = 0)
	if(human_occupant)
		eject_action.Grant(user, src)
	internals_action.Grant(user, src)
	cycle_action.Grant(user, src)
	if(haslights)
		lights_action.Grant(user, src)
	stats_action.Grant(user, src)
	if(canstrafe)
		strafing_action.Grant(user, src)


/obj/mecha/proc/RemoveActions(mob/living/user, human_occupant = 0)
	if(human_occupant)
		eject_action.Remove(user)
	internals_action.Remove(user)
	cycle_action.Remove(user)
	if(haslights)
		lights_action.Remove(user)
	stats_action.Remove(user)
	if(canstrafe)
		strafing_action.Remove(user)


/datum/action/innate/mecha
	check_flags = AB_CHECK_RESTRAINED | AB_CHECK_STUN | AB_CHECK_CONSCIOUS
	icon_icon = 'icons/mob/actions/actions_mecha.dmi'
	var/obj/mecha/chassis

/datum/action/innate/mecha/Grant(mob/living/L, obj/mecha/M)
	if(M)
		chassis = M
	..()

/datum/action/innate/mecha/Destroy()
	chassis = null
	return ..()

/datum/action/innate/mecha/mech_eject
	name = "Eject From Mech"
	button_icon_state = "mech_eject"

/datum/action/innate/mecha/mech_eject/Activate()
	if(!owner)
		return
	if(!chassis || chassis.occupant != owner)
		return
	chassis.is_currently_ejecting = TRUE
	to_chat(owner, "<span class='notice'>You begin the ejection procedure. Equipment is disabled during this process. Hold still to finish ejecting.<span>")
	if(do_after(chassis.occupant,chassis.exit_delay, target = chassis))
		to_chat(owner, "<span class='notice'>You exit the mech.<span>")
		chassis.go_out()
	else
		to_chat(owner, "<span class='notice'>You stop exiting the mech. Weapons are enabled again.<span>")
	chassis.is_currently_ejecting = FALSE


/datum/action/innate/mecha/mech_toggle_internals
	name = "Toggle Internal Airtank Usage"
	button_icon_state = "mech_internals_off"

/datum/action/innate/mecha/mech_toggle_internals/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.use_internal_tank = !chassis.use_internal_tank
	button_icon_state = "mech_internals_[chassis.use_internal_tank ? "on" : "off"]"
	chassis.occupant_message("Now taking air from [chassis.use_internal_tank?"internal airtank":"environment"].")
	chassis.mecha_log_message("Now taking air from [chassis.use_internal_tank?"internal airtank":"environment"].")
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_cycle_equip
	name = "Cycle Equipment"
	button_icon_state = "mech_cycle_equip_off"

/datum/action/innate/mecha/mech_cycle_equip/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return

	var/list/available_equipment = list()
	for(var/obj/item/mecha_parts/mecha_equipment/M in chassis.equipment)
		if(M.selectable)
			available_equipment += M

	if(available_equipment.len == 0)
		chassis.occupant_message("No equipment available.")
		playsound(chassis,'sound/machines/terminal_error.ogg', 40, FALSE)
		return
	if(!chassis.selected)
		chassis.selected = available_equipment[1]
		chassis.occupant_message("You select [chassis.selected]")
		send_byjax(chassis.occupant,"exosuit.browser","eq_list",chassis.get_equipment_list())
		button_icon_state = "mech_cycle_equip_on"
		playsound(chassis,'sound/machines/piston_raise.ogg', 40, TRUE)
		UpdateButtonIcon()
		return
	var/number = 0
	for(var/A in available_equipment)
		number++
		if(A == chassis.selected)
			if(available_equipment.len == number)
				chassis.selected = null
				chassis.occupant_message("You switch to no equipment")
				button_icon_state = "mech_cycle_equip_off"
				playsound(chassis,'sound/machines/piston_lower.ogg', 40, TRUE)
			else
				chassis.selected = available_equipment[number+1]
				chassis.occupant_message("You switch to [chassis.selected]")
				button_icon_state = "mech_cycle_equip_on"
				playsound(chassis,'sound/machines/piston_raise.ogg', 40, TRUE)
			send_byjax(chassis.occupant,"exosuit.browser","eq_list",chassis.get_equipment_list())
			UpdateButtonIcon()
			return


/datum/action/innate/mecha/mech_toggle_lights
	name = "Toggle Lights"
	button_icon_state = "mech_lights_off"

/datum/action/innate/mecha/mech_toggle_lights/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.lights = !chassis.lights
	if(chassis.lights)
		chassis.set_light(chassis.lights_power)
		button_icon_state = "mech_lights_on"
	else
		chassis.set_light(-chassis.lights_power)
		button_icon_state = "mech_lights_off"
	chassis.occupant_message("Toggled lights [chassis.lights?"on":"off"].")
	playsound(chassis,'sound/machines/clockcult/brass_skewer.ogg', 40, TRUE)
	chassis.mecha_log_message("Toggled lights [chassis.lights?"on":"off"].")
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_view_stats
	name = "View Stats"
	button_icon_state = "mech_view_stats"

/datum/action/innate/mecha/mech_view_stats/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.occupant << browse(HTML_SKELETON(chassis.get_stats_html()), "window=exosuit")


/datum/action/innate/mecha/strafe
	name = "Toggle Strafing. Disabled when Alt is held."
	button_icon_state = "strafe"

/datum/action/innate/mecha/strafe/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return

	chassis.toggle_strafe()

/obj/mecha/AltClick(mob/living/user)
	. = ..()
	if((user == occupant) && user.canUseTopic(src) && canstrafe == TRUE)
		toggle_strafe()
		return TRUE

/obj/mecha/proc/toggle_strafe()
	strafe = !strafe

	occupant_message("Toggled strafing mode [strafe?"on":"off"].")
	mecha_log_message("Toggled strafing mode [strafe?"on":"off"].")
	strafing_action.UpdateButtonIcon()

//////////////////////////////////////// Specific Ability Actions  ///////////////////////////////////////////////
//Need to be granted by the mech type, Not default abilities.

/datum/action/innate/mecha/mech_toggle_thrusters
	name = "Toggle Thrusters"
	button_icon_state = "mech_thrusters_off"

/datum/action/innate/mecha/mech_toggle_thrusters/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.get_charge() > 0)
		chassis.thrusters_active = !chassis.thrusters_active
		button_icon_state = "mech_thrusters_[chassis.thrusters_active ? "on" : "off"]"
		chassis.mecha_log_message("Toggled thrusters.")
		chassis.occupant_message("<font color='[chassis.thrusters_active ?"blue":"red"]'>Thrusters [chassis.thrusters_active ?"en":"dis"]abled.")


/datum/action/innate/mecha/mech_defense_mode
	name = "Toggle Defense Mode"
	button_icon_state = "mech_defense_mode_off"
	var/image/def_overlay

/datum/action/innate/mecha/mech_defense_mode/Activate(forced_state = FALSE)
	SEND_SIGNAL(chassis, COMSIG_MECHA_ACTION_ACTIVATE, args) ///Signal sent to the mech, to be handed to the shield. See durand.dm for more details

/datum/action/innate/mecha/mech_overload_mode
	name = "Toggle leg actuators overload"
	button_icon_state = "mech_overload_off"

/datum/action/innate/mecha/mech_overload_mode/Activate(forced_state = null)
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(!isnull(forced_state))
		chassis.leg_overload_mode = forced_state
	else
		chassis.leg_overload_mode = !chassis.leg_overload_mode
	button_icon_state = "mech_overload_[chassis.leg_overload_mode ? "on" : "off"]"
	chassis.mecha_log_message("Toggled leg actuators overload.")
	if(chassis.leg_overload_mode)
		chassis.leg_overload_mode = 1
		chassis.bumpsmash = 1
		chassis.step_in = max(1, round(chassis.step_in*0.75, 0.25))
		chassis.step_energy_drain = max(chassis.overload_step_energy_drain_min,chassis.step_energy_drain*chassis.leg_overload_coeff)
		chassis.occupant_message(span_danger("You enable leg actuators overload."))
	else
		chassis.leg_overload_mode = 0
		chassis.bumpsmash = 0
		chassis.step_in = initial(chassis.step_in)
		chassis.step_energy_drain = chassis.normal_step_energy_drain
		chassis.occupant_message(span_notice("You disable leg actuators overload."))
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_smoke
	name = "Regenerative Smoke-shot"
	button_icon_state = "mech_smoke"

/datum/action/innate/mecha/mech_smoke/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(chassis.smoke_ready && chassis.smoke)
		chassis.smoke_system.start()
		chassis.smoke_ready = 0
		spawn(chassis.smoke_cooldown)
			chassis.smoke_ready = 1


/datum/action/innate/mecha/mech_zoom
	name = "Zoom"
	button_icon_state = "mech_zoom_off"

/datum/action/innate/mecha/mech_zoom/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	if(owner.client)
		chassis.zoom_mode = !chassis.zoom_mode
		button_icon_state = "mech_zoom_[chassis.zoom_mode ? "on" : "off"]"
		chassis.mecha_log_message("Toggled zoom mode.")
		chassis.occupant_message("<font color='[chassis.zoom_mode?"blue":"red"]'>Zoom mode [chassis.zoom_mode?"en":"dis"]abled.</font>")
		if(chassis.zoom_mode)
			owner.client.change_view(12)
			SEND_SOUND(owner, sound('sound/mecha/imag_enh.ogg',volume=50))
		else
			owner.client.change_view(CONFIG_GET(string/default_view)) //world.view - default mob view size
		UpdateButtonIcon()

/datum/action/innate/mecha/mech_switch_damtype
	name = "Reconfigure arm microtool arrays"
	button_icon_state = "mech_damtype_brute"

/datum/action/innate/mecha/mech_switch_damtype/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	var/new_damtype
	switch(chassis.damtype)
		if("tox")
			new_damtype = "brute"
			chassis.occupant_message("Your exosuit's hands form into fists.")
		if("brute")
			new_damtype = "fire"
			chassis.occupant_message("A torch tip extends from your exosuit's hand, glowing red.")
		if("fire")
			new_damtype = "tox"
			chassis.occupant_message("A bone-chillingly thick plasteel needle protracts from the exosuit's palm.")
	chassis.damtype = new_damtype
	button_icon_state = "mech_damtype_[new_damtype]"
	playsound(src, 'sound/mecha/mechmove01.ogg', 50, 1)
	UpdateButtonIcon()

/datum/action/innate/mecha/mech_toggle_phasing
	name = "Toggle Phasing"
	button_icon_state = "mech_phasing_off"

/datum/action/innate/mecha/mech_toggle_phasing/Activate()
	if(!owner || !chassis || chassis.occupant != owner)
		return
	chassis.phasing = !chassis.phasing
	button_icon_state = "mech_phasing_[chassis.phasing ? "on" : "off"]"
	chassis.occupant_message("<font color=\"[chassis.phasing?"#00f\">En":"#f00\">Dis"]abled phasing.</font>")
	UpdateButtonIcon()
