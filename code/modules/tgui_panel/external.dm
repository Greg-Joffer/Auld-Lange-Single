/*!
 * Copyright (c) 2020 Aleksej Komarov
 * SPDX-License-Identifier: MIT
 */

/client/var/datum/tgui_panel/tgui_panel

/**
 * tgui panel / chat troubleshooting verb
 */
/client/verb/fix_tgui_panel()
	set name = "Fix chat"
	set category = "OOC"
	var/action
	log_tgui(src, "Started fixing.", context = "verb/fix_tgui_panel")

	nuke_chat()

	// Failed to fix
	action = alert(src, "Did that work?", "", "Yes", "No, switch to old ui")
	if (action == "No, switch to old ui")
		winset(src, "legacy_output_selector", "left=output_legacy")
		log_tgui(src, "Failed to fix.", context = "verb/fix_tgui_panel")

/client/proc/nuke_chat()
	// Catch all solution (kick the whole thing in the pants)
	winset(src, "legacy_output_selector", "left=output_legacy")
	if(!tgui_panel || !istype(tgui_panel))
		log_tgui(src, "tgui_panel datum is missing",
			context = "verb/fix_tgui_panel")
		tgui_panel = new(src)
	tgui_panel.initialize(force = TRUE)
	// Force show the panel to see if there are any errors
	winset(src, "output", "is-disabled=1&is-visible=0")
	winset(src, "browseroutput", "is-disabled=0;is-visible=1")
	if(byond_version >= 516)
		winset(src, null, list("browser-options" = "find,refresh"))


/client/verb/panel_devtools()
	set name = "Enable TGUI Devtools"
	set category = "OOC"
	winset(src, "", "browser-options=devtools")
