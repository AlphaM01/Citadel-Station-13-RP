// the power cell
// charge from 0 to 100%
// fits in APC to provide backup power

/obj/item/cell
	name = "power cell"
	desc = "A rechargable electrochemical power cell."
	icon = 'icons/obj/power.dmi'
	icon_state = "cell"
	item_state = "cell"
	origin_tech = list(TECH_POWER = 1)
	damage_force = 5.0
	throw_force = 5.0
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	/// Are we EMP immune?
	var/emp_proof = FALSE
	var/charge
	var/maxcharge = 1000
	var/rigged = 0		// true if rigged to explode
	var/minor_fault = 0 //If not 100% reliable, it will build up faults.
	var/self_recharge = FALSE // If true, the cell will recharge itself.
	var/charge_amount = 25 // How much power to give, if self_recharge is true.  The number is in absolute cell charge, as it gets divided by CELLRATE later.
	var/last_use = 0 // A tracker for use in self-charging
	var/charge_delay = 0 // How long it takes for the cell to start recharging after last use
	var/rating = 1
	materials_base = list(MAT_STEEL = 700, MAT_GLASS = 50)

	// Overlay stuff.
	var/overlay_half_state = "cell-o1" // Overlay used when not fully charged but not empty.
	var/overlay_full_state = "cell-o2" // Overlay used when fully charged.
	var/last_overlay_state = null // Used to optimize update_icon() calls.

/obj/item/cell/Initialize(mapload)
	. = ..()
	if(isnull(charge))
		charge = maxcharge
	update_icon()
	if(self_recharge)
		START_PROCESSING(SSobj, src)

/obj/item/cell/Destroy()
	if(self_recharge)
		STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/cell/get_rating()
	return rating

/obj/item/cell/get_cell(inducer)
	return src

/obj/item/cell/process(delta_time)
	if(self_recharge)
		if(world.time >= last_use + charge_delay)
			give(charge_amount)
	else
		return PROCESS_KILL

/obj/item/cell/drain_energy(datum/actor, amount, flags)
	if(charge <= 0)
		return 0
	return use(DYNAMIC_KJ_TO_CELL_UNITS(amount)) * GLOB.cellrate

/obj/item/cell/can_drain_energy(datum/actor, flags)
	return TRUE

#define OVERLAY_FULL	2
#define OVERLAY_PARTIAL	1
#define OVERLAY_EMPTY	0

/obj/item/cell/update_icon()
	var/new_overlay = null // The overlay that is needed.
	// If it's different than the current overlay, then it'll get changed.
	// Otherwise nothing happens, to save on CPU.

	if(charge < 0.01) // Empty.
		new_overlay = OVERLAY_EMPTY
		if(last_overlay_state != new_overlay)
			cut_overlays()

	else if(charge/maxcharge >= 0.995) // Full
		new_overlay = OVERLAY_FULL
		if(last_overlay_state != new_overlay)
			cut_overlay(overlay_half_state)
			add_overlay(overlay_full_state)


	else // Inbetween.
		new_overlay = OVERLAY_PARTIAL
		if(last_overlay_state != new_overlay)
			cut_overlay(overlay_full_state)
			add_overlay(overlay_half_state)

	last_overlay_state = new_overlay

#undef OVERLAY_FULL
#undef OVERLAY_PARTIAL
#undef OVERLAY_EMPTY

/obj/item/cell/proc/percent()		// return % charge of cell
	if(!maxcharge)
		return 0
	return 100.0*charge/maxcharge

/obj/item/cell/proc/fully_charged()
	return (charge == maxcharge)

// checks if the power cell is able to provide the specified amount of charge
/obj/item/cell/proc/check_charge(var/amount)
	return (charge >= amount)

// Returns how much charge is missing from the cell, useful to make sure not overdraw from the grid when recharging.
/obj/item/cell/proc/amount_missing()
	return max(maxcharge - charge, 0)

// use power from a cell, returns the amount actually used
/obj/item/cell/proc/use(var/amount)
	if(rigged && amount > 0)
		explode()
		return 0
	var/used = min(charge, amount)
	charge -= used
	last_use = world.time
	update_icon()
	return used

// Checks if the specified amount can be provided. If it can, it removes the amount
// from the cell and returns 1. Otherwise does nothing and returns 0.
/obj/item/cell/proc/checked_use(amount, reserve)
	if(!check_charge(amount + reserve))
		return 0
	use(amount)
	return 1

// recharge the cell
/obj/item/cell/proc/give(var/amount)
	if(rigged && amount > 0)
		explode()
		return FALSE
	var/amount_used = min(maxcharge-charge,amount)
	charge += amount_used
	update_icon()
	if(loc)
		loc.update_icon()
	return amount_used


/obj/item/cell/examine(mob/user, dist)
	. = ..()
	if(get_dist(src, user) <= 1)
		. += " It has a power rating of [maxcharge].\nThe charge meter reads [round(src.percent() )]%."
	if(maxcharge < 30000)
		. += "[desc]\nThe manufacturer's label states this cell has a power rating of [maxcharge], and that you should not swallow it.\nThe charge meter reads [round(src.percent() )]%."
	else
		. += "This power cell has an exciting chrome finish, as it is an uber-capacity cell type! It has a power rating of [maxcharge]!\nThe charge meter reads [round(src.percent() )]%."

/obj/item/cell/attackby(obj/item/W, mob/user)
	..()
	if(istype(W, /obj/item/reagent_containers/syringe))
		var/obj/item/reagent_containers/syringe/S = W

		to_chat(user, "You inject the solution into the power cell.")

		if(S.reagents.has_reagent("phoron", 5))

			rigged = 1

			log_admin("LOG: [user.name] ([user.ckey]) injected a power cell with phoron, rigging it to explode.")
			message_admins("LOG: [user.name] ([user.ckey]) injected a power cell with phoron, rigging it to explode.")

		S.reagents.clear_reagents()

/obj/item/cell/proc/explode()
	var/turf/T = get_turf(src.loc)
/*
 * 1000-cell	explosion(T, -1, 0, 1, 1)
 * 2500-cell	explosion(T, -1, 0, 1, 1)
 * 10000-cell	explosion(T, -1, 1, 3, 3)
 * 15000-cell	explosion(T, -1, 2, 4, 4)
 * */
	if (charge==0)
		return
	var/devastation_range = -1 //round(charge/11000)
	var/heavy_impact_range = round(sqrt(charge)/60)
	var/light_impact_range = round(sqrt(charge)/30)
	var/flash_range = light_impact_range
	if (light_impact_range==0)
		rigged = 0
		corrupt()
		return
	//explosion(T, 0, 1, 2, 2)

	log_admin("LOG: Rigged power cell explosion, last touched by [fingerprintslast]")
	message_admins("LOG: Rigged power cell explosion, last touched by [fingerprintslast]")

	explosion(T, devastation_range, heavy_impact_range, light_impact_range, flash_range)

	qdel(src)

/obj/item/cell/proc/corrupt()
	charge /= 2
	maxcharge /= 2
	if (prob(10))
		rigged = 1 //broken batteries are dangerous

/obj/item/cell/emp_act(severity)
	. = ..()
	if(emp_proof)
		return
	//remove this once emp changes on dev are merged in
	if(isrobot(loc))
		var/mob/living/silicon/robot/R = loc
		severity *= R.cell_emp_mult

	charge -= charge / (severity + 1)
	if (charge < 0)
		charge = 0

	update_icon()

/obj/item/cell/legacy_ex_act(severity)

	switch(severity)
		if(1.0)
			qdel(src)
			return
		if(2.0)
			if (prob(50))
				qdel(src)
				return
			if (prob(50))
				corrupt()
		if(3.0)
			if (prob(25))
				qdel(src)
				return
			if (prob(25))
				corrupt()
	return

/obj/item/cell/proc/get_electrocute_damage()
	//1kW = 5
	//10kW = 24
	//100kW = 45
	//250kW = 53
	//1MW = 66
	//10MW = 88
	//100MW = 110
	//1GW = 132
	if(charge >= 1000)
		var/damage = log(1.1,charge)
		damage = damage - (log(1.1,damage)*1.5)
		return round(damage)
	else
		return 0

//* Setters *//

/obj/item/cell/proc/set_charge(amount, update)
	charge = clamp(amount, 0, maxcharge)
	if(update)
		update_icon()
