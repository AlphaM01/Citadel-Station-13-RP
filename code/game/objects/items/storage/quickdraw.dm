// -----------------------------
//       Quickdraw storage
// -----------------------------
//These items are pouches and cases made to be kept in belts or pockets to quickly draw objects from
//Largely inspired by the vest pouches on Colonial Marines

/obj/item/storage/quickdraw
	name = "quickdraw"
	desc = "This object should not appear"
	icon = 'icons/obj/storage.dmi'

// todo: i just fully disabled this for now. sorry.
// todo: add quickdrawing.

	//Quickmode
	//When set to 0, this storage will operate as a regular storage, and clicking on it while equipped will open it as a storage
	//When set to 1, a click while it is equipped will instead move the first item inside it to your hand
// 	var/quickmode = 0

// /obj/item/storage/quickdraw/attack_hand(mob/user, datum/event_args/actor/clickchain/e_args)
// 	if(src.loc == user) //If they aren't holding us, we do nothing special
// 		if(ishuman(user))
// 			var/mob/living/carbon/human/H = user
// 			if(quickmode)
// 				var/first_item = contents[1]
// 				if(first_item && !H.get_active_held_item()) //Do we have anything to give you?
// 					H.put_in_hands(first_item)
// 					return

// 			if(H.l_store == src && !H.get_active_held_item()) //overrides
// 				src.open(user)
// 				return
// 			if(H.r_store == src && !H.get_active_held_item())
// 				src.open(user)
// 				return
// 	..() //Nothing special happened, go call the other proc


// /obj/item/storage/quickdraw/verb/toggle_quickdraw()
// 	set name = "Switch Quickdraw Mode"
// 	set category = VERB_CATEGORY_OBJECT

// 	quickmode = !quickmode
// 	switch (quickmode)
// 		if(1)
// 			to_chat(usr, "[src] now draws the first object inside.")
// 		if(0)
// 			to_chat(usr, "[src] now opens as a container.")

// /obj/item/storage/quickdraw/AltClick(mob/user)
// 	..()
// 	if(src.loc == user) //Are they carrying us?
// 		toggle_quickdraw()


// If we start adding more of these, we'll need to make them their own folder. 'til then, this one should be fine.

// -----------------------------
//       Syringe case
// -----------------------------

/obj/item/storage/quickdraw/syringe_case
	name = "syringe case"
	desc = "A small case for safely carrying sharps around."
	icon_state = "syringe_case"

	w_class = WEIGHT_CLASS_SMALL
	max_single_weight_class = WEIGHT_CLASS_TINY
	max_combined_volume = WEIGHT_CLASS_TINY * 6 //Capable of holding six syringes

	//Can hold syringes and autoinjectors, but also pills if you really wanted. Syringe-shaped objects like pens and cigarettes also fit, but why would you do that?
	insertion_whitelist = list(/obj/item/reagent_containers/syringe, /obj/item/reagent_containers/hypospray/autoinjector,
					/obj/item/reagent_containers/pill, /obj/item/pen, /obj/item/flashlight/pen, /obj/item/clothing/mask/smokable/cigarette)

	// quickmode = 1 //Starts in quickdraw mode
	//Preloaded for your convenience!
	starts_with = list(
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/syringe,
		/obj/item/reagent_containers/syringe
	)
