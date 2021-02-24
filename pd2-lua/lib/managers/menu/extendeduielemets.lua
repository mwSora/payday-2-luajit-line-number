require("lib/managers/menu/ExtendedPanel")
require("lib/managers/menu/UiPlacer")
require("lib/managers/menu/ScrollablePanel")

local massive_font = tweak_data.menu.pd2_massive_font
local large_font = tweak_data.menu.pd2_large_font
local medium_font = tweak_data.menu.pd2_medium_font
local small_font = tweak_data.menu.pd2_small_font
local tiny_font = tweak_data.menu.pd2_tiny_font
local massive_font_size = tweak_data.menu.pd2_massive_font_size
local large_font_size = tweak_data.menu.pd2_large_font_size
local medium_font_size = tweak_data.menu.pd2_medium_font_size
local small_font_size = tweak_data.menu.pd2_small_font_size
local tiny_font_size = tweak_data.menu.pd2_tiny_font_size

-- Lines 21-29
local function set_defaults(target, source)
	target = target or {}

	for k, v in pairs(source) do
		if target[k] == nil then
			target[k] = v
		end
	end

	return target
end

GrowPanel = GrowPanel or class(ExtendedPanel)

-- Lines 46-60
function GrowPanel:init(parent, config)
	config = config or {}

	GrowPanel.super.init(self, parent, config)

	self._fixed_w = config.fixed_w and (config.fixed_w ~= true and config.fixed_w or config.w or parent:w())
	self._fixed_h = config.fixed_h and (config.fixed_h ~= true and config.fixed_h or config.h or parent:h())

	self:set_size(self._fixed_w or config.w or 0, self._fixed_h or config.h or 0)

	local padd_x = config.padding_x or config.padding or 0
	local padd_y = config.padding_y or config.padding or 0
	local bord_x = config.border_x or config.border or padd_x
	local bord_y = config.border_y or config.border or padd_y
	self._placer = ResizingPlacer:new(self, {
		border_x = bord_x,
		border_y = bord_y,
		padding_x = padd_x,
		padding_y = padd_y
	})
end

-- Lines 62-66
function GrowPanel:clear()
	GrowPanel.super.clear(self)
	self._placer:clear()
	self:_set_ensure_size(self._fixed_w or 0, self._fixed_h or 0)
end

-- Lines 68-70
function GrowPanel:placer()
	return self._placer
end

-- Lines 72-75
function GrowPanel:set_fixed_w(w)
	self._fixed_w = w

	self:set_w(w)
end

-- Lines 77-80
function GrowPanel:set_fixed_h(h)
	self._fixed_h = h

	self:set_h(h)
end

-- Lines 82-86
function GrowPanel:_ensure_size(w, h)
	w = math.max(self._fixed_w or w, self:w())
	h = math.max(self._fixed_h or h, self:h())

	self:_set_ensure_size(w, h)
end

-- Lines 88-90
function GrowPanel:_set_ensure_size(w, h)
	self:set_size(w, h)
end

-- Lines 93-95
function GrowPanel:row_w()
	return self:w() - self._placer._border_padding_x * 2
end

ScrollGrowPanel = ScrollGrowPanel or class(GrowPanel)

-- Lines 101-105
function ScrollGrowPanel:init(scroll, config)
	config = set_defaults(config, {
		use_given = true
	})

	ScrollGrowPanel.super.init(self, scroll:canvas(), config)

	self._scroll = scroll
end

-- Lines 107-111
function ScrollGrowPanel:clear()
	self._scroll:set_canvas_size(0, 0)
	ScrollGrowPanel.super.clear(self)
end

-- Lines 113-115
function ScrollGrowPanel:_set_ensure_size(w, h)
	self._scroll:set_canvas_size(w, h)
end

local ScrollablePanelExt = ScrollablePanelExt or class(ScrollablePanel)

-- Lines 123-127
function ScrollablePanelExt:init(parent_panel, name, data)
	self._scroll_padding = data and data.scrollbar_padding

	ScrollablePanelExt.super.init(self, parent_panel, name, data)
end

-- Lines 129-131
function ScrollablePanelExt:scrollbar_padding()
	return self._scroll_padding or ScrollablePanelExt.super.scrollbar_padding(self)
end

-- Lines 133-138
function ScrollablePanelExt:set_canvas_size(w, h)
	ScrollablePanelExt.super.set_canvas_size(self, w, h)

	if self.on_canvas_resized then
		self:on_canvas_resized()
	end
end

ScrollableList = ScrollableList or class(ExtendedPanel)

-- Lines 144-187
function ScrollableList:init(parent, scroll_config, canvas_config)
	scroll_config = set_defaults(scroll_config, {
		ignore_up_indicator = true,
		padding = 0,
		ignore_down_indicator = true,
		layer = parent:layer()
	})

	if scroll_config.horizontal then
		self._scroll = HorizontalScrollablePanel:new(parent, nil, scroll_config)
	else
		self._scroll = ScrollablePanelExt:new(parent, nil, scroll_config)
	end

	scroll_config.use_given = true
	local add_as_input = scroll_config.input
	scroll_config.input = nil

	ScrollableList.super.init(self, self._scroll:panel(), scroll_config)

	local scrollbar_padding = scroll_config.scrollbar_padding or scroll_config.padding or self._scroll:padding()
	canvas_config = canvas_config or {}
	local add_canvas = canvas_config.input or add_as_input
	canvas_config.input = nil

	if not scroll_config.horizontal then
		canvas_config.fixed_w = self._scroll._scroll_bar:left() - scrollbar_padding
	else
		canvas_config.fixed_h = self._scroll._scroll_bar:top() - scrollbar_padding
	end

	self._canvas = ScrollGrowPanel:new(self._scroll, canvas_config)

	self._scroll:set_canvas_size(canvas_config.w or canvas_config.fixed_w, canvas_config.h or canvas_config.fixed_h or 0)

	if add_canvas then
		self:add_input_component(self._canvas)
	end

	if add_as_input then
		if parent.add_input_component then
			parent:add_input_component(self)
		else
			error("Trying to add as input component on parent that doesn't have a add_input_component function")
		end
	end
end

-- Lines 189-194
function ScrollableList:resize(w, h)
	w = w or self:w()
	h = h or self:h()

	self._scroll:set_size(w, h)
end

-- Lines 196-201
function ScrollableList:resize_canvas(w, h)
	w = w or self._canvas:w()
	h = h or self._canvas:h()

	self._canvas:_set_ensure_size(w, h)
end

-- Lines 203-206
function ScrollableList:clear()
	self._canvas:clear()
end

-- Lines 208-220
function ScrollableList:mouse_moved(button, x, y)
	local h, c = self._scroll:mouse_moved(button, x, y)

	if not self._scroll:panel():inside(x, y) then
		return h, c
	end

	local hover, cursor = ScrollableList.super.mouse_moved(self, button, x, y)
	hover = hover or h
	cursor = cursor or c

	return hover, cursor
end

-- Lines 222-227
function ScrollableList:mouse_clicked(o, button, x, y)
	self._scroll:mouse_clicked(o, button, x, y)

	if not self._scroll:panel():inside(x, y) then
		return
	end

	return ScrollableList.super.mouse_clicked(self, o, button, x, y)
end

-- Lines 229-234
function ScrollableList:mouse_pressed(button, x, y)
	self._scroll:mouse_pressed(button, x, y)

	if not self._scroll:panel():inside(x, y) then
		return
	end

	return ScrollableList.super.mouse_pressed(self, button, x, y)
end

-- Lines 236-241
function ScrollableList:mouse_released(button, x, y)
	self._scroll:mouse_released(button, x, y)

	if not self._scroll:panel():inside(x, y) then
		return
	end

	return ScrollableList.super.mouse_released(self, button, x, y)
end

-- Lines 243-248
function ScrollableList:mouse_wheel_up(x, y)
	self._scroll:scroll(x, y, 1)

	if not self._scroll:panel():inside(x, y) then
		return
	end

	return ScrollableList.super.mouse_wheel_up(self, x, y)
end

-- Lines 250-255
function ScrollableList:mouse_wheel_down(x, y)
	self._scroll:scroll(x, y, -1)

	if not self._scroll:panel():inside(x, y) then
		return
	end

	return ScrollableList.super.mouse_wheel_down(self, x, y)
end

-- Lines 257-259
function ScrollableList:canvas()
	return self._canvas
end

-- Lines 261-263
function ScrollableList:scroll_item()
	return self._scroll
end

-- Lines 265-267
function ScrollableList:perform_scroll(val)
	self._scroll:perform_scroll(val, 1)
end

-- Lines 269-287
function ScrollableList:scroll_to_show(top_or_item, bottom)
	local top = nil

	if type(top_or_item) == "table" and top_or_item.top and top_or_item.bottom then
		top = top_or_item:top()
		bottom = top_or_item:bottom()
	else
		top = top_or_item
		bottom = bottom or top_or_item
	end

	local cur = -self._canvas:y()

	if top then
		if top < cur then
			self._scroll:scroll_to(top)
		elseif bottom > cur + self._scroll:scroll_panel():h() then
			self._scroll:scroll_to(bottom - self._scroll:scroll_panel():h())
		end
	end
end

-- Lines 289-291
function ScrollableList:scroll_to_show_item_at_world(item, world_y)
	self._scroll:perform_scroll(world_y - item:world_y(), 1)
end

-- Lines 295-310
function ScrollableList:add_lines_and_static_down_indicator()
	local box = BoxGuiObject:new(self:scroll_item():scroll_panel(), {
		w = self:canvas():w(),
		sides = {
			1,
			1,
			2,
			0
		}
	})
	local down_no_scroll = BoxGuiObject:new(box._panel, {
		sides = {
			0,
			0,
			0,
			1
		}
	})
	local down_scroll = BoxGuiObject:new(box._panel, {
		sides = {
			0,
			0,
			0,
			2
		}
	})

	-- Lines 302-306
	local function update_down_indicator()
		local indicate = self:scroll_item()._scroll_bar:visible()

		down_no_scroll:set_visible(not indicate)
		down_scroll:set_visible(indicate)
	end

	update_down_indicator()

	self._scroll.on_canvas_resized = update_down_indicator
end

ScrollItemList = ScrollItemList or class(ScrollableList)

-- Lines 316-323
function ScrollItemList:init(parent, scroll_config, canvas_config)
	ScrollItemList.super.init(self, parent, scroll_config, canvas_config)

	self._input_focus = scroll_config.input_focus
	self._all_items = {}
	self._current_items = {}
end

-- Lines 325-330
function ScrollItemList:clear()
	self._all_items = {}
	self._current_items = {}
	self._selected_item = nil

	ScrollItemList.super.clear(self)
end

-- Lines 332-334
function ScrollItemList:all_items()
	return self._all_items
end

-- Lines 336-338
function ScrollItemList:items()
	return self._current_items
end

-- Lines 340-342
function ScrollItemList:set_input_focus(state)
	self._input_focus = state
end

-- Lines 345-347
function ScrollItemList:input_focus()
	return self:allow_input() and self._input_focus
end

-- Lines 349-362
function ScrollItemList:mouse_moved(button, x, y)
	if not self._scroll:panel():inside(x, y) then
		return
	end

	for k, v in pairs(self._current_items) do
		if v:inside(x, y) then
			if self._selected_item ~= v then
				self:select_item(v)
			end

			break
		end
	end

	return ScrollItemList.super.mouse_moved(self, button, x, y)
end

-- Lines 364-368
function ScrollItemList:_on_selected_changed(selected)
	if self._on_selected_callback then
		self._on_selected_callback(selected)
	end
end

-- Lines 370-372
function ScrollItemList:set_selected_callback(func)
	self._on_selected_callback = func
end

-- Lines 374-376
function ScrollItemList:selected_item()
	return self._selected_item
end

-- Lines 378-380
function ScrollItemList:select_index(index)
	self:select_item(self._current_items[index])
end

-- Lines 382-395
function ScrollItemList:move_selection(move)
	if not self._selected_item then
		self:select_index(1)
	else
		local index = table.index_of(self._current_items, self._selected_item)
		local new_index = index + move
		new_index = math.clamp(new_index, 1, #self._current_items)

		self:select_index(new_index)
	end

	if self._selected_item then
		self:scroll_to_show(self._selected_item)
	end
end

-- Lines 397-412
function ScrollItemList:select_item(item)
	if item == self._selected_item then
		return
	end

	if self._selected_item then
		self._selected_item:set_selected(false)

		self._selected_item = nil
	end

	if item then
		self._selected_item = item

		item:set_selected(true)
	end

	self:_on_selected_changed(item)
end

-- Lines 414-426
function ScrollItemList:add_item(item, force_visible)
	if force_visible ~= nil then
		item:set_visible(force_visible)
	end

	if item:visible() then
		self._canvas:placer():add_row(item)
		table.insert(self._current_items, item)
	end

	table.insert(self._all_items, item)

	return item
end

-- Lines 428-432
function ScrollItemList:move_up()
	if not self:input_focus() then
		return
	end

	self:move_selection(-1)

	return true
end

-- Lines 434-438
function ScrollItemList:move_down()
	if not self:input_focus() then
		return
	end

	self:move_selection(1)

	return true
end

-- Lines 441-461
function ScrollItemList:sort_items(sort_function, mod_placer, keep_selection)
	table.sort(self._current_items, sort_function)
	table.sort(self._all_items, sort_function)

	local placer = self._canvas:placer()

	placer:clear()

	if mod_placer then
		mod_placer(placer)
	end

	local w_y = self._selected_item and self._selected_item:world_y()

	for _, item in ipairs(self._current_items) do
		placer:add_row(item)
	end

	if not keep_selection and self._selected_item then
		self:select_index(1)
	elseif self._selected_item and w_y then
		self:scroll_to_show_item_at_world(self._selected_item, w_y)
	end
end

-- Lines 464-488
function ScrollItemList:filter_items(filter_function, mod_start, keep_selection)
	local placer = self._canvas:placer()

	placer:clear()
	self._canvas:set_size(0, 0)

	if mod_start then
		mod_start(placer, self._canvas)
	end

	local w_y = self._selected_item and self._selected_item:world_y()
	self._current_items = {}

	for _, item in ipairs(self._all_items) do
		if filter_function(item) then
			item:set_visible(true)
			placer:add_row(item)
			table.insert(self._current_items, item)
		else
			item:set_visible(false)
		end
	end

	if self._selected_item and not self._selected_item:visible() or not keep_selection then
		self:select_index(1)
	elseif self._selected_item and w_y then
		self:scroll_to_show_item_at_world(self._selected_item, w_y)
	end
end

HorizontalScrollItemList = HorizontalScrollItemList or class(ScrollItemList)

-- Lines 494-497
function HorizontalScrollItemList:init(parent, scroll_config, canvas_config)
	HorizontalScrollItemList.super.init(self, parent, scroll_config, canvas_config)
end

-- Lines 499-511
function HorizontalScrollItemList:add_item(item, force_visible)
	if force_visible ~= nil then
		item:set_visible(force_visible)
	end

	if item:visible() then
		self._canvas:placer():add_right(item)
		table.insert(self._current_items, item)
	end

	table.insert(self._all_items, item)

	return item
end

-- Lines 513-528
function HorizontalScrollItemList:add_lines_and_static_down_indicator()
	local box = BoxGuiObject:new(self:scroll_item():scroll_panel(), {
		layer = 5,
		h = self:canvas():h(),
		sides = {
			2,
			2,
			1,
			1
		}
	})
end

-- Lines 530-548
function HorizontalScrollItemList:scroll_to_show(left_or_item, right)
	local left = nil

	if type(left_or_item) == "table" and left_or_item.left and left_or_item.right then
		left = left_or_item:left()
		right = left_or_item:right()
	else
		left = left_or_item
		right = right or left_or_item
	end

	local cur = -self._canvas:x()

	if left then
		if left < cur then
			self._scroll:scroll_to(left)
		elseif right > cur + self._scroll:scroll_panel():w() then
			self._scroll:scroll_to(right - self._scroll:scroll_panel():w())
		end
	end
end

-- Lines 550-552
function HorizontalScrollItemList:scroll_to_show_item_at_world(item, world_x)
	self._scroll:perform_scroll(world_x - item:world_x(), 1)
end

-- Lines 555-575
function HorizontalScrollItemList:sort_items(sort_function, mod_placer, keep_selection)
	table.sort(self._current_items, sort_function)
	table.sort(self._all_items, sort_function)

	local placer = self._canvas:placer()

	placer:clear()

	if mod_placer then
		mod_placer(placer)
	end

	local w_x = self._selected_item and self._selected_item:world_x()

	for _, item in ipairs(self._current_items) do
		placer:add_right(item)
	end

	if not keep_selection and self._selected_item then
		self:select_index(1)
	elseif self._selected_item and w_x then
		self:scroll_to_show_item_at_world(self._selected_item, w_x)
	end
end

ListItem = ListItem or class(ExtendedPanel)

-- Lines 581-583
function ListItem:init(...)
	ListItem.super.init(self, ...)
end

-- Lines 585-589
function ListItem:_selected_changed(state)
	if self._select_panel then
		self._select_panel:set_visible(state)
	end
end

-- Lines 591-599
function ListItem:set_selected(state)
	if self._selected == state then
		return
	end

	self._selected = state

	self:_selected_changed(state)

	local _ = state and managers.menu_component:post_event("highlight")
end

BaseButton = BaseButton or class(ExtendedPanel)

-- Lines 609-616
function BaseButton:init(parent, config)
	config = set_defaults(config, {
		input = true
	})

	BaseButton.super.init(self, parent, config)

	self._binding = config.binding and Idstring(config.binding)
	self._enabled = config.enabled == nil and true or config.enabled
	self._hover = false
end

-- Lines 618-625
function BaseButton:set_enabled(state)
	if self._enabled == state then
		return
	end

	self._enabled = state

	self:_enabled_changed(state)
end

-- Lines 627-628
function BaseButton:_enabled_changed(state)
end

-- Lines 630-631
function BaseButton:_hover_changed(state)
end

-- Lines 633-634
function BaseButton:_trigger()
end

-- Lines 636-638
function BaseButton:allow_input()
	return self._enabled and BaseButton.super.allow_input(self)
end

-- Lines 640-651
function BaseButton:mouse_moved(o, x, y)
	local hover = self:inside(x, y)

	if self._hover ~= hover then
		self._hover = hover

		self:_hover_changed(hover)
	end

	if hover then
		return true, "link"
	end
end

-- Lines 653-658
function BaseButton:mouse_clicked(o, button, x, y)
	if button == Idstring("0") and self:inside(x, y) then
		self:_trigger()

		return true
	end
end

-- Lines 660-665
function BaseButton:special_btn_pressed(button)
	if button == self._binding then
		self:_trigger()

		return true
	end
end

TextButton = TextButton or class(BaseButton)

-- Lines 679-703
function TextButton:init(parent, text_config, func, panel_config)
	panel_config = set_defaults(panel_config, {
		binding = text_config.binding
	})

	TextButton.super.init(self, parent, panel_config)

	self._normal_color = text_config.normal_color or text_config.color or tweak_data.screen_colors.button_stage_3
	self._hover_color = text_config.hover_color or text_config.color or tweak_data.screen_colors.button_stage_2
	self._disabled_color = text_config.disabled_color or tweak_data.menu.default_disabled_text_color
	text_config.color = self._normal_color

	if text_config.text_id and text_config.binding then
		text_config.text = managers.localization:text(text_config.text_id, {
			MY_BTN = managers.localization:btn_macro(text_config.binding, true)
		})
		text_config.text_id = nil
	end

	self._text = self:fine_text(text_config)
	self._trigger = func or function ()
	end
	self._is_fixed = panel_config.fixed_size

	if not panel_config.fixed_size then
		self._panel:set_size(self._text:rightbottom())
	end

	self:_enabled_changed(self._enabled)
end

-- Lines 705-707
function TextButton:_enabled_changed(state)
	self._text:set_color(state and self._normal_color or self._disabled_color)
end

-- Lines 709-714
function TextButton:_hover_changed(hover)
	self._text:set_color(hover and self._hover_color or self._normal_color)

	if hover then
		managers.menu_component:post_event("highlight")
	end
end

-- Lines 716-723
function TextButton:set_text(text)
	self._text:set_text(text)
	self.make_fine_text(self._text)

	if not self._is_fixed then
		self:set_size(self._text:rightbottom())
	end
end

IconButton = IconButton or class(BaseButton)

-- Lines 734-749
function IconButton:init(parent, icon_config, func)
	IconButton.super.init(self, parent, {
		binding = icon_config.binding
	}, func)

	self._select_panel = ExtendedPanel:new(self)
	self._normal_color = icon_config.normal_color or icon_config.color
	self._hover_color = icon_config.hover_color or icon_config.color or self._normal_color
	self._disabled_color = icon_config.disabled_color or self._normal_color
	self._button = self._select_panel:bitmap(icon_config)

	self:_set_color(self._normal_color)

	self._trigger = func or function ()
	end

	self:set_size(self._button:size())
end

-- Lines 751-755
function IconButton:_set_color(col)
	if col then
		self._button:set_color(col)
	end
end

-- Lines 757-759
function IconButton:icon()
	return self._button
end

-- Lines 761-763
function IconButton:_hover_changed(hover)
	self:_set_color(hover and self._hover_color or self._normal_color)
end

-- Lines 765-767
function IconButton:_enabled_changed(state)
	self:_set_color(state and self._normal_color or self._disabled_color)
end

ProgressBar = ProgressBar or class(ExtendedPanel)

-- Lines 777-826
function ProgressBar:init(parent, config, progress)
	ProgressBar.super.init(self, parent, config)

	config = config or {}
	self._max = config.max or 1
	self._back_color = config.back_config and config.back_config.color or config.back_color or Color.black
	self._progress_color = config.progress_config and config.progress_config.color or config.progress_color or Color.white
	self._back = self:rect(config.back_config or {
		color = self._back_color
	})
	self._progress = self:rect(config.progress_config or {
		w = 0,
		color = self._progress_color
	})

	if config.edges then
		local h = self:h() * 1.6
		local y = -(h - self:h()) / 2

		if config.edges ~= "both" then
			h = self:h() * 1.3
		end

		if config.edges == "down" then
			y = 0
		end

		self._edges = {
			left = self:rect({
				w = 3,
				rotation = 360,
				color = self._back_color,
				h = h,
				y = y
			})
		}

		self._edges.left:set_right(0)

		self._edges.right = self:rect({
			w = 3,
			rotation = 360,
			color = self._back_color,
			h = h,
			y = y
		})

		self._edges.right:set_x(self:w())
	end

	self._at = 0

	if progress then
		self:set_progress(progress)
	end
end

-- Lines 828-830
function ProgressBar:max()
	return self._max
end

-- Lines 833-843
function ProgressBar:set_progress(v)
	self._at = math.clamp(v, 0, self._max)

	self._progress:set_w(self._back:w() * self._at / self._max)

	if self._edges then
		self._edges.left:set_color(self._at > 0 and self._progress_color or self._back_color)
		self._edges.right:set_color(self._max <= self._at and self._progress_color or self._back_color)
	end

	return self._at
end

-- Lines 846-851
function ProgressBar:set_max(v, dont_scale_current)
	local current = dont_scale_current and self._at or self._at / self._max * v
	self._max = v

	self:set_progress(current)
end

TextProgressBar = TextProgressBar or class(ProgressBar)

-- Lines 866-890
function TextProgressBar:init(parent, config, text_config, progress)
	TextProgressBar.super.init(self, parent, config)

	text_config = text_config or {}
	self._on_back_color = text_config.on_back_color or text_config.color or self._progress_color
	self._on_progress_color = text_config.on_progress_color or text_config.color or self._back_color

	if config.percent ~= nil then
		self._percentage = config.percent
	else
		self._percentage = not config.max
	end

	self._to_text_func = config.format_func or self._percentage and self._percentage_format or self._normal_format
	text_config.text = text_config.text or self._percentage and " 0% " or string.format(" 0 / %d ", self._max)
	text_config.color = text_config.color or self._on_back_color
	text_config.layer = text_config.layer or self._progress:layer() + 1
	self._text = self:fine_text(text_config)

	self._text:set_center_y(self._back:center_y())

	if progress then
		self:set_progress(progress)
	end
end

-- Lines 892-895
function TextProgressBar:_percentage_format()
	local num = self._at / self._max * 100

	return string.format(" %d%% ", num)
end

-- Lines 897-899
function TextProgressBar:_normal_format()
	return string.format(" %d / %d ", self._at, self._max)
end

-- Lines 901-920
function TextProgressBar:set_progress(v)
	TextProgressBar.super.set_progress(self, v)

	local at = self._progress:right()
	local max = self._back:right()

	self._text:set_text(self:_to_text_func(self._at, self._max))
	self.make_fine_text(self._text)
	self._text:set_left(at)

	local col = self._on_back_color

	if max < self._text:right() then
		col = self._on_progress_color

		self._text:set_right(at)
	end

	self._text:set_color(col)

	return self._at
end

SpecialButtonBinding = SpecialButtonBinding or class()

-- Lines 926-935
function SpecialButtonBinding:init(binding, func, add_to_panel)
	self._binding = Idstring(binding)
	self._on_trigger = func or function ()
	end
	self._enabled = true

	if add_to_panel then
		add_to_panel:add_input_component(self)
	end
end

-- Lines 937-939
function SpecialButtonBinding:allow_input()
	return self._enabled
end

-- Lines 941-946
function SpecialButtonBinding:special_btn_pressed(button)
	if button == self._binding then
		self._on_trigger()

		return true
	end
end

-- Lines 948-950
function SpecialButtonBinding:set_enabled(state)
	self._enabled = state
end

ButtonLegendsBar = ButtonLegendsBar or class(GrowPanel)
ButtonLegendsBar.PADDING = 10

-- Lines 984-996
function ButtonLegendsBar:init(panel, config, panel_config)
	panel_config = set_defaults(panel_config, {
		border = 0,
		padding_y = 0,
		input = true,
		w = panel:w(),
		padding = self.PADDING
	})
	panel_config = set_defaults(panel_config, {
		fixed_w = panel_config.w
	})

	ButtonLegendsBar.super.init(self, panel, panel_config)

	self._text_config = set_defaults(config, {
		font = small_font,
		font_size = small_font_size
	})
	self._wrap = panel_config.wrap
	self._legends_only = self._text_config.no_buttons or not panel_config.input or not managers.menu:is_pc_controller()
	self._items = {}
	self._lookup = {}
end

-- Lines 998-1020
function ButtonLegendsBar:add_item(data, id, dont_update)
	if type(data) == "string" then
		local text = managers.localization:exists(data) and managers.localization:to_upper_text(data) or data

		table.insert(self._items, self:_create_legend(nil, text))
	else
		local macro_name = data.macro_name or "MY_BTN"
		local text = data.text or managers.localization:to_upper_text(data.text_id, {
			[macro_name] = managers.localization:btn_macro(data.binding, true) or ""
		})
		local item = nil

		if data.func and not self._legends_only then
			table.insert(self._items, self:_create_btn(data, text))
		else
			table.insert(self._items, self:_create_legend(data, text))
		end
	end

	if id or data.id then
		self._lookup[id or data.id] = #self._items
	end

	if dont_update or data.enabled == false then
		return
	end

	self:_update_items()
end

-- Lines 1022-1032
function ButtonLegendsBar:_create_btn(data, text)
	local config = clone(self._text_config)
	config.text = text
	config.binding = data.binding
	local button = TextButton:new(self, config, data.func)

	button:set_visible(false)

	local item = {
		button = true,
		item = button,
		enabled = data.enabled ~= false,
		force_break = data.force_break
	}

	return item
end

-- Lines 1034-1048
function ButtonLegendsBar:_create_legend(data, text)
	data = data or {}
	local config = data.config or clone(self._text_config)
	config.text = text
	local text = self:fine_text(config)

	text:set_visible(false)

	local item = {
		text = true,
		item = text,
		enabled = data.enabled ~= false,
		force_break = data.force_break
	}

	if data.binding and data.func then
		item.listener = SpecialButtonBinding:new(data.binding, data.func, self)
	end

	return item
end

-- Lines 1050-1056
function ButtonLegendsBar:add_items(list)
	for k, v in pairs(list) do
		self:add_item(v, nil, true)
	end

	self:_update_items()
end

-- Lines 1058-1065
function ButtonLegendsBar:set_item_enabled(id_or_pos, state)
	local id = type(id_or_pos) == "number" and id_or_pos or self._lookup[id_or_pos]
	local data = self._items[id]

	if data and data.enabled ~= state then
		data.enabled = state

		self:_update_items()
	end
end

-- Lines 1067-1090
function ButtonLegendsBar:_update_items()
	local placer = self:placer()

	placer:clear()
	placer:set_start(self:w(), 0)
	self:set_size(0, 0)

	for _, v in pairs(self._items) do
		v.item:set_visible(v.enabled)

		if v.force_break and not placer:is_first_in_row() then
			placer:new_row()
		end

		if v.enabled then
			placer:add_left(v.item)

			if self._wrap and v.item:left() < 0 and not placer:is_first_in_row() then
				placer:new_row()
				placer:add_left(v.item)
			end
		end

		if v.listener then
			v.listener:set_enabled(v.enabled)
		end
	end
end

TextLegendsBar = TextLegendsBar or class(ButtonLegendsBar)
TextLegendsBar.SEPERATOR = "  |  "

-- Lines 1097-1103
function TextLegendsBar:init(panel, config, panel_config)
	TextLegendsBar.super.init(self, panel, config, panel_config)

	self._text_config = set_defaults(self._text_config, {
		text = " ",
		align = "right",
		keep_w = true
	})
	self._seperator = self._text_config.seperator or TextLegendsBar.SEPERATOR
	self._lines = {}
end

-- Lines 1105-1107
function TextLegendsBar:_create_btn(data, text)
	return self:_create_legend(data, text)
end

-- Lines 1109-1118
function TextLegendsBar:_create_legend(data, text)
	data = data or {}
	local item = {
		item = text,
		enabled = data.enabled ~= false,
		force_break = data.force_break
	}

	if data.binding and data.func then
		item.listener = SpecialButtonBinding:new(data.binding, data.func, self)
	end

	return item
end

-- Lines 1120-1171
function TextLegendsBar:_update_items()
	for _, v in pairs(self._lines) do
		self:remove(v)
	end

	self._lines = {}
	local placer = self:placer()

	placer:clear()
	placer:set_start(self:w(), 0)
	self:set_size(self:w(), 0)

	-- Lines 1131-1138
	local function complete_line(text_item)
		self.make_fine_text(text_item, true)
		placer:add_left(text_item)
		placer:new_row()
		self:set_h(text_item:bottom())
		table.insert(self._lines, text_item)
	end

	local text_item = nil

	for _, v in pairs(self._items) do
		if v.force_break then
			text_item = nil
		end

		if v.enabled then
			if text_item then
				local str = text_item:text()

				text_item:set_text(v.item .. self._seperator .. str)

				local _, _, w, _ = text_item:text_rect()

				if self._wrap and self:w() < w then
					text_item:set_text(str)
					complete_line(text_item)

					text_item = nil
				end
			end

			if not text_item then
				text_item = self:text(self._text_config)

				text_item:set_text(v.item)
			end
		end

		if v.listener then
			v.listener:set_enabled(v.enabled)
		end
	end

	if text_item then
		complete_line(text_item)
	end
end
