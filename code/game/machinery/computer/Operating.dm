#define MENU_OPERATION 1
#define MENU_SURGERIES 2

/obj/machinery/computer/operating
	name = "operating computer"
	desc = "Monitors patient vitals and displays surgery steps. Can be loaded with surgery disks to perform experimental procedures."
	icon_state = "fallout_console"
	icon_screen = "fallout_screen_operating_empty"
	icon_keyboard = "fallout_attatchments_operating"
	circuit = /obj/item/circuitboard/computer/operating
	var/mob/living/carbon/human/patient
	var/obj/structure/table/optable/table
	var/list/advanced_surgeries = list()
	var/datum/techweb/linked_techweb
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/operating/process()
	if (table)
		table.check_patient()
		patient = table.patient
	if (!patient)
		icon_screen = "fallout_screen_operating_empty"
	else
		switch(patient.stat)
			if(CONSCIOUS)
				icon_screen = "fallout_screen_operating_alive"
			if(SOFT_CRIT)
				icon_screen = "fallout_screen_operating_crit"
			if(UNCONSCIOUS)
				icon_screen = "fallout_screen_operating_crit"
			if(DEAD)
				icon_screen = "fallout_screen_operating_dead"
	why_overlays()

/obj/machinery/computer/operating/Initialize()
	. = ..()
	for(var/obj/machinery/computer/rdconsole/console in orange(8, loc))
		linked_techweb = console.stored_research
		break
	linked_techweb = linked_techweb ? linked_techweb : SSresearch.science_tech
	find_table()

/obj/machinery/computer/operating/bos

/obj/machinery/computer/operating/followers

/obj/machinery/computer/operating/followers/Initialize()
	. = ..()
	linked_techweb = SSresearch.followers_tech

/obj/machinery/computer/operating/bos/Initialize()
	. = ..()
	linked_techweb = SSresearch.bos_tech

/obj/machinery/computer/operating/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/disk/surgery))
		user.visible_message("[user] begins to load \the [O] in \the [src]...",
			"You begin to load a surgery protocol from \the [O]...",
			"You hear the chatter of a floppy drive.")
		var/obj/item/disk/surgery/D = O
		if(do_after(user, 10, target = src))
			advanced_surgeries |= D.surgeries
		return TRUE
	return ..()

/obj/machinery/computer/operating/proc/sync_surgeries()
	for(var/i in linked_techweb.researched_designs)
		var/datum/design/surgery/D = SSresearch.techweb_design_by_id(i)
		if(!istype(D))
			continue
		advanced_surgeries |= D.surgery

/obj/machinery/computer/operating/proc/find_table()
	for(var/direction in GLOB.cardinals)
		table = locate(/obj/structure/table/optable, get_step(src, direction))
		if(table)
			table.computer = src
			break

/obj/machinery/computer/operating/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/computer/operating/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OperatingComputer", name)
		ui.open()

/obj/machinery/computer/operating/ui_data(mob/user)
	var/list/data = list()
	data["table"] = table
	if(table)
		var/list/surgeries = list()
		for(var/X in advanced_surgeries)
			var/datum/surgery/S = X
			var/list/surgery = list()
			surgery["name"] = initial(S.name)
			surgery["desc"] = initial(S.desc)
			surgeries += list(surgery)
		data["surgeries"] = surgeries
		if(table.check_patient())
			data["patient"] = list()
			patient = table.patient
			switch(patient.stat)
				if(CONSCIOUS)
					data["patient"]["stat"] = "Conscious"
					data["patient"]["statstate"] = "good"
				if(SOFT_CRIT)
					data["patient"]["stat"] = "Conscious"
					data["patient"]["statstate"] = "average"
				if(UNCONSCIOUS)
					data["patient"]["stat"] = "Unconscious"
					data["patient"]["statstate"] = "average"
				if(DEAD)
					data["patient"]["stat"] = "Dead"
					data["patient"]["statstate"] = "bad"
			data["patient"]["health"] = patient.health
			data["patient"]["blood_type"] = patient.dna.blood_type
			data["patient"]["maxHealth"] = patient.maxHealth
			data["patient"]["minHealth"] = HEALTH_THRESHOLD_DEAD
			data["patient"]["bruteLoss"] = patient.getBruteLoss()
			data["patient"]["fireLoss"] = patient.getFireLoss()
			data["patient"]["toxLoss"] = patient.getToxLoss()
			data["patient"]["oxyLoss"] = patient.getOxyLoss()
			if(patient.surgeries.len)
				data["procedures"] = list()
				for(var/datum/surgery/procedure in patient.surgeries)
					var/datum/surgery_step/surgery_step = procedure.get_surgery_step()
					var/chems_needed = surgery_step.get_chem_list()
					var/alternative_step
					var/alt_chems_needed = ""
					if(surgery_step.repeatable)
						var/datum/surgery_step/next_step = procedure.get_surgery_next_step()
						if(next_step)
							alternative_step = capitalize(next_step.name)
							alt_chems_needed = next_step.get_chem_list()
						else
							alternative_step = "Finish operation"
					data["procedures"] += list(list(
						"name" = capitalize(procedure.name),
						"next_step" = capitalize(surgery_step.name),
						"chems_needed" = chems_needed,
						"alternative_step" = alternative_step,
						"alt_chems_needed" = alt_chems_needed
					))
		else
			data["patient"] = null
			return data
	switch(patient.stat)
		if(CONSCIOUS)
			data["patient"]["stat"] = "Conscious"
			data["patient"]["statstate"] = "good"
		if(SOFT_CRIT)
			data["patient"]["stat"] = "Conscious"
			data["patient"]["statstate"] = "average"
		if(UNCONSCIOUS)
			data["patient"]["stat"] = "Unconscious"
			data["patient"]["statstate"] = "average"
		if(DEAD)
			data["patient"]["stat"] = "Dead"
			data["patient"]["statstate"] = "bad"
	data["patient"]["health"] = patient.health
	data["patient"]["blood_type"] = patient.dna.blood_type
	data["patient"]["maxHealth"] = patient.maxHealth
	data["patient"]["minHealth"] = HEALTH_THRESHOLD_DEAD
	data["patient"]["bruteLoss"] = patient.getBruteLoss()
	data["patient"]["fireLoss"] = patient.getFireLoss()
	data["patient"]["toxLoss"] = patient.getToxLoss()
	data["patient"]["oxyLoss"] = patient.getOxyLoss()
	data["procedures"] = list()
	if(patient.surgeries.len)
		for(var/datum/surgery/procedure in patient.surgeries)
			var/datum/surgery_step/surgery_step = procedure.get_surgery_step()
			var/chems_needed = surgery_step.get_chem_list()
			var/alternative_step
			var/alt_chems_needed = ""
			if(surgery_step.repeatable)
				var/datum/surgery_step/next_step = procedure.get_surgery_next_step()
				if(next_step)
					alternative_step = capitalize(next_step.name)
					alt_chems_needed = next_step.get_chem_list()
				else
					alternative_step = "Finish operation"
			data["procedures"] += list(list(
				"name" = capitalize("[parse_zone(procedure.location)] [procedure.name]"),
				"next_step" = capitalize(surgery_step.name),
				"chems_needed" = chems_needed,
				"alternative_step" = alternative_step,
				"alt_chems_needed" = alt_chems_needed
			))
	return data



/obj/machinery/computer/operating/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("sync")
			sync_surgeries()
			. = TRUE
	. = TRUE

#undef MENU_OPERATION
#undef MENU_SURGERIES
