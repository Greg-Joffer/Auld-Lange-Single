#define ROUND_START_MUSIC_LIST "strings/round_start_sounds.txt"
#define ROUND_BEGIN_MUSIC_LIST "strings/round_begin_sounds.txt"

SUBSYSTEM_DEF(ticker)
	name = "Ticker"
	init_order = INIT_ORDER_TICKER

	priority = FIRE_PRIORITY_TICKER
	flags = SS_KEEP_TIMING
	runlevels = RUNLEVEL_LOBBY | RUNLEVEL_SETUP | RUNLEVEL_GAME

	var/current_state = GAME_STATE_STARTUP	//state of current round (used by process()) Use the defines GAME_STATE_* !
	var/force_ending = 0					//Round was ended by admin intervention
	// If true, there is no lobby phase, the game starts immediately.
	var/start_immediately = FALSE
	var/setup_done = FALSE //All game setup done including mode post setup and

	var/hide_mode = 0
	var/datum/game_mode/mode = null
	var/event_time = null
	var/event = 0

	var/login_music							//music played in pregame lobby
	var/begin_music							//F13 Round start sound
	var/round_end_sound						//music/jingle played when the world reboots
	var/round_end_sound_sent = TRUE			//If all clients have loaded it

	var/list/datum/mind/minds = list()		//The characters in the game. Used for objective tracking.

	var/list/syndicate_coalition = list()	//list of traitor-compatible factions
	var/list/factions = list()				//list of all factions
	var/list/availablefactions = list()		//list of factions with openings
	var/list/scripture_states = list(SCRIPTURE_DRIVER = TRUE, \
	SCRIPTURE_SCRIPT = FALSE, \
	SCRIPTURE_APPLICATION = FALSE) //list of clockcult scripture states for announcements

	var/delay_end = 0						//if set true, the round will not restart on it's own
	var/admin_delay_notice = ""				//a message to display to anyone who tries to restart the world after a delay
	var/ready_for_reboot = FALSE			//all roundend preparation done with, all that's left is reboot

	var/triai = 0							//Global holder for Triumvirate
	var/tipped = 0							//Did we broadcast the tip of the day yet?
	var/selected_tip						// What will be the tip of the day?

	var/timeLeft						//pregame timer
	var/start_at

	/// Deciseconds to add to world.time for station time.
	var/gametime_offset = 216000
	var/station_time_rate_multiplier = 6		//factor of station time progressal vs real time.
	var/timezone_offset_positive = 0            //add time for a timezone offset
	var/timezone_offset_negative = 216000       //remove time for a timezone offset (UTC to CT)

	var/totalPlayers = 0					//used for pregame stats on statpanel
	var/totalPlayersReady = 0				//used for pregame stats on statpanel

	var/queue_delay = 0
	var/list/queued_players = list()		//used for join queues when the server exceeds the hard population cap

	var/maprotatechecked = 0

	var/news_report

	var/late_join_disabled

	var/roundend_check_paused = FALSE

	var/round_start_time = 0
	var/list/round_start_events
	var/list/round_end_events
	var/mode_result = "undefined"
	var/end_state = "undefined"

	var/modevoted = FALSE					//Have we sent a vote for the gamemode?

	var/station_integrity = 100				// stored at roundend for use in some antag goals

/datum/controller/subsystem/ticker/Initialize(timeofday)
	load_mode()

	var/list/byond_sound_formats = list(
		"mid"  = TRUE,
		"midi" = TRUE,
		"mod"  = TRUE,
		"it"   = TRUE,
		"s3m"  = TRUE,
		"xm"   = TRUE,
		"oxm"  = TRUE,
		"wav"  = TRUE,
		"ogg"  = TRUE,
		"raw"  = TRUE,
		"wma"  = TRUE,
		"aiff" = TRUE
	)

	var/list/provisional_title_music = flist("[global.config.directory]/title_music/sounds/")
	var/list/music = list()
	var/use_rare_music = prob(1)

	for(var/S in provisional_title_music)
		var/lower = lowertext(S)
		var/list/L = splittext(lower,"+")
		switch(L.len)
			if(3) //rare+MAP+sound.ogg or MAP+rare.sound.ogg -- Rare Map-specific sounds
				if(use_rare_music)
					if(L[1] == "rare" && L[2] == SSmapping.config.map_name)
						music += S
					else if(L[2] == "rare" && L[1] == SSmapping.config.map_name)
						music += S
			if(2) //rare+sound.ogg or MAP+sound.ogg -- Rare sounds or Map-specific sounds
				if((use_rare_music && L[1] == "rare") || (L[1] == SSmapping.config.map_name))
					music += S
			if(1) //sound.ogg -- common sound
				music += S

	var/old_login_music = trim(file2text("data/last_round_lobby_music.txt"))
	if(music.len > 1)
		music -= old_login_music

	for(var/S in music)
		var/list/L = splittext(S,".")
		if(L.len >= 2)
			var/ext = lowertext(L[L.len]) //pick the real extension, no nonsense here
			if(byond_sound_formats[ext])
				continue
		music -= S

	if(isemptylist(music))
		music = world.file2list(ROUND_BEGIN_MUSIC_LIST, "\n")
		begin_music = pick(music)
		music = world.file2list(ROUND_START_MUSIC_LIST, "\n")
		login_music = pick(music)
	else
		login_music = "[global.config.directory]/title_music/sounds/[pick(music)]"


	if(!GLOB.syndicate_code_phrase)
		GLOB.syndicate_code_phrase	= generate_code_phrase(return_list=TRUE)

		var/codewords = jointext(GLOB.syndicate_code_phrase, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_phrase_regex = codeword_match

	if(!GLOB.syndicate_code_response)
		GLOB.syndicate_code_response = generate_code_phrase(return_list=TRUE)

		var/codewords = jointext(GLOB.syndicate_code_response, "|")
		var/regex/codeword_match = new("([codewords])", "ig")

		GLOB.syndicate_code_response_regex = codeword_match

	start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
	if(CONFIG_GET(flag/randomize_shift_time))
		gametime_offset = rand(0, 23) HOURS
	else if(CONFIG_GET(flag/shift_time_realtime))
		gametime_offset = world.timeofday + timezone_offset_positive - timezone_offset_negative
	return ..()

/datum/controller/subsystem/ticker/fire()
	switch(current_state)
		if(GAME_STATE_STARTUP)
			if(Master.initializations_finished_with_no_players_logged_in)
				start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
			for(var/client/C in GLOB.clients)
				window_flash(C, ignorepref = TRUE) //let them know lobby has opened up.
			to_chat(world, span_boldnotice("Welcome to [station_name()]!"))
			send2chat("New round starting on [SSmapping.config.map_name]!", CONFIG_GET(string/chat_announce_new_game))
			current_state = GAME_STATE_PREGAME
			//Everyone who wants to be an observer is now spawned
			create_observers()
			fire()
		if(GAME_STATE_PREGAME)
				//lobby stats for statpanels
			if(isnull(timeLeft))
				timeLeft = max(0,start_at - world.time)
			totalPlayers = 0
			totalPlayersReady = 0
			for(var/mob/dead/new_player/player in GLOB.player_list)
				++totalPlayers
				if(player.ready == PLAYER_READY_TO_PLAY)
					++totalPlayersReady

			if(start_immediately)
				timeLeft = 0

			//clampif(!modevoted)
				//send_gamemode_vote()
			//countdown
			if(timeLeft < 0)
				return
			timeLeft -= wait

			if(timeLeft <= 300 && !tipped)
				send_tip_of_the_round()
				tipped = TRUE

			if(timeLeft <= 0)
				if(SSvote.mode && (SSvote.mode == "roundtype" || SSvote.mode == "dynamic" || SSvote.mode == "mode tiers"))
					SSvote.result()
					SSpersistence.SaveSavedVotes()
					for(var/client/C in SSvote.voting)
						C << browse(null, "window=vote;can_close=0")
					SSvote.reset()
				current_state = GAME_STATE_SETTING_UP
				Master.SetRunLevel(RUNLEVEL_SETUP)
				if(start_immediately)
					fire()

		if(GAME_STATE_SETTING_UP)
			if(!setup())
				//setup failed
				current_state = GAME_STATE_STARTUP
				start_at = world.time + (CONFIG_GET(number/lobby_countdown) * 10)
				timeLeft = null
				Master.SetRunLevel(RUNLEVEL_LOBBY)

		if(GAME_STATE_PLAYING)
			mode.process(wait * 0.1)
			check_queue()
			check_maprotate()
			scripture_states = scripture_unlock_alert(scripture_states)
			//SSshuttle.autoEnd()

			if(!roundend_check_paused && mode.check_finished(force_ending) || force_ending)
				current_state = GAME_STATE_FINISHED
				toggle_ooc(TRUE) // Turn it on
				toggle_dooc(TRUE)
				declare_completion(force_ending)
				Master.SetRunLevel(RUNLEVEL_POSTGAME)


/datum/controller/subsystem/ticker/proc/setup()
	to_chat(world, span_boldannounce("Starting game..."))
	var/init_start = world.timeofday
		//Create and announce mode
	var/list/datum/game_mode/runnable_modes
	if(GLOB.master_mode == "random" || GLOB.master_mode == "secret")
		runnable_modes = config.get_runnable_modes()

		if(GLOB.master_mode == "secret")
			hide_mode = 1
			if(GLOB.secret_force_mode != "secret")
				var/datum/game_mode/smode = config.pick_mode(GLOB.secret_force_mode)
				if(!smode.can_start())
					message_admins(span_notice("Unable to force secret [GLOB.secret_force_mode]. [smode.required_players] players and [smode.required_enemies] eligible antagonists needed."))
				else
					mode = smode

		if(!mode)
			if(!runnable_modes.len)
				to_chat(world, "<B>Unable to choose playable game mode.</B> Reverting to pre-game lobby.")
				return 0
			mode = pickweight(runnable_modes)
			if(!mode)	//too few roundtypes all run too recently
				mode = pick(runnable_modes)

	else
		mode = config.pick_mode(GLOB.master_mode)
		if(!mode.can_start())
			to_chat(world, "<B>Unable to start [mode.name].</B> Not enough players, [mode.required_players] players and [mode.required_enemies] eligible antagonists needed. Reverting to pre-game lobby.")
			qdel(mode)
			mode = null
			SSjob.ResetOccupations()
			return 0

	CHECK_TICK
	//Configure mode and assign player to special mode stuff
	var/can_continue = 0
	can_continue = src.mode.pre_setup()		//Choose antagonists
	CHECK_TICK
	can_continue = can_continue && SSjob.DivideOccupations(mode.required_jobs) 				//Distribute jobs
	CHECK_TICK

	if(!GLOB.Debug2)
		if(!can_continue)
			log_game("[mode.name] failed pre_setup, cause: [mode.setup_error]")
			send2irc("SSticker", "[mode.name] failed pre_setup, cause: [mode.setup_error]")
			message_admins(span_notice("[mode.name] failed pre_setup, cause: [mode.setup_error]"))
			QDEL_NULL(mode)
			to_chat(world, "<B>Error setting up [GLOB.master_mode].</B> Reverting to pre-game lobby.")
			SSjob.ResetOccupations()
			return 0
	else
		message_admins(span_notice("DEBUG: Bypassing prestart checks..."))

	CHECK_TICK
	/*if(hide_mode) CIT CHANGE - comments this section out to obfuscate gamemodes. Quit self-antagging during extended just because "hurrrrr no antaggs!!!!!! i giv sec thing 2 do!!!!!!!!!" it's bullshit and everyone hates it
		var/list/modes = new
		for (var/datum/game_mode/M in runnable_modes)
			modes += M.name
		modes = sortList(modes)
		to_chat(world, "<b>The gamemode is: secret!\nPossibilities:</B> [english_list(modes)]")
	else
		mode.announce()*/

	if(!CONFIG_GET(flag/ooc_during_round))
		toggle_ooc(FALSE) // Turn it off

	CHECK_TICK
	GLOB.start_landmarks_list = shuffle(GLOB.start_landmarks_list) //Shuffle the order of spawn points so they dont always predictably spawn bottom-up and right-to-left
	create_characters() //Create player characters
	collect_minds()
	equip_characters()

	GLOB.data_core.manifest()

	transfer_characters()	//transfer keys to the new mobs

	for(var/I in round_start_events)
		var/datum/callback/cb = I
		cb.InvokeAsync()
	LAZYCLEARLIST(round_start_events)

	log_world("Game start took [(world.timeofday - init_start)/10]s")
	round_start_time = world.time
	// Time sync
	if(CONFIG_GET(flag/shift_time_realtime) && !CONFIG_GET(flag/randomize_shift_time))
		gametime_offset = world.timeofday + timezone_offset_positive - timezone_offset_negative
	SSdbcore.SetRoundStart()

	to_chat(world, "<span class='notice'><B>Welcome to [station_name()], enjoy your stay!</B></span>")
	SEND_SOUND(world, sound(begin_music))

	current_state = GAME_STATE_PLAYING
	Master.SetRunLevel(RUNLEVEL_GAME)

	if(SSevents.holidays)
		to_chat(world, span_notice("and..."))
		for(var/holidayname in SSevents.holidays)
			var/datum/holiday/holiday = SSevents.holidays[holidayname]
			to_chat(world, "<h4>[holiday.greet()]</h4>")

	PostSetup()
	SSshuttle.realtimeofstart = world.realtime

	return TRUE

/datum/controller/subsystem/ticker/proc/PostSetup()
	set waitfor = FALSE
	mode.post_setup()
	GLOB.start_state = new /datum/station_state()
	GLOB.start_state.count()

	var/list/adm = get_admin_counts()
	var/list/allmins = adm["present"]
	send2irc("Server", "Round [GLOB.round_id ? "#[GLOB.round_id]:" : "of"] [hide_mode ? "secret":"[mode.name]"] has started[allmins.len ? ".":" with no active admins online!"]")
	setup_done = TRUE

	for(var/i in GLOB.start_landmarks_list)
		var/obj/effect/landmark/start/S = i
		if(istype(S))							//we can not runtime here. not in this important of a proc.
			S.after_round_start()
		else
			stack_trace("[S] [S.type] found in start landmarks list, which isn't a start landmark!")


//These callbacks will fire after roundstart key transfer
/datum/controller/subsystem/ticker/proc/OnRoundstart(datum/callback/cb)
	if(!HasRoundStarted())
		LAZYADD(round_start_events, cb)
	else
		cb.InvokeAsync()

//These callbacks will fire before roundend report
/datum/controller/subsystem/ticker/proc/OnRoundend(datum/callback/cb)
	if(current_state >= GAME_STATE_FINISHED)
		cb.InvokeAsync()
	else
		LAZYADD(round_end_events, cb)

/datum/controller/subsystem/ticker/proc/station_explosion_detonation(atom/bomb)
	if(bomb)	//BOOM
		var/turf/epi = bomb.loc
		qdel(bomb)
		if(epi)
			explosion(epi, 512, 0, 0, 0, TRUE, TRUE, 0, TRUE)

/datum/controller/subsystem/ticker/proc/create_characters()
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if(player.ready == PLAYER_READY_TO_PLAY && player.mind)
			GLOB.joined_player_list += player.ckey
			player.create_character(FALSE)
		else
			player.new_player_panel()
		CHECK_TICK

/datum/controller/subsystem/ticker/proc/collect_minds()
	for(var/mob/dead/new_player/P in GLOB.player_list)
		if(P.new_character && P.new_character.mind)
			SSticker.minds += P.new_character.mind
		CHECK_TICK


/datum/controller/subsystem/ticker/proc/equip_characters()
	var/captainless=1
	for(var/mob/dead/new_player/N in GLOB.player_list)
		var/mob/living/carbon/human/player = N.new_character
		if(istype(player) && player.mind && player.mind.assigned_role)
			var/datum/job/J = SSjob.GetJob(player.mind.assigned_role)
			if(J)
				J.standard_assign_skills(player.mind)
			if(player.mind.assigned_role == "Captain")
				captainless=0
			if(player.mind.assigned_role != player.mind.special_role)
				SSjob.EquipRank(N, player.mind.assigned_role, 0)
				if(CONFIG_GET(flag/roundstart_traits) && ishuman(N.new_character))
					SSquirks.AssignQuirks(N.new_character, N.client, TRUE, TRUE, SSjob.GetJob(player.mind.assigned_role), FALSE, N)
			N.client.prefs.post_copy_to(player)
		CHECK_TICK
	if(captainless)
		for(var/mob/dead/new_player/N in GLOB.player_list)
			if(N.new_character)
				to_chat(N, "Captainship not forced on anyone.")
			CHECK_TICK

/datum/controller/subsystem/ticker/proc/transfer_characters()
	var/list/livings = list()
	for(var/mob/dead/new_player/player in GLOB.mob_list)
		var/mob/living = player.transfer_character()
		if(living)
			qdel(player)
			living.mob_transforming = TRUE
			if(living.client)
				if (living.client.prefs && living.client.prefs.auto_ooc)
					if (living.client.prefs.chat_toggles & CHAT_OOC)
						living.client.prefs.chat_toggles ^= CHAT_OOC
				var/obj/screen/splash/S = new(living.client, TRUE)
				S.Fade(TRUE)
				living.client.init_verbs()
			livings += living

	if(livings.len)
		addtimer(CALLBACK(src, PROC_REF(release_characters), livings), 30, TIMER_CLIENT_TIME)

	SSmatchmaking.matchmake()


/datum/controller/subsystem/ticker/proc/release_characters(list/livings)
	for(var/I in livings)
		var/mob/living/L = I
		L.mob_transforming = FALSE

/datum/controller/subsystem/ticker/proc/send_tip_of_the_round()
	var/m
	if(selected_tip)
		m = selected_tip
	else
		var/list/randomtips = world.file2list("strings/tips.txt")
		if(randomtips.len)
			m = pick(randomtips)

	if(m)
		to_chat(world, "<span class='purple'><b>Tip of the round: </b>[html_encode(m)]</span>")

/datum/controller/subsystem/ticker/proc/check_queue()
	var/hpc = CONFIG_GET(number/hard_popcap)
	if(!queued_players.len || !hpc)
		return

	queue_delay++
	var/mob/dead/new_player/next_in_line = queued_players[1]

	switch(queue_delay)
		if(5) //every 5 ticks check if there is a slot available
			if(living_player_count() < hpc)
				if(next_in_line && next_in_line.client)
					to_chat(next_in_line, "<span class='userdanger'>A slot has opened! You have approximately 20 seconds to join. <a href='byond://?src=[REF(next_in_line)];late_join=override'>\>\>Join Game\<\<</a></span>")
					SEND_SOUND(next_in_line, sound('sound/misc/notice1.ogg'))
					next_in_line.LateChoices()
					return
				queued_players -= next_in_line //Client disconnected, remove he
			queue_delay = 0 //No vacancy: restart timer
		if(25 to INFINITY)  //No response from the next in line when a vacancy exists, remove he
			to_chat(next_in_line, span_danger("No response received. You have been removed from the line."))
			queued_players -= next_in_line
			queue_delay = 0

/datum/controller/subsystem/ticker/proc/check_maprotate()
	if (!CONFIG_GET(flag/maprotation))
		return
	if (SSshuttle.emergency && SSshuttle.emergency.mode != SHUTTLE_ESCAPE || SSshuttle.canRecall())
		return
	if (maprotatechecked)
		return

	maprotatechecked = 1

	//map rotate chance defaults to 75% of the length of the round (in minutes)
	if (!prob((world.time/600)*CONFIG_GET(number/maprotatechancedelta)) && CONFIG_GET(flag/tgstyle_maprotation))
		return
	if(CONFIG_GET(flag/tgstyle_maprotation))
		INVOKE_ASYNC(SSmapping, TYPE_PROC_REF(/datum/controller/subsystem/mapping/, maprotate))
	else
		var/vote_type = CONFIG_GET(string/map_vote_type)
		switch(vote_type)
			if("PLURALITY")
				SSvote.initiate_vote("map","server", display = SHOW_RESULTS)
			if("APPROVAL")
				SSvote.initiate_vote("map","server", display = SHOW_RESULTS, votesystem = APPROVAL_VOTING)
			if("IRV")
				SSvote.initiate_vote("map","server", display = SHOW_RESULTS, votesystem = INSTANT_RUNOFF_VOTING)
			if("SCORE")
				SSvote.initiate_vote("map","server", display = SHOW_RESULTS, votesystem = MAJORITY_JUDGEMENT_VOTING)
			else
				SSvote.initiate_vote("map","server", display = SHOW_RESULTS)
		// fallback

/datum/controller/subsystem/ticker/proc/HasRoundStarted()
	return current_state >= GAME_STATE_PLAYING

/datum/controller/subsystem/ticker/proc/IsRoundInProgress()
	return current_state == GAME_STATE_PLAYING

/proc/send_gamemode_vote() //CIT CHANGE - adds roundstart gamemode votes
	if(SSticker.current_state == GAME_STATE_PREGAME)
		if(SSticker.timeLeft < 900)
			SSticker.timeLeft = 900
		SSticker.modevoted = TRUE
		var/dynamic = CONFIG_GET(flag/dynamic_voting)
		if(dynamic)
			SSvote.initiate_vote("dynamic", "server", display = NONE, votesystem = SCORE_VOTING, forced = TRUE,vote_time = 20 MINUTES)
		else
			SSvote.initiate_vote("roundtype", "server", display = NONE, votesystem = PLURALITY_VOTING, forced=TRUE, \
			vote_time = (CONFIG_GET(flag/modetier_voting) ? 1 MINUTES : 20 MINUTES))

/datum/controller/subsystem/ticker/Recover()
	current_state = SSticker.current_state
	force_ending = SSticker.force_ending
	hide_mode = SSticker.hide_mode
	mode = SSticker.mode
	event_time = SSticker.event_time
	event = SSticker.event

	login_music = SSticker.login_music
	begin_music = SSticker.begin_music
	round_end_sound = SSticker.round_end_sound

	minds = SSticker.minds

	syndicate_coalition = SSticker.syndicate_coalition
	factions = SSticker.factions
	availablefactions = SSticker.availablefactions

	delay_end = SSticker.delay_end

	triai = SSticker.triai
	tipped = SSticker.tipped
	selected_tip = SSticker.selected_tip

	timeLeft = SSticker.timeLeft

	totalPlayers = SSticker.totalPlayers
	totalPlayersReady = SSticker.totalPlayersReady

	queue_delay = SSticker.queue_delay
	queued_players = SSticker.queued_players
	maprotatechecked = SSticker.maprotatechecked
	round_start_time = SSticker.round_start_time

	queue_delay = SSticker.queue_delay
	queued_players = SSticker.queued_players
	maprotatechecked = SSticker.maprotatechecked

	modevoted = SSticker.modevoted

	switch (current_state)
		if(GAME_STATE_SETTING_UP)
			Master.SetRunLevel(RUNLEVEL_SETUP)
		if(GAME_STATE_PLAYING)
			Master.SetRunLevel(RUNLEVEL_GAME)
		if(GAME_STATE_FINISHED)
			Master.SetRunLevel(RUNLEVEL_POSTGAME)

/datum/controller/subsystem/ticker/proc/send_news_report()
	var/news_message
	var/news_source = "Oasis Publishing"
	switch(news_report)
		if(NUKE_SYNDICATE_BASE)
			news_message = "In a daring raid, the heroic crew of [station_name()] detonated a nuclear device in the heart of a terrorist base."
		if(STATION_DESTROYED_NUKE)
			news_message = "We would like to reassure all employees that the reports of a Syndicate backed nuclear attack on [station_name()] are, in fact, a hoax. Have a secure day!"
		if(STATION_EVACUATED)
			news_message = "The inhabitants of [station_name()] breathe a sigh of the relief as the week comes to an end. "
		if(BLOB_WIN)
			news_message = "[station_name()] was overcome by an unknown biological outbreak, killing all crew on board. Don't let it happen to you! Remember, a clean work station is a safe work station."
		if(BLOB_NUKE)
			news_message = "[station_name()] is currently undergoing decontanimation after a controlled burst of radiation was used to remove a biological ooze. All employees were safely evacuated prior, and are enjoying a relaxing vacation."
		if(BLOB_DESTROYED)
			news_message = "[station_name()] is currently undergoing decontamination procedures after the destruction of a biological hazard. As a reminder, any crew members experiencing cramps or bloating should report immediately to security for incineration."
		if(CULT_ESCAPE)
			news_message = "Security Alert: A group of religious fanatics have escaped from [station_name()]."
		if(CULT_FAILURE)
			news_message = "Following the dismantling of a restricted cult aboard [station_name()], we would like to remind all employees that worship outside of the Chapel is strictly prohibited, and cause for termination."
		if(CULT_SUMMON)
			news_message = "Company officials would like to clarify that [station_name()] was scheduled to be decommissioned following meteor damage earlier this year. Earlier reports of an unknowable eldritch horror were made in error."
		if(NUKE_MISS)
			news_message = "The Syndicate have bungled a terrorist attack [station_name()], detonating a nuclear weapon in empty space nearby."
		if(OPERATIVES_KILLED)
			news_message = "Repairs to [station_name()] are underway after an elite Syndicate death squad was wiped out by the crew."
		if(OPERATIVE_SKIRMISH)
			news_message = "A skirmish between security forces and Syndicate agents aboard [station_name()] ended with both sides bloodied but intact."
		if(REVS_WIN)
			news_message = "Company officials have reassured investors that despite a union led revolt aboard [station_name()] there will be no wage increases for workers."
		if(REVS_LOSE)
			news_message = "[station_name()] quickly put down a misguided attempt at mutiny. Remember, unionizing is illegal!"
		if(WIZARD_KILLED)
			news_message = "Tensions have flared with the Space Wizard Federation following the death of one of their members aboard [station_name()]."
		if(STATION_NUKED)
			news_message = "[station_name()] activated its self destruct device for unknown reasons. Attempts to clone the Captain so he can be arrested and executed are underway."
		if(CLOCK_SUMMON)
			news_message = "The garbled messages about hailing a mouse and strange energy readings from [station_name()] have been discovered to be an ill-advised, if thorough, prank by a clown."
		if(CLOCK_SILICONS)
			news_message = "The project started by [station_name()] to upgrade their silicon units with advanced equipment have been largely successful, though they have thus far refused to release schematics in a violation of company policy."
		if(CLOCK_PROSELYTIZATION)
			news_message = "The burst of energy released near [station_name()] has been confirmed as merely a test of a new weapon. However, due to an unexpected mechanical error, their communications system has been knocked offline."
		if(SHUTTLE_HIJACK)
			news_message = "During routine evacuation procedures, the emergency shuttle of [station_name()] had its navigation protocols corrupted and went off course, but was recovered shortly after."
		if(GANG_VICTORY)
			news_message = "Company officials reaffirmed that sudden deployments of special forces are not in any way connected to rumors of [station_name()] being covered in graffiti."

	if(SSblackbox.first_death)
		var/list/ded = SSblackbox.first_death
		//fortuna addition. list of random names for the roundend news investigator
		var/list/investigator = list("Oasis Investigators","A band of couriers","Patrolling rangers","A few mysterious strangers","The NCR","The Legion","The Brotherhood","The Den")
		if(ded.len)
			news_message += "[pick(investigator)] discovered the corpse of a person of interest in the area. Their name was: [ded["name"]], the [ded["role"]], who died in a nearby [ded["area"]].[ded["last_words"] ? " Their last words were: \"[ded["last_words"]]\"" : ""]"
		else
			news_message += " [pick(investigator)] have reported a relatively safe week so far!"

		//role ping for discord
		news_message += " \n <@&922230570791108628> "

	if(news_message)
		send2otherserver(news_source, news_message,"News_Report")
		return news_message
	else
		return "We regret to inform you that shit be whack, yo. None of our reporters have any idea of what may or may not have gone on."

/datum/controller/subsystem/ticker/proc/GetTimeLeft()
	if(isnull(SSticker.timeLeft))
		return max(0, start_at - world.time)
	return timeLeft

/datum/controller/subsystem/ticker/proc/SetTimeLeft(newtime)
	if(newtime >= 0 && isnull(timeLeft))	//remember, negative means delayed
		start_at = world.time + newtime
	else
		timeLeft = newtime

//Everyone who wanted to be an observer gets made one now
/datum/controller/subsystem/ticker/proc/create_observers()
	for(var/mob/dead/new_player/player in GLOB.player_list)
		if(player.ready == PLAYER_READY_TO_OBSERVE && player.mind)
			//Break chain since this has a sleep input in it
			addtimer(CALLBACK(player, TYPE_PROC_REF(/mob/dead/new_player, make_me_an_observer)), 1)

/datum/controller/subsystem/ticker/proc/load_mode()
	var/mode = trim(file2text("data/mode.txt"))
	if(mode)
		GLOB.master_mode = mode
	else
		GLOB.master_mode = "extended"
	log_game("Saved mode is '[GLOB.master_mode]'")

/datum/controller/subsystem/ticker/proc/save_mode(the_mode)
	var/F = file("data/mode.txt")
	fdel(F)
	WRITE_FILE(F, the_mode)

/datum/controller/subsystem/ticker/proc/SetRoundEndSound(the_sound)
	set waitfor = FALSE
	round_end_sound_sent = FALSE
	round_end_sound = fcopy_rsc(the_sound)
	for(var/thing in GLOB.clients)
		var/client/C = thing
		if (!C)
			continue
		C.Export("##action=load_rsc", round_end_sound)
	round_end_sound_sent = TRUE

/datum/controller/subsystem/ticker/proc/Reboot(reason, end_string, delay)
	set waitfor = FALSE
	if(usr && !check_rights(R_SERVER, TRUE))
		return

	if(!delay)
		delay = CONFIG_GET(number/round_end_countdown) * 10

	var/skip_delay = check_rights()
	if(delay_end && !skip_delay)
		to_chat(world, span_boldannounce("An admin has delayed the round end."))
		return

	to_chat(world, span_boldannounce("Rebooting World in [DisplayTimeText(delay)]. [reason]"))

	var/start_wait = world.time
	UNTIL(round_end_sound_sent || (world.time - start_wait) > (delay * 2))	//don't wait forever
	sleep(delay - (world.time - start_wait))

	if(delay_end && !skip_delay)
		to_chat(world, span_boldannounce("Reboot was cancelled by an admin."))
		return
	if(end_string)
		end_state = end_string

	var/statspage = CONFIG_GET(string/roundstatsurl)
	var/gamelogloc = CONFIG_GET(string/gamelogurl)
	if(statspage)
		to_chat(world, "<span class='info'>Round statistics and logs can be viewed <a href=\"[statspage][GLOB.round_id]\">at this website!</a></span>")
	else if(gamelogloc)
		to_chat(world, "<span class='info'>Round logs can be located <a href=\"[gamelogloc]\">at this website!</a></span>")

	log_game(span_boldannounce("Rebooting World. [reason]"))

	world.Reboot()

/datum/controller/subsystem/ticker/Shutdown()
	gather_newscaster() //called here so we ensure the log is created even upon admin reboot
	save_admin_data()
	update_everything_flag_in_db()
	if(!round_end_sound)
		round_end_sound = pick(\
		'sound/roundend/fallout_dodgeball_truncated.ogg',
		'sound/roundend/get_fucked.ogg',
		'sound/roundend/roundend_jean_baptist.ogg',
		'sound/roundend/roundend_nuclear_backyard.ogg',
		'sound/roundend/roundend_patrolling.ogg',
		'sound/roundend/roundend_real_tunnel_snake.ogg',
		'sound/roundend/roundend_smoothskin.ogg',
		'sound/roundend/roundend_tunnel_snakes_rule.ogg',
		'sound/roundend/gondolabridge.ogg',
		'sound/roundend/haveabeautifultime.ogg',
		'sound/roundend/whereisyourpowerarmor.ogg',
		'sound/roundend/timetodie.ogg',
		'sound/roundend/ishouldkickyourass.ogg',
		'sound/roundend/triumphantvictory.ogg',
		'sound/roundend/evilmrnv.ogg'\
		)

	SEND_SOUND(world, sound(round_end_sound))
	text2file(login_music, "data/last_round_lobby_music.txt")
