InventoryIconCreator = InventoryIconCreator or class()
InventoryIconCreator.OPTIONAL = "<optional>"
InventoryIconCreator.ANIM_POSES_PATH = "anims/units/menu_character/player_criminal/menu_criminal"
InventoryIconCreator.ANIM_POSES_FILE_EXTENSION = "animation_states"
InventoryIconCreator.ANIM_POSES_STATE_NAME = "std/stand/still/idle/menu"

-- Lines 8-11
function InventoryIconCreator:init()
	self:_set_job_settings()
	self:_set_anim_poses()
end

-- Lines 13-21
function InventoryIconCreator:_set_job_settings()
	self._job_settings = {
		weapon = {
			distance = 4500,
			rot = Rotation(90, 0, 0),
			res = Vector3(3000, 1000, 0)
		},
		mask = {
			distance = 4500,
			rot = Rotation(90, 0, 0),
			res = Vector3(1000, 1000, 0)
		},
		melee = {
			distance = 5500,
			rot = Rotation(90, 0, 0),
			res = Vector3(2500, 1000, 0)
		},
		throwable = {
			distance = 4500,
			rot = Rotation(90, 0, 0),
			res = Vector3(2500, 1000, 0)
		},
		character = {
			distance = 4500,
			fov = 5,
			rot = Rotation(90, 0, 0),
			res = Vector3(1500, 3000, 0)
		},
		gloves = {
			distance = 4500,
			fov = 0.6,
			rot = Rotation(90, 0, 0),
			res = Vector3(1000, 1000, 0),
			offset = Vector3(0, 0, 0)
		}
	}
end

-- Lines 23-41
function InventoryIconCreator:_set_anim_poses()
	self._anim_poses = {}

	if DB:has(self.ANIM_POSES_FILE_EXTENSION, self.ANIM_POSES_PATH) then
		local node = DB:load_node(self.ANIM_POSES_FILE_EXTENSION, self.ANIM_POSES_PATH)

		for node_child in node:children() do
			if node_child:name() == "state" and node_child:parameter("name") == self.ANIM_POSES_STATE_NAME then
				for state_data in node_child:children() do
					if state_data:name() == "param" then
						table.insert(self._anim_poses, state_data:parameter("name"))
					end
				end

				table.sort(self._anim_poses)

				return
			end
		end
	end
end

-- Lines 48-75
function InventoryIconCreator:_create_weapon(factory_id, blueprint, weapon_skin_or_cosmetics, assembled_clbk)
	self:destroy_items()

	local cosmetics = {}

	if type(weapon_skin_or_cosmetics) == "string" then
		cosmetics.id = weapon_skin_or_cosmetics
		cosmetics.quality = "mint"
	else
		cosmetics = weapon_skin_or_cosmetics
	end

	self._current_texture_name = factory_id .. (cosmetics and "_" .. cosmetics.id or "")
	local unit_name = tweak_data.weapon.factory[factory_id].unit

	managers.dyn_resource:load(Idstring("unit"), Idstring(unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	local thisrot = self._item_rotation
	local rot = Rotation(thisrot[1] + 180, thisrot[2], thisrot[3])
	self._wait_for_assemble = true
	self._ignore_first_assemble_complete = true
	self._weapon_unit = World:spawn_unit(Idstring(unit_name), self._item_position, rot)

	self._weapon_unit:base():set_factory_data(factory_id)
	self._weapon_unit:base():assemble_from_blueprint(factory_id, blueprint, callback(self, self, "_assemble_completed", {
		cosmetics = cosmetics or {},
		clbk = assembled_clbk or function ()
		end
	}))
	self._weapon_unit:set_moving(true)
	self._weapon_unit:base():on_enabled()
end

-- Lines 77-101
function InventoryIconCreator:_create_mask(mask_id, blueprint)
	self:destroy_items()

	self._current_texture_name = mask_id
	local thisrot = self._item_rotation
	local rot = Rotation(thisrot[1] + 90, thisrot[2] + 90, thisrot[3])
	local mask_unit_name = managers.blackmarket:mask_unit_name_by_mask_id(mask_id)

	managers.dyn_resource:load(Idstring("unit"), Idstring(mask_unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	self._mask_unit = World:spawn_unit(Idstring(mask_unit_name), self._item_position, rot)

	if not tweak_data.blackmarket.masks[mask_id].type then
		-- Nothing
	end

	if blueprint then
		self._mask_unit:base():apply_blueprint(blueprint)
	end

	self._mask_unit:set_moving(true)
end

-- Lines 103-118
function InventoryIconCreator:_create_melee(melee_id)
	self:destroy_items()

	self._current_texture_name = melee_id
	local thisrot = self._item_rotation
	local rot = Rotation(thisrot[1], thisrot[2], thisrot[3])
	local melee_unit_name = tweak_data.blackmarket.melee_weapons[melee_id].unit

	managers.dyn_resource:load(Idstring("unit"), Idstring(melee_unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	self._melee_unit = World:spawn_unit(Idstring(melee_unit_name), self._item_position, rot)

	self._melee_unit:set_moving(true)
end

-- Lines 120-138
function InventoryIconCreator:_create_throwable(throwable_id)
	self:destroy_items()

	self._current_texture_name = throwable_id
	local thisrot = self._item_rotation
	local rot = Rotation(thisrot[1], thisrot[2], thisrot[3])
	local throwable_unit_name = tweak_data.blackmarket.projectiles[throwable_id].unit_dummy

	managers.dyn_resource:load(Idstring("unit"), Idstring(throwable_unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	self._throwable_unit = World:spawn_unit(Idstring(throwable_unit_name), self._item_position, rot)

	for _, effect_spawner in ipairs(self._throwable_unit:get_objects_by_type(Idstring("effect_spawner"))) do
		effect_spawner:set_enabled(false)
	end

	self._throwable_unit:set_moving(true)
end

-- Lines 140-162
function InventoryIconCreator:_create_character(character_name, anim_pose)
	self:destroy_items()

	self._current_texture_name = character_name
	local thisrot = self._item_rotation
	local rot = Rotation(thisrot[1] - 90, thisrot[2], thisrot[3])
	local character_id = managers.blackmarket:get_character_id_by_character_name(character_name)
	local unit_name = tweak_data.blackmarket.characters[character_id].menu_unit

	managers.dyn_resource:load(Idstring("unit"), Idstring(unit_name), DynamicResourceManager.DYN_RESOURCES_PACKAGE, false)

	self._character_unit = World:spawn_unit(Idstring(unit_name), self._item_position, rot)

	self._character_unit:base():set_character_name(CriminalsManager.convert_new_to_old_character_workname(character_name))
	self._character_unit:base():update_character_visuals()

	local state = self._character_unit:play_redirect(Idstring("idle_menu"))

	if anim_pose then
		self._character_unit:anim_state_machine():set_parameter(state, anim_pose, 1)
	end

	self._character_unit:set_moving(true)
end

-- Lines 164-173
function InventoryIconCreator:_create_player_style(player_style, material_variation, character_name, anim_pose)
	self:destroy_items()
	self:_create_character(character_name, anim_pose)

	self._current_texture_name = player_style

	self._character_unit:base():set_player_style(player_style, material_variation)
	self._character_unit:base():add_clbk_listener("done", callback(self, self, "_player_style_done"))
	self._character_unit:set_visible(false)
end

-- Lines 175-197
function InventoryIconCreator:_create_gloves(glove_id, character_name, anim_pose)
	self._wait_for_assemble = true

	self:_create_character(character_name, anim_pose)

	self._current_texture_name = glove_id

	self._character_unit:base():set_glove_id(glove_id)
	self._character_unit:base():add_clbk_listener("done", callback(self, self, "_gloves_done"))
	self._character_unit:set_visible(false)
end

-- Lines 199-204
function InventoryIconCreator:_player_style_done()
	if alive(self._character_unit) and self._character_unit:spawn_manager() then
		self._character_unit:spawn_manager():remove_unit("char_gloves")
		self._character_unit:spawn_manager():remove_unit("char_glove_adapter")
	end
end

-- Lines 206-234
function InventoryIconCreator:_gloves_done()
	call_on_next_update(function ()
		if alive(self._character_unit) and self._character_unit:spawn_manager() then
			self._character_unit:spawn_manager():remove_unit("char_mesh")
			self._character_unit:spawn_manager():remove_unit("char_glove_adapter")

			self._center_points = {
				self._character_unit:position()
			}
			local left_hand = self._character_unit:get_object(Idstring("LeftHand"))
			local right_hand = self._character_unit:get_object(Idstring("RightHand"))

			if alive(left_hand) and right_hand then
				-- Nothing
			end
		end

		self:start_create()
	end)
end

-- Lines 236-249
function InventoryIconCreator:_assemble_completed(data)
	if self._ignore_first_assemble_complete then
		self._ignore_first_assemble_complete = false

		return
	end

	self._weapon_unit:base():change_cosmetics(data.cosmetics, function ()
		self._weapon_unit:set_moving(true)
		call_on_next_update(function ()
			data.clbk(self._weapon_unit)
		end)
	end)
end

-- Lines 251-255
function InventoryIconCreator:start_jobs(jobs)
	self._current_job = 0
	self._jobs = jobs

	managers.editor:add_tool_updator("InventoryIconCreator", callback(self, self, "_update"))
end

-- Lines 257-299
function InventoryIconCreator:start_all_weapons_skin(test)
	local filter = self._filter:get_value()

	if not filter or #filter == 0 then
		EWS:message_box(Global.frame_panel, "Search filter empty!", "Error", "OK,ICON_ERROR", Vector3(-1, -1, 0))

		return
	end

	local weapons = {}

	if test then
		weapons = {
			"wpn_fps_rpg7",
			"wpn_fps_snp_r93",
			"wpn_fps_pis_x_g17",
			"wpn_fps_ass_74"
		}
	else
		weapons = self:_get_all_weapons()
	end

	local jobs = {}
	local search_string = "_" .. filter .. "$"

	for _, factory_id in ipairs(weapons) do
		local blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
		local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(factory_id)

		for name, item_data in pairs(tweak_data.blackmarket.weapon_skins) do
			local match_weapon_id = item_data.weapon_id or item_data.weapon_ids[1]

			if match_weapon_id == weapon_id and string.find(name, search_string) then
				local bp = name and tweak_data.blackmarket.weapon_skins[name].default_blueprint or blueprint

				table.insert(jobs, {
					factory_id = factory_id,
					blueprint = bp,
					weapon_skin = name
				})
			end
		end
	end

	if #jobs == 0 then
		EWS:message_box(Global.frame_panel, "No weapons found matching speficied skin filter '" .. filter .. "'", "Error", "OK,ICON_ERROR", Vector3(-1, -1, 0))

		return
	end

	local confirm = EWS:message_box(Global.frame_panel, "Really, all of them (" .. tostring(#jobs) .. ")?", "Icon creator", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	self:start_jobs(jobs)
end

-- Lines 301-320
function InventoryIconCreator:start_all_weapons(test)
	local confirm = EWS:message_box(Global.frame_panel, "Really, all of them?", "Icon creator", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	local weapons = {}

	if test then
		weapons = {
			"wpn_fps_rpg7",
			"wpn_fps_snp_r93",
			"wpn_fps_pis_x_g17"
		}
	else
		weapons = self:_get_all_weapons()
	end

	local jobs = {}

	for _, factory_id in ipairs(weapons) do
		local blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)

		table.insert(jobs, {
			factory_id = factory_id,
			blueprint = blueprint
		})
	end

	self:start_jobs(jobs)
end

-- Lines 322-334
function InventoryIconCreator:start_all_weapon_skins()
	local factory_id = self._ctrlrs.weapon.factory_id:get_value()
	local blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	local jobs = {}

	for _, weapon_skin in ipairs(self:_get_weapon_skins()) do
		weapon_skin = weapon_skin ~= "none" and weapon_skin

		if weapon_skin then
			blueprint = tweak_data.blackmarket.weapon_skins[weapon_skin].default_blueprint or blueprint
		end

		table.insert(jobs, {
			factory_id = factory_id,
			blueprint = blueprint,
			weapon_skin = weapon_skin
		})
	end

	self:start_jobs(jobs)
end

-- Lines 336-345
function InventoryIconCreator:start_one_weapon()
	local factory_id = self._ctrlrs.weapon.factory_id:get_value()
	local weapon_skin = self._ctrlrs.weapon.weapon_skin:get_value()
	weapon_skin = weapon_skin ~= "none" and weapon_skin
	local blueprint = weapon_skin and tweak_data.blackmarket.weapon_skins[weapon_skin].default_blueprint
	blueprint = blueprint or self:_get_blueprint_from_ui()
	local cosmetics = self:_make_current_weapon_cosmetics()

	self:start_jobs({
		{
			factory_id = factory_id,
			blueprint = blueprint,
			weapon_skin = cosmetics
		}
	})
end

-- Lines 347-356
function InventoryIconCreator:preview_one_weapon()
	local factory_id = self._ctrlrs.weapon.factory_id:get_value()
	local weapon_skin = self._ctrlrs.weapon.weapon_skin:get_value()
	weapon_skin = weapon_skin ~= "none" and weapon_skin
	local blueprint = weapon_skin and tweak_data.blackmarket.weapon_skins[weapon_skin].default_blueprint
	blueprint = blueprint or self:_get_blueprint_from_ui()
	local cosmetics = self:_make_current_weapon_cosmetics()

	self:_create_weapon(factory_id, blueprint, cosmetics)
end

-- Lines 358-367
function InventoryIconCreator:export_one_weapon()
	local factory_id = self._ctrlrs.weapon.factory_id:get_value()
	local weapon_skin = self._ctrlrs.weapon.weapon_skin:get_value()
	weapon_skin = weapon_skin ~= "none" and weapon_skin
	local blueprint = weapon_skin and tweak_data.blackmarket.weapon_skins[weapon_skin].default_blueprint
	blueprint = blueprint or self:_get_blueprint_from_ui()
	local cosmetics = self:_make_current_weapon_cosmetics()

	self:_create_weapon(factory_id, blueprint, cosmetics, callback(self, self, "export_weapon_to_obj", factory_id .. (cosmetics and "_" .. cosmetics.id or "")))
end

-- Lines 369-377
function InventoryIconCreator:export_weapon_to_obj(id, unit)
	local dump_units = {
		unit
	}

	for pid, data in pairs(unit:base()._parts) do
		table.insert(dump_units, data.unit)
	end

	managers.editor:dump_mesh(dump_units, id)
end

-- Lines 379-394
function InventoryIconCreator:_make_current_weapon_cosmetics()
	local weapon_skin = self._ctrlrs.weapon.weapon_skin:get_value()
	local weapon_color = self._ctrlrs.weapon.weapon_color:get_value()
	local quality = self._ctrlrs.weapon.weapon_quality:get_value()
	local color_index = self._ctrlrs.weapon.weapon_color_variation:get_value()
	local pattern_scale = self._ctrlrs.weapon.weapon_pattern_scale:get_value()

	if weapon_skin ~= "none" then
		return self:_make_weapon_cosmetics(weapon_skin, quality)
	elseif weapon_color ~= "none" then
		return self:_make_weapon_cosmetics(weapon_color, quality, color_index, pattern_scale)
	end

	return nil
end

-- Lines 396-412
function InventoryIconCreator:_make_weapon_cosmetics(id, quality, color_index, pattern_scale)
	local tweak = id ~= "none" and tweak_data.blackmarket.weapon_skins[id]

	if not tweak then
		return nil
	end

	local cosmetics = {
		id = id,
		quality = quality
	}

	if tweak.is_a_color_skin then
		cosmetics.color_index = tonumber(color_index)
		cosmetics.pattern_scale = tonumber(pattern_scale)
	end

	return cosmetics
end

-- Lines 414-427
function InventoryIconCreator:_get_blueprint_from_ui()
	local blueprint = {}
	local non_mod_types = {
		"factory_id",
		"weapon_skin",
		"weapon_quality",
		"weapon_color",
		"weapon_color_variation",
		"weapon_pattern_scale"
	}

	for type, ctrlr in pairs(self._ctrlrs.weapon) do
		if not table.contains(non_mod_types, type) then
			local part_id = ctrlr:get_value()

			if part_id ~= self.OPTIONAL then
				table.insert(blueprint, part_id)
			end
		end
	end

	return blueprint
end

-- Lines 429-436
function InventoryIconCreator:_get_all_weapons()
	local weapons = {}

	for _, data in pairs(Global.blackmarket_manager.weapons) do
		table.insert(weapons, data.factory_id)
	end

	table.sort(weapons)

	return weapons
end

-- Lines 438-452
function InventoryIconCreator:_get_weapon_skins()
	local factory_id = self._ctrlrs.weapon.factory_id:get_value()
	local weapon_id = managers.weapon_factory:get_weapon_id_by_factory_id(factory_id)
	local t = {
		"none"
	}

	for name, item_data in pairs(tweak_data.blackmarket.weapon_skins) do
		local match_weapon_id = not item_data.is_a_color_skin and (item_data.weapon_id or item_data.weapon_ids[1])

		if match_weapon_id == weapon_id then
			table.insert(t, name)
		end
	end

	return t
end

-- Lines 454-467
function InventoryIconCreator:_get_weapon_colors()
	local t = {}

	for name, item_data in pairs(tweak_data.blackmarket.weapon_skins) do
		if item_data.is_a_color_skin then
			table.insert(t, name)
		end
	end

	table.sort(t)
	table.insert(t, 1, "none")

	return t
end

-- Lines 469-478
function InventoryIconCreator:_get_weapon_color_variations()
	local t = {}
	local weapon_color_variation_template = tweak_data.blackmarket.weapon_color_templates.color_variation

	for index = 1, #weapon_color_variation_template do
		table.insert(t, index)
	end

	return t
end

-- Lines 480-497
function InventoryIconCreator:_get_weapon_qualities()
	local qualities = {}

	for id, data in pairs(tweak_data.economy.qualities) do
		table.insert(qualities, {
			id = id,
			index = data.index
		})
	end

	table.sort(qualities, function (x, y)
		return y.index < x.index
	end)

	local t = {}

	for index, data in ipairs(qualities) do
		table.insert(t, data.id)
	end

	return t
end

-- Lines 499-507
function InventoryIconCreator:_get_weapon_pattern_scales()
	local t = {}

	for index, data in ipairs(tweak_data.blackmarket.weapon_color_pattern_scales) do
		table.insert(t, index)
	end

	return t
end

-- Lines 510-530
function InventoryIconCreator:start_all_masks(with_blueprint)
	local confirm = EWS:message_box(Global.frame_panel, "Really, all of them?", "Icon creator", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	local masks = {}

	if false then
		masks = {
			"troll",
			"mr_sinister",
			"baby_cry",
			"pazuzu",
			"anubis",
			"infamy_lurker",
			"plague",
			"robo_santa"
		}
	else
		masks = self:_get_all_masks()
	end

	local blueprint = with_blueprint and self:_get_mask_blueprint_from_ui() or nil
	local jobs = {}

	for _, mask_id in ipairs(masks) do
		table.insert(jobs, {
			mask_id = mask_id,
			blueprint = blueprint
		})
	end

	self:start_jobs(jobs)
end

-- Lines 532-536
function InventoryIconCreator:start_one_mask(with_blueprint)
	local mask_id = self._ctrlrs.mask.mask_id:get_value()
	local blueprint = with_blueprint and self:_get_mask_blueprint_from_ui() or nil

	self:start_jobs({
		{
			mask_id = mask_id,
			blueprint = blueprint
		}
	})
end

-- Lines 538-542
function InventoryIconCreator:preview_one_mask(with_blueprint)
	local mask_id = self._ctrlrs.mask.mask_id:get_value()
	local blueprint = with_blueprint and self:_get_mask_blueprint_from_ui() or nil

	self:_create_mask(mask_id, blueprint)
end

-- Lines 544-553
function InventoryIconCreator:_get_mask_blueprint_from_ui()
	local blueprint = {}

	for type, ctrlr in pairs(self._ctrlrs.mask) do
		if type ~= "mask_id" then
			local id = ctrlr:get_value()
			blueprint[type] = {
				id = id
			}
		end
	end

	return blueprint
end

-- Lines 555-564
function InventoryIconCreator:_get_all_masks()
	local t = {}

	for mask_id, data in pairs(tweak_data.blackmarket.masks) do
		if mask_id ~= "character_locked" then
			table.insert(t, mask_id)
		end
	end

	table.sort(t)

	return t
end

-- Lines 568-579
function InventoryIconCreator:start_all_melee()
	local confirm = EWS:message_box(Global.frame_panel, "Really, all of them?", "Icon creator", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	local jobs = {}

	for _, melee_id in ipairs(self:_get_all_melee()) do
		table.insert(jobs, {
			melee_id = melee_id
		})
	end

	self:start_jobs(jobs)
end

-- Lines 581-584
function InventoryIconCreator:start_one_melee()
	local melee_id = self._ctrlrs.melee.melee_id:get_value()

	self:start_jobs({
		{
			melee_id = melee_id
		}
	})
end

-- Lines 586-589
function InventoryIconCreator:preview_one_melee()
	local melee_id = self._ctrlrs.melee.melee_id:get_value()

	self:_create_melee(melee_id)
end

-- Lines 591-603
function InventoryIconCreator:_get_all_melee()
	local t = {}

	for melee_id, data in pairs(tweak_data.blackmarket.melee_weapons) do
		if data.unit then
			table.insert(t, melee_id)
		else
			Application:error("No unit for " .. melee_id .. ". No icon created.")
		end
	end

	table.sort(t)

	return t
end

-- Lines 607-618
function InventoryIconCreator:start_all_throwable()
	local confirm = EWS:message_box(Global.frame_panel, "Really, all of them?", "Icon creator", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	local jobs = {}

	for _, throwable_id in ipairs(self:_get_all_throwable()) do
		table.insert(jobs, {
			throwable_id = throwable_id
		})
	end

	self:start_jobs(jobs)
end

-- Lines 620-623
function InventoryIconCreator:start_one_throwable()
	local throwable_id = self._ctrlrs.throwable.throwable_id:get_value()

	self:start_jobs({
		{
			throwable_id = throwable_id
		}
	})
end

-- Lines 625-628
function InventoryIconCreator:preview_one_throwable()
	local throwable_id = self._ctrlrs.throwable.throwable_id:get_value()

	self:_create_throwable(throwable_id)
end

-- Lines 630-641
function InventoryIconCreator:_get_all_throwable()
	local t = {}

	for throwable_id, data in pairs(tweak_data.blackmarket.projectiles) do
		if data.throwable and data.unit_dummy then
			table.insert(t, throwable_id)
		end
	end

	table.sort(t)

	return t
end

-- Lines 644-656
function InventoryIconCreator:start_all_character()
	local confirm = EWS:message_box(Global.frame_panel, "Really, all of them?", "Icon creator", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	local jobs = {}
	local anim_pose = self._ctrlrs.character.anim_pose:get_value()

	for _, character_id in ipairs(self:_get_all_characters()) do
		table.insert(jobs, {
			character_id = character_id,
			anim_pose = anim_pose
		})
	end

	self:start_jobs(jobs)
end

-- Lines 658-662
function InventoryIconCreator:start_one_character()
	local character_id = self._ctrlrs.character.character_id:get_value()
	local anim_pose = self._ctrlrs.character.anim_pose:get_value()

	self:start_jobs({
		{
			character_id = character_id,
			anim_pose = anim_pose
		}
	})
end

-- Lines 664-668
function InventoryIconCreator:preview_one_character()
	local character_id = self._ctrlrs.character.character_id:get_value()
	local anim_pose = self._ctrlrs.character.anim_pose:get_value()

	self:_create_character(character_id, anim_pose)
end

-- Lines 670-677
function InventoryIconCreator:_get_all_characters()
	local t = {}

	for _, character in ipairs(CriminalsManager.character_names()) do
		table.insert(t, CriminalsManager.convert_old_to_new_character_workname(character))
	end

	return t
end

-- Lines 679-681
function InventoryIconCreator:_get_all_anim_poses()
	return self._anim_poses
end

-- Lines 684-698
function InventoryIconCreator:start_all_player_style()
	local confirm = EWS:message_box(Global.frame_panel, "Really, all of them?", "Icon creator", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	local jobs = {}
	local material_variation = "default"
	local character_id = self._ctrlrs.player_style.character_id:get_value()
	local anim_pose = self._ctrlrs.player_style.anim_pose:get_value()

	for _, player_style in ipairs(self:_get_all_player_style()) do
		table.insert(jobs, {
			player_style = player_style,
			material_variation = material_variation,
			character_id = character_id,
			anim_pose = anim_pose
		})
	end

	self:start_jobs(jobs)
end

-- Lines 700-706
function InventoryIconCreator:start_one_player_style()
	local player_style = self._ctrlrs.player_style.player_style:get_value()
	local material_variation = self._ctrlrs.player_style.material_variation:get_value()
	local character_id = self._ctrlrs.player_style.character_id:get_value()
	local anim_pose = self._ctrlrs.player_style.anim_pose:get_value()

	self:start_jobs({
		{
			player_style = player_style,
			material_variation = material_variation,
			character_id = character_id,
			anim_pose = anim_pose
		}
	})
end

-- Lines 708-714
function InventoryIconCreator:preview_one_player_style()
	local player_style = self._ctrlrs.player_style.player_style:get_value()
	local material_variation = self._ctrlrs.player_style.material_variation:get_value()
	local character_id = self._ctrlrs.player_style.character_id:get_value()
	local anim_pose = self._ctrlrs.player_style.anim_pose:get_value()

	self:_create_player_style(player_style, material_variation, character_id, anim_pose)
end

-- Lines 716-720
function InventoryIconCreator:_get_all_player_style()
	local t = clone(tweak_data.blackmarket.player_style_list)

	table.delete(t, "none")

	return t
end

-- Lines 722-726
function InventoryIconCreator:_get_all_suit_variations(player_style)
	local t = clone(managers.blackmarket:get_all_suit_variations(player_style))

	return t
end

-- Lines 729-742
function InventoryIconCreator:start_all_gloves()
	local confirm = EWS:message_box(Global.frame_panel, "Really, all of them?", "Icon creator", "YES_NO,ICON_QUESTION", Vector3(-1, -1, 0))

	if confirm == "NO" then
		return
	end

	local jobs = {}
	local character_id = self._ctrlrs.gloves.character_id:get_value()
	local anim_pose = self._ctrlrs.gloves.anim_pose:get_value()

	for _, glove_id in ipairs(self:_get_all_gloves()) do
		table.insert(jobs, {
			glove_id = glove_id,
			character_id = character_id,
			anim_pose = anim_pose
		})
	end

	self:start_jobs(jobs)
end

-- Lines 744-749
function InventoryIconCreator:start_one_gloves()
	local glove_id = self._ctrlrs.gloves.glove_id:get_value()
	local character_id = self._ctrlrs.gloves.character_id:get_value()
	local anim_pose = self._ctrlrs.gloves.anim_pose:get_value()

	self:start_jobs({
		{
			glove_id = glove_id,
			character_id = character_id,
			anim_pose = anim_pose
		}
	})
end

-- Lines 751-756
function InventoryIconCreator:preview_one_gloves()
	local glove_id = self._ctrlrs.gloves.glove_id:get_value()
	local character_id = self._ctrlrs.gloves.character_id:get_value()
	local anim_pose = self._ctrlrs.gloves.anim_pose:get_value()

	self:_create_gloves(glove_id, character_id, anim_pose)
end

-- Lines 758-762
function InventoryIconCreator:_get_all_gloves()
	local t = clone(tweak_data.blackmarket.glove_list)

	table.delete(t, "default")

	return t
end

-- Lines 765-787
function InventoryIconCreator:_start_job()
	self._has_job = true
	local job = self._jobs[self._current_job]

	if job.factory_id then
		self:_create_weapon(job.factory_id, job.blueprint, job.weapon_skin, callback(self, self, "start_create"))
	elseif job.mask_id then
		self:_create_mask(job.mask_id, job.blueprint)
	elseif job.melee_id then
		self:_create_melee(job.melee_id)
	elseif job.throwable_id then
		self:_create_throwable(job.throwable_id)
	elseif job.player_style then
		self:_create_player_style(job.player_style, job.material_variation, job.character_id, job.anim_pose)
	elseif job.glove_id then
		self:_create_gloves(job.glove_id, job.character_id, job.anim_pose)
	elseif job.character_id then
		self:_create_character(job.character_id, job.anim_pose)
	end

	if not self._wait_for_assemble then
		self:start_create()
	end
end

-- Lines 789-800
function InventoryIconCreator:check_next_job()
	if self._has_job then
		return
	end

	self._current_job = self._current_job + 1

	if self._current_job > #self._jobs then
		managers.editor:remove_tool_updator("InventoryIconCreator")

		return
	end

	self:_start_job()
end

-- Lines 802-807
function InventoryIconCreator:_update()
	if self._steps then
		self:_next_step()
	end

	self:check_next_job()
end

-- Lines 809-849
function InventoryIconCreator:update_debug()
	return

	if self._has_job then
		return
	end

	if not self._brush then
		self._brush = Draw:brush(Color.green:with_alpha(0.3))
	end

	self._text_brush = nil

	if not self._text_brush then
		self._text_brush = Draw:brush(Color.red)

		self._text_brush:set_font(Idstring("fonts/font_medium"), 1)
	end

	if self._camera_position then
		self._brush:sphere(self._camera_position, 50, 2)
		self._brush:cone(self._camera_position, self._camera_position + self._camera_rotation:y() * 100, self._camera_fov, 4)
	end

	if self._object_position then
		self._brush:sphere(self._object_position, 3, 2)
	end
end

-- Lines 851-886
function InventoryIconCreator:start_create()
	self._wait_for_assemble = nil

	if not self._has_job then
		return
	end

	self._old_data = {
		camera_position = managers.editor:camera_position(),
		camera_rotation = managers.editor:camera_rotation(),
		camera_fov = managers.editor:camera_fov(),
		layer_draw_grid = managers.editor._layer_draw_grid,
		layer_draw_marker = managers.editor._layer_draw_marker,
		base_chromatic_amount = managers.environment_controller:base_chromatic_amount(),
		base_contrast = managers.environment_controller:base_contrast()
	}

	managers.editor:set_show_camera_info(false)

	managers.editor._show_center = false
	managers.editor._layer_draw_grid = false
	managers.editor._layer_draw_marker = false

	self:_setup_camera()
	self:_create_backdrop()
	managers.editor:enable_all_post_effects()
	managers.environment_controller:set_dof_setting("none")
	managers.environment_controller:set_base_chromatic_amount(0)
	managers.environment_controller:set_base_contrast(0)

	self._steps = {}
	self._current_step = 0

	table.insert(self._steps, callback(self, self, "_take_screen_shot_1"))
	table.insert(self._steps, callback(self, self, "_pre_screen_shot_2"))
	table.insert(self._steps, callback(self, self, "_take_screen_shot_2"))
	table.insert(self._steps, callback(self, self, "end_create"))
end

-- Lines 888-907
function InventoryIconCreator:end_create()
	managers.editor:set_camera(self._old_data.camera_position, self._old_data.camera_rotation)
	managers.editor:set_camera_fov(self._old_data.camera_fov)
	managers.editor:set_show_camera_info(true)

	managers.editor._show_center = true
	managers.editor._layer_draw_grid = self._old_data.layer_draw_grid
	managers.editor._layer_draw_marker = self._old_data.layer_draw_marker

	self:_destroy_backdrop()
	managers.editor:change_visualization("deferred_lighting")
	managers.environment_controller:set_dof_setting("standard")
	managers.editor:_set_appwin_fixed_resolution(nil)
	managers.environment_controller:set_base_chromatic_amount(self._old_data.base_chromatic_amount)
	managers.environment_controller:set_base_contrast(self._old_data.base_contrast)

	self._has_job = false
end

-- Lines 909-912
function InventoryIconCreator:_create_backdrop()
	self:_destroy_backdrop()

	self._backdrop = safe_spawn_unit(Idstring("units/test/jocke/oneplanetorulethemall"), self._backdrop_position, self._backdrop_rotation)
end

-- Lines 914-919
function InventoryIconCreator:_destroy_backdrop()
	if alive(self._backdrop) then
		World:delete_unit(self._backdrop)

		self._backdrop = nil
	end
end

-- Lines 921-975
function InventoryIconCreator:_setup_camera()
	self:_set_job_settings()

	local job_setting = nil

	if self._jobs[1].factory_id then
		job_setting = self._job_settings.weapon
	elseif self._jobs[1].mask_id then
		job_setting = self._job_settings.mask
	elseif self._jobs[1].melee_id then
		job_setting = self._job_settings.melee
	elseif self._jobs[1].throwable_id then
		job_setting = self._job_settings.throwable
	elseif self._jobs[1].glove_id then
		job_setting = self._job_settings.gloves
	elseif self._jobs[1].character_id then
		job_setting = self._job_settings.character
	end

	if not self._custom_ctrlrs.use_camera_setting:get_value() then
		local camera_position = Vector3(0, 0, 0)

		if self._center_points then
			for _, pos in ipairs(self._center_points) do
				mvector3.add(camera_position, pos)
			end

			mvector3.divide(camera_position, #self._center_points)

			self._center_points = nil
		else
			local oobb = (self._weapon_unit or self._mask_unit or self._melee_unit or self._throwable_unit or self._gloves_unit or self._character_unit):oobb()

			if oobb then
				camera_position = oobb:center()
			end
		end

		self._object_position = mvector3.copy(camera_position)

		mvector3.add(camera_position, job_setting.offset or Vector3(0, 0, 0))
		mvector3.set_x(camera_position, job_setting.distance)

		self._camera_position = camera_position
		self._camera_rotation = job_setting.rot
		self._camera_fov = job_setting.fov or 1

		managers.editor:set_camera(self._camera_position, self._camera_rotation)
		managers.editor:set_camera_fov(self._camera_fov)
	end

	local w = job_setting.res.x
	local h = job_setting.res.y

	if self._custom_ctrlrs.resolution.use:get_value() then
		w = tonumber(self._custom_ctrlrs.resolution.width:get_value())
		h = tonumber(self._custom_ctrlrs.resolution.height:get_value())
	end

	managers.editor:_set_appwin_fixed_resolution(Vector3(w + 4, h + 4, 0))
end

-- Lines 977-984
function InventoryIconCreator:_next_step()
	self._current_step = self._current_step + 1

	if self._current_step > #self._steps then
		return
	end

	local func = self._steps[self._current_step]

	func()
end

-- Lines 986-990
function InventoryIconCreator:_take_screen_shot_1()
	local name = self._current_texture_name .. "_dif.tga"
	local path = managers.database:root_path()

	Application:screenshot(path .. name)
end

-- Lines 992-996
function InventoryIconCreator:_pre_screen_shot_2()
	managers.editor:on_post_processor_effect("empty")
	managers.editor:change_visualization("depth_visualization")
	self._backdrop:set_visible(false)
end

-- Lines 998-1002
function InventoryIconCreator:_take_screen_shot_2()
	local name = self._current_texture_name .. "_dph.tga"
	local path = managers.database:root_path()

	Application:screenshot(path .. name)
end

-- Lines 1004-1012
function InventoryIconCreator:destroy_items()
	self:destroy_weapon()
	self:destroy_mask()
	self:destroy_melee()
	self:destroy_throwable()
	self:destroy_character()
	self:destroy_player_style()
	self:destroy_gloves()
end

-- Lines 1014-1021
function InventoryIconCreator:destroy_weapon()
	if not alive(self._weapon_unit) then
		return
	end

	self._weapon_unit:set_slot(0)

	self._weapon_unit = nil
end

-- Lines 1023-1030
function InventoryIconCreator:destroy_mask()
	if not alive(self._mask_unit) then
		return
	end

	self._mask_unit:set_slot(0)

	self._mask_unit = nil
end

-- Lines 1032-1039
function InventoryIconCreator:destroy_melee()
	if not alive(self._melee_unit) then
		return
	end

	self._melee_unit:set_slot(0)

	self._melee_unit = nil
end

-- Lines 1041-1048
function InventoryIconCreator:destroy_throwable()
	if not alive(self._throwable_unit) then
		return
	end

	self._throwable_unit:set_slot(0)

	self._throwable_unit = nil
end

-- Lines 1050-1057
function InventoryIconCreator:destroy_character()
	if not alive(self._character_unit) then
		return
	end

	self._character_unit:set_slot(0)

	self._character_unit = nil
end

-- Lines 1059-1061
function InventoryIconCreator:destroy_player_style()
	self:destroy_character()
end

-- Lines 1063-1072
function InventoryIconCreator:destroy_gloves()
	self:destroy_character()

	if not alive(self._gloves_unit) then
		return
	end

	self._gloves_unit:set_slot(0)

	self._gloves_unit = nil
	self._gloves_object = nil
end

-- Lines 1075-1079
function InventoryIconCreator:show_ews()
	if not self._main_frame then
		self:create_ews()
	end
end

-- Lines 1081-1123
function InventoryIconCreator:create_ews()
	self:close_ews()

	self._main_frame = EWS:Frame("Icon creator", Vector3(250, 0, 0), Vector3(420, 700, 0), "FRAME_FLOAT_ON_PARENT,DEFAULT_FRAME_STYLE,FULL_REPAINT_ON_RESIZE", Global.frame)

	self._main_frame:set_icon(CoreEws.image_path("world_editor/icon_creator_16x16.png"))

	local main_box = EWS:BoxSizer("HORIZONTAL")
	self._main_panel = EWS:Panel(self._main_frame, "", "FULL_REPAINT_ON_RESIZE")
	local main_panel_sizer = EWS:BoxSizer("VERTICAL")

	self._main_panel:set_sizer(main_panel_sizer)
	main_box:add(self._main_panel, 1, 0, "EXPAND")
	self._main_frame:connect("", "EVT_CLOSE_WINDOW", callback(self, self, "close_ews"), "")

	local common_sizer = EWS:StaticBoxSizer(self._main_panel, "VERTICAL", "")

	main_panel_sizer:add(common_sizer, 0, 0, "EXPAND")

	local btn_sizer = EWS:BoxSizer("HORIZONTAL")

	common_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local _btn = EWS:Button(self._main_panel, "Delete item", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "destroy_items"), false)
	self:_create_custom_job(self._main_panel, common_sizer)

	local notebook = EWS:Notebook(self._main_panel, "", "NB_TOP,NB_MULTILINE")

	main_panel_sizer:add(notebook, 1, 0, "EXPAND")

	self._ctrlrs = {
		weapon = {},
		mask = {},
		melee = {},
		throwable = {},
		character = {},
		player_style = {},
		gloves = {}
	}

	notebook:add_page(self:_create_weapons_page(notebook), "Weapons", true)
	notebook:add_page(self:_create_masks_page(notebook), "Masks", false)
	notebook:add_page(self:_create_melee_page(notebook), "Melee", false)
	notebook:add_page(self:_create_throwable_page(notebook), "Throwable", false)
	notebook:add_page(self:_create_character_page(notebook), "Character", false)
	notebook:add_page(self:_create_player_style_page(notebook), "Outfit", false)
	notebook:add_page(self:_create_gloves_page(notebook), "Gloves", false)
	self._main_frame:set_sizer(main_box)
	self._main_frame:set_visible(true)
end

-- Lines 1127-1193
function InventoryIconCreator:_create_custom_job(panel, sizer)
	self._custom_ctrlrs = {
		resolution = {}
	}
	local checkbox = EWS:CheckBox(panel, "Use current camera setting", "")

	checkbox:set_value(false)
	sizer:add(checkbox, 0, 0, "EXPAND,RIGHT")

	self._custom_ctrlrs.use_camera_setting = checkbox
	local h_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(h_sizer, 0, 0, "EXPAND")

	local checkbox = EWS:CheckBox(panel, "Use custom resolution", "")

	checkbox:set_value(false)
	h_sizer:add(checkbox, 0, 4, "EXPAND,RIGHT")

	self._custom_ctrlrs.resolution.use = checkbox
	local number_params = {
		value = 64,
		name = "Width:",
		ctrlr_proportions = 1,
		name_proportions = 1,
		tooltip = "Set a number value",
		min = 64,
		sizer_proportions = 1,
		max = 8192,
		panel = panel,
		sizer = h_sizer
	}
	local ctrlr = CoreEws.number_controller(number_params)
	self._custom_ctrlrs.resolution.width = ctrlr
	local number_params = {
		value = 64,
		name = "Height:",
		ctrlr_proportions = 1,
		name_proportions = 1,
		tooltip = "Set a number value",
		min = 64,
		sizer_proportions = 1,
		max = 8192,
		panel = panel,
		sizer = h_sizer
	}
	local ctrlr = CoreEws.number_controller(number_params)
	self._custom_ctrlrs.resolution.height = ctrlr

	h_sizer:add(EWS:BoxSizer("HORIZONTAL"), 1, 0, "EXPAND")

	self._backdrop_position = Vector3(-500, 0, 0)
	self._backdrop_rotation = Rotation(180, 0, -90)
	self._item_position = Vector3(0, 0, 0)
	self._item_rotation = {
		0,
		0,
		0
	}
	self._backdrop_position_control = self:_create_position_control("Backdrop Position: ", self._backdrop_position, panel, sizer, callback(self, self, "_update_backdrop_position"))
	self._backdrop_rotation_control = self:_create_rotation_control("Backdrop Rotation: ", self._backdrop_rotation, panel, sizer, callback(self, self, "_update_backdrop_rotation"))
	self._item_position_control = self:_create_item_position("Item Position: ", self._item_position, panel, sizer, callback(self, self, "_update_item_position"))
	self._item_rotation_control = self:_create_item_rotation("Item Rotation: ", self._item_rotation, panel, sizer, callback(self, self, "_update_item_rotation"))
end

-- Lines 1195-1197
function InventoryIconCreator:_update_backdrop_position(position)
	self._backdrop_position = position
end

-- Lines 1199-1201
function InventoryIconCreator:_update_backdrop_rotation(rotation)
	self._backdrop_rotation = rotation
end

-- Lines 1203-1205
function InventoryIconCreator:_update_item_position(position)
	self._item_position = position
end

-- Lines 1207-1209
function InventoryIconCreator:_update_item_rotation(rotation)
	self._item_rotation = rotation
end

-- Lines 1211-1228
function InventoryIconCreator:_create_axis_control(name, default_value, panel, sizer, cb, prop)
	local axis_params = {
		floats = 0,
		name_proportions = 1,
		name = name,
		panel = panel,
		sizer = sizer,
		value = default_value,
		ctrlr_proportions = prop or 5,
		events = {
			{
				event = "EVT_COMMAND_TEXT_ENTER",
				callback = cb
			},
			{
				event = "EVT_KILL_FOCUS",
				callback = cb
			}
		}
	}

	CoreEws.number_controller(axis_params)

	return axis_params
end

-- Lines 1230-1242
function InventoryIconCreator:_create_position_control(name, default_value, panel, sizer, cb)
	local h_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(h_sizer, 0, 0, "EXPAND")

	local text_ctrlr = EWS:StaticText(panel, name, 0, "ALIGN_LEFT")

	h_sizer:add(text_ctrlr, 0, 0, "ALIGN_LEFT")

	local pp = {}

	table.insert(pp, self:_create_axis_control(" X:", default_value.x, panel, h_sizer, function ()
		cb(Vector3(pp[1].value, pp[2].value, pp[3].value))
	end))
	table.insert(pp, self:_create_axis_control(" Y:", default_value.y, panel, h_sizer, function ()
		cb(Vector3(pp[1].value, pp[2].value, pp[3].value))
	end))
	table.insert(pp, self:_create_axis_control(" Z:", default_value.z, panel, h_sizer, function ()
		cb(Vector3(pp[1].value, pp[2].value, pp[3].value))
	end))

	return pp
end

-- Lines 1244-1256
function InventoryIconCreator:_create_rotation_control(name, default_value, panel, sizer, cb)
	local h_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(h_sizer, 0, 0, "EXPAND")

	local text_ctrlr = EWS:StaticText(panel, name, 0, "ALIGN_LEFT")

	h_sizer:add(text_ctrlr, 0, 0, "ALIGN_LEFT")

	local rp = {}

	table.insert(rp, self:_create_axis_control(" Yaw:", default_value:yaw(), panel, h_sizer, function ()
		cb(Rotation(rp[1].value, rp[2].value, rp[3].value))
	end, 2))
	table.insert(rp, self:_create_axis_control(" Pitch:", default_value:pitch(), panel, h_sizer, function ()
		cb(Rotation(rp[1].value, rp[2].value, rp[3].value))
	end, 2))
	table.insert(rp, self:_create_axis_control(" Roll:", default_value:roll(), panel, h_sizer, function ()
		cb(Rotation(rp[1].value, rp[2].value, rp[3].value))
	end, 2))

	return rp
end

-- Lines 1258-1270
function InventoryIconCreator:_create_item_position(name, default_value, panel, sizer, cb)
	local h_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(h_sizer, 0, 0, "EXPAND")

	local text_ctrlr = EWS:StaticText(panel, name, 0, "ALIGN_LEFT")

	h_sizer:add(text_ctrlr, 0, 0, "ALIGN_LEFT")

	local ppx = {}

	table.insert(ppx, self:_create_axis_control(" X:", default_value.x, panel, h_sizer, function ()
		cb(Vector3(ppx[1].value, ppx[2].value, ppx[3].value))
	end))
	table.insert(ppx, self:_create_axis_control(" Y:", default_value.y, panel, h_sizer, function ()
		cb(Vector3(ppx[1].value, ppx[2].value, ppx[3].value))
	end))
	table.insert(ppx, self:_create_axis_control(" Z:", default_value.z, panel, h_sizer, function ()
		cb(Vector3(ppx[1].value, ppx[2].value, ppx[3].value))
	end))

	return ppx
end

-- Lines 1273-1285
function InventoryIconCreator:_create_item_rotation(name, default_value, panel, sizer, cb)
	local h_sizer = EWS:BoxSizer("HORIZONTAL")

	sizer:add(h_sizer, 0, 0, "EXPAND")

	local text_ctrlr = EWS:StaticText(panel, name, 0, "ALIGN_LEFT")

	h_sizer:add(text_ctrlr, 0, 0, "ALIGN_LEFT")

	local rpx = {}

	table.insert(rpx, self:_create_axis_control(" Yaw:", 0, panel, h_sizer, function ()
		cb({
			rpx[1].value,
			rpx[2].value,
			rpx[3].value
		})
	end, 2))
	table.insert(rpx, self:_create_axis_control(" Pitch:", 0, panel, h_sizer, function ()
		cb({
			rpx[1].value,
			rpx[2].value,
			rpx[3].value
		})
	end, 2))
	table.insert(rpx, self:_create_axis_control(" Roll:", 0, panel, h_sizer, function ()
		cb({
			rpx[1].value,
			rpx[2].value,
			rpx[3].value
		})
	end, 2))

	return rpx
end

-- Lines 1291-1352
function InventoryIconCreator:_create_weapons_page(notebook)
	local panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	local btn_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "")

	panel_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local all_weapons_btn = EWS:Button(panel, "All (vanilla)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(all_weapons_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	all_weapons_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_weapons"), false)

	local all_weapons_skin_btn = EWS:Button(panel, "All (filter)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(all_weapons_skin_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	all_weapons_skin_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_weapons_skin"), false)

	local one_weapon_btn = EWS:Button(panel, "Selected", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(one_weapon_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	one_weapon_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_one_weapon"), true)

	local _btn = EWS:Button(panel, "Preview", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "preview_one_weapon"), true)

	local _btn = EWS:Button(panel, "Export", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "export_one_weapon"), false)

	local _btn = EWS:Button(panel, "Selected (all skins)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 5, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_weapon_skins"), true)

	local filtertext = EWS:StaticText(panel, "Filter:", 0, "ALIGN_LEFT")

	btn_sizer:add(filtertext, 0, 0, "ALIGN_CENTER")

	self._filter = EWS:TextCtrl(panel, "", "", "TE_LEFT")

	btn_sizer:add(self._filter, 10, 10, "ALIGN_CENTER")

	local comboboxes_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "")

	panel_sizer:add(comboboxes_sizer, 0, 0, "EXPAND")

	local weapon_ctrlr = self:_add_weapon_ctrlr(panel, comboboxes_sizer, "factory_id", self:_get_all_weapons())

	weapon_ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_add_weapon_mods"), {
		panel = panel,
		sizer = comboboxes_sizer
	})
	weapon_ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_update_weapon_skins"), nil)

	local weapon_qualities_ctrlr = self:_add_weapon_ctrlr(panel, comboboxes_sizer, "weapon_quality", self:_get_weapon_qualities())

	weapon_qualities_ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_set_weapon_quality"), {})

	local weapon_skins_ctrlr = self:_add_weapon_ctrlr(panel, comboboxes_sizer, "weapon_skin", self:_get_weapon_skins())

	weapon_skins_ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_set_weapon_skin"), {})

	local weapon_colors_ctrlr = self:_add_weapon_ctrlr(panel, comboboxes_sizer, "weapon_color", self:_get_weapon_colors())

	weapon_colors_ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_set_weapon_color"), {})

	local weapon_color_variations_ctrlr = self:_add_weapon_ctrlr(panel, comboboxes_sizer, "weapon_color_variation", self:_get_weapon_color_variations())

	weapon_color_variations_ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_set_weapon_color_variation"), {})

	local weapon_pattern_scales_ctrlr = self:_add_weapon_ctrlr(panel, comboboxes_sizer, "weapon_pattern_scale", self:_get_weapon_pattern_scales())

	weapon_pattern_scales_ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_set_weapon_pattern_scales"), {})
	self:_add_weapon_mods({
		panel = panel,
		sizer = comboboxes_sizer
	})

	return panel
end

-- Lines 1354-1410
function InventoryIconCreator:_add_weapon_mods(params)
	local panel = params.panel
	local sizer = params.sizer

	if alive(self._weapon_mods_panel) then
		self._weapon_mods_panel:destroy()

		self._weapon_mods_panel = nil
	end

	self._weapon_mods_panel = EWS:Panel(panel, "", "FULL_REPAINT_ON_RESIZE")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	self._weapon_mods_panel:set_sizer(panel_sizer)
	sizer:add(self._weapon_mods_panel, 0, 0, "EXPAND")

	local factory_id = self._ctrlrs.weapon.factory_id:get_value()
	local blueprint = managers.weapon_factory:get_default_blueprint_by_factory_id(factory_id)
	self._ctrlrs.weapon = {
		factory_id = self._ctrlrs.weapon.factory_id,
		weapon_skin = self._ctrlrs.weapon.weapon_skin,
		weapon_quality = self._ctrlrs.weapon.weapon_quality,
		weapon_color = self._ctrlrs.weapon.weapon_color,
		weapon_color_variation = self._ctrlrs.weapon.weapon_color_variation,
		weapon_pattern_scale = self._ctrlrs.weapon.weapon_pattern_scale
	}
	local parts = managers.weapon_factory:get_parts_from_factory_id(factory_id)
	local optional_types = tweak_data.weapon.factory[factory_id].optional_types or {}

	for type, options in pairs(parts) do
		local new_options = {}
		local default_part_id = managers.weapon_factory:get_part_id_from_weapon_by_type(type, blueprint)

		for _, part_id in ipairs(options) do
			local part_data = tweak_data.weapon.factory.parts[part_id]

			if part_data.pcs or part_data.pc then
				table.insert(new_options, part_id)
			end
		end

		if default_part_id then
			table.insert(new_options, 1, default_part_id)
		elseif #new_options > 0 then
			table.insert(new_options, 1, self.OPTIONAL)
		end

		if #new_options > 0 then
			self:_add_weapon_ctrlr(self._weapon_mods_panel, panel_sizer, type, new_options, default_part_id or self.OPTIONAL)
		end
	end

	self._weapon_mods_panel:parent():layout()
end

-- Lines 1412-1444
function InventoryIconCreator:_add_weapon_ctrlr(panel, sizer, name, options, value)
	local combobox_params = {
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "",
		sorted = false,
		ctrlr_proportions = 2,
		name = string.pretty(name, true) .. ":",
		panel = panel,
		sizer = sizer,
		options = options,
		value = value or options[1]
	}
	local ctrlr = CoreEws.combobox(combobox_params)
	self._ctrlrs.weapon[name] = ctrlr
	local text_ctrlr = EWS:StaticText(panel, "", 0, "ALIGN_RIGHT")

	sizer:add(text_ctrlr, 0, 0, "ALIGN_RIGHT")
	self:_update_weapon_combobox_text({
		no_layout = true,
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})
	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_update_weapon_combobox_text"), {
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})

	return ctrlr
end

-- Lines 1446-1473
function InventoryIconCreator:_update_weapon_combobox_text(param)
	local name = param.name
	local value = param.ctrlr:get_value()
	local text = nil

	if name == "factory_id" then
		text = managers.weapon_factory:get_weapon_name_by_factory_id(value)
	elseif name == "weapon_skin" or name == "weapon_color" then
		local name_id = tweak_data.blackmarket.weapon_skins[value] and tweak_data.blackmarket.weapon_skins[value].name_id or "none"
		text = managers.localization:text(name_id)
	elseif name == "weapon_quality" then
		local name_id = tweak_data.economy.qualities[value] and tweak_data.economy.qualities[value].name_id or "none"
		text = managers.localization:text(name_id)
	elseif name == "weapon_color_variation" then
		local name_id = tweak_data.blackmarket:get_weapon_color_index_string(value) or "none"
		text = managers.localization:text(name_id)
	elseif name == "weapon_pattern_scale" then
		local name_id = tweak_data.blackmarket.weapon_color_pattern_scales[tonumber(value)] and tweak_data.blackmarket.weapon_color_pattern_scales[tonumber(value)].name_id or "none"
		text = managers.localization:text(name_id)
	else
		text = value == self.OPTIONAL and self.OPTIONAL or managers.weapon_factory:get_part_name_by_part_id(value)
	end

	param.text_ctrlr:set_value(text)

	if not param.no_layout then
		param.text_ctrlr:parent():layout()
	end
end

-- Lines 1475-1478
function InventoryIconCreator:_set_weapon_skin()
	local weapon_color = self._ctrlrs.weapon.weapon_color

	weapon_color:set_value("none")
end

-- Lines 1480-1490
function InventoryIconCreator:_update_weapon_skins()
	local weapon_skin = self._ctrlrs.weapon.weapon_skin

	weapon_skin:clear()

	for _, name in ipairs(self:_get_weapon_skins()) do
		weapon_skin:append(name)
	end

	weapon_skin:set_value("none")
end

-- Lines 1493-1496
function InventoryIconCreator:_set_weapon_color()
	local weapon_skin = self._ctrlrs.weapon.weapon_skin

	weapon_skin:set_value("none")
end

-- Lines 1498-1499
function InventoryIconCreator:_set_weapon_color_variation()
end

-- Lines 1501-1502
function InventoryIconCreator:_set_weapon_quality()
end

-- Lines 1504-1505
function InventoryIconCreator:_set_weapon_pattern_scales()
end

-- Lines 1509-1555
function InventoryIconCreator:_create_masks_page(notebook)
	local panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	local btn_sizer = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local _btn = EWS:Button(panel, "All (vanilla)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_masks"), false)

	local _btn = EWS:Button(panel, "All (blueprint)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_masks"), true)

	local btn_sizer2 = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(btn_sizer2, 0, 0, "EXPAND")

	local _btn = EWS:Button(panel, "Selected (vanilla)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer2:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_one_mask"), false)

	local _btn = EWS:Button(panel, "Selected (blueprint)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer2:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_one_mask"), true)

	local btn_sizer3 = EWS:BoxSizer("HORIZONTAL")

	panel_sizer:add(btn_sizer3, 0, 0, "EXPAND")

	local _btn = EWS:Button(panel, "Preview (vanilla)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer3:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "preview_one_mask"), false)

	local _btn = EWS:Button(panel, "Preview (blueprint)", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer3:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "preview_one_mask"), true)

	local comboboxes_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "")

	panel_sizer:add(comboboxes_sizer, 0, 0, "EXPAND")

	local mask_ctrlr = self:_add_mask_ctrlr(panel, comboboxes_sizer, "mask_id", self:_get_all_masks())

	self:_add_mask_ctrlr(panel, comboboxes_sizer, "color", table.map_keys(tweak_data.blackmarket.colors), "nothing")
	self:_add_mask_ctrlr(panel, comboboxes_sizer, "material", table.map_keys(tweak_data.blackmarket.materials), "plastic")
	self:_add_mask_ctrlr(panel, comboboxes_sizer, "pattern", table.map_keys(tweak_data.blackmarket.textures), "no_color_no_material")

	return panel
end

-- Lines 1557-1587
function InventoryIconCreator:_add_mask_ctrlr(panel, sizer, name, options, value)
	local combobox_params = {
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "",
		sorted = false,
		ctrlr_proportions = 2,
		name = string.pretty(name, true) .. ":",
		panel = panel,
		sizer = sizer,
		options = options,
		value = value or options[1]
	}
	local ctrlr = CoreEws.combobox(combobox_params)
	self._ctrlrs.mask[name] = ctrlr
	local text_ctrlr = EWS:StaticText(panel, "", 0, "ALIGN_RIGHT")

	sizer:add(text_ctrlr, 0, 0, "ALIGN_RIGHT")
	self:_update_mask_combobox_text({
		no_layout = true,
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})
	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_update_mask_combobox_text"), {
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})

	return ctrlr
end

-- Lines 1589-1608
function InventoryIconCreator:_update_mask_combobox_text(params)
	local name = params.name
	local value = params.ctrlr:get_value()
	local text = nil

	if name == "mask_id" then
		text = managers.localization:text(tweak_data.blackmarket.masks[value].name_id)
	elseif name == "color" then
		text = managers.localization:text(tweak_data.blackmarket.colors[value].name_id)
	elseif name == "material" then
		text = managers.localization:text(tweak_data.blackmarket.materials[value].name_id)
	elseif name == "pattern" then
		text = managers.localization:text(tweak_data.blackmarket.textures[value].name_id)
	end

	params.text_ctrlr:set_value(text)

	if not params.no_layout then
		params.text_ctrlr:parent():layout()
	end
end

-- Lines 1612-1637
function InventoryIconCreator:_create_melee_page(notebook)
	local panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	local btn_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "")

	panel_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local _btn = EWS:Button(panel, "All", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_melee"), false)

	local _btn = EWS:Button(panel, "Selected", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_one_melee"), false)

	local _btn = EWS:Button(panel, "Preview", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "preview_one_melee"), false)

	local comboboxes_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "")

	panel_sizer:add(comboboxes_sizer, 0, 0, "EXPAND")

	local melee_ctrlr = self:_add_melee_ctrlr(panel, comboboxes_sizer, "melee_id", self:_get_all_melee())

	return panel
end

-- Lines 1639-1669
function InventoryIconCreator:_add_melee_ctrlr(panel, sizer, name, options, value)
	local combobox_params = {
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "",
		sorted = false,
		ctrlr_proportions = 2,
		name = string.pretty(name, true) .. ":",
		panel = panel,
		sizer = sizer,
		options = options,
		value = value or options[1]
	}
	local ctrlr = CoreEws.combobox(combobox_params)
	self._ctrlrs.melee[name] = ctrlr
	local text_ctrlr = EWS:StaticText(panel, "", 0, "ALIGN_RIGHT")

	sizer:add(text_ctrlr, 0, 0, "ALIGN_RIGHT")
	self:_update_melee_combobox_text({
		no_layout = true,
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})
	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_update_melee_combobox_text"), {
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})

	return ctrlr
end

-- Lines 1671-1684
function InventoryIconCreator:_update_melee_combobox_text(params)
	local name = params.name
	local value = params.ctrlr:get_value()
	local text = nil

	if name == "melee_id" then
		text = managers.localization:text(tweak_data.blackmarket.melee_weapons[value].name_id)
	end

	params.text_ctrlr:set_value(text)

	if not params.no_layout then
		params.text_ctrlr:parent():layout()
	end
end

-- Lines 1688-1713
function InventoryIconCreator:_create_throwable_page(notebook)
	local panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	local btn_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "")

	panel_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local _btn = EWS:Button(panel, "All", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_throwable"), false)

	local _btn = EWS:Button(panel, "Selected", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_one_throwable"), false)

	local _btn = EWS:Button(panel, "Preview", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "preview_one_throwable"), false)

	local comboboxes_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "")

	panel_sizer:add(comboboxes_sizer, 0, 0, "EXPAND")

	local throwable_ctrlr = self:_add_throwable_ctrlr(panel, comboboxes_sizer, "throwable_id", self:_get_all_throwable())

	return panel
end

-- Lines 1716-1746
function InventoryIconCreator:_add_throwable_ctrlr(panel, sizer, name, options, value)
	local combobox_params = {
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "",
		sorted = false,
		ctrlr_proportions = 2,
		name = string.pretty(name, true) .. ":",
		panel = panel,
		sizer = sizer,
		options = options,
		value = value or options[1]
	}
	local ctrlr = CoreEws.combobox(combobox_params)
	self._ctrlrs.throwable[name] = ctrlr
	local text_ctrlr = EWS:StaticText(panel, "", 0, "ALIGN_RIGHT")

	sizer:add(text_ctrlr, 0, 0, "ALIGN_RIGHT")
	self:_update_throwable_combobox_text({
		no_layout = true,
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})
	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_update_throwable_combobox_text"), {
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})

	return ctrlr
end

-- Lines 1748-1762
function InventoryIconCreator:_update_throwable_combobox_text(params)
	local name = params.name
	local value = params.ctrlr:get_value()
	local text = nil

	if name == "throwable_id" then
		print(value, tweak_data.blackmarket.projectiles[value].name_id)

		text = managers.localization:text(tweak_data.blackmarket.projectiles[value].name_id or "N/A")
	end

	params.text_ctrlr:set_value(text)

	if not params.no_layout then
		params.text_ctrlr:parent():layout()
	end
end

-- Lines 1765-1791
function InventoryIconCreator:_create_character_page(notebook)
	local panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	local btn_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "")

	panel_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local _btn = EWS:Button(panel, "All", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_character"), false)

	local _btn = EWS:Button(panel, "Selected", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_one_character"), false)

	local _btn = EWS:Button(panel, "Preview", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "preview_one_character"), false)

	local comboboxes_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "")

	panel_sizer:add(comboboxes_sizer, 0, 0, "EXPAND")
	self:_add_character_ctrlr(panel, comboboxes_sizer, "character_id", self:_get_all_characters())
	self:_add_character_ctrlr(panel, comboboxes_sizer, "anim_pose", self:_get_all_anim_poses())

	return panel
end

-- Lines 1793-1817
function InventoryIconCreator:_add_character_ctrlr(panel, sizer, name, options, value)
	local combobox_params = {
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "",
		sorted = false,
		ctrlr_proportions = 2,
		name = string.pretty(name, true) .. ":",
		panel = panel,
		sizer = sizer,
		options = options,
		value = value or options[1]
	}
	local ctrlr = CoreEws.combobox(combobox_params)
	self._ctrlrs.character[name] = ctrlr
	local text_ctrlr = EWS:StaticText(panel, "", 0, "ALIGN_RIGHT")

	sizer:add(text_ctrlr, 0, 0, "ALIGN_RIGHT")
	self:_update_character_combobox_text({
		no_layout = true,
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})
	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_update_character_combobox_text"), {
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})

	return ctrlr
end

-- Lines 1819-1836
function InventoryIconCreator:_update_character_combobox_text(params)
	local name = params.name
	local value = params.ctrlr:get_value()
	local text = nil

	if name == "character_id" then
		text = managers.blackmarket:_character_tweak_data_by_name(value).name_id
		text = text and managers.localization:text(text) or "N/A"
	elseif name == "anim_pose" then
		text = value
	end

	params.text_ctrlr:set_value(text)

	if not params.no_layout then
		params.text_ctrlr:parent():layout()
	end
end

-- Lines 1839-1868
function InventoryIconCreator:_create_player_style_page(notebook)
	local panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	local btn_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "")

	panel_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local _btn = EWS:Button(panel, "All", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_player_style"), false)

	local _btn = EWS:Button(panel, "Selected", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_one_player_style"), false)

	local _btn = EWS:Button(panel, "Preview", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "preview_one_player_style"), false)

	local comboboxes_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "")

	panel_sizer:add(comboboxes_sizer, 0, 0, "EXPAND")

	local player_styles = self:_get_all_player_style()

	self:_add_player_style_ctrlr(panel, comboboxes_sizer, "player_style", player_styles)
	self:_add_player_style_ctrlr(panel, comboboxes_sizer, "material_variation", self._get_all_suit_variations(player_styles[1]))
	self:_add_player_style_ctrlr(panel, comboboxes_sizer, "character_id", self:_get_all_characters())
	self:_add_player_style_ctrlr(panel, comboboxes_sizer, "anim_pose", self:_get_all_anim_poses(), "generic_stance")

	return panel
end

-- Lines 1870-1894
function InventoryIconCreator:_add_player_style_ctrlr(panel, sizer, name, options, value)
	local combobox_params = {
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "",
		sorted = false,
		ctrlr_proportions = 2,
		name = string.pretty(name, true) .. ":",
		panel = panel,
		sizer = sizer,
		options = options,
		value = value or options[1]
	}
	local ctrlr = CoreEws.combobox(combobox_params)
	self._ctrlrs.player_style[name] = ctrlr
	local text_ctrlr = EWS:StaticText(panel, "", 0, "ALIGN_RIGHT")

	sizer:add(text_ctrlr, 0, 0, "ALIGN_RIGHT")
	self:_update_player_style_combobox_text({
		no_layout = true,
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})
	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_update_player_style_combobox_text"), {
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})

	return ctrlr
end

-- Lines 1896-1938
function InventoryIconCreator:_update_player_style_combobox_text(params)
	local name = params.name
	local value = params.ctrlr:get_value()
	local text = nil

	if name == "player_style" then
		local character_ctrlr = self._ctrlrs.player_style.character_id
		local character_id = character_ctrlr and character_ctrlr:get_value() or "dallas"
		local name_id = tweak_data.blackmarket:get_player_style_value(value, character_id, "name_id")
		text = name_id and managers.localization:text(name_id) or "N/A"
		local material_variation_ctrlr = self._ctrlrs.player_style.material_variation

		if material_variation_ctrlr then
			material_variation_ctrlr:clear()

			local suit_variations = self:_get_all_suit_variations(value)

			for _, option in ipairs(suit_variations) do
				material_variation_ctrlr:append(option)
			end

			material_variation_ctrlr:set_value(suit_variations[1])
			material_variation_ctrlr:parent():layout()
		end
	elseif name == "material_variation" then
		local character_ctrlr = self._ctrlrs.player_style.character_id
		local character_id = character_ctrlr and character_ctrlr:get_value() or "dallas"
		local player_style_ctrlr = self._ctrlrs.player_style.player_style
		local player_style = player_style_ctrlr and player_style_ctrlr:get_value() or "none"
		local name_id = tweak_data.blackmarket:get_suit_variation_value(player_style, value, character_id, "name_id")
		text = name_id and managers.localization:text(name_id) or "N/A"
	else
		return self:_update_character_combobox_text(params)
	end

	params.text_ctrlr:set_value(text)

	if not params.no_layout then
		params.text_ctrlr:parent():layout()
	end
end

-- Lines 1941-1968
function InventoryIconCreator:_create_gloves_page(notebook)
	local panel = EWS:Panel(notebook, "", "TAB_TRAVERSAL")
	local panel_sizer = EWS:BoxSizer("VERTICAL")

	panel:set_sizer(panel_sizer)

	local btn_sizer = EWS:StaticBoxSizer(panel, "HORIZONTAL", "")

	panel_sizer:add(btn_sizer, 0, 0, "EXPAND")

	local _btn = EWS:Button(panel, "All", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_all_gloves"), false)

	local _btn = EWS:Button(panel, "Selected", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "start_one_gloves"), false)

	local _btn = EWS:Button(panel, "Preview", "", "BU_EXACTFIT,NO_BORDER")

	btn_sizer:add(_btn, 0, 1, "RIGHT,TOP,BOTTOM")
	_btn:connect("EVT_COMMAND_BUTTON_CLICKED", callback(self, self, "preview_one_gloves"), false)

	local comboboxes_sizer = EWS:StaticBoxSizer(panel, "VERTICAL", "")

	panel_sizer:add(comboboxes_sizer, 0, 0, "EXPAND")
	self:_add_gloves_ctrlr(panel, comboboxes_sizer, "glove_id", self:_get_all_gloves())
	self:_add_gloves_ctrlr(panel, comboboxes_sizer, "character_id", self:_get_all_characters())
	self:_add_gloves_ctrlr(panel, comboboxes_sizer, "anim_pose", self:_get_all_anim_poses(), "gloves")

	return panel
end

-- Lines 1970-1994
function InventoryIconCreator:_add_gloves_ctrlr(panel, sizer, name, options, value)
	local combobox_params = {
		sizer_proportions = 1,
		name_proportions = 1,
		tooltip = "",
		sorted = false,
		ctrlr_proportions = 2,
		name = string.pretty(name, true) .. ":",
		panel = panel,
		sizer = sizer,
		options = options,
		value = value or options[1]
	}
	local ctrlr = CoreEws.combobox(combobox_params)
	self._ctrlrs.gloves[name] = ctrlr
	local text_ctrlr = EWS:StaticText(panel, "", 0, "ALIGN_RIGHT")

	sizer:add(text_ctrlr, 0, 0, "ALIGN_RIGHT")
	self:_update_gloves_combobox_text({
		no_layout = true,
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})
	ctrlr:connect("EVT_COMMAND_COMBOBOX_SELECTED", callback(self, self, "_update_gloves_combobox_text"), {
		name = name,
		ctrlr = ctrlr,
		text_ctrlr = text_ctrlr
	})

	return ctrlr
end

-- Lines 1996-2016
function InventoryIconCreator:_update_gloves_combobox_text(params)
	local name = params.name
	local value = params.ctrlr:get_value()
	local text = nil

	if name == "glove_id" then
		local character_ctrlr = self._ctrlrs.gloves.character_id
		local character_id = character_ctrlr and character_ctrlr:get_value() or "dallas"
		local name_id = tweak_data.blackmarket:get_glove_value(value, character_id, "name_id", "none", "default")
		text = name_id and managers.localization:text(name_id) or "N/A"
	else
		return self:_update_character_combobox_text(params)
	end

	params.text_ctrlr:set_value(text)

	if not params.no_layout then
		params.text_ctrlr:parent():layout()
	end
end

-- Lines 2020-2030
function InventoryIconCreator:close_ews()
	if alive(self._weapon_mods_panel) then
		self._weapon_mods_panel:destroy()

		self._weapon_mods_panel = nil
	end

	if self._main_frame then
		self._main_frame:destroy()

		self._main_frame = nil
	end
end
