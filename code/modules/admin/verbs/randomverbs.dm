/client/proc/cmd_admin_drop_everything(mob/M in GLOB.mob_list)
	set category = null
	set name = "Drop Everything"
	if(!check_rights(R_ADMIN))
		return

	var/confirm = alert(src, "Make [M] drop everything?", "Message", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/item/W in M)
		if(!M.dropItemToGround(W))
			qdel(W)
			M.regenerate_icons()

	log_admin("[key_name(usr)] made [key_name(M)] drop everything!")
	var/msg = "[key_name_admin(usr)] made [ADMIN_LOOKUPFLW(M)] drop everything!"
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Drop Everything") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_subtle_message(mob/M in GLOB.mob_list)
	set category = "Admin.Events"
	set name = "Subtle Message"

	if(!ismob(M))
		return
	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_subtle_message() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_subtle_message() without admin perms.")
		return

	message_admins("[key_name_admin(src)] has started answering [ADMIN_LOOKUPFLW(M)]'s prayer.")
	var/msg = input("Message:", text("Subtle PM to [M.key]")) as text|null

	if (!msg)
		message_admins("[key_name_admin(src)] decided not to answer [ADMIN_LOOKUPFLW(M)]'s prayer")
		return
	if(usr)
		if (usr.client)
			if(usr.client.holder)
				to_chat(M, "<i>You hear a voice in your head... <b>[msg]</i></b>")

	log_admin("SubtlePM: [key_name(usr)] -> [key_name(M)] : [msg]")
	msg = "<span class='adminnotice'><b> SubtleMessage: [key_name_admin(usr)] -> [key_name_admin(M)] :</b> [msg]</span>"
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Subtle Message") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_headset_message(mob/M in GLOB.mob_list)
	set category = "Admin.Events"
	set name = "Headset Message"

	admin_headset_message(M)

/client/proc/admin_headset_message(mob/M in GLOB.mob_list, sender = null)
	var/mob/living/carbon/human/H = M

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use admin_headset_message() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use admin_headset_message() without admin perms.")
		return

	if(!istype(H))
		to_chat(usr, "This can only be used on instances of type /mob/living/carbon/human")
		return
	if(!istype(H.ears, /obj/item/radio/headset))
		to_chat(usr, "The person you are trying to contact is not wearing a headset.")
		return

	if (!sender)
		sender = input("Who is the message from?", "Sender") as null|anything in list(RADIO_CHANNEL_CENTCOM,RADIO_CHANNEL_SYNDICATE)
		if(!sender)
			return

	message_admins("[key_name_admin(src)] has started answering [key_name_admin(H)]'s [sender] request.")
	var/input = input("Please enter a message to reply to [key_name(H)] via their headset.","Outgoing message from [sender]", "") as text|null
	if(!input)
		message_admins("[key_name_admin(src)] decided not to answer [key_name_admin(H)]'s [sender] request.")
		return

	log_directed_talk(mob, H, input, LOG_ADMIN, "reply")
	message_admins("[key_name_admin(src)] replied to [key_name_admin(H)]'s [sender] message with: \"[input]\"")
	to_chat(H, "You hear something crackle in your ears for a moment before a voice speaks.  \"Please stand by for a message from [sender == "Syndicate" ? "your benefactor" : "Central Command"].  Message as follows[sender == "Syndicate" ? ", agent." : ":"] <span class='bold'>[input].</span> Message ends.\"")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Headset Message") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_mod_antag_rep(client/C in GLOB.clients, operation)
	set category = "Special Verbs"
	set name = "Modify Antagonist Reputation"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_mod_antag_rep() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_mod_antag_rep() without admin perms.")
		return

	var/msg = ""
	var/log_text = ""

	if(operation == "zero")
		log_text = "Set to 0"
		SSpersistence.antag_rep -= C.ckey
	else
		var/prompt = "Please enter the amount of reputation to [operation]:"

		if(operation == "set")
			prompt = "Please enter the new reputation value:"

		msg = input("Message:", prompt) as num|null

		if (!msg)
			return

		var/ANTAG_REP_MAXIMUM = CONFIG_GET(number/antag_rep_maximum)

		if(operation == "set")
			log_text = "Set to [num2text(msg)]"
			SSpersistence.antag_rep[C.ckey] = max(0, min(msg, ANTAG_REP_MAXIMUM))
		else if(operation == "add")
			log_text = "Added [num2text(msg)]"
			SSpersistence.antag_rep[C.ckey] = min(SSpersistence.antag_rep[C.ckey]+msg, ANTAG_REP_MAXIMUM)
		else if(operation == "subtract")
			log_text = "Subtracted [num2text(msg)]"
			SSpersistence.antag_rep[C.ckey] = max(SSpersistence.antag_rep[C.ckey]-msg, 0)
		else
			to_chat(src, "Invalid operation for antag rep modification: [operation] by user [key_name(usr)]")
			return

		if(SSpersistence.antag_rep[C.ckey] <= 0)
			SSpersistence.antag_rep -= C.ckey

	log_admin("[key_name(usr)]: Modified [key_name(C)]'s antagonist reputation [log_text]")
	message_admins(span_adminnotice("[key_name_admin(usr)]: Modified [key_name(C)]'s antagonist reputation ([log_text])"))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Modify Antagonist Reputation") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_world_narrate()
	set category = "Admin.Events"
	set name = "Global Narrate"

	if(!check_rights(R_SPAWN)) //fortuna edit. event manager change
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_world_narrate() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_world_narrate() without admin perms.")
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to everyone:")) as text|null

	if (!msg)
		return
	to_chat(world, "[msg]")
	log_admin("GlobalNarrate: [key_name(usr)] : [msg]")
	message_admins(span_adminnotice("[key_name_admin(usr)] Sent a global narrate"))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Global Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_direct_narrate(mob/M)
	set category = "Admin.Events"
	set name = "Direct Narrate"

	if(!check_rights(R_SPAWN)) //fortuna edit. event manager change
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_direct_narrate() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_direct_narrate() without admin perms.")
		return

	if(!M)
		M = input("Direct narrate to whom?", "Active Players") as null|anything in GLOB.player_list

	if(!M)
		return

	var/msg = input("Message:", text("Enter the text you wish to appear to your target:")) as text|null

	if( !msg )
		return

	to_chat(M, msg)
	log_admin("DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]): [msg]")
	msg = "<span class='adminnotice'><b> DirectNarrate: [key_name(usr)] to ([M.name]/[M.key]):</b> [msg]<BR></span>"
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Direct Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_local_narrate(atom/A)
	set category = "Admin.Events"
	set name = "Local Narrate"

	if(!check_rights(R_SPAWN)) //fortuna edit. event manager change
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_local_narrate() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_local_narrate() without admin perms.")
		return
	if(!A)
		return
	var/range = input("Range:", "Narrate to mobs within how many tiles:", 50) as num|null
	if(!range)
		return
	var/msg = input("Message:", text("Enter the text you wish to appear to everyone within view:")) as text|null
	if (!msg)
		return
	for(var/mob/M in view(range,A))
		to_chat(M, msg)

	log_admin("LocalNarrate: [key_name(usr)] at [AREACOORD(A)]: [msg]")
	message_admins("<span class='adminnotice'><b> LocalNarrate: [key_name_admin(usr)] at [ADMIN_VERBOSEJMP(A)]:</b> [msg]<BR></span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Local Narrate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_godmode(mob/M in GLOB.mob_list)
	set category = "Admin.Game"
	set name = "Godmode"
	if(!check_rights(R_SPAWN)) //fortuna edit. event manager change
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_godmode() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_godmode() without admin perms.")
		return

	M.status_flags ^= GODMODE
	to_chat(usr, span_adminnotice("Toggled [(M.status_flags & GODMODE) ? "ON" : "OFF"]"))

	log_admin("[key_name(usr)] has toggled [key_name(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]")
	var/msg = "[key_name_admin(usr)] has toggled [ADMIN_LOOKUPFLW(M)]'s nodamage to [(M.status_flags & GODMODE) ? "On" : "Off"]"
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Godmode", "[M.status_flags & GODMODE ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/proc/cmd_admin_mute(whom, mute_type, automute = 0)
	if(!whom)
		return

	var/muteunmute
	var/mute_string
	var/feedback_string
	switch(mute_type)
		if(MUTE_IC)
			mute_string = "IC (say and emote)"
			feedback_string = "IC"
		if(MUTE_OOC)
			mute_string = "OOC"
			feedback_string = "OOC"
		if(MUTE_PRAY)
			mute_string = "pray"
			feedback_string = "Pray"
		if(MUTE_ADMINHELP)
			mute_string = "adminhelp, admin PM and ASAY"
			feedback_string = "Adminhelp"
		if(MUTE_DEADCHAT)
			mute_string = "deadchat and DSAY"
			feedback_string = "Deadchat"
		if(MUTE_ALL)
			mute_string = "everything"
			feedback_string = "Everything"
		else
			return

	var/client/C
	if(istype(whom, /client))
		C = whom
	else if(istext(whom))
		C = GLOB.directory[whom]
	else
		return

	var/datum/preferences/P
	if(C)
		P = C.prefs
	else
		P = GLOB.preferences_datums[whom]
	if(!P)
		return

	if(automute)
		if(!CONFIG_GET(flag/automute_on))
			return
	else
		if(!check_rights())
			return

	if(automute)
		muteunmute = "auto-muted"
		P.muted |= mute_type
		log_admin("SPAM AUTOMUTE: [muteunmute] [key_name(whom)] from [mute_string]")
		message_admins("SPAM AUTOMUTE: [muteunmute] [key_name_admin(whom)] from [mute_string].")
		if(C)
			to_chat(C, "You have been [muteunmute] from [mute_string] by the SPAM AUTOMUTE system. Contact an admin.", confidential = TRUE)
		SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Auto Mute [feedback_string]", "1")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return

	if(P.muted & mute_type)
		muteunmute = "unmuted"
		P.muted &= ~mute_type
	else
		muteunmute = "muted"
		P.muted |= mute_type

	log_admin("[key_name(usr)] has [muteunmute] [key_name(whom)] from [mute_string]")
	message_admins("[key_name_admin(usr)] has [muteunmute] [key_name_admin(whom)] from [mute_string].")
	if(C)
		to_chat(C, "You have been [muteunmute] from [mute_string] by [key_name(usr, include_name = FALSE)].", confidential = TRUE)
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Mute [feedback_string]", "[P.muted & mute_type]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


//I use this proc for respawn character too. /N
/proc/create_xeno(ckey)
	if(!ckey)
		var/list/candidates = list()
		for(var/mob/M in GLOB.player_list)
			if(M.stat != DEAD)
				continue	//we are not dead!
			if(!(ROLE_ALIEN in M.client.prefs.be_special))
				continue	//we don't want to be an alium
			if(M.client.is_afk())
				continue	//we are afk
			if(M.mind && M.mind.current && M.mind.current.stat != DEAD)
				continue	//we have a live body we are tied to
			candidates += M.ckey
		if(candidates.len)
			ckey = input("Pick the player you want to respawn as a xeno.", "Suitable Candidates") as null|anything in candidates
		else
			to_chat(usr, span_danger("Error: create_xeno(): no suitable candidates."))
	if(!istext(ckey))
		return 0

	var/alien_caste = input(usr, "Please choose which caste to spawn.","Pick a caste",null) as null|anything in list("Queen","Praetorian","Hunter","Sentinel","Drone","Larva")
	var/obj/effect/landmark/spawn_here = GLOB.xeno_spawn.len ? pick(GLOB.xeno_spawn) : null
	var/mob/living/carbon/alien/new_xeno
	switch(alien_caste)
		if("Queen")
			new_xeno = new /mob/living/carbon/alien/humanoid/royal/queen(spawn_here)
		if("Praetorian")
			new_xeno = new /mob/living/carbon/alien/humanoid/royal/praetorian(spawn_here)
		if("Hunter")
			new_xeno = new /mob/living/carbon/alien/humanoid/hunter(spawn_here)
		if("Sentinel")
			new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(spawn_here)
		if("Drone")
			new_xeno = new /mob/living/carbon/alien/humanoid/drone(spawn_here)
		if("Larva")
			new_xeno = new /mob/living/carbon/alien/larva(spawn_here)
		else
			return 0
	if(!spawn_here)
		SSjob.SendToLateJoin(new_xeno, FALSE)

	new_xeno.ckey = ckey
	var/msg = span_notice("[key_name_admin(usr)] has spawned [ckey] as a filthy xeno [alien_caste].")
	message_admins(msg)
	admin_ticket_log(new_xeno, msg)
	return 1

/*
If a guy was gibbed and you want to revive him, this is a good way to do so.
Works kind of like entering the game with a new character. Character receives a new mind if they didn't have one.
Traitors and the like can also be revived with the previous role mostly intact.
/N */
/client/proc/respawn_character()
	set category = "Admin.Game"
	set name = "Respawn Character"
	set desc = "Respawn a person that has been gibbed/dusted/killed. They must be a ghost for this to work and preferably should not have a body to go back into."
	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use respawn_character() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use respawn_character() without admin perms.")
		return

	var/input = ckey(input(src, "Please specify which key will be respawned.", "Key", ""))
	if(!input)
		return

	var/mob/dead/observer/G_found
	for(var/mob/dead/observer/G in GLOB.player_list)
		if(G.ckey == input)
			G_found = G
			break

	if(!G_found)//If a ghost was not found.
		to_chat(usr, "<font color='red'>There is no active key like that in the game or the person is not currently a ghost.</font>")
		return

	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		//Check if they were an alien
		if(G_found.mind.assigned_role == ROLE_ALIEN)
			if(alert("This character appears to have been an alien. Would you like to respawn them as such?",,"Yes","No")=="Yes")
				var/turf/T
				if(GLOB.xeno_spawn.len)
					T = pick(GLOB.xeno_spawn)

				var/mob/living/carbon/alien/new_xeno
				switch(G_found.mind.special_role)//If they have a mind, we can determine which caste they were.
					if("Hunter")
						new_xeno = new /mob/living/carbon/alien/humanoid/hunter(T)
					if("Sentinel")
						new_xeno = new /mob/living/carbon/alien/humanoid/sentinel(T)
					if("Drone")
						new_xeno = new /mob/living/carbon/alien/humanoid/drone(T)
					if("Praetorian")
						new_xeno = new /mob/living/carbon/alien/humanoid/royal/praetorian(T)
					if("Queen")
						new_xeno = new /mob/living/carbon/alien/humanoid/royal/queen(T)
					else//If we don't know what special role they have, for whatever reason, or they're a larva.
						create_xeno(G_found.ckey)
						return

				if(!T)
					SSjob.SendToLateJoin(new_xeno, FALSE)

				//Now to give them their mind back.
				G_found.mind.transfer_to(new_xeno)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				G_found.transfer_ckey(new_xeno, FALSE)
				to_chat(new_xeno, "You have been fully respawned. Enjoy the game.")
				var/msg = span_adminnotice("[key_name_admin(usr)] has respawned [new_xeno.key] as a filthy xeno.")
				message_admins(msg)
				admin_ticket_log(new_xeno, msg)
				return	//all done. The ghost is auto-deleted

		//check if they were a monkey
		else if(findtext(G_found.real_name,"monkey"))
			if(alert("This character appears to have been a monkey. Would you like to respawn them as such?",,"Yes","No")=="Yes")
				var/mob/living/carbon/monkey/new_monkey = new
				SSjob.SendToLateJoin(new_monkey)
				G_found.mind.transfer_to(new_monkey)	//be careful when doing stuff like this! I've already checked the mind isn't in use
				G_found.transfer_ckey(new_monkey, FALSE)
				to_chat(new_monkey, "You have been fully respawned. Enjoy the game.")
				var/msg = span_adminnotice("[key_name_admin(usr)] has respawned [new_monkey.key] as a filthy xeno.")
				message_admins(msg)
				admin_ticket_log(new_monkey, msg)
				return	//all done. The ghost is auto-deleted


	//Ok, it's not a xeno or a monkey. So, spawn a human.
	var/mob/living/carbon/human/new_character = new//The mob being spawned.
	SSjob.SendToLateJoin(new_character)

	var/datum/data/record/record_found			//Referenced to later to either randomize or not randomize the character.
	if(G_found.mind && !G_found.mind.active)	//mind isn't currently in use by someone/something
		/*Try and locate a record for the person being respawned through GLOB.data_core.
		This isn't an exact science but it does the trick more often than not.*/
		var/id = md5("[G_found.real_name][G_found.mind.assigned_role]")

		record_found = find_record("id", id, GLOB.data_core.locked)

	if(record_found)//If they have a record we can determine a few things.
		new_character.real_name = record_found.fields["name"]
		new_character.gender = record_found.fields["gender"]
		new_character.age = record_found.fields["age"]
		new_character.hardset_dna(record_found.fields["identity"], record_found.fields["enzymes"], null, record_found.fields["name"], record_found.fields["blood_type"], new record_found.fields["species"], record_found.fields["features"])
	else
		var/datum/preferences/A = new()
		A.copy_to(new_character)
		A.real_name = G_found.real_name
		new_character.dna.update_dna_identity()

	new_character.name = new_character.real_name

	if(G_found.mind && !G_found.mind.active)
		G_found.mind.transfer_to(new_character)	//be careful when doing stuff like this! I've already checked the mind isn't in use
	else
		new_character.mind_initialize()
	if(!new_character.mind.assigned_role)
		new_character.mind.assigned_role = "Assistant"//If they somehow got a null assigned role.

	G_found.transfer_ckey(new_character, FALSE)

	/*
	The code below functions with the assumption that the mob is already a traitor if they have a special role.
	So all it does is re-equip the mob with powers and/or items. Or not, if they have no special role.
	If they don't have a mind, they obviously don't have a special role.
	*/

	//Two variables to properly announce later on.
	var/admin = key_name_admin(src)
	var/player_key = G_found.key

	//Now for special roles and equipment.
	var/datum/antagonist/traitor/traitordatum = new_character.mind.has_antag_datum(/datum/antagonist/traitor)
	if(traitordatum)
		SSjob.EquipRank(new_character, new_character.mind.assigned_role, 1)
		traitordatum.equip()


	switch(new_character.mind.special_role)
		if(ROLE_WIZARD)
			new_character.forceMove(pick(GLOB.wizardstart))
			var/datum/antagonist/wizard/A = new_character.mind.has_antag_datum(/datum/antagonist/wizard,TRUE)
			A.equip_wizard()
		if(ROLE_SYNDICATE)
			new_character.forceMove(pick(GLOB.nukeop_start))
			var/datum/antagonist/nukeop/N = new_character.mind.has_antag_datum(/datum/antagonist/nukeop,TRUE)
			N.equip_op()
		if(ROLE_NINJA)
			var/list/ninja_spawn = list()
			for(var/obj/effect/landmark/carpspawn/L in GLOB.landmarks_list)
				ninja_spawn += L
			var/datum/antagonist/ninja/ninjadatum = new_character.mind.has_antag_datum(/datum/antagonist/ninja)
			ninjadatum.equip_space_ninja()
			if(ninja_spawn.len)
				new_character.forceMove(pick(ninja_spawn))

		else//They may also be a cyborg or AI.
			switch(new_character.mind.assigned_role)
				if("Cyborg")//More rigging to make em' work and check if they're traitor.
					new_character = new_character.Robotize(TRUE)
				if("AI")
					new_character = new_character.AIize()
				else
					SSjob.EquipRank(new_character, new_character.mind.assigned_role, 1)//Or we simply equip them.

	//Announces the character on all the systems, based on the record.
	if(!issilicon(new_character))//If they are not a cyborg/AI.
		if(!record_found&&new_character.mind.assigned_role!=new_character.mind.special_role)//If there are no records for them. If they have a record, this info is already in there. MODE people are not announced anyway.
			//Power to the user!
			if(alert(new_character,"Warning: No data core entry detected. Would you like to announce the arrival of this character by adding them to various databases, such as medical records?",,"No","Yes")=="Yes")
				GLOB.data_core.manifest_inject(new_character)

			if(alert(new_character,"Would you like an active AI to announce this character?",,"No","Yes")=="Yes")
				AnnounceArrival(new_character, new_character.mind.assigned_role)

	var/msg = span_adminnotice("[admin] has respawned [player_key] as [new_character.real_name].")
	message_admins(msg)
	admin_ticket_log(new_character, msg)

	to_chat(new_character, "You have been fully respawned. Enjoy the game.")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Respawn Character") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	return new_character

/client/proc/cmd_admin_add_freeform_ai_law()
	set category = "Admin.Events"
	set name = "Add Custom AI law"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_add_freeform_ai_law() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_add_freeform_ai_law() without admin perms.")
		return

	var/input = input(usr, "Please enter anything you want the AI to do. Anything. Serious.", "What?", "") as text|null
	if(!input)
		return

	log_admin("Admin [key_name(usr)] has added a new AI law - [input]")
	message_admins("Admin [key_name_admin(usr)] has added a new AI law - [input]")

	var/show_log = alert(src, "Show ion message?", "Message", "Yes", "No")
	var/announce_ion_laws = (show_log == "Yes" ? 1 : -1)

	var/datum/round_event/ion_storm/add_law_only/ion = new()
	ion.announceEvent = announce_ion_laws
	ion.ionMessage = input

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Add Custom AI Law") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_rejuvenate(mob/living/M in GLOB.mob_list)
	set category = "Special Verbs"
	set name = "Rejuvenate"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_rejuvenate() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_rejuvenate() without admin perms.")
		return

	if(!mob)
		return
	if(!istype(M))
		alert("Cannot revive a ghost")
		return
	M.revive(full_heal = 1, admin_revive = 1)

	log_admin("[key_name(usr)] healed / revived [key_name(M)]")
	var/msg = span_danger("Admin [key_name_admin(usr)] healed / revived [ADMIN_LOOKUPFLW(M)]!")
	message_admins(msg)
	admin_ticket_log(M, msg)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Rejuvinate") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_create_centcom_report()
	set category = "Admin.Events"
	set name = "Create Command Report"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_create_centcom_report() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_create_centcom_report() without admin perms.")
		return

	var/input = input(usr, "Enter a Command Report. Ensure it makes sense IC.", "What?", "") as message|null
	if(!input)
		return

	var/confirm = alert(src, "Do you want to announce the contents of the report to the crew?", "Announce", "Yes", "No", "Cancel")
	var/announce_command_report = TRUE
	switch(confirm)
		if("Yes")
			priority_announce(input, null, "commandreport")
			announce_command_report = FALSE
		if("Cancel")
			return

	print_command_report(input, "[announce_command_report ? "Classified " : ""][command_name()] Update", announce_command_report)

	log_admin("[key_name(src)] has created a command report: [input]")
	message_admins("[key_name_admin(src)] has created a command report")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Create Command Report") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_make_priority_announcement()
	set category = "Admin.Events"
	set name = "Make Priority Announcement"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_make_priority_announcement() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_make_priority_announcement() without admin perms.")
		return

	var/input = input(usr, "Enter a priority announcement. Ensure it makes sense IC.", "What?", "") as message|null
	if(!input)
		return

	var/title = input(src, "What should the title be?", "What?","") as text|null

	var/special_name = input(src, "Who is making the announcement?", "Who?", "") as text|null
	priority_announce(input, title, sender_override = special_name)

	log_admin("[key_name(src)] has sent a priority announcement: [input]")
	message_admins("[key_name_admin(src)] has made a priority announcement")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Priority Announcement") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_change_command_name()
	set category = "Admin.Events"
	set name = "Change Command Name"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_change_command_name() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_change_command_name() without admin perms.")
		return

	var/input = input(usr, "Please input a new name for Central Command.", "What?", "") as text|null
	if(!input)
		return
	change_command_name(input)
	message_admins("[key_name_admin(src)] has changed Central Command's name to [input]")
	log_admin("[key_name(src)] has changed the Central Command name to: [input]")

/client/proc/cmd_admin_delete(atom/A as obj|mob|turf in world)
	set category = "Admin"
	set name = "Delete"

	if(!check_rights(R_SPAWN)) //fortuna edit. event manager change
		return

	admin_delete(A)

/client/proc/cmd_admin_list_open_jobs()
	set category = "Admin.Game"
	set name = "Manage Job Slots"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_list_open_jobs() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_list_open_jobs() without admin perms.")
		return
	holder.manage_free_slots()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Manage Job Slots") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_explosion(atom/O as obj|mob|turf in world)
	set category =  "Admin.Fun"
	set name = "Explosion"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_explosion() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_explosion() without admin perms.")
		return

	var/devastation = input("Range of total devastation. -1 to none", text("Input"))  as num|null
	if(devastation == null)
		return
	var/heavy = input("Range of heavy impact. -1 to none", text("Input"))  as num|null
	if(heavy == null)
		return
	var/light = input("Range of light impact. -1 to none", text("Input"))  as num|null
	if(light == null)
		return
	var/flash = input("Range of flash. -1 to none", text("Input"))  as num|null
	if(flash == null)
		return
	var/flames = input("Range of flames. -1 to none", text("Input"))  as num|null
	if(flames == null)
		return

	if ((devastation != -1) || (heavy != -1) || (light != -1) || (flash != -1) || (flames != -1))
		if ((devastation > 20) || (heavy > 20) || (light > 20) || (flames > 20))
			if (alert(src, "Are you sure you want to do this? It will laaag.", "Confirmation", "Yes", "No") == "No")
				return

		explosion(O, devastation, heavy, light, flash, null, null,flames)
		log_admin("[key_name(usr)] created an explosion ([devastation],[heavy],[light],[flames]) at [AREACOORD(O)]")
		message_admins("[key_name_admin(usr)] created an explosion ([devastation],[heavy],[light],[flames]) at [AREACOORD(O)]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Explosion") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		return
	else
		return

/client/proc/cmd_admin_emp(atom/O as obj|mob|turf in world)
	set category = "Admin.Fun"
	set name = "EM Pulse"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_emp() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_emp() without admin perms.")
		return

	var/range = input("Range.", text("Input"))  as num|null
	if(!range)
		return
	log_admin("[key_name(usr)] created an EM Pulse - log below") //because we'll just log the empulse itself
	message_admins("[key_name_admin(usr)] created an EM Pulse at [AREACOORD(O)] with range [range]")
	empulse_using_range(O, range, TRUE) //its details get shown too

	SSblackbox.record_feedback("tally", "admin_verb", 1, "EM Pulse") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_gib(mob/M in GLOB.mob_list)
	set category = "Admin.Fun"
	set name = "Gib"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_gib() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_gib() without admin perms.")
		return

	var/confirm = alert(src, "Drop a brain?", "Confirm", "Yes", "No","Cancel")
	if(confirm == "Cancel")
		return
	//Due to the delay here its easy for something to have happened to the mob
	if(!M)
		return

	log_admin("[key_name(usr)] has gibbed [key_name(M)]")
	message_admins("[key_name_admin(usr)] has gibbed [key_name_admin(M)]")

	if(isobserver(M))
		new /obj/effect/gibspawner/generic(get_turf(M))
		return
	if(confirm == "Yes")
		M.gib()
	else
		M.gib(1)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Gib") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_gib_self()
	set name = "Gibself"
	set category = "Admin.Fun"

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm == "Yes")
		log_admin("[key_name(usr)] used gibself.")
		message_admins(span_adminnotice("[key_name_admin(usr)] used gibself."))
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Gib Self") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		mob.gib(1, 1, 1)

/client/proc/cmd_admin_check_contents(mob/living/M in GLOB.mob_list)
	set category = "Special Verbs"
	set name = "Check Contents"

	var/list/L = M.get_contents()
	for(var/t in L)
		to_chat(usr, "[t]")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Check Contents") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_view_range()
	set category = "Admin.Game"
	set name = "Change View Range"
	set desc = "switches between 1x and custom views"

	if(view == CONFIG_GET(string/default_view))
		change_view(input("Select view range:", "FUCK YE", 7) in list(1,2,3,4,5,6,7,8,9,10,11,12,13,14,128))
	else
		change_view(CONFIG_GET(string/default_view))

	log_admin("[key_name(usr)] changed their view range to [view].")

	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Change View Range", "[view]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/admin_call_shuttle()
	set category = "Admin.Events"
	set name = "Call Train"

	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use admin_call_shuttle() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use admin_call_shuttle() without admin perms.")
		return

	var/confirm = alert(src, "You sure?", "Confirm", "Yes", "No")
	if(confirm != "Yes")
		return

	SSshuttle.emergency.request()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Call Train") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-called the train.")
	message_admins(span_adminnotice("[key_name_admin(usr)] admin-called the train."))
	return

/client/proc/admin_cancel_shuttle()
	set category = "Admin.Events"
	set name = "Cancel Train"
	if(!check_rights(0))
		return
	if(alert(src, "You sure?", "Confirm", "Yes", "No") != "Yes")
		return

	if(EMERGENCY_AT_LEAST_DOCKED)
		return

	SSshuttle.emergency.cancel()
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Cancel Train") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(usr)] admin-recalled the train.")
	message_admins(span_adminnotice("[key_name_admin(usr)] admin-recalled the train."))

	return
/*
/client/proc/admin_disable_shuttle()
	set category = "Admin.Events"
	set name = "Disable Shuttle"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use admin_disable_shuttle() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use admin_disable_shuttle() without admin perms.")
		return
	if(SSshuttle.emergency.mode == SHUTTLE_DISABLED)
		to_chat(usr, span_warning("Error, shuttle is already disabled."))
		return
	if(alert(src, "You sure?", "Confirm", "Yes", "No") != "Yes")
		return
	message_admins(span_adminnotice("[key_name_admin(usr)] disabled the shuttle."))
	SSshuttle.lastMode = SSshuttle.emergency.mode
	SSshuttle.lastCallTime = SSshuttle.emergency.timeLeft(1)
	SSshuttle.adminEmergencyNoRecall = TRUE
	SSshuttle.emergency.setTimer(0)
	SSshuttle.emergency.mode = SHUTTLE_DISABLED
	priority_announce("Warning: Emergency Shuttle uplink failure, shuttle disabled until further notice.", "Emergency Shuttle Uplink Alert", 'sound/misc/announce_dig.ogg')

/client/proc/admin_enable_shuttle()
	set category = "Admin - Events"
	set category = "Admin.Events"
	set name = "Enable Shuttle"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use admin_enable_shuttle() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use admin_enable_shuttle() without admin perms.")
		return
	if(SSshuttle.emergency.mode != SHUTTLE_DISABLED)
		to_chat(usr, span_warning("Error, shuttle not disabled."))
		return
	if(alert(src, "You sure?", "Confirm", "Yes", "No") != "Yes")
		return
	message_admins(span_adminnotice("[key_name_admin(usr)] enabled the emergency shuttle."))
	SSshuttle.adminEmergencyNoRecall = FALSE
	SSshuttle.emergencyNoRecall = FALSE
	if(SSshuttle.lastMode == SHUTTLE_DISABLED) //If everything goes to shit, fix it.
		SSshuttle.lastMode = SHUTTLE_IDLE
	SSshuttle.emergency.mode = SSshuttle.lastMode
	if(SSshuttle.lastCallTime < 10 SECONDS && SSshuttle.lastMode != SHUTTLE_IDLE)
		SSshuttle.lastCallTime = 10 SECONDS //Make sure no insta departures.
	SSshuttle.emergency.setTimer(SSshuttle.lastCallTime)
	priority_announce("Warning: Emergency Shuttle uplink reestablished, shuttle enabled.", "Emergency Shuttle Uplink Alert", 'sound/misc/announce_dig.ogg')
*/
/client/proc/everyone_random()
	set category = "Admin.Fun"
	set name = "Make Everyone Random"
	set desc = "Make everyone have a random appearance. You can only use this before rounds!"

	if(SSticker.HasRoundStarted())
		to_chat(usr, "Nope you can't do this, the game's already started. This only works before rounds!")
		return

	var/frn = CONFIG_GET(flag/force_random_names)
	if(frn)
		CONFIG_SET(flag/force_random_names, FALSE)
		message_admins("Admin [key_name_admin(usr)] has disabled \"Everyone is Special\" mode.")
		to_chat(usr, "Disabled.")
		return


	var/notifyplayers = alert(src, "Do you want to notify the players?", "Options", "Yes", "No", "Cancel")
	if(notifyplayers == "Cancel")
		return

	log_admin("Admin [key_name(src)] has forced the players to have random appearances.")
	message_admins("Admin [key_name_admin(usr)] has forced the players to have random appearances.")

	if(notifyplayers == "Yes")
		to_chat(world, span_adminnotice("Admin [usr.key] has forced the players to have completely random identities!"))

	to_chat(usr, "<i>Remember: you can always disable the randomness by using the verb again, assuming the round hasn't started yet</i>.")

	CONFIG_SET(flag/force_random_names, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Everyone Random") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/toggle_random_events()
	set category = "Server"
	set name = "Toggle random events on/off"
	set desc = "Toggles random events such as meteors, black holes, blob (but not space dust) on/off"
	var/new_are = !CONFIG_GET(flag/allow_random_events)
	CONFIG_SET(flag/allow_random_events, new_are)
	if(new_are)
		to_chat(usr, "Random events enabled")
		message_admins("Admin [key_name_admin(usr)] has enabled random events.")
	else
		to_chat(usr, "Random events disabled")
		message_admins("Admin [key_name_admin(usr)] has disabled random events.")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Random Events", "[new_are ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/admin_change_sec_level()
	set category = "Admin.Events"
	set name = "Set Security Level"
	set desc = "Changes the security level. Announcement only, i.e. setting to Delta won't activate nuke"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use admin_change_sec_level() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use admin_change_sec_level() without admin perms.")
		return

	var/level = input("Select security level to change to","Set Security Level") as null|anything in list("green","blue","amber","red","delta")
	if(level)
		set_security_level(level)

		log_admin("[key_name(usr)] changed the security level to [level]")
		message_admins("[key_name_admin(usr)] changed the security level to [level]")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Set Security Level [capitalize(level)]") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/toggle_nuke(obj/machinery/nuclearbomb/N in GLOB.nuke_list)
	set name = "Toggle Nuke"
	set category = "Admin.Events"
	set popup_menu = 0
	if(!check_rights(R_DEBUG))
		return

	if(!N.timing)
		var/newtime = input(usr, "Set activation timer.", "Activate Nuke", "[N.timer_set]") as num|null
		if(!newtime)
			return
		N.timer_set = newtime
	N.set_safety()
	N.set_active()

	log_admin("[key_name(usr)] [N.timing ? "activated" : "deactivated"] a nuke at [AREACOORD(N)].")
	message_admins("[ADMIN_LOOKUPFLW(usr)] [N.timing ? "activated" : "deactivated"] a nuke at [ADMIN_VERBOSEJMP(N)].")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Nuke", "[N.timing]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

GLOBAL_LIST_EMPTY(custom_outfits) //Admin created outfits

/client/proc/create_outfits()
	set category = "Debug"
	set name = "Create Custom Outfit"

	if(!check_rights(R_DEBUG))
		return

	holder.create_outfit()

/datum/admins/proc/create_outfit()
	var/list/uniforms = typesof(/obj/item/clothing/under)
	var/list/suits = typesof(/obj/item/clothing/suit)
	var/list/gloves = typesof(/obj/item/clothing/gloves)
	var/list/shoes = typesof(/obj/item/clothing/shoes)
	var/list/headwear = typesof(/obj/item/clothing/head)
	var/list/glasses = typesof(/obj/item/clothing/glasses)
	var/list/masks = typesof(/obj/item/clothing/mask)
	var/list/ids = typesof(/obj/item/card/id)

	var/uniform_select = "<select name=\"outfit_uniform\"><option value=\"\">None</option>"
	for(var/path in uniforms)
		uniform_select += "<option value=\"[path]\">[path]</option>"
	uniform_select += "</select>"

	var/suit_select = "<select name=\"outfit_suit\"><option value=\"\">None</option>"
	for(var/path in suits)
		suit_select += "<option value=\"[path]\">[path]</option>"
	suit_select += "</select>"

	var/gloves_select = "<select name=\"outfit_gloves\"><option value=\"\">None</option>"
	for(var/path in gloves)
		gloves_select += "<option value=\"[path]\">[path]</option>"
	gloves_select += "</select>"

	var/shoes_select = "<select name=\"outfit_shoes\"><option value=\"\">None</option>"
	for(var/path in shoes)
		shoes_select += "<option value=\"[path]\">[path]</option>"
	shoes_select += "</select>"

	var/head_select = "<select name=\"outfit_head\"><option value=\"\">None</option>"
	for(var/path in headwear)
		head_select += "<option value=\"[path]\">[path]</option>"
	head_select += "</select>"

	var/glasses_select = "<select name=\"outfit_glasses\"><option value=\"\">None</option>"
	for(var/path in glasses)
		glasses_select += "<option value=\"[path]\">[path]</option>"
	glasses_select += "</select>"

	var/mask_select = "<select name=\"outfit_mask\"><option value=\"\">None</option>"
	for(var/path in masks)
		mask_select += "<option value=\"[path]\">[path]</option>"
	mask_select += "</select>"

	var/id_select = "<select name=\"outfit_id\"><option value=\"\">None</option>"
	for(var/path in ids)
		id_select += "<option value=\"[path]\">[path]</option>"
	id_select += "</select>"

	var/dat = {"
	<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Create Outfit</title></head><body>
	<form name="outfit" action="byond://?src=[REF(src)];[HrefToken()]" method="get">
	<input type="hidden" name="src" value="[REF(src)]">
	[HrefTokenFormField()]
	<input type="hidden" name="create_outfit" value="1">
	<table>
		<tr>
			<th>Name:</th>
			<td>
				<input type="text" name="outfit_name" value="Custom Outfit">
			</td>
		</tr>
		<tr>
			<th>Uniform:</th>
			<td>
				[uniform_select]
			</td>
		</tr>
		<tr>
			<th>Suit:</th>
			<td>
				[suit_select]
			</td>
		</tr>
		<tr>
			<th>Back:</th>
			<td>
				<input type="text" name="outfit_back" value="">
			</td>
		</tr>
		<tr>
			<th>Belt:</th>
			<td>
				<input type="text" name="outfit_belt" value="">
			</td>
		</tr>
		<tr>
			<th>Gloves:</th>
			<td>
				[gloves_select]
			</td>
		</tr>
		<tr>
			<th>Shoes:</th>
			<td>
				[shoes_select]
			</td>
		</tr>
		<tr>
			<th>Head:</th>
			<td>
				[head_select]
			</td>
		</tr>
		<tr>
			<th>Mask:</th>
			<td>
				[mask_select]
			</td>
		</tr>
		<tr>
			<th>Ears:</th>
			<td>
				<input type="text" name="outfit_ears" value="">
			</td>
		</tr>
		<tr>
			<th>Glasses:</th>
			<td>
				[glasses_select]
			</td>
		</tr>
		<tr>
			<th>ID:</th>
			<td>
				[id_select]
			</td>
		</tr>
		<tr>
			<th>Left Pocket:</th>
			<td>
				<input type="text" name="outfit_l_pocket" value="">
			</td>
		</tr>
		<tr>
			<th>Right Pocket:</th>
			<td>
				<input type="text" name="outfit_r_pocket" value="">
			</td>
		</tr>
		<tr>
			<th>Suit Store:</th>
			<td>
				<input type="text" name="outfit_s_store" value="">
			</td>
		</tr>
		<tr>
			<th>Right Hand:</th>
			<td>
				<input type="text" name="outfit_r_hand" value="">
			</td>
		</tr>
		<tr>
			<th>Left Hand:</th>
			<td>
				<input type="text" name="outfit_l_hand" value="">
			</td>
		</tr>
	</table>
	<br>
	<input type="submit" value="Save">
	</form></body></html>
	"}
	usr << browse(HTML_SKELETON(dat), "window=dressup;size=550x600")

/client/proc/toggle_combo_hud()
	set category = "Admin.Game"
	set name = "Toggle Combo HUD"
	set desc = "Toggles the Admin Combo HUD (antag, sci, med, eng)"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use toggle_combo_hud() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use toggle_combo_hud() without admin perms.")
		return

	var/adding_hud = !has_antag_hud()

	for(var/hudtype in list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_MEDICAL_ADVANCED, DATA_HUD_DIAGNOSTIC_ADVANCED)) // add data huds
		var/datum/atom_hud/H = GLOB.huds[hudtype]
		(adding_hud) ? H.add_hud_to(usr) : H.remove_hud_from(usr)
	for(var/datum/atom_hud/antag/H in GLOB.huds) // add antag huds
		(adding_hud) ? H.add_hud_to(usr) : H.remove_hud_from(usr)

	if(prefs.toggles & COMBOHUD_LIGHTING)
		if(adding_hud)
			mob.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
		else
			mob.lighting_alpha = initial(mob.lighting_alpha)

	mob.update_sight()

	to_chat(usr, "You toggled your admin combo HUD [adding_hud ? "ON" : "OFF"].")
	message_admins("[key_name_admin(usr)] toggled their admin combo HUD [adding_hud ? "ON" : "OFF"].")
	log_admin("[key_name(usr)] toggled their admin combo HUD [adding_hud ? "ON" : "OFF"].")
	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggle Combo HUD", "[adding_hud ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/has_antag_hud()
	var/datum/atom_hud/A = GLOB.huds[ANTAG_HUD_TRAITOR]
	return A.hudusers[mob]


/client/proc/run_weather()
	set category = "Admin.Events"
	set name = "Run Weather"
	set desc = "Triggers a weather on the z-level you choose."

	if(!holder)
		return

	var/weather_type = input("Choose a weather", "Weather")  as null|anything in subtypesof(/datum/weather)
	if(!weather_type)
		return

	SSweather.run_weather(weather_type)

	message_admins("[key_name_admin(usr)] started weather of type [weather_type].")
	log_admin("[key_name(usr)] started weather of type [weather_type].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Run Weather")

/client/proc/mass_zombie_infection()
	set category = "Admin.Fun"
	set name = "Mass Zombie Infection"
	set desc = "Infects all humans with a latent organ that will zombify \
		them on death."

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use mass_zombie_infection() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use mass_zombie_infection() without admin perms.")
		return

	var/confirm = alert(src, "Please confirm you want to add latent zombie organs in all humans?", "Confirm Zombies", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/mob/living/carbon/human/H in GLOB.carbon_list)
		new /obj/item/organ/zombie_infection/nodamage(H)

	message_admins("[key_name_admin(usr)] added a latent zombie infection to all humans.")
	log_admin("[key_name(usr)] added a latent zombie infection to all humans.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Mass Zombie Infection")

/client/proc/mass_zombie_cure()
	set category = "Admin.Fun"
	set name = "Mass Zombie Cure"
	set desc = "Removes the zombie infection from all humans, returning them to normal."
	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use mass_zombie_cure() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use mass_zombie_cure() without admin perms.")
		return

	var/confirm = alert(src, "Please confirm you want to cure all zombies?", "Confirm Zombie Cure", "Yes", "No")
	if(confirm != "Yes")
		return

	for(var/obj/item/organ/zombie_infection/nodamage/I in GLOB.zombie_infection_list)
		qdel(I)

	message_admins("[key_name_admin(usr)] cured all zombies.")
	log_admin("[key_name(usr)] cured all zombies.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Mass Zombie Cure")

/client/proc/polymorph_all()
	set category = "Admin.Fun"
	set name = "Polymorph All"
	set desc = "Applies the effects of the bolt of change to every single mob."

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use polymorph_all() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use polymorph_all() without admin perms.")
		return

	var/confirm = alert(src, "Please confirm you want polymorph all mobs?", "Confirm Polymorph", "Yes", "No")
	if(confirm != "Yes")
		return

	var/list/mobs = shuffle(GLOB.alive_mob_list.Copy()) // might change while iterating
	var/who_did_it = key_name_admin(usr)

	message_admins("[key_name_admin(usr)] started polymorphed all living mobs.")
	log_admin("[key_name(usr)] polymorphed all living mobs.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Polymorph All")

	for(var/mob/living/M in mobs)
		CHECK_TICK

		if(!M)
			continue

		M.audible_message(span_italic("...wabbajack...wabbajack..."))
		playsound(M.loc, 'sound/magic/staff_change.ogg', 50, 1, -1)

		wabbajack(M)

	message_admins("Mass polymorph started by [who_did_it] is complete.")


/client/proc/show_tip()
	set category = "Admin"
	set name = "Show Tip"
	set desc = "Sends a tip (that you specify) to all players. After all \
		you're the experienced player here."

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use show_tip() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use show_tip() without admin perms.")
		return

	var/input = input(usr, "Please specify your tip that you want to send to the players.", "Tip", "") as message|null
	if(!input)
		return

	if(!SSticker)
		return

	SSticker.selected_tip = input

	// If we've already tipped, then send it straight away.
	if(SSticker.tipped)
		SSticker.send_tip_of_the_round()


	message_admins("[key_name_admin(usr)] sent a tip of the round.")
	log_admin("[key_name(usr)] sent \"[input]\" as the Tip of the Round.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Show Tip")

/client/proc/modify_goals()
	set category = "Debug"
	set name = "Modify goals"

	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use modify_goals() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use modify_goals() without admin perms.")
		return

	holder.modify_goals()

/datum/admins/proc/modify_goals()
	var/dat = ""
	for(var/datum/station_goal/S in SSticker.mode.station_goals)
		dat += "[S.name] - <a href='byond://?src=[REF(S)];[HrefToken()];announce=1'>Announce</a> | <a href='byond://?src=[REF(S)];[HrefToken()];remove=1'>Remove</a><br>"
	dat += "<br><a href='byond://?src=[REF(src)];[HrefToken()];add_station_goal=1'>Add New Goal</a>"
	usr << browse(HTML_SKELETON(dat), "window=goals;size=400x400")


/client/proc/toggle_hub()
	set category = "Server"
	set name = "Toggle Hub"

	world.update_hub_visibility(!GLOB.hub_visibility)

	log_admin("[key_name(usr)] has toggled the server's hub status for the round, it is now [(GLOB.hub_visibility?"on":"off")] the hub.")
	message_admins("[key_name_admin(usr)] has toggled the server's hub status for the round, it is now [(GLOB.hub_visibility?"on":"off")] the hub.")
	if (GLOB.hub_visibility && !world.reachable)
		message_admins("WARNING: The server will not show up on the hub because byond is detecting that a filewall is blocking incoming connections.")

	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggled Hub Visibility", "[GLOB.hub_visibility ? "Enabled" : "Disabled"]")) //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_toggle_fov()
	set category = "Admin.Fun"
	set name = "Enable/Disable Field of Vision"

	var/static/busy_toggling_fov = FALSE
	if(!check_rights(R_ADMIN) || !check_rights(R_FUN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_toggle_fov() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_toggle_fov() without admin perms.")
		return

	var/on_off = CONFIG_GET(flag/use_field_of_vision)

	if(busy_toggling_fov)
		to_chat(usr, "<span class='warning'>A previous call of this function is still busy toggling FoV [on_off ? "on" : "off"]. Have some patiece</span>.")
		return
	busy_toggling_fov = TRUE

	log_admin("[key_name(usr)] has [on_off ? "disabled" : "enabled"] the Field of Vision configuration.")
	CONFIG_SET(flag/use_field_of_vision, !on_off)

	SSblackbox.record_feedback("nested tally", "admin_toggle", 1, list("Toggled Field of Vision", "[on_off ? "Enabled" : "Disabled"]"))

	if(on_off)
		for(var/k in GLOB.mob_list)
			if(!k)
				continue
			var/mob/M = k
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(!(H.dna?.species.has_field_of_vision))
					continue
			else if(!M.has_field_of_vision)
				continue
			var/datum/component/field_of_vision/FoV = M.GetComponent(/datum/component/field_of_vision)
			if(FoV)
				qdel(FoV)
			CHECK_TICK
	else
		for(var/k in GLOB.clients)
			if(!k)
				continue
			var/client/C = k
			var/mob/M = C.mob
			if(ishuman(M))
				var/mob/living/carbon/human/H = M
				if(!(H.dna?.species.has_field_of_vision))
					continue
			else if(!M.has_field_of_vision)
				continue
			M.LoadComponent(/datum/component/field_of_vision, M.field_of_vision_type)
			CHECK_TICK

	busy_toggling_fov = FALSE

/client/proc/smite(mob/living/carbon/human/target as mob)
	set name = "Smite"
	set category = "Admin.Fun"
	if(!check_rights(R_ADMIN) || !check_rights(R_FUN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use smite() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use smite() without admin perms.")
		return

	var/list/punishment_list = list(ADMIN_PUNISHMENT_PIE,
		ADMIN_PUNISHMENT_CUSTOM_PIE,
		ADMIN_PUNISHMENT_FIREBALL,
		ADMIN_PUNISHMENT_LIGHTNING,
		ADMIN_PUNISHMENT_BRAINDAMAGE,
		ADMIN_PUNISHMENT_BSA,
		ADMIN_PUNISHMENT_GIB,
		ADMIN_PUNISHMENT_SUPPLYPOD_QUICK,
		ADMIN_PUNISHMENT_SUPPLYPOD,
		ADMIN_PUNISHMENT_MAZING,
		ADMIN_PUNISHMENT_ROD,
		ADMIN_PUNISHMENT_SHOES,
		ADMIN_PUNISHMENT_PICKLE,
		ADMIN_PUNISHMENT_FRY,
	ADMIN_PUNISHMENT_CRACK,
	ADMIN_PUNISHMENT_BLEED,
	ADMIN_PUNISHMENT_SCARIFY)

	var/punishment = input("Choose a punishment", "DIVINE SMITING") as null|anything in punishment_list

	if(QDELETED(target) || !punishment)
		return

	switch(punishment)
		if(ADMIN_PUNISHMENT_LIGHTNING)
			var/turf/T = get_step(get_step(target, NORTH), NORTH)
			T.Beam(target, icon_state="lightning[rand(1,12)]", time = 5)
			target.adjustFireLoss(75)
			target.electrocution_animation(40)
			to_chat(target, span_userdanger("The gods have punished you for your sins!"))
		if(ADMIN_PUNISHMENT_BRAINDAMAGE)
			target.adjustOrganLoss(ORGAN_SLOT_BRAIN, 199, 199)
		if(ADMIN_PUNISHMENT_GIB)
			target.gib(FALSE)
		if(ADMIN_PUNISHMENT_BSA)
			bluespace_artillery(target)
		if(ADMIN_PUNISHMENT_FIREBALL)
			new /obj/effect/temp_visual/target(get_turf(target))
		if(ADMIN_PUNISHMENT_ROD)
			var/turf/T = get_turf(target)
			var/startside = pick(GLOB.cardinals)
			var/turf/startT = spaceDebrisStartLoc(startside, T.z)
			var/turf/endT = spaceDebrisFinishLoc(startside, T.z)
			new /obj/effect/immovablerod(startT, endT,target)
		if(ADMIN_PUNISHMENT_SUPPLYPOD_QUICK)
			var/target_path = input(usr,"Enter typepath of an atom you'd like to send with the pod (type \"empty\" to send an empty pod):" ,"Typepath","/obj/item/reagent_containers/food/snacks/grown/harebell") as null|text
			var/obj/structure/closet/supplypod/centcompod/pod = new()
			pod.damage = 40
			pod.explosionSize = list(0,0,0,2)
			pod.effectStun = TRUE
			if (isnull(target_path)) //The user pressed "Cancel"
				return
			if (target_path != "empty")//if you didn't type empty, we want to load the pod with a delivery
				var/delivery = text2path(target_path)
				if(!ispath(delivery))
					delivery = pick_closest_path(target_path)
					if(!delivery)
						alert("ERROR: Incorrect / improper path given.")
				new delivery(pod)
			new /obj/effect/abstract/DPtarget(get_turf(target), pod)
		if(ADMIN_PUNISHMENT_SUPPLYPOD)
			var/datum/centcom_podlauncher/plaunch  = new(usr)
			if(!holder)
				return
			plaunch.specificTarget = target
			plaunch.launchChoice = 0
			plaunch.damageChoice = 1
			plaunch.explosionChoice = 1
			plaunch.temp_pod.damage = 40//bring the mother fuckin ruckus
			plaunch.temp_pod.explosionSize = list(0,0,0,2)
			plaunch.temp_pod.effectStun = TRUE
			plaunch.ui_interact(usr)
			return //We return here because punish_log() is handled by the centcom_podlauncher datum

		if(ADMIN_PUNISHMENT_MAZING)
			if(!puzzle_imprison(target))
				to_chat(usr,span_warning("Imprisonment failed!"))
				return
		if(ADMIN_PUNISHMENT_PIE)
			var/obj/item/reagent_containers/food/snacks/pie/cream/nostun/creamy = new(get_turf(target))
			creamy.splat(target)
		if(ADMIN_PUNISHMENT_CUSTOM_PIE)
			var/obj/item/reagent_containers/food/snacks/pie/cream/nostun/A = new()
			if(!A.reagents)
				var/amount = input(usr, "Specify the reagent size of [A]", "Set Reagent Size", 50) as num|null
				if(amount)
					A.create_reagents(amount)
			if(A.reagents)
				var/chosen_id = choose_reagent_id(usr)
				if(chosen_id)
					var/amount = input(usr, "Choose the amount to add.", "Choose the amount.", A.reagents.maximum_volume) as num|null
					if(amount)
						A.reagents.add_reagent(chosen_id, amount)
						A.splat(target)
		if(ADMIN_PUNISHMENT_CRACK)
			if(!iscarbon(target))
				to_chat(usr,span_warning("This must be used on a carbon mob."), confidential = TRUE)
				return
			var/mob/living/carbon/C = target
			for(var/i in C.bodyparts)
				var/obj/item/bodypart/squish_part = i
				var/type_wound = pick(list(/datum/wound/blunt/critical, /datum/wound/blunt/severe, /datum/wound/blunt/critical, /datum/wound/blunt/severe, /datum/wound/blunt/moderate))
				squish_part.force_wound_upwards(type_wound, smited=TRUE)
		if(ADMIN_PUNISHMENT_BLEED)
			if(!iscarbon(target))
				to_chat(usr,span_warning("This must be used on a carbon mob."), confidential = TRUE)
				return
			var/mob/living/carbon/C = target
			for(var/i in C.bodyparts)
				var/obj/item/bodypart/slice_part = i
				slice_part.bleed_dam += 200
				slice_part.apply_bleed_wound(WOUND_PIERCE, GLOB.global_wound_types[WOUND_PIERCE])
				slice_part.apply_bleed_wound(WOUND_SLASH, GLOB.global_wound_types[WOUND_SLASH])
		if(ADMIN_PUNISHMENT_SCARIFY)
			if(!iscarbon(target))
				to_chat(usr,span_warning("This must be used on a carbon mob."), confidential = TRUE)
				return
			var/mob/living/carbon/dude = target
			dude.generate_fake_scars(rand(1, 4))
			to_chat(dude, span_warning("You feel your body grow jaded and torn..."))
		if(ADMIN_PUNISHMENT_PERFORATE)
			if(!iscarbon(target))
				to_chat(usr,span_warning("This must be used on a carbon mob."), confidential = TRUE)
				return

			var/list/how_fucked_is_this_dude = list("A little", "A lot", "So fucking much", "FUCK THIS DUDE")
			var/hatred = input("How much do you hate this guy?") in how_fucked_is_this_dude
			var/repetitions
			var/shots_per_limb_per_rep = 2
			var/damage
			switch(hatred)
				if("A little")
					repetitions = 1
					damage = 5
				if("A lot")
					repetitions = 2

					damage = 8
				if("So fucking much")
					repetitions = 3
					damage = 10
				if("FUCK THIS DUDE")
					repetitions = 4
					damage = 10

			var/mob/living/carbon/dude = target
			var/list/open_adj_turfs = get_adjacent_open_turfs(dude)
			var/list/wound_bonuses = list(15, 70, 110, 250)

			var/delay_per_shot = 1
			var/delay_counter = 1

			dude.Immobilize(5 SECONDS)
			for(var/wound_bonus_rep in 1 to repetitions)
				for(var/i in dude.bodyparts)
					var/obj/item/bodypart/slice_part = i
					var/shots_this_limb = 0
					for(var/t in shuffle(open_adj_turfs))
						var/turf/iter_turf = t
						addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(firing_squad), dude, iter_turf, slice_part.body_zone, wound_bonuses[wound_bonus_rep], damage), delay_counter)
						delay_counter += delay_per_shot
						shots_this_limb++
						if(shots_this_limb > shots_per_limb_per_rep)
							break
		if(ADMIN_PUNISHMENT_PICKLE)
			target.turn_into_pickle()
		if(ADMIN_PUNISHMENT_FRY)
			target.fry()

		if(ADMIN_PUNISHMENT_SHOES)
			if(!iscarbon(target))
				to_chat(usr,span_warning("This must be used on a carbon mob."))
				return
			var/mob/living/carbon/C = target
			var/obj/item/clothing/shoes/sick_kicks = C.shoes
			if(!sick_kicks?.can_be_tied)
				to_chat(usr,span_warning("[C] does not have knottable shoes!"))
				return
			sick_kicks.adjust_laces(SHOES_KNOTTED)

	punish_log(target, punishment)

/**
 * firing_squad is a proc for the :B:erforate smite to shoot each individual bullet at them, so that we can add actual delays without sleep() nonsense
 *
 * Hilariously, if you drag someone away mid smite, the bullets will still chase after them from the original spot, possibly hitting other people. Too funny to fix imo
 *
 * Arguments:
 * * target- guy we're shooting obviously
 * * source_turf- where the bullet begins, preferably on a turf next to the target
 * * body_zone- which bodypart we're aiming for, if there is one there
 * * wound_bonus- the wounding power we're assigning to the bullet, since we don't care about the base one
 * * damage- the damage we're assigning to the bullet, since we don't care about the base one
 */
/proc/firing_squad(mob/living/carbon/target, turf/source_turf, body_zone, wound_bonus, damage)
	if(!target.get_bodypart(body_zone))
		return
	playsound(target, 'sound/weapons/shot.ogg', 100)
	var/obj/item/projectile/bullet/smite/divine_wrath = new(source_turf)
	divine_wrath.damage = damage
	divine_wrath.wound_bonus = wound_bonus
	divine_wrath.original = target
	divine_wrath.def_zone = body_zone
	divine_wrath.spread = 0
	divine_wrath.preparePixelProjectile(target, source_turf)
	divine_wrath.fire()

/client/proc/punish_log(whom, punishment)
	var/msg = "[key_name_admin(usr)] punished [key_name_admin(whom)] with [punishment]."
	message_admins(msg)
	admin_ticket_log(whom, msg)
	log_admin("[key_name(usr)] punished [key_name(whom)] with [punishment].")

/client/proc/trigger_centcom_recall()
	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use trigger_centcom_recall() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use trigger_centcom_recall() without admin perms.")
		return
	var/message = pick(GLOB.admiral_messages)
	message = input("Enter message from the on-call admiral to be put in the recall report.", "Admiral Message", message) as text|null

	if(!message)
		return

	message_admins("[key_name_admin(usr)] triggered a CentCom recall, with the admiral message of: [message]")
	log_game("[key_name(usr)] triggered a CentCom recall, with the message of: [message]")
	SSshuttle.centcom_recall(SSshuttle.emergency.timer, message)

/client/proc/cmd_admin_check_player_exp()	//Allows admins to determine who the newer players are.
	set category = "Admin"
	set name = "Player Playtime"
	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_admin_check_player_exp() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_admin_check_player_exp() without admin perms.")
		return

	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(usr, span_warning("Tracking is disabled in the server configuration file."))
		return

	var/list/msg = list()
	msg += "<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Playtime Report</title></head><body>Playtime:<BR><UL>"
	for(var/client/C in GLOB.clients)
		msg += "<LI> - [key_name_admin(C)]: <A href='byond://?_src_=holder;[HrefToken()];getplaytimewindow=[REF(C.mob)]'>" + C.get_exp_living() + "</a></LI>"
	msg += "</UL></BODY></HTML>"
	src << browse(HTML_SKELETON(msg.Join()), "window=Player_playtime_check")

/datum/admins/proc/cmd_show_exp_panel(client/C)
	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use cmd_show_exp_panel() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use cmd_show_exp_panel() without admin perms.")
		return
	if(!C)
		to_chat(usr, span_danger("ERROR: Client not found."))
		return
	if(!CONFIG_GET(flag/use_exp_tracking))
		to_chat(usr, span_warning("Tracking is disabled in the server configuration file."))
		return

	var/list/body = list()
	body += "<html><head><meta http-equiv='Content-Type' content='text/html; charset=UTF-8'><title>Playtime for [C.key]</title></head><BODY><BR>Playtime:"
	body += C.get_exp_report()
	body += "<A href='byond://?_src_=holder;[HrefToken()];toggleexempt=[REF(C)]'>Toggle Exempt status</a>"
	body += "</BODY></HTML>"
	usr << browse(HTML_SKELETON(body.Join()), "window=playerplaytime[C.ckey];size=550x615")

/datum/admins/proc/toggle_exempt_status(client/C)
	if(!check_rights(R_ADMIN))
		message_admins("[ADMIN_TPMONTY(usr)] tried to use toggle_exempt_status() without admin perms.")
		log_admin("INVALID ADMIN PROC ACCESS: [key_name(usr)] tried to use toggle_exempt_status() without admin perms.")
		return
	if(!C)
		to_chat(usr, span_danger("ERROR: Client not found."))
		return

	if(!C.set_db_player_flags())
		to_chat(usr, span_danger("ERROR: Unable read player flags from database. Please check logs."))
	var/dbflags = C.prefs.db_flags
	var/newstate = FALSE
	if(dbflags & DB_FLAG_EXEMPT)
		newstate = FALSE
	else
		newstate = TRUE

	if(C.update_flag_db(DB_FLAG_EXEMPT, newstate))
		to_chat(usr, span_danger("ERROR: Unable to update player flags. Please check logs."))
	else
		message_admins("[key_name_admin(usr)] has [newstate ? "activated" : "deactivated"] job exp exempt status on [key_name_admin(C)]")
		log_admin("[key_name(usr)] has [newstate ? "activated" : "deactivated"] job exp exempt status on [key_name(C)]")

/// Allow admin to add or remove traits of datum
/datum/admins/proc/modify_traits(datum/D)
	if(!D)
		return

	var/add_or_remove = input("Remove/Add?", "Trait Remove/Add") as null|anything in list("Add","Remove")
	if(!add_or_remove)
		return
	var/list/availible_traits = list()

	switch(add_or_remove)
		if("Add")
			for(var/key in GLOB.traits_by_type)
				if(istype(D,key))
					availible_traits += GLOB.traits_by_type[key]
		if("Remove")
			if(!GLOB.trait_name_map)
				GLOB.trait_name_map = generate_trait_name_map()
			for(var/trait in D.status_traits)
				var/name = GLOB.trait_name_map[trait] || trait
				availible_traits[name] = trait

	var/chosen_trait = input("Select trait to modify", "Trait") as null|anything in sortList(availible_traits)
	if(!chosen_trait)
		return
	chosen_trait = availible_traits[chosen_trait]

	var/source = "adminabuse"
	switch(add_or_remove)
		if("Add") //Not doing source choosing here intentionally to make this bit faster to use, you can always vv it.
			ADD_TRAIT(D,chosen_trait,source)
		if("Remove")
			var/specific = input("All or specific source ?", "Trait Remove/Add") as null|anything in list("All","Specific")
			if(!specific)
				return
			switch(specific)
				if("All")
					source = null
				if("Specific")
					source = input("Source to be removed","Trait Remove/Add") as null|anything in sortList(D.status_traits[chosen_trait])
					if(!source)
						return
			REMOVE_TRAIT(D,chosen_trait,source)
