-- Lines 5-891
function LootDropTweakData:init_generated(tweak_data)
	self.global_values.afp = {
		name_id = "bm_global_value_afp",
		desc_id = "menu_l_global_value_afp",
		unlock_id = "bm_global_value_afp_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = false,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "dlc"
	}
	self.global_values.anv = {
		name_id = "bm_global_value_anv",
		desc_id = "menu_l_global_value_anv",
		unlock_id = "bm_global_value_anv_unlock",
		color = tweak_data.screen_colors.event_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = -5,
		category = "global_event"
	}
	self.global_values.atw = {
		name_id = "bm_global_value_atw",
		desc_id = "menu_l_global_value_atw",
		unlock_id = "bm_global_value_atw_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = false,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "normal"
	}
	self.global_values.bex = {
		name_id = "bm_global_value_bex",
		desc_id = "menu_l_global_value_bex",
		unlock_id = "bm_global_value_bex_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = false,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "dlc"
	}
	self.global_values.ess = {
		name_id = "bm_global_value_ess",
		desc_id = "menu_l_global_value_ess",
		unlock_id = "bm_global_value_ess_unlock",
		color = tweak_data.screen_colors.event_color,
		dlc = true,
		free = false,
		hide_unavailable = true,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 250,
		category = "global_event"
	}
	self.global_values.flm = {
		name_id = "bm_global_value_flm",
		desc_id = "menu_l_global_value_sb18",
		unlock_id = "bm_global_value_flm_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "normal"
	}
	self.global_values.ghx = {
		name_id = "bm_global_value_ghx",
		desc_id = "menu_l_global_value_ghx",
		unlock_id = "bm_global_value_ghx_unlock",
		color = tweak_data.screen_colors.community_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 333,
		category = "pd2_clan"
	}
	self.global_values.hnd = {
		name_id = "bm_global_value_hnd",
		desc_id = "menu_l_global_value_hnd",
		unlock_id = "bm_global_value_hnd_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 302,
		category = "normal"
	}
	self.global_values.maw = {
		name_id = "bm_global_value_maw",
		desc_id = "menu_l_global_value_infamous",
		unlock_id = "bm_global_value_maw_unlock",
		color = tweak_data.screen_colors.infamous_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 350,
		category = "infamous"
	}
	self.global_values.mbs = {
		name_id = "bm_global_value_mbs",
		desc_id = "menu_l_global_value_mbs",
		unlock_id = "bm_global_value_mbs_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = false,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 301,
		category = "dlc"
	}
	self.global_values.mex = {
		name_id = "bm_global_value_mex",
		desc_id = "menu_l_global_value_mex",
		unlock_id = "bm_global_value_mex_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = false,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 338,
		category = "dlc"
	}
	self.global_values.mmh = {
		name_id = "bm_global_value_mmh",
		desc_id = "menu_l_global_value_infamous",
		unlock_id = "bm_global_value_mmh_unlock",
		color = tweak_data.screen_colors.infamous_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 30,
		category = "infamous"
	}
	self.global_values.mwm = {
		name_id = "bm_global_value_mwm",
		desc_id = "menu_l_global_value_mwm",
		unlock_id = "bm_global_value_mwm_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = false,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "dlc"
	}
	self.global_values.pex = {
		name_id = "bm_global_value_pex",
		desc_id = "menu_l_global_value_pex",
		unlock_id = "bm_global_value_pex_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = false,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 339,
		category = "dlc"
	}
	self.global_values.scm = {
		name_id = "bm_global_value_scm",
		desc_id = "menu_l_global_value_scm",
		unlock_id = "bm_global_value_scm_unlock",
		color = tweak_data.screen_colors.infamous_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 345,
		category = "infamous"
	}
	self.global_values.sdm = {
		name_id = "bm_global_value_sdm",
		desc_id = "menu_l_global_value_sb18",
		unlock_id = "bm_global_value_sdm_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "normal"
	}
	self.global_values.sft = {
		name_id = "bm_global_value_sft",
		desc_id = "menu_l_global_value_sft",
		unlock_id = "bm_global_value_sft_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 332,
		category = "normal"
	}
	self.global_values.shl = {
		name_id = "bm_global_value_shl",
		desc_id = "menu_l_global_value_shl",
		unlock_id = "bm_global_value_shl_unlock",
		color = tweak_data.screen_colors.event_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 400,
		category = "global_event"
	}
	self.global_values.skm = {
		name_id = "bm_global_value_skm",
		desc_id = "menu_l_global_value_skm",
		unlock_id = "bm_global_value_skm_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "normal"
	}
	self.global_values.smo = {
		name_id = "bm_global_value_smo",
		desc_id = "menu_l_global_value_smo",
		unlock_id = "bm_global_value_smo_unlock",
		color = tweak_data.screen_colors.infamous_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 344,
		category = "infamous"
	}
	self.global_values.sms = {
		name_id = "bm_global_value_sms",
		desc_id = "menu_l_global_value_sms",
		unlock_id = "bm_global_value_sms_unlock",
		color = tweak_data.screen_colors.infamous_color,
		dlc = true,
		free = false,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 499,
		category = "infamous"
	}
	self.global_values.sus = {
		name_id = "bm_global_value_sus",
		desc_id = "menu_l_global_value_sus",
		unlock_id = "bm_global_value_sus_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = false,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 100,
		category = "normal"
	}
	self.global_values.svc = {
		name_id = "bm_global_value_svc",
		desc_id = "menu_l_global_value_svc",
		unlock_id = "bm_global_value_svc_unlock",
		color = tweak_data.screen_colors.event_color,
		dlc = true,
		free = false,
		hide_unavailable = true,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "global_event"
	}
	self.global_values.tam = {
		name_id = "bm_global_value_tam",
		desc_id = "menu_l_global_value_infamous",
		unlock_id = "bm_global_value_tam_unlock",
		color = tweak_data.screen_colors.infamous_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "infamous"
	}
	self.global_values.tar = {
		name_id = "bm_global_value_tar",
		desc_id = "menu_l_global_value_tar",
		unlock_id = "bm_global_value_tar_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 336,
		category = "normal"
	}
	self.global_values.tjp = {
		name_id = "bm_global_value_tjp",
		desc_id = "menu_l_global_value_tjp",
		unlock_id = "bm_global_value_tjp_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = false,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "normal"
	}
	self.global_values.toon = {
		name_id = "bm_global_value_toon",
		unlock_id = "bm_global_value_toon_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "normal"
	}
	self.global_values.trd = {
		name_id = "bm_global_value_trd",
		desc_id = "menu_l_global_value_trd",
		unlock_id = "bm_global_value_trd_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = false,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "dlc"
	}
	self.global_values.wcc = {
		name_id = "bm_global_value_wcc",
		desc_id = "menu_l_global_value_wcc",
		unlock_id = "bm_global_value_wcc_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = false,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 291,
		category = "normal"
	}
	self.global_values.wcc_s01 = {
		name_id = "bm_global_value_wcc_s01",
		desc_id = "menu_l_global_value_wcc_s01",
		unlock_id = "bm_global_value_wcc_s01_unlock",
		color = tweak_data.screen_colors.event_color,
		dlc = true,
		free = false,
		hide_unavailable = true,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "global_event"
	}
	self.global_values.wcc_s02 = {
		name_id = "bm_global_value_wcc_s02",
		desc_id = "menu_l_global_value_wcc_s02",
		unlock_id = "bm_global_value_wcc_s02_unlock",
		color = tweak_data.screen_colors.event_color,
		dlc = true,
		free = false,
		hide_unavailable = true,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "global_event"
	}
	self.global_values.wcs = {
		name_id = "bm_global_value_wcs",
		desc_id = "menu_l_global_value_wcs",
		unlock_id = "bm_global_value_wcs_unlock",
		color = tweak_data.screen_colors.dlc_color,
		dlc = true,
		free = false,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 300,
		category = "dlc"
	}
	self.global_values.xmn = {
		name_id = "bm_global_value_xmn",
		desc_id = "menu_l_global_value_xmn",
		unlock_id = "bm_global_value_xmn_unlock",
		color = tweak_data.screen_colors.event_color,
		dlc = true,
		free = true,
		hide_unavailable = false,
		chance = 1,
		value_multiplier = 1,
		durability_multiplier = 1,
		drops = true,
		track = true,
		sort_number = 250,
		category = "global_event"
	}

	table.insert(self.global_value_list_index, "afp")
	table.insert(self.global_value_list_index, "mwm")
end
