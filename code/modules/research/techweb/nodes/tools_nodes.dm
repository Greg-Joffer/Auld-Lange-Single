
////////////////////////Tools////////////////////////
/datum/techweb_node/basic_tools
	id = "basic_tools"
	display_name = "Basic Tools"
	description = "Basic mechanical, electronic, surgical and botanical tools."
	prereq_ids = list("base")
	design_ids = list("screwdriver", "wrench", "wirecutters", "crowbar", "multitool", "welding_tool", "tscanner", "analyzer", "cable_coil", "pipe_painter", "airlock_painter", "decal_painter", "scalpel", "circular_saw", "surgicaldrill", "retractor", "cautery", "hemostat", "cultivator", "plant_analyzer", "shovel", "spade", "hatchet", "mop", "broom", "normtrash", "spraycan")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500)
	alt_skill = SKILL_REPAIR

/datum/techweb_node/basic_mining
	id = "basic_mining"
	display_name = "Mining Technology"
	description = "Better than Efficiency V."
	prereq_ids = list("engineering", "basic_plasma")
	design_ids = list("drill", "superresonator", "triggermod", "damagemod", "cooldownmod", "rangemod", "ore_redemption", "mining_equipment_vendor", "cargoexpress", "mining_scanner")//CB Edit Yeet Plasma cutter
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1000)
	alt_skill = SKILL_REPAIR

/datum/techweb_node/adv_mining
	id = "adv_mining"
	display_name = "Advanced Mining Technology"
	description = "Efficiency Level 127"	//dumb mc references
	prereq_ids = list("basic_mining", "adv_engi", "adv_power", "adv_plasma")
	design_ids = list("drill_diamond", "mole_miner", "hypermod", "ore_silo", "plasteel_pick", "titanium_pick", "adv_mining_scanner") //CB Edit Yeet Plasma Cutter
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
	alt_skill = SKILL_REPAIR
	skill_level_needed = REGULAR_CHECK


/datum/techweb_node/janitor
	id = "janitor"
	display_name = "Advanced Sanitation Technology"
	description = "Clean things better, faster, stronger, and harder!"
	prereq_ids = list("adv_engi")
	design_ids = list("advmop", "buffer", "light_replacer", "spraybottle", "beartrap", "ci-janitor", "paint_remover")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 1750) // No longer has its bag

/datum/techweb_node/botany
	id = "botany"
	display_name = "Botanical Engineering"
	description = "Botanical tools."
	prereq_ids = list("adv_engi", "biotech")
	design_ids = list("diskplantgene", "portaseeder", "plantgenes", "hydro_tray", "biogenerator", "seed_extractor")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2750)

/datum/techweb_node/exp_tools
	id = "exp_tools"
	display_name = "Experimental Tools"
	description = "Highly advanced construction tools."
	design_ids = list("exwelder", "jawsoflife", "handdrill", "holosigncombifan", "ranged_analyzer")
	prereq_ids = list("adv_engi")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2750)
	alt_skill = SKILL_REPAIR
	skill_level_needed = REGULAR_CHECK


/datum/techweb_node/sec_basic
	id = "sec_basic"
	display_name = "Basic Security Equipment"
	description = "Standard equipment used by security."
	design_ids = list("seclite", "pepperspray", "zipties", "evidencebag")
	prereq_ids = list("base")
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 500)
