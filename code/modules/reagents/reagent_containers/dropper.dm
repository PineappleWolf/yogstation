/obj/item/weapon/reagent_containers/dropper
	name = "dropper"
	desc = "A dropper. Holds up to 5 units."
	icon = 'icons/obj/chemical.dmi'
	icon_state = "dropper0"
	amount_per_transfer_from_this = 5
	possible_transfer_amounts = list(1, 2, 3, 4, 5)
	volume = 5
	var/filled = 0

	afterattack(obj/target, mob/user , proximity)
		if(!proximity) return
		if(!target.reagents) return

		if(filled)
			if(target.reagents.total_volume >= target.reagents.maximum_volume)
				user << "<span class='notice'>[target] is full.</span>"
				return

			if(!target.is_open_container() && !ismob(target) && !istype(target,/obj/item/weapon/reagent_containers/food) && !istype(target, /obj/item/clothing/mask/cigarette)) //You can inject humans and food but you cant remove the shit.
				user << "<span class='notice'>You cannot directly fill [target].</span>"
				return

			var/trans = 0

			if(ismob(target))
				if(istype(target , /mob/living/carbon/human))
					var/mob/living/carbon/human/victim = target

					var/obj/item/safe_thing = null
					if(victim.wear_mask)
						if(victim.wear_mask.flags & MASKCOVERSEYES)
							safe_thing = victim.wear_mask
					if(victim.head)
						if(victim.head.flags & MASKCOVERSEYES)
							safe_thing = victim.head
					if(victim.glasses)
						if(!safe_thing)
							safe_thing = victim.glasses

					if(safe_thing)
						if(!safe_thing.reagents)
							safe_thing.create_reagents(100)
						trans = reagents.trans_to(safe_thing, amount_per_transfer_from_this)

						target.visible_message("<span class='danger'>[user] tries to squirt something into [target]'s eyes, but fails!</span>", \
												"<span class='userdanger'>[user] tries to squirt something into [target]'s eyes, but fails!</span>")
						spawn(5)
							reagents.reaction(safe_thing, TOUCH)

						user << "<span class='notice'>You transfer [trans] unit\s of the solution.</span>"
						if(reagents.total_volume<=0)
							filled = 0
							icon_state = "dropper[filled]"
						return

				target.visible_message("<span class='danger'>[user] squirts something into [target]'s eyes!</span>", \
										"<span class='userdanger'>[user] squirts something into [target]'s eyes!</span>")
				reagents.reaction(target, TOUCH)
				var/mob/M = target
				var/R
				var/viruslist = ""
				if(reagents)
					for(var/datum/reagent/A in src.reagents.reagent_list)
						R += A.id + " ("
						R += num2text(A.volume) + "),"
						if(istype(R, /datum/reagent/blood))
							var/datum/reagent/blood/RR = R
							for(var/datum/disease/D in RR.data["viruses"])
								viruslist += " [D.name]"
								if(istype(D, /datum/disease/advance))
									var/datum/disease/advance/DD = D
									viruslist += " \[ symptoms: "
									for(var/datum/symptom/S in DD.symptoms)
										viruslist += "[S.name] "
									viruslist += "\]"
				add_logs(user, M, "squirted", object="[R]")
				if(viruslist)
					investigate_log("[user.name] ([user.ckey]) injected [M.name] ([M.ckey]) with [viruslist]", "viro")

			trans = src.reagents.trans_to(target, amount_per_transfer_from_this)
			user << "<span class='notice'>You transfer [trans] unit\s of the solution.</span>"
			if(reagents.total_volume<=0)
				filled = 0
				icon_state = "dropper[filled]"

		else

			if(!target.is_open_container() && !istype(target,/obj/structure/reagent_dispensers))
				user << "<span class='notice'>You cannot directly remove reagents from [target].</span>"
				return

			if(!target.reagents.total_volume)
				user << "<span class='notice'>[target] is empty.</span>"
				return

			var/trans = target.reagents.trans_to(src, amount_per_transfer_from_this)

			user << "<span class='notice'>You fill [src] with [trans] unit\s of the solution.</span>"

			filled = 1
			icon_state = "dropper[filled]"