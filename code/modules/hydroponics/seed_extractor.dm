/**
 * Finds and extracts seeds from an object
 *
 * Checks if the object is such that creates a seed when extracted.  Used by seed
 * extractors or posably anything that would create seeds in some way.  The seeds
 * are dropped either at the extractor, if it exists, or where the original object
 * was and it qdel's the object
 *
 * Arguments:
 * * O - Object containing the seed, can be the loc of the dumping of seeds
 * * t_max - Amount of seed copies to dump, -1 is ranomized
 * * extractor - Seed Extractor, used as the dumping loc for the seeds and seed multiplier
 * * user - checks if we can remove the object from the inventory
 * *
 */
/proc/seedify(obj/item/O, t_max, obj/machinery/seed_extractor/extractor, mob/living/user)
	var/t_amount = 0
	var/list/seeds = list()
	if(t_max == -1)
		if(extractor)
			t_max = rand(1,4) * extractor.seed_multiplier
		else
			t_max = rand(1,4)

	var/seedloc = O.loc
	if(extractor)
		seedloc = extractor.loc

	if(istype(O, /obj/item/reagent_containers/food/snacks/grown/))
		var/obj/item/reagent_containers/food/snacks/grown/F = O
		if(F.seed)
			if(user && !user.temporarilyRemoveItemFromInventory(O)) //couldn't drop the item
				return
			while(t_amount < t_max)
				var/obj/item/seeds/t_prod = F.seed.Copy()
				seeds.Add(t_prod)
				t_prod.forceMove(seedloc)
				t_amount++
			qdel(O)
			return seeds

	else if(istype(O, /obj/item/grown))
		var/obj/item/grown/F = O
		if(F.seed)
			if(user && !user.temporarilyRemoveItemFromInventory(O))
				return
			while(t_amount < t_max)
				var/obj/item/seeds/t_prod = F.seed.Copy()
				t_prod.forceMove(seedloc)
				t_amount++
			qdel(O)
		return 1

	return 0


/obj/machinery/seed_extractor
	name = "seed extractor"
	desc = "Extracts and bags seeds from produce."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "sextractor"
	density = TRUE
	circuit = /obj/item/circuitboard/machine/seed_extractor
	/// Associated list of seeds, they are all weak refs.  We check the len to see how many refs we have for each
	// seed
	tooadvanced = TRUE
	var/list/piles = list()
	var/max_seeds = 1000
	var/seed_multiplier = 1

/obj/machinery/seed_extractor/RefreshParts()
	for(var/obj/item/stock_parts/matter_bin/B in component_parts)
		max_seeds = initial(max_seeds) * B.rating
	for(var/obj/item/stock_parts/manipulator/M in component_parts)
		seed_multiplier = initial(seed_multiplier) * M.rating

/obj/machinery/seed_extractor/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		. += "<span class='notice'>The status display reads: Extracting <b>[seed_multiplier]</b> seed(s) per piece of produce.<br>Machine can store up to <b>[max_seeds]%</b> seeds.</span>"

/obj/machinery/seed_extractor/attackby(obj/item/O, mob/user, params)

	if(default_deconstruction_screwdriver(user, "sextractor_open", "sextractor", O))
		return

	if(default_pry_open(O))
		return

	if(default_unfasten_wrench(user, O))
		return

	if(default_deconstruction_crowbar(O))
		return

	if(istype(O, /obj/item/storage/bag/plants))
		var/obj/item/storage/P = O
		var/loaded = 0
		for(var/obj/item/seeds/G in P.contents)
			if(contents.len >= max_seeds)
				break
			++loaded
			add_seed(G)
		if (loaded)
			to_chat(user, span_notice("You put as many seeds from \the [O.name] into [src] as you can."))
		else
			to_chat(user, span_notice("There are no seeds in \the [O.name]."))
		return

	else if(seedify(O,-1, src, user))
		to_chat(user, span_notice("You extract some seeds."))
		return
	else if (istype(O, /obj/item/seeds))
		if(add_seed(O))
			to_chat(user, span_notice("You add [O] to [src.name]."))
			updateUsrDialog()
		return
	else if(user.a_intent != INTENT_HARM)
		to_chat(user, span_warning("You can't extract any seeds from \the [O.name]!"))
	else
		return ..()

/**
 * Generate seed string
 *
 * Creates a string based of the traits of a seed.  We use this string as a bucket for all
 * seeds that match as well as the key the ui uses to get the seed.  We also use the key
 * for the data shown in the ui.  Javascript parses this string to display
 *
 * Arguments:
 * * O - seed to generate the string from
 */
/obj/machinery/seed_extractor/proc/generate_seed_string(obj/item/seeds/O)
	return "name=[O.name];lifespan=[O.lifespan];endurance=[O.endurance];maturation=[O.maturation];production=[O.production];yield=[O.yield];potency=[O.potency];instability=0"


/** Add Seeds Proc.
 *
 * Adds the seeds to the contents and to an associated list that pregenerates the data
 * needed to go to the ui handler
 *
 */
/obj/machinery/seed_extractor/proc/add_seed(obj/item/seeds/O)
	if(contents.len >= 999)
		to_chat(usr, span_notice("\The [src] is full."))
		return FALSE

	var/datum/component/storage/STR = O.loc.GetComponent(/datum/component/storage)
	if(STR)
		if(!STR.remove_from_storage(O,src))
			return FALSE
	else if(ismob(O.loc))
		var/mob/M = O.loc
		if(!M.transferItemToLoc(O, src))
			return FALSE

	var/seed_string = generate_seed_string(O)
	if(piles[seed_string])
		piles[seed_string] += WEAKREF(O)
	else
		piles[seed_string] = list(WEAKREF(O))

	. = TRUE

/obj/machinery/seed_extractor/ui_state(mob/user)
	return GLOB.notcontained_state

/obj/machinery/seed_extractor/ui_interact(mob/user, datum/tgui/ui)
	if(tooadvanced == TRUE && HAS_TRAIT(user, TRAIT_TECHNOPHOBE))
		to_chat(user, span_warning("The array of simplistic button pressing confuses you. Besides, did you really want to spend all day staring at a screen?"))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SeedExtractor", name)
		ui.open()


/obj/machinery/seed_extractor/ui_data()

	var/list/seeds = list()

	for(var/key in piles)
		var/obj/item/seeds/seed = GET_WEAKREF(piles[key][1])
		seeds[key] = list()
		seeds[key]["name"] = seed.name
		seeds[key]["key"] = key
		seeds[key]["lifespan"] = seed.lifespan
		seeds[key]["endurance"] = seed.endurance
		seeds[key]["maturation"] = seed.maturation
		seeds[key]["production"] = seed.production
		seeds[key]["yield"] = seed.yield
		seeds[key]["potency"] = seed.potency
		seeds[key]["instability"] = seed.instability
		seeds[key]["amount"] = piles[key]:len

	/*
	var/list/V = list()
	for(var/key in piles)
		if(piles[key])
			var/len = length(piles[key])
			if(len)
				V[key] = len


	*/
	. = list()
	.["seeds"] = seeds

/obj/machinery/seed_extractor/ui_act(action, params)
	if(..())
		return

	switch(action)
		if("select")
			var/item = params["item"]
			if(piles[item] && length(piles[item]) > 0)
				var/datum/weakref/WO = piles[item][1]
				var/obj/item/seeds/O = WO.resolve()
				if(O)
					piles[item] -= WO
					O.forceMove(drop_location())
					. = TRUE
					//to_chat(usr, span_notice("[src] clanks to life briefly before vending [prize.equipment_name]!"))
