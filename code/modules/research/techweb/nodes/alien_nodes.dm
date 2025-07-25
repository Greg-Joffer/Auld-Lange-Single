
////////////////////////Alien technology////////////////////////
/datum/techweb_node/alientech //AYYYYYYYYLMAOO tech
	id = "alientech"
	display_name = "Experimental Technology" //Fortuna edit: Alien tech -> Experimental tech
	description = "The absolute cutting edge."
	prereq_ids = list("biotech","engineering")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
	hidden = TRUE
	design_ids = list("alienalloy")

/datum/techweb_node/alientech/New()
	. = ..()
	boost_item_paths = typesof(/obj/item/gun/energy/alien, /obj/item/scalpel/alien, /obj/item/hemostat/alien,
							/obj/item/retractor/alien, /obj/item/circular_saw/alien, /obj/item/cautery/alien,
							/obj/item/surgicaldrill/alien, /obj/item/screwdriver/abductor, /obj/item/wrench/abductor,
							/obj/item/crowbar/abductor, /obj/item/multitool/abductor,
							/obj/item/stock_parts/cell/infinite/abductor, /obj/item/weldingtool/abductor,
							/obj/item/wirecutters/abductor, /obj/item/circuitboard/machine/abductor,
							/obj/item/abductor, /obj/item/stack/sheet/mineral/abductor)

/datum/techweb_node/alien_bio
	id = "alien_bio"
	display_name = "Experimental Biological Tools" //Fortuna edit: Alien tech -> Experimental tech
	description = "Highly advanced surgical tools."
	prereq_ids = list("alientech", "advance_surgerytools")
	design_ids = list("alien_scalpel", "alien_hemostat", "alien_retractor", "alien_saw", "alien_drill", "alien_cautery", "ayyplantgenes")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)

/datum/techweb_node/alien_engi
	id = "alien_engi"
	display_name = "Experimental Engineering" //Fortuna edit: Alien tech -> Experimental tech
	description = "Highly advanced engineering tools."
	prereq_ids = list("alientech", "exp_tools")
	design_ids = list("alien_wrench", "alien_wirecutters", "alien_screwdriver", "alien_crowbar", "alien_welder", "alien_multitool", "plasmacutter_adv")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 5000)
