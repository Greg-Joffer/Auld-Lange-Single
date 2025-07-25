/obj/item/projectile/beam
	name = "laser"
	icon_state = "laser"
	pass_flags = PASSTABLE| PASSGLASS
	damage = 20
	light_range = 2
	damage_type = BURN
	hitsound = 'sound/weapons/sear.ogg'
	hitsound_wall = 'sound/weapons/effects/searwall.ogg'
	flag = "laser"
	eyeblur = 2
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED
	ricochets_max = 50	//Honk!
	ricochet_chance = 80
	is_reflectable = TRUE
	wound_bonus = -10
	bare_wound_bonus = 10

/obj/item/projectile/beam/laser
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser
	wound_bonus = -10
	bare_wound_bonus = 20
	damage_threshold_penetration = 3

/obj/item/projectile/beam/laser/mech
	hitscan = TRUE
	wound_bonus = 0

// Low energy drain and cooldown
/obj/item/projectile/beam/laser/mech/light
	name = "laser beam"
	damage = 30
	armour_penetration = 0.1

// More energy drain and higher cooldown
/obj/item/projectile/beam/laser/mech/heavy
	name = "heavy laser beam"
	damage = 40
	armour_penetration = 0.2
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser

// The highest energy drain and cooldown
/obj/item/projectile/beam/laser/mech/pulse
	name = "charged pulse beam"
	damage = 49
	armour_penetration = 0.3
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse

//overclocked laser, does a bit more damage but has much higher wound power (-0 vs -20)
/obj/item/projectile/beam/laser/hellfire
	name = "hellfire laser"
	wound_bonus = 0
	damage = 25

/obj/item/projectile/beam/laser/hellfire/Initialize()
	. = ..()
	transform *= 2

/obj/item/projectile/beam/laser/heavylaser
	name = "heavy laser"
	icon_state = "heavylaser"
	damage = 40
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser

/obj/item/projectile/beam/laser/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.IgniteMob()
	else if(isturf(target))
		impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser/wall

/obj/item/projectile/beam/weak
	damage = 25
	armour_penetration = 0.1

/obj/item/projectile/beam/weak/penetrator
	armour_penetration = 0.35

/obj/item/projectile/beam/practice
	name = "practice laser"
	damage = 0
	nodamage = 1

/obj/item/projectile/beam/scatter
	name = "laser pellet"
	icon_state = "scatterlaser"
	damage = 12.5

/obj/item/projectile/beam/xray
	name = "\improper X-ray beam"
	icon_state = "xray"
	damage = 15
	irradiate = 300
	range = 15
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF

	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/gamma
	name = "gamma beam"
	icon_state = "xray"
	damage = 15 //makes it more useful against mobs
	flag = "energy"
	armour_penetration = 0.85 //it only does 15 damage.
	irradiate = 100 //incase friendly fire
	range = 15
	pass_flags = PASSTABLE | PASSGLASS | PASSGRILLE | PASSCLOSEDTURF

	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray

/obj/item/projectile/beam/disabler
	name = "disabler beam"
	icon_state = "omnilaser"
	damage = 28 // Citadel change for balance from 36
	damage_type = STAMINA
	flag = "energy"
	hitsound = 'sound/weapons/tap.ogg'
	eyeblur = 0
	pixels_per_second = TILES_TO_PIXELS(16.667)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/item/projectile/beam/pulse
	name = "pulse"
	icon_state = "u_laser"
	damage = 50
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse
	wound_bonus = 10

/obj/item/projectile/beam/pulse/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if (!QDELETED(target) && (isturf(target) || istype(target, /obj/structure/)))
		target.ex_act(EXPLODE_HEAVY)

/obj/item/projectile/beam/pulse/shotgun
	damage = 40

/obj/item/projectile/beam/pulse/heavy
	name = "heavy pulse laser"
	icon_state = "pulse1_bl"
	var/life = 20

/obj/item/projectile/beam/pulse/heavy/on_hit(atom/target, blocked = FALSE)
	life -= 10
	if(life > 0)
		. = BULLET_ACT_FORCE_PIERCE
	return ..()

/obj/item/projectile/beam/emitter
	name = "emitter beam"
	icon_state = "emitter"
	damage = 30
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	wound_bonus = -40
	bare_wound_bonus = 70

/obj/item/projectile/beam/emitter/singularity_pull()
	return

/obj/item/projectile/beam/emitter/hitscan
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/laser/emitter
	tracer_type = /obj/effect/projectile/tracer/laser/emitter
	impact_type = /obj/effect/projectile/impact/laser/emitter
	impact_effect_type = null

/obj/item/projectile/beam/lasertag
	name = "laser tag beam"
	icon_state = "omnilaser"
	hitsound = null
	damage = 0
	damage_type = STAMINA
	flag = "laser"
	var/suit_types = list(/obj/item/clothing/suit/redtag, /obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/item/projectile/beam/lasertag/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(ishuman(target))
		var/mob/living/carbon/human/M = target
		if(istype(M.wear_suit))
			if(M.wear_suit.type in suit_types)
				M.adjustStaminaLoss(34)

/obj/item/projectile/beam/lasertag/mag		//the projectile, compatible with regular laser tag armor
	icon_state = "magjectile-toy"
	name = "lasertag magbolt"
	movement_type = FLYING | UNSTOPPABLE		//for penetration memes
	range = 5		//so it isn't super annoying
	light_range = 2
	light_color = LIGHT_COLOR_YELLOW
	eyeblur = 0

/obj/item/projectile/beam/lasertag/redtag
	icon_state = "laser"
	suit_types = list(/obj/item/clothing/suit/bluetag)
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/lasertag/redtag/hitscan
	hitscan = TRUE

/obj/item/projectile/beam/lasertag/redtag/hitscan/holy
	name = "lasrifle beam"
	damage = 0.1
	damage_type = BURN

/obj/item/projectile/beam/lasertag/bluetag
	icon_state = "bluelaser"
	suit_types = list(/obj/item/clothing/suit/redtag)
	tracer_type = /obj/effect/projectile/tracer/laser/blue
	muzzle_type = /obj/effect/projectile/muzzle/laser/blue
	impact_type = /obj/effect/projectile/impact/laser/blue

/obj/item/projectile/beam/lasertag/bluetag/hitscan
	hitscan = TRUE

/obj/item/projectile/beam/instakill
	name = "instagib laser"
	icon_state = "purple_laser"
	damage = 200
	damage_type = BURN
	impact_effect_type = /obj/effect/temp_visual/impact_effect/purple_laser
	light_color = LIGHT_COLOR_PURPLE

/obj/item/projectile/beam/instakill/blue
	icon_state = "blue_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/item/projectile/beam/instakill/red
	icon_state = "red_laser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED

/obj/item/projectile/beam/instakill/on_hit(atom/target)
	. = ..()
	if(iscarbon(target))
		var/mob/living/carbon/M = target
		M.visible_message(span_danger("[M] explodes into a shower of gibs!"))
		M.gib()

//a shrink ray that shrinks stuff, which grows back after a short while.
/obj/item/projectile/beam/shrink
	name = "shrink ray"
	icon_state = "blue_laser"
	hitsound = 'sound/weapons/shrink_hit.ogg'
	damage = 0
	damage_type = STAMINA
	flag = "energy"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/shrink
	light_color = LIGHT_COLOR_BLUE
	var/shrink_time = 90

/obj/item/projectile/beam/shrink/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isopenturf(target) || istype(target, /turf/closed/indestructible))//shrunk floors wouldnt do anything except look weird, i-walls shouldnt be bypassable
		return
	target.AddComponent(/datum/component/shrink, shrink_time)

//musket
/obj/item/projectile/beam/laser/musket //musket
	name = "laser beam"
	damage = 34
	hitscan = TRUE
	armour_penetration = 0.01 //rare laser to have AP, to offset single-fire
	pixels_per_second = TILES_TO_PIXELS(50)

//plasma caster
/obj/item/projectile/f13plasma/plasmacaster
	name = "plasma bolt"
	icon_state = "plasma_clot"
	damage_type = BURN
	damage = 55
	flag = "energy"
	eyeblur = 0
	is_reflectable = TRUE
	pixels_per_second = TILES_TO_PIXELS(80)

//Securitrons Beam
/obj/item/projectile/beam/laser/pistol/ultraweak
	damage = 15 //quantity over quality

//Chews Beam
/obj/item/projectile/beam/laser/pistol/ultraweak/chew
	damage = 14 //less dam..
	armour_penetration = 0.7 //..more pen
	is_reflectable = FALSE

//Big Chews Beam
/obj/item/projectile/beam/laser/pistol/ultraweak/chew/strong
	damage = 20 //it fucks
	icon_state = "gaussstrong"
	movement_type = FLYING | UNSTOPPABLE //stopping for nothing except its range
	pixels_per_second = TILES_TO_PIXELS(12) //slow
	range = 18

//Alrem's plasmacaster
/obj/item/projectile/f13plasma/plasmacaster/arlem
	name = "plasma bolt"
	icon_state = "plasma_clot"
	damage_type = BURN
	damage = 55
	armour_penetration = 0.8
	flag = "laser"
	eyeblur = 0
	is_reflectable = FALSE
	pixels_per_second = TILES_TO_PIXELS(80)

/obj/item/projectile/beam/laser/lasgun //AER9
	name = "laser beam"
	damage = 33

/obj/item/projectile/beam/laser/lasgun/hitscan //hitscan aer9 test
	name = "laser beam"
	damage = 30
	armour_penetration = 0.33 // 33% so you can get through tougher stuff
	damage_threshold_penetration = 5
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/laser/lasgun/hitscan/focused
	name = "overcharged laser beam"
	damage = 34
	armour_penetration = 0.6
	damage_threshold_penetration = 7

/obj/item/projectile/beam/laser/gatling/hitscan //Gatling Laser
	name = "laser beam"
	damage = 15
	armour_penetration = 0.14
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/laser/pistol
	name = "laser beam"
	damage = 35

/obj/item/projectile/beam/laser/pistol/hitscan //Actual AEP7
	name = "laser beam"
	damage = 18
	hitscan = TRUE
	armour_penetration = 0.02
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/laser/pistol/hitscan/debug_10_damage_0_dt_pierce
	name = "debug 10 damage 0 DT pierce"
	damage = 10
	hitscan = TRUE
	armour_penetration = 0
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/laser/pistol/hitscan/debug_10_damage_0_dt_pierce_50_ap
	name = "debug 10 damage 0 DT pierce"
	damage = 10
	hitscan = TRUE
	armour_penetration = 0.5
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/laser/pistol/hitscan/stun //compliance regulator beam
	name = "compliance beam"
	damage = 33
	armour_penetration = 0.05
	damage_type = STAMINA
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	tracer_type = /obj/effect/projectile/tracer/disabler
	muzzle_type = /obj/effect/projectile/muzzle/disabler
	impact_type = /obj/effect/projectile/impact/disabler

/obj/item/projectile/beam/laser/pistol/hitscan/revolver //AEP9
	name = "laser beam"
	damage = 44
	armour_penetration = 0.2

/obj/item/projectile/beam/laser/recharger/hitscan //hitscan recharger pistol
	name = "recharger beam"
	damage = 18
	hitscan = TRUE
	armour_penetration = 0.02
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse
	light_color = LIGHT_COLOR_BLUE

/obj/item/projectile/beam/laser/recharger/hitscan/rifle //hitscan recharger rifle
	damage = 20
	armour_penetration = 0.02

/obj/item/projectile/beam/laser/ultra_pistol //unused
	name = "laser beam"
	damage = 40
	armour_penetration = 0.35
	irradiate = 200

/obj/item/projectile/beam/laser/ultra_rifle //unused
	name = "laser beam"
	damage = 45
	armour_penetration = 0.42
	irradiate = 200

/obj/item/projectile/beam/laser/gatling //Gatling Laser Projectile
	name = "rapid-fire laser beam"
	damage = 12

/obj/item/projectile/beam/laser/pistol/wattz //Wattz pistol
	damage = 31

/obj/item/projectile/beam/laser/pistol/wattz/hitscan //hitscan wattz
	name = "laser beam"
	damage = 22 // Civilian gun hits harder but has less charge now.
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/laser/pistol/wattz/magneto //upgraded Wattz
	name = "penetrating laser beam"
	damage = 31
	armour_penetration = 0.20

/obj/item/projectile/beam/laser/pistol/wattz/magneto/hitscan
	name = "penetrating laser beam"
	damage = 20 // Hits less than the W1K but has innate AP/DT reduction.
	hitscan = TRUE
	armour_penetration = 0.2 //rare laser to keep its AP, since base model is so bad
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/laser/pistol/wattzs //Wattz 1000s pistol
	damage = 31

/obj/item/projectile/beam/laser/pistol/wattzs/hitscan //hitscan wattz
	name = "laser beam"
	damage = 20 //Less damage but more charge
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/laser/solar //Solar Scorcher
	name = "solar scorcher beam"
	damage = 28
	armour_penetration = 0.35

/obj/item/projectile/beam/laser/solar/hitscan
	name = "solar scorcher beam"
	damage = 27
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/laser/pistol/badlands //Badland's Special
	name = "badland's special beam"
	damage = 25
	armour_penetration = 0.3
	icon_state = "bluelaser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/item/projectile/beam/laser/pistol/badlands/hitscan
	name = "badland's special beam"
	damage = 24
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/laser/badlands
	muzzle_type = /obj/effect/projectile/muzzle/laser/badlands
	impact_type = /obj/effect/projectile/impact/laser/badlands

/obj/item/projectile/beam/laser/pistol/badlands/worn //Worn Badland's Special
	name = "badland's special beam"
	damage = 20
	armour_penetration = 0.3
	icon_state = "bluelaser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/item/projectile/beam/laser/pistol/badlands/worn/hitscan
	name = "badland's special beam"
	damage = 24
	hitscan = TRUE
	tracer_type = /obj/effect/projectile/tracer/laser/badlands
	muzzle_type = /obj/effect/projectile/muzzle/laser/badlands
	impact_type = /obj/effect/projectile/impact/laser/badlands

/obj/item/projectile/beam/laser/pistol/freeblade //Freeblade Blaster
	name = "freeblade beam"
	damage = 15
	armour_penetration = 0.6
	icon_state = "freeblade"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/red_laser
	light_color = LIGHT_COLOR_RED

/obj/item/projectile/beam/laser/tribeam //Tribeam laser, fires 3 shots, will melt you
	name = "tribeam laser"
	damage = 21

/obj/item/projectile/beam/laser/tribeam/hitscan
	name = "tribeam laser"
	damage = 23 //if all bullets connect, this will do 69
	hitscan = TRUE
	bare_wound_bonus = 0
	armour_penetration = 0.02
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/beam/laser/tribeam/laserbuss //Tribeam laser, fires 3 shots, will melt you
	name = "tribeam laser"
	damage = 21

/obj/item/projectile/beam/laser/tribeam/laserbuss/hitscan
	name = "tribeam laser"
	damage = 26
	hitscan = TRUE
	bare_wound_bonus = 5
	tracer_type = /obj/effect/projectile/tracer/laser
	muzzle_type = /obj/effect/projectile/muzzle/laser
	impact_type = /obj/effect/projectile/impact/laser

/obj/item/projectile/f13plasma //FNV plasma caster
	name = "plasma bolt"
	icon_state = "plasma_clot"
	damage_type = BURN
	damage = 60 //fucc you normies
	armour_penetration = 0 //no AP, armor shouldnt have more than 20 resist against plasma unless its specialized
	flag = "energy" //checks vs. energy protection
	wound_bonus = 90 //being hit with plasma is horrific
	eyeblur = 0
	is_reflectable = TRUE
	pixels_per_second =  TILES_TO_PIXELS(15) //About half the base speed of bullets, so still real slow

/obj/item/projectile/f13plasma/balanced //the kind you are meant to use
	damage = 50 //2-hit KO, 3 with armor, 4 with good armor
	wound_bonus = 51 //just to get that one over a plasma rifle

/obj/item/projectile/plasmacarbine //Plasma carbine
	name = "plasma bolt"
	icon_state = "plasma_clot"
	damage_type = BURN
	damage = 40
	flag = "energy" //checks vs. energy protection
	wound_bonus = 50 //let's not make the carbine horrifying // nah lets make it horrifying
	eyeblur = 0
	is_reflectable = TRUE
	pixels_per_second = TILES_TO_PIXELS(15)

/obj/item/projectile/f13plasma/repeater //Plasma repeater
	name = "plasma stream"
	icon_state = "plasma_clot"
	damage_type = BURN
	damage = 90
	flag = "energy" //checks vs. energy protection
	eyeblur = 0
	is_reflectable = FALSE

/obj/item/projectile/f13plasma/repeater/mining
	name = "mining plasma stream"
	icon_state = "plasma_clot"
	damage_type = BURN
	damage = 25
	flag = "energy"
	eyeblur = 0
	is_reflectable = FALSE

/obj/item/projectile/f13plasma/repeater/mining/on_hit(atom/target)
	. = ..()
	if(ismineralturf(target))
		var/turf/closed/mineral/M = target
		M.gets_drilled(firer)

/obj/item/projectile/f13plasma/pistol //Plasma pistol
	damage = 35
	wound_bonus = 70 //being hit with plasma is horrific

/obj/item/projectile/f13plasma/pistol/eve //Eve
	icon = 'icons/fallout/objects/guns/projectiles.dmi'
	icon_state = "eve"
	damage = 45
	wound_bonus = 75 //being hit with plasma is horrific
	light_color = LIGHT_COLOR_PINK

/obj/item/projectile/f13plasma/pistol/eve/worn //Eve worn
	icon = 'icons/fallout/objects/guns/projectiles.dmi'
	icon_state = "eve"
	damage = 35
	wound_bonus = 65 //being hit with plasma is horrific
	light_color = LIGHT_COLOR_PINK

/obj/item/projectile/f13plasma/pistol/adam //Adam
	icon = 'icons/fallout/objects/guns/projectiles.dmi'
	icon_state = "adam"
	damage = 55
	wound_bonus = 35 //Adam is stronger, but not in the wounding department.
	light_color = LIGHT_COLOR_RED

/obj/item/projectile/f13plasma/pistol/worn
	damage = 30

/obj/item/projectile/f13plasma/pistol/glock //Glock (streamlined plasma pistol)
	damage = 40
	wound_bonus = 75 //being hit with plasma is horrific

/obj/item/projectile/f13plasma/scatter //Multiplas, fires 3 shots, will melt you
	damage = 35

/obj/item/projectile/beam/laser/rcw //RCW
	name = "rapidfire beam"
	icon_state = "xray"
	damage = 30
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN

/obj/item/projectile/beam/laser/rcw/hitscan //RCW
	name = "rapidfire beam"
	icon_state = "emitter"
	damage = 15
	armour_penetration = 0.12
	hitscan = TRUE
	muzzle_type = /obj/effect/projectile/muzzle/laser/emitter
	tracer_type = /obj/effect/projectile/tracer/laser/emitter
	impact_type = /obj/effect/projectile/impact/laser/emitter
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser

/obj/item/projectile/beam/laser/rcw/hitscan/autolaser //Compact RCW
	damage = 7 //Good for piercing armor, terrible damage
	bare_wound_bonus = -20 //The intensity of the beams are no where near enough to cause lasting prolonged trauma.
	armour_penetration = 0.6

/obj/item/projectile/beam/laser/rcw/hitscan/autolaser/worn //Compact RCW
	damage = 7 //Good for piercing armor, terrible damage
	bare_wound_bonus = -20 //The intensity of the beams are no where near enough to cause lasting prolonged trauma.
	armour_penetration = 0.3

/obj/item/projectile/f13plasma/pistol/alien
	name = "alien projectile"
	icon_state = "ion"
	damage = 90 //horrifyingly powerful, but very limited ammo
	armour_penetration = 0.8 //keeps AP, because lol aliens
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_range = 2
	light_color = LIGHT_COLOR_BLUE

/obj/item/projectile/beam/laser/laer //Elder's/Unique LAER
	name = "advanced laser beam"
	icon_state = "u_laser"
	damage = 45
	armour_penetration = 0.8
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE

/obj/item/projectile/beam/laser/laer/hitscan
	hitscan = TRUE

/obj/item/projectile/beam/laser/laer/hitscan/Initialize()
	. = ..()
	transform *= 2

/obj/item/projectile/beam/laser/aer14 //AER14
	name = "laser beam"
	damage = 38
	armour_penetration = 0.65
	icon_state = "omnilaser"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/blue_laser
	light_color = LIGHT_COLOR_BLUE
	damage_threshold_penetration = 6

/obj/item/projectile/beam/laser/aer14/hitscan
	damage = 34
	wound_bonus = 20
	armour_penetration = 0.5
	tracer_type = /obj/effect/projectile/tracer/pulse
	muzzle_type = /obj/effect/projectile/muzzle/pulse
	impact_type = /obj/effect/projectile/impact/pulse
	hitscan = TRUE
	hitscan_light_intensity = 3
	hitscan_light_range = 0.75
	hitscan_light_color_override = LIGHT_COLOR_BLUE
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = LIGHT_COLOR_BLUE
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = LIGHT_COLOR_BLUE

/obj/item/projectile/beam/laser/aer12 //AER12
	name = "laser beam"
	damage = 36
	armour_penetration = 0.55
	icon_state = "xray"
	impact_effect_type = /obj/effect/temp_visual/impact_effect/green_laser
	light_color = LIGHT_COLOR_GREEN
	damage_threshold_penetration = 6

/obj/item/projectile/beam/laser/aer12/hitscan
	name = "laser beam"
	damage = 32
	hitscan = TRUE
	armour_penetration = 0.37
	tracer_type = /obj/effect/projectile/tracer/xray
	muzzle_type = /obj/effect/projectile/muzzle/xray
	impact_type = /obj/effect/projectile/impact/xray
	hitscan_light_intensity = 3
	hitscan_light_range = 0.75
	hitscan_light_color_override = COLOR_LIME
	muzzle_flash_intensity = 6
	muzzle_flash_range = 2
	muzzle_flash_color_override = COLOR_LIME
	impact_light_intensity = 7
	impact_light_range = 2.5
	impact_light_color_override = COLOR_LIME

/obj/item/projectile/beam/laser/wattz2k
	name = "laser bolt"
	damage = 35
	armour_penetration = 0.5
	damage_threshold_penetration = 5

/obj/item/projectile/beam/laser/wattz2k/hitscan
	name = "sniper laser bolt"
	damage = 50
	wound_bonus = 10
	bare_wound_bonus = 20
	armour_penetration = 0.25
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser
	hitscan = TRUE

/obj/item/projectile/beam/laser/wattz2k/hitscan/weak //Hits less than the main wattz2k with less AP but has more shots comparable to an aer9
	name = "weak sniper laser bolt"
	damage = 40
	wound_bonus = 10
	bare_wound_bonus = 20
	armour_penetration = 0.15
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser
	hitscan = TRUE

/obj/item/projectile/beam/laser/wattz2ks
	name = "laser bolt"
	damage = 35
	armour_penetration = 0.5

/obj/item/projectile/beam/laser/wattz2ks/hitscan
	name = "sniper laser bolt"
	damage = 45
	wound_bonus = 5
	bare_wound_bonus = 15
	armour_penetration = 0.15
	tracer_type = /obj/effect/projectile/tracer/heavy_laser
	muzzle_type = /obj/effect/projectile/muzzle/heavy_laser
	impact_type = /obj/effect/projectile/impact/heavy_laser
	hitscan = TRUE



// BETA // Obsolete
/obj/item/projectile/beam/laser/pistol/lasertesting //Wattz pistol
	damage = 25
