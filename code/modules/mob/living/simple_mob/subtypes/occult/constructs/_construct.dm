////////////////////////////
//		Base Construct
////////////////////////////

/datum/category_item/catalogue/fauna/construct
	name = "Constructs"
	desc = "Although much of the information behind these occult constructs \
	is presumably still classified, Nanotrasen's general briefings have confirmed \
	several key facts. Constructs are animate obsidian statues imbued with strong \
	paracausal energies. They are considered extremely dangerous, and evidence of \
	constructs necessitates immediate notification of the PMD."
	value = CATALOGUER_REWARD_TRIVIAL
	unlocked_by_any = list(/datum/category_item/catalogue/fauna/construct)

// Obtained by scanning all Constructs.
/datum/category_item/catalogue/fauna/all_X
	name = "Collection - Constructs"
	desc = "You have scanned a large array of different types of Construct, \
	and therefore you have been granted a large sum of points, through this \
	entry."
	value = CATALOGUER_REWARD_HARD
	unlocked_by_all = list(
		/datum/category_item/catalogue/fauna/construct/artificer,
		/datum/category_item/catalogue/fauna/construct/harvester,
		/datum/category_item/catalogue/fauna/construct/juggernaut,
		/datum/category_item/catalogue/fauna/construct/proteon,
		/datum/category_item/catalogue/fauna/construct/shade,
		/datum/category_item/catalogue/fauna/construct/wraith
		)

/mob/living/simple_mob/construct
	name = "Construct"
	real_name = "Construct"
	desc = ""
	tt_desc = "Error"

	icon_living = "shade"
	icon_dead = "shade_dead"

	mob_class = MOB_CLASS_DEMONIC

	ui_icons = 'icons/mob/screen1_construct.dmi'
	hand_count = 2
	hand_form = "stone manipulators"

	response_help  = "thinks better of touching"
	response_disarm = "flailed at"
	response_harm   = "punched"
	icon = 'icons/mob/cult.dmi'

	hovering = TRUE
	softfall = TRUE //Beings made of Hellmarble and powered by the tears of the damned are not concerned with mortal things such as 'gravity'.
	parachuting = TRUE

	has_langs = list(LANGUAGE_GALCOM, LANGUAGE_CULT, LANGUAGE_OCCULT)

	has_eye_glow = TRUE

	taser_kill = FALSE

	min_oxy = 0
	max_oxy = 0
	min_tox = 0
	max_tox = 0
	min_co2 = 0
	max_co2 = 0
	min_n2 = 0
	max_n2 = 0
	minbodytemp = 0

	shock_resist = 0.1 //Electricity isn't very effective on stone, especially that from hell.
	poison_resist = 1.0

	armor_legacy_mob = list(
				"melee" = 10,
				"bullet" = 10,
				"laser" = 10,
				"energy" = 10,
				"bomb" = 10,
				"bio" = 100,
				"rad" = 100)

	can_be_antagged = TRUE
	iff_factions = MOB_IFF_FACTION_SANGUINE_CULT

	supernatural = TRUE

	var/construct_type = "shade"
	var/list/construct_spells = list()
//	var/do_glow = TRUE

	ai_holder_type = /datum/ai_holder/polaris/simple_mob/melee

/mob/living/simple_mob/construct/place_spell_in_hand(var/path)
	if(!path || !ispath(path))
		return 0

	//var/obj/item/spell/S = new path(src)
	var/obj/item/spell/construct/S = new path(src)

	//No hands needed for innate casts.
	if(S.cast_methods & CAST_INNATE)
		if(S.run_checks())
			S.on_innate_cast(src)

	if(are_usable_hands_full())
		var/found = FALSE
		for(var/obj/item/spell/spell as anything in get_held_item_of_type(/obj/item/spell))
			if(spell.aspect != ASPECT_CHROMATIC)
				continue
			found = TRUE
			spell.on_combine_cast(S, src)
		if(!found)
			to_chat(src, "<span class='warning'>You require a free manipulator to use this power.</span>")
			return 0

	if(S.run_checks())
		put_in_hands(S)
		return 1
	else
		qdel(S)
		return 0

/mob/living/simple_mob/construct/cultify()
	return

/mob/living/simple_mob/construct/Initialize(mapload)
	. = ..()
	name = "[initial(name)] ([rand(1, 1000)])"
	real_name = name
	for(var/spell in construct_spells)
		src.add_spell(new spell, "const_spell_ready")
	updateicon()

/*
/mob/living/simple_mob/construct/update_icon()
	..()
	if(do_glow)
		add_glow()
*/

/mob/living/simple_mob/construct/death()
	new /obj/item/ectoplasm (src.loc)
	..(null,"collapses in a shattered heap.")
	ghostize()
	qdel(src)

/mob/living/simple_mob/construct/attack_generic(var/mob/user)
	if(istype(user, /mob/living/simple_mob/construct/artificer))
		var/mob/living/simple_mob/construct/artificer/A = user
		if(health < getMaxHealth())
			var/repair_lower_bound = A.legacy_melee_damage_lower * -1
			var/repair_upper_bound = A.legacy_melee_damage_upper * -1
			adjustBruteLoss(rand(repair_lower_bound, repair_upper_bound))
			adjustFireLoss(rand(repair_lower_bound, repair_upper_bound))
			user.visible_message("<span class='notice'>\The [user] mends some of \the [src]'s wounds.</span>")
		else
			to_chat(user, "<span class='notice'>\The [src] is undamaged.</span>")
		return
	return ..()

/mob/living/simple_mob/construct/examine(mob/user, dist)
	..(user)
	var/msg = "<span cass='info'>This is [icon2html(thing = src, target = user)] \a <EM>[src]</EM>!\n"
	if (src.health < src.getMaxHealth())
		msg += "<span class='warning'>"
		if (src.health >= src.getMaxHealth()/2)
			msg += "It looks slightly dented.\n"
		else
			msg += "<B>It looks severely dented!</B>\n"
		msg += "</span>"

	to_chat(user, msg)

//Constructs levitate, can fall from a shuttle with no harm, and are piloted by either damned spirits or some otherworldly entity. Let 'em float in space.
/mob/living/simple_mob/construct/Process_Spacemove()
	return 1


//Glowing Procs
/mob/living/simple_mob/construct/proc/add_glow()
	var/image/eye_glow = image(icon,"glow-[icon_state]")
	eye_glow.plane = ABOVE_LIGHTING_PLANE
	add_overlay(eye_glow)
	set_light(2, -2, l_color = "#FFFFFF")

/mob/living/simple_mob/construct/proc/remove_glow()
	cut_overlays()
