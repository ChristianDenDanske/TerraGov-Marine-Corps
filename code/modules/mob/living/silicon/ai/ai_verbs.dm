/mob/living/silicon/ai/verb/ai_network_change()
	set category = "AI Commands"
	set name = "Jump To Network"

	if(incapacitated())
		return

	unset_interaction()
	cameraFollow = null

	var/new_network = input(src, "Which network would you like to view?", "Jump To Network") as null|anything in available_networks
	if(!new_network)
		return

	if(!eyeobj)
		view_core()
		return

	for(var/i in GLOB.cameranet.cameras)
		var/obj/machinery/camera/C = i

		if(!C.can_use())
			continue

		if(new_network in C.network)
			eyeobj.setLoc(get_turf(C))
			break

	to_chat(src, "<span class='notice'>Switched to the \"[uppertext(new_network)]\" camera network.</span>")



/mob/living/silicon/ai/verb/display_status()
	set category = "AI Commands"
	set name = "Display Status"

	if(incapacitated())
		return

	var/list/ai_emotions = list("Very Happy", "Happy", "Neutral", "Unsure", "Confused", "Sad", "BSOD", "Blank", "Problems?", "Awesome", "Facepalm", "Thinking", "Friend Computer", "Dorfy", "Blue Glow", "Red Glow")
	var/emote = input("Please, select a status!", "AI Status") as null|anything in ai_emotions
	if(!emote)
		return

	for(var/i in GLOB.ai_status_displays)
		var/obj/machinery/status_display/ai/SD = i
		SD.emotion = emote
		SD.update()
	
	if(emote == "Friend Computer")
		var/datum/radio_frequency/frequency = SSradio.return_frequency(FREQ_STATUS_DISPLAYS)

		if(!frequency)
			return

		var/datum/signal/status_signal = new(list("command" = "friendcomputer"))
		frequency.post_signal(src, status_signal)

	to_chat(src, "<span class='notice'>Changed display status to: [emote]</span>")


/mob/living/silicon/ai/verb/change_hologram()
	set category = "AI Commands"
	set name = "Change Hologram"

	if(incapacitated())
		return

	var/hologram = input(src, "Would you like to select a hologram based on a crew member, an animal, or switch to a unique avatar?", "Hologram") as null|anything in list("Crew Member", "Unique", "Animal")
	switch(hologram)
		if("Crew Member")
			var/list/personnel_list = list()

			for(var/datum/data/record/t in GLOB.datacore.general)
				personnel_list["[t.fields["name"]]: [t.fields["rank"]]"] = t.fields["photo_front"]

			if(!length(personnel_list))
				to_chat(src, "<span class='warning'>No suitable records found. Aborting.</span>")
				return

			hologram = input("Select a crew member:") as null|anything in personnel_list
			var/icon/character_icon = personnel_list[hologram]
			if(!character_icon)
				return

			holo_icon = getHologramIcon(icon(character_icon))

		if("Animal")
			var/list/icon_list = list(
			"bear" = 'icons/mob/animal.dmi',
			"carp" = 'icons/mob/animal.dmi',
			"chicken_brown" = 'icons/mob/animal.dmi',
			"corgi" = 'icons/mob/pets.dmi',
			"cow" = 'icons/mob/animal.dmi',
			"crab" = 'icons/mob/animal.dmi',
			"fox" = 'icons/mob/pets.dmi',
			"goat" = 'icons/mob/animal.dmi',
			"cat" = 'icons/mob/pets.dmi',
			"cat2" = 'icons/mob/pets.dmi',
			"parrot_fly" = 'icons/mob/animal.dmi',
			"pug" = 'icons/mob/pets.dmi',
			"guard" = 'icons/mob/animal.dmi'
			)

			hologram = input("Please select a hologram:") as null|anything in icon_list
			if(!hologram)
				return

			holo_icon = getHologramIcon(icon(icon_list[hologram], hologram))
		
		if("Unique")
			var/list/icon_list = list(
				"default" = 'icons/mob/ai.dmi',
				"floating face" = 'icons/mob/ai.dmi',
				"alienq" = 'icons/mob/alien.dmi',
				"horror" = 'icons/mob/ai.dmi'
				)

			hologram = input("Please select a hologram:") as null|anything in icon_list
			if(!hologram)
				return

			holo_icon = getHologramIcon(icon(icon_list[hologram], hologram))

		else
			return

	to_chat(src, "<span class='notice'>Changed hologram to: [hologram]</span>")


/mob/living/silicon/ai/verb/toggle_sensors()
	set category = "AI Commands"
	set name = "Toggle Sensors"

	if(incapacitated())
		return

	toggle_sensor_mode()


/mob/living/silicon/ai/verb/make_announcement()
	set category = "AI Commands"
	set name = "Make Announcement"

	if(incapacitated() || last_announcement > world.time + 60 SECONDS)
		return

	var/input = stripped_input(usr, "Please write a message to announce to the station crew.", "Announcement")
	if(!input || incapacitated())
		return

	last_announcement = world.time
	priority_announce(input, "AI Announcement", sound = 'sound/AI/aireport.ogg')


/mob/living/silicon/ai/verb/ai_core_display()
	set category = "AI Commands"
	set name = "AI Core Display"

	if(incapacitated())
		return

	var/list/iconstates = GLOB.ai_core_display_screens
	for(var/option in iconstates)
		if(option == "Random")
			iconstates[option] = image(icon = icon, icon_state = "ai-random")
			continue
		iconstates[option] = image(icon = icon, icon_state = resolve_ai_icon(option))

	view_core()

	var/ai_core_icon = input(src, "Choose your AI core display icon.", "AI Core Display", iconstates) as null|anything in iconstates
	if(!ai_core_icon || incapacitated())
		return

	icon_state = resolve_ai_icon(ai_core_icon)


/mob/living/silicon/ai/cancel_camera()
	set category = "AI Commands"
	set name = "Cancel Camera View"

	view_core()