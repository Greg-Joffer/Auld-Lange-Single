
/////////////////////////////////////////
/////////////////Mining//////////////////
/////////////////////////////////////////
/datum/design/cargo_express
	name = "Computer Design (Express Supply Console)"//shes beautiful
	desc = "Allows for the construction of circuit boards used to build an Express Supply Console."//who?
	id = "cargoexpress"//the coder reading this
	build_type = IMPRINTER
	materials = list(/datum/material/glass = 1000)
	build_path = /obj/item/circuitboard/computer/cargo/express
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/bluespace_pod
	name = "Supply Drop Pod Upgrade Disk"
	desc = "Allows the Cargo Express Console to call down the Bluespace Drop Pod, greatly increasing user safety."//who?
	id = "bluespace_pod"//the coder reading this
	build_type = PROTOLATHE
	materials = list(/datum/material/glass = 1000)
	build_path = /obj/item/disk/cargo/bluespace_pod
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/drill
	name = "Mining Drill"
	desc = "Yours is the drill that will pierce through the rock walls."
	id = "drill"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 1000) //expensive, but no need for miners.
	build_path = /obj/item/pickaxe/drill
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/drill_diamond
	name = "Diamond-Tipped Mining Drill"
	desc = "Yours is the drill that will pierce the heavens!"
	id = "drill_diamond"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 1000, /datum/material/diamond = 2000) //Yes, a whole diamond is needed.
	build_path = /obj/item/pickaxe/drill/diamonddrill
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/plasmacutter
	name = "Plasma Cutter"
	desc = "You could use it to cut limbs off of xenos! Or, you know, mine stuff."
	id = "plasmacutter"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 1500, /datum/material/glass = 500, /datum/material/plasma = 400)
	build_path = /obj/item/gun/energy/plasmacutter
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/plasmacutter_adv
	name = "Advanced Plasma Cutter"
	desc = "It's an advanced plasma cutter, oh my god."
	id = "plasmacutter_adv"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 3000, /datum/material/glass = 1000, /datum/material/plasma = 2000, /datum/material/gold = 500)
	build_path = /obj/item/gun/energy/plasmacutter/adv
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/mining_scanner
	name = "Mining Scanner"
	desc = "A simple scanner for detecting ores."
	id = "mining_scanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 400, /datum/material/glass = 800, /datum/material/uranium = 100)
	build_path = /obj/item/mining_scanner
	category = list("Tool Designs")
	departmental_flags =  DEPARTMENTAL_FLAG_CARGO

/datum/design/adv_mining_scanner
	name = "Mining Scanner"
	desc = "A simple scanner for detecting ores."
	id = "adv_mining_scanner"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 400, /datum/material/glass = 800, /datum/material/uranium = 100, /datum/material/gold = 200)
	build_path = /obj/item/t_scanner/adv_mining_scanner
	category = list("Tool Designs")
	departmental_flags =  DEPARTMENTAL_FLAG_CARGO

/datum/design/plasteel_pick
	name = "plasteel-tipped pickaxe"
	desc = "A pickaxe with a plasteel pick head. Less robust at cracking rock walls and digging up dirt than the titanium pickaxe, but better at cracking open skulls."
	id = "plasteel_pick"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron=2000, /datum/material/plasma=2000)
	build_path = /obj/item/pickaxe/plasteel
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/titanium_pick
	name = "titanium-tipped pickaxe"
	desc = "A pickaxe with a titanium pick head. Extremely robust at cracking rock walls and digging up dirt, but less than the plasteel pickaxe at cracking open skulls."
	id = "titanium_pick"
	build_type = PROTOLATHE
	materials = list(/datum/material/titanium = 4000)
	build_path = /obj/item/pickaxe/titanium
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/moleminer
	name = "mole miner gauntlet"
	desc = "A hand-held mining and cutting implement, repurposed into a deadly melee weapon.  Its name origins are a mystery..."
	id = "mole_miner"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 6000, /datum/material/glass = 2000, /datum/material/silver = 2000, /datum/material/diamond = 6000)
	build_path = /obj/item/melee/powerfist/f13/moleminer
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/superresonator
	name = "Upgraded Resonator"
	desc = "An upgraded version of the resonator that allows more fields to be active at once."
	id = "superresonator"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 4000, /datum/material/glass = 1500, /datum/material/silver = 1000, /datum/material/uranium = 1000)
	build_path = /obj/item/resonator/upgraded
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/trigger_guard_mod
	name = "Kinetic Accelerator Trigger Guard Mod"
	desc = "A device which allows kinetic accelerators to be wielded by any organism."
	id = "triggermod"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1500, /datum/material/gold = 1500, /datum/material/uranium = 1000)
	build_path = /obj/item/borg/upgrade/modkit/trigger_guard
	category = list("Mining Designs")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/damage_mod
	name = "Kinetic Accelerator Damage Mod"
	desc = "A device which allows kinetic accelerators to deal more damage."
	id = "damagemod"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1500, /datum/material/gold = 1500, /datum/material/uranium = 1000)
	build_path = /obj/item/borg/upgrade/modkit/damage
	category = list("Mining Designs", "Cyborg Upgrade Modules")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/cooldown_mod
	name = "Kinetic Accelerator Cooldown Mod"
	desc = "A device which decreases the cooldown of a Kinetic Accelerator."
	id = "cooldownmod"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1500, /datum/material/gold = 1500, /datum/material/uranium = 1000)
	build_path = /obj/item/borg/upgrade/modkit/cooldown
	category = list("Mining Designs", "Cyborg Upgrade Modules")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/range_mod
	name = "Kinetic Accelerator Range Mod"
	desc = "A device which allows kinetic accelerators to fire at a further range."
	id = "rangemod"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 2000, /datum/material/glass = 1500, /datum/material/gold = 1500, /datum/material/uranium = 1000)
	build_path = /obj/item/borg/upgrade/modkit/range
	category = list("Mining Designs", "Cyborg Upgrade Modules")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/design/hyperaccelerator
	name = "Kinetic Accelerator Mining AoE Mod"
	desc = "A modification kit for Kinetic Accelerators which causes it to fire AoE blasts that destroy rock."
	id = "hypermod"
	build_type = PROTOLATHE | MECHFAB
	materials = list(/datum/material/iron = 8000, /datum/material/glass = 1500, /datum/material/silver = 2000, /datum/material/gold = 2000, /datum/material/diamond = 2000)
	build_path = /obj/item/borg/upgrade/modkit/aoe/turfs
	category = list("Mining Designs", "Cyborg Upgrade Modules")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO
