/datum/weather/snow_storm
	name = "snow storm"
	desc = "Harsh snowstorms roam the topside of this freezing place, burying any area unfortunate enough to be in its path."
	probability = 10

	telegraph_message = span_warning("Drifting particles of snow begin to dust the surrounding area..")
	telegraph_duration = 300
	telegraph_overlay = "light_snow"

	weather_message = "<span class='userdanger'><i>Harsh winds pick up as dense snow begins to fall from the sky! Seek shelter!</i></span>"
	weather_overlay = "snow_storm"
	weather_duration_lower = 600
	weather_duration_upper = 1500

	end_duration = 100
	end_message = span_boldannounce("The snowfall dies down, it should be safe to go outside again.")

	tag_weather = WEATHER_SNOW
	area_types = list(/area)
	protect_indoors = TRUE
	target_trait = ZTRAIT_STATION

	immunity_type = "snow"

	barometer_predictable = TRUE


/datum/weather/snow_storm/weather_act(mob/living/L)
	L.adjust_bodytemperature(-rand(5,15))

