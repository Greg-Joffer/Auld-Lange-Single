/obj/machinery/computer/terminal
	name = "desktop terminal"
	desc = "A RobCo Industries terminal, widely available for commercial and private use before the war."
	icon_state = "terminal"
	icon_keyboard = "terminal_key"
	icon_screen = "terminal_on_alt"
	connectable = FALSE
	light_color = LIGHT_COLOR_GREEN
	circuit = /obj/item/circuitboard/computer/robco_terminal
	var/broken = FALSE // Used for pre-broken terminals
	var/prog_notekeeper = TRUE // Almost all consoles have the word processor installed, but we can remove it if we want to
	var/termtag = "Home" // We use this for flavor.
	var/termnumber = null // Flavor
	var/mode = 0 // What page we're on. 0 is the main menu.
	var/vault_secrets = FALSE
	var/maybe_vault_secrets = FALSE

// Document variables
	var/doc_title_1 = "readme"
	var/doc_content_1 = ""
	var/doc_title_2 = ""
	var/doc_content_2 = ""
	var/doc_title_3 = ""
	var/doc_content_3 = ""
	var/doc_title_4 = ""
	var/doc_content_4 = ""
	var/doc_title_5 = ""
	var/doc_content_5 = ""
	var/loaded_title = ""
	var/loaded_content = ""

// Notekeeper vars
	var/notehtml = ""
	var/note = "ERR://null-data #236XF51"

/obj/machinery/computer/terminal/Initialize()
	..()

	if(!broken)
		desc = "[initial(desc)] Remarkably, it still works."
		termnumber = rand(69,420) // Unlikely to get two identical numbers.
//		write_documents()
	else
		desc = "[initial(desc)] Unfortunately, this one seems to have broken down."

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/terminal/LateInitialize()
	. = ..()
	if (vault_secrets || (maybe_vault_secrets && prob(40)))
		doc_title_4 = "TOP SECRET - VAULT TEC"
		doc_content_4 = "To whom it may concern.<br> Vault external access code is as follows: [GLOB.vault_password], This code is valid for Vaults: {113, 13, 141, 0}<br> Not to be redistributed."


/obj/machinery/computer/terminal/ui_interact(mob/user)
	. = ..()
	if(broken)
		return

	var/dat = ""
	dat += "<head><style>body {padding: 0; margin: 15px; background-color: #062113; color: #4aed92; line-height: 170%;} a, button, a:link, a:visited, a:active, .linkOn, .linkOff {color: #4aed92; text-decoration: none; background: #062113; border: none; padding: 1px 4px 1px 4px; margin: 0 2px 0 0; cursor:default;} a:hover {color: #062113; background: #4aed92; border: 1px solid #4aed92} a.white, a.white:link, a.white:visited, a.white:active {color: #4aed92; text-decoration: none; background: #4aed92; border: 1px solid #161616; padding: 1px 4px 1px 4px; margin: 0 2px 0 0; cursor:default;} a.white:hover {color: #062113; background: #4aed92;} .linkOn, a.linkOn:link, a.linkOn:visited, a.linkOn:active, a.linkOn:hover {color: #4aed92; background: #062113; border-color: #062113;} .linkOff, a.linkOff:link, a.linkOff:visited, a.linkOff:active, a.linkOff:hover{color: #4aed92; background: #062113; border-color: #062113;}</style></head><font face='courier'>"
	dat += "<center><b>ROBCO INDUSTRIES UNIFIED OPERATING SYSTEM v.85</b><br>"
	dat += "<b>COPYRIGHT 2075-2077 ROBCO INDUSTRIES</b><br>"

	switch (mode)
		if (0) // If we're on the home page
			dat += "= [termtag] Terminal [termnumber] =</center>"
		if (1) // If we're in the word processor
			dat += "= RobCo Word Processor V.22 =</center>"
		if (2) // If we're viewing a document
			dat += "= [loaded_title] =</center>"
	dat += "<br>"
// The next line is the death of hope. Gaze not longer upon it than you need to.
	switch (mode)
		if (0)
			if(prog_notekeeper)
				dat += "TERMINAL FUNCTIONS"
				dat += "<br><a href='byond://?src=[REF(src)];choice=1'>\>  Word Processor</a>"
				dat += "<br><br>"
			dat += "FILE SYSTEM"

			if(doc_title_1)
				dat += "<br><a href='byond://?src=[REF(src)];choice=doc_1'>\>  [doc_title_1]</a>"
			if(doc_title_2)
				dat += "<br><a href='byond://?src=[REF(src)];choice=doc_2'>\>  [doc_title_2]</a>"
			if(doc_title_3)
				dat += "<br><a href='byond://?src=[REF(src)];choice=doc_3'>\>  [doc_title_3]</a>"
			if(doc_title_4)
				dat += "<br><a href='byond://?src=[REF(src)];choice=doc_4'>\>  [doc_title_4]</a>"
			if(doc_title_5)
				dat += "<br><a href='byond://?src=[REF(src)];choice=doc_5'>\>  [doc_title_5]</a>"

		if (1)
			dat += "</center><font face=\"Courier\">[(!notehtml ? note : notehtml)]</font>"

		if (2)
			dat += "[loaded_content]"

	if (mode)
		dat += "<br><br><center>=============================================================================</center>"
		if(mode == 1)
			dat += "<a href='byond://?src=[REF(src)];choice=Edit'>\>  Edit</a><br>"
		dat += "<a href='byond://?src=[REF(src)];choice=Return'>\>  Return</a>"


	dat += "</font></div>"

	var/datum/browser/popup = new(user, "terminal", null, 600, 400)
	popup.set_content(dat)
//	popup.set_title_image(user.browse_rsc_icon(src.icon, src.icon_state))
	popup.open()

/obj/machinery/computer/terminal/Topic(href, href_list)
	..()
	var/mob/living/U = usr

	if(usr.canUseTopic(src) && !href_list["close"])
		add_fingerprint(U)
		U.set_machine(src)

		switch(href_list["choice"])

// Notekeeper

			if ("Edit")
				var/n = stripped_multiline_input(U, "Please enter message", name, note, max_length=MAX_MESSAGE_LEN * 4) //Probably not abusable?? I'd be surprised if anyone managed to crash anything with this
				if (in_range(src, U))
					if (mode == 1 && n)
						note = n
						notehtml = parsemarkdown(n, U)
				else
					return

// Files - We assign the datum information to the loaded_ variables so we don't need a different page for each document

			if ("doc_1")
				loaded_title = doc_title_1
				loaded_content = doc_content_1
				mode = 2
			if ("doc_2")
				loaded_title = doc_title_2
				loaded_content = doc_content_2
				mode = 2
			if ("doc_3")
				loaded_title = doc_title_3
				loaded_content = doc_content_3
				mode = 2
			if ("doc_4")
				loaded_title = doc_title_4
				loaded_content = doc_content_4
				mode = 2
			if ("doc_5")
				loaded_title = doc_title_5
				loaded_content = doc_content_5
				mode = 2

// Return

			if("Return")
				if(mode) // If we're not on the home page...
					mode = 0 // Take us there

// Menu functions
			if ("1")
				mode = 1
	updateUsrDialog()
	return
/*
/obj/machinery/computer/terminal/proc/write_documents()
	if (doc_title_1)
		var/file_in_memory = text2path("/datum/terminal/document/[doc_title_1]")
		var/datum/terminal/document/N = new file_in_memory
		doc_title_1 = "[N.title]"
		doc_content_1 = "[N.content]"
	if (doc_title_2)
		var/file_in_memory = text2path("/datum/terminal/document/[doc_title_2]")
		var/datum/terminal/document/N = new file_in_memory
		doc_title_2 = "[N.title]"
		doc_content_2 = "[N.content]"
	if (doc_title_3)
		var/file_in_memory = text2path("/datum/terminal/document/[doc_title_3]")
		var/datum/terminal/document/N = new file_in_memory
		doc_title_3 = "[N.title]"
		doc_content_3 = "[N.content]"
	if (doc_title_4)
		var/file_in_memory = text2path("/datum/terminal/document/[doc_title_4]")
		var/datum/terminal/document/N = new file_in_memory
		doc_title_4 = "[N.title]"
		doc_content_4 = "[N.content]"
	if (doc_title_5)
		var/file_in_memory = text2path("/datum/terminal/document/[doc_title_5]")
		var/datum/terminal/document/N = new file_in_memory
		doc_title_5 = "[N.title]"
		doc_content_5 = "[N.content]"

	return
*/


/obj/machinery/computer/terminal/stored_password
	var/door_id = ""
	var/obj/machinery/door/password/our_door = null
	var/first_time = TRUE

/obj/machinery/computer/terminal/stored_password/ui_interact(mob/user)
	. = ..()
	if (first_time)
		doc_content_2 = "Hi " + pick(GLOB.first_names_male + GLOB.first_names_female) + ", \n" + "Just wanted to give you a heads up about the password change on the door controller. \n New password is: " + our_door.password + " \n remember to delete this when you have it memorized. \n " + pick(GLOB.first_names_male + GLOB.first_names_female)
		first_time = FALSE


/obj/machinery/computer/terminal/stored_password/Initialize()
	. = ..()
	for (var/obj/machinery/door/password/pass_door in orange(10, src))
		if (pass_door.door_id == door_id)
			our_door = pass_door
	if (our_door != null)
		doc_title_2 = "Password updated"
		doc_content_2 = "Hi " + pick(GLOB.first_names_male + GLOB.first_names_female) + ", \n" + "Just wanted to give you a heads up about the password change on the door controller. \n New password is: " + our_door.password + " \n remember to delete this when you have it memorized. \n " + pick(GLOB.first_names_male + GLOB.first_names_female)
	else
		doc_title_2 = "Corrupt File"
		doc_content_2 = "Data Corrupt Contact System Admin."


/obj/machinery/computer/terminal/stored_password/enclave/Initialize()
	var/the_password = random_string(8, GLOB.alphabet)
	for (var/obj/machinery/door/password/enclave/pass_door in world)
		pass_door.password = the_password
		our_door = pass_door
	. = ..()

/obj/machinery/computer/terminal/telecoms_cracker/Initialize()
	. = ..()
	doc_title_1 = "Telecommunications Hack"
	doc_content_1 = "<a href='byond://?src=[REF(src)];choice=decypher'>\> Decypher Encryption Key - (Science)</a><br>"


/obj/machinery/computer/terminal/telecoms_cracker/Topic(href, href_list)
	..()
	var/mob/living/U = usr
	switch(href_list["choice"])
		if ("decypher")
			if (U.skill_check(SKILL_SCIENCE, HARD_CHECK, TRUE))
				doc_content_1 = "Hack Successful <br>"
				for(var/obj/machinery/telecomms/message_server/T in GLOB.telecomms_list)
					doc_content_1 += "[T] with key [T.decryptkey] <br>"
				loaded_content = doc_content_1
			else
				to_chat(U, span_bad("You lack the skill needed to do that."))
	updateUsrDialog()
	return
