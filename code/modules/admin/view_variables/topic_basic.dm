//Not using datum.vv_do_topic for very basic/low level debug things, incase the datum's vv_do_topic is runtiming/whatnot.
/client/proc/vv_do_basic(datum/target, href_list)
	var/target_var = GET_VV_VAR_TARGET
	if(check_rights(R_VAREDIT))
		if(target_var)
			if(href_list[VV_HK_BASIC_EDIT])
				if(!modify_variables(target, target_var, 1))
					return
				switch(target_var)
					if("name")
						vv_update_display(target, "name", "[target]")
					if("dir")
						var/atom/A = target
						if(istype(A))
							vv_update_display(target, "dir", dir2text(A.dir) || A.dir)
					if("ckey")
						var/mob/living/L = target
						if(istype(L))
							vv_update_display(target, "ckey", L.ckey || "No ckey")
					if("real_name")
						var/mob/living/L = target
						if(istype(L))
							vv_update_display(target, "real_name", L.real_name || "No real name")
			if(href_list[VV_HK_BASIC_CHANGE])
				modify_variables(target, target_var, 0)
			if(href_list[VV_HK_BASIC_MASSEDIT])
				cmd_mass_modify_object_variables(target, target_var)
	if(check_rights(R_ADMIN, FALSE))
		if(href_list[VV_HK_EXPOSE])
			var/value = vv_get_value(VV_CLIENT)
			if (value["class"] != VV_CLIENT)
				return
			var/client/C = value["value"]
			if (!C)
				return
			if(!target)
				to_chat(usr, span_warning("The object you tried to expose to [C] no longer exists (nulled or hard-deled)"), confidential = TRUE)
				return
			message_admins("[key_name_admin(usr)] Showed [key_name_admin(C)] a <a href='byond://?_src_=vars;datumrefresh=[REF(target)]'>VV window</a>")
			log_admin("Admin [key_name(usr)] Showed [key_name(C)] a VV window of a [target]")
			to_chat(C, "[holder.fakekey ? "an Administrator" : "[usr.client.key]"] has granted you access to view a View Variables window", confidential = TRUE)
			C.debug_variables(target)
	if(check_rights(R_SPAWN)) //fortuna edit. event manager change
		if(href_list[VV_HK_DELETE])
			usr.client.admin_delete(target)
			if (isturf(src))	// show the turf that took its place
				usr.client.debug_variables(src)
				return

		#ifdef REFERENCE_TRACKING //people with debug can only access this putnam!
		if(href_list[VV_HK_VIEW_REFERENCES])
			var/datum/D = locate(href_list[VV_HK_TARGET])
			if(!D)
				to_chat(usr, span_warning("Unable to locate item."))
				return
			//usr.client.holder.view_refs(target)
			return
		#endif

	if(href_list[VV_HK_MARK])
		usr.client.mark_datum(target)
	if(href_list[VV_HK_ADDCOMPONENT])
		if(!check_rights(NONE))
			return
		var/list/names = list()
		var/list/componentsubtypes = sortList(subtypesof(/datum/component), GLOBAL_PROC_REF(cmp_typepaths_asc))
		names += "---Components---"
		names += componentsubtypes
		names += "---Elements---"
		names += sortList(subtypesof(/datum/element), GLOBAL_PROC_REF(cmp_typepaths_asc))
		var/result = input(usr, "Choose a component/element to add","better know what ur fuckin doin pal") as null|anything in names
		if(!usr || !result || result == "---Components---" || result == "---Elements---")
			return
		if(QDELETED(src))
			to_chat(usr, "That thing doesn't exist anymore!", confidential = TRUE)
			return
		var/list/lst = get_callproc_args()
		if(!lst)
			return
		var/datumname = "error"
		lst.Insert(1, result)
		if(result in componentsubtypes)
			datumname = "component"
			target._AddComponent(lst)
		else
			datumname = "element"
			target._AddElement(lst)
		log_admin("[key_name(usr)] has added [result] [datumname] to [key_name(target)].")
		message_admins(span_notice("[key_name_admin(usr)] has added [result] [datumname] to [key_name_admin(target)]."))
	if(href_list[VV_HK_CALLPROC])
		usr.client.callproc_datum(target)
