if RequiredScript == "lib/managers/menu/skilltreeguinew" then
	log("[STD] Skilltree Detection Indicator loaded for skilltreeguinew")
	_G.STD = _G.STD or {}

	-- Getters / Setters
	local function get_indicator_anchor(self) return self._std_anchor end
	local function set_indicator_anchor(self, value) self._std_anchor = value end

	local function get_detection_text(self) return self._std_detection_text end
	local function set_detection_text(self, value) self._std_detection_text = value end

	local function get_low_blow_basic_label_text(self) return self._std_low_blow_basic_label_text end
	local function set_low_blow_basic_label_text(self, value) self._std_low_blow_basic_label_text = value end

	local function get_low_blow_basic_value_text(self) return self._std_low_blow_basic_value_text end
	local function set_low_blow_basic_value_text(self, value) self._std_low_blow_basic_value_text = value end

	local function get_low_blow_ace_label_text(self) return self._std_low_blow_ace_label_text end
	local function set_low_blow_ace_label_text(self, value) self._std_low_blow_ace_label_text = value end

	local function get_low_blow_ace_value_text(self) return self._std_low_blow_ace_value_text end
	local function set_low_blow_ace_value_text(self, value) self._std_low_blow_ace_value_text = value end

	local function get_last_detection_value(self) return self._std_detection_last end
	local function set_last_detection_value(self, value) self._std_detection_last = value end

	-- Utilities
	local function detection_label()
		if managers.localization then return managers.localization:to_upper_text("menu_skilltree_score_detection", {}) end
		return "DETECTION"
	end

	local function low_blow_basic_label()
		if managers.localization then return managers.localization:to_upper_text("menu_skilltree_score_lbb", {}) end
		return "LOW BLOW BASIC"
	end

	local function low_blow_ace_label()
		if managers.localization then return managers.localization:to_upper_text("menu_skilltree_score_lba", {}) end
		return "LOW BLOW ACE"
	end

	local function is_matching_anchor_text(text, patterns)
		if text == nil then return false end
		local upper = tostring(text):upper()
		for _, pattern in ipairs(patterns) do
			if upper:find(pattern, 1, true) then return true end
		end
		return false
	end

	local function find_anchor_by_patterns(panel, patterns)
		if not alive(panel) then return nil end
		for _, child in pairs(panel:children()) do
			if child.text and is_matching_anchor_text(child:text(), patterns) then return child end
			if child.children then
				local found = find_anchor_by_patterns(child, patterns)
				if found then return found end
			end
		end
		return nil
	end

	local function find_anchor(panel)
		return find_anchor_by_patterns(panel, { "SWITCH SKILLSET", "SWITCH SKILL SET", "CHANGER DE SKILLSET", "CHANGER DE SKILL SET", "CHANGER DE COMPETENCE" })
	end

	local function color_for_detection(detection_value)
		if detection_value < 25 then return Color(1, 0.2, 0.8, 0.2) end
		if detection_value < 50 then return Color(1, 1, 0.8, 0.2) end
		return Color(1, 1, 0.2, 0.2)
	end

	local function color_for_crit(crit_value)
		if crit_value <= 0 then return Color.white end
		if crit_value < 20 then return Color(1, 1, 0.2, 0.2) end
		if crit_value < 30 then return Color(1, 1, 0.8, 0.2) end
		return Color(1, 0.2, 0.8, 0.2)
	end

	local function low_blow_crit_from_detection(detection_value)
		local concealment = detection_value or 35
		local under = math.max(0, 35 - concealment)
		local crit_basic = math.min(30, math.floor(under / 3) * 3)
		local crit_ace = math.min(30, under * 3)
		return crit_basic, crit_ace
	end

	local function create_text(parent, name, text)
		local text_object = parent:text({ name = name, text = text, font = tweak_data.menu.pd2_small_font, font_size = tweak_data.menu.pd2_small_font_size, color = Color.white })
		local _, _, width, height = text_object:text_rect()
		text_object:set_size(width, height)
		return text_object
	end

	local function set_text_and_resize(text_object, value)
		text_object:set_text(value)
		local _, _, width, height = text_object:text_rect()
		text_object:set_size(width, height)
	end

	local function layout_indicator(self)
		local detection_text = get_detection_text(self)
		local low_blow_basic_label_text = get_low_blow_basic_label_text(self)
		local low_blow_basic_value_text = get_low_blow_basic_value_text(self)
		local low_blow_ace_label_text = get_low_blow_ace_label_text(self)
		local low_blow_ace_value_text = get_low_blow_ace_value_text(self)
		local anchor = get_indicator_anchor(self)
		local parent = self._panel

		if not (anchor and alive(anchor)) then
			low_blow_ace_value_text:set_right(parent:w() - 10)
			low_blow_ace_value_text:set_top(10)
			low_blow_ace_label_text:set_right(low_blow_ace_value_text:left() - 4)
			low_blow_ace_label_text:set_top(10)
			low_blow_basic_value_text:set_right(low_blow_ace_label_text:left() - 10)
			low_blow_basic_value_text:set_top(10)
			low_blow_basic_label_text:set_right(low_blow_basic_value_text:left() - 4)
			low_blow_basic_label_text:set_top(10)
			detection_text:set_right(low_blow_basic_label_text:left() - 10)
			detection_text:set_top(10)
			return
		end

		local is_right_side = anchor:center_x() > (parent:w() * 0.6)
		if is_right_side then
			low_blow_ace_value_text:set_right(anchor:left() - 10)
			low_blow_ace_label_text:set_right(low_blow_ace_value_text:left() - 4)
			low_blow_basic_value_text:set_right(low_blow_ace_label_text:left() - 10)
			low_blow_basic_label_text:set_right(low_blow_basic_value_text:left() - 4)
			detection_text:set_right(low_blow_basic_label_text:left() - 10)
		else
			detection_text:set_left(anchor:right() + 10)
			low_blow_basic_label_text:set_left(detection_text:right() + 10)
			low_blow_basic_value_text:set_left(low_blow_basic_label_text:right() + 4)
			low_blow_ace_label_text:set_left(low_blow_basic_value_text:right() + 10)
			low_blow_ace_value_text:set_left(low_blow_ace_label_text:right() + 4)
		end
		detection_text:set_top(anchor:top())
		low_blow_basic_label_text:set_top(anchor:top())
		low_blow_basic_value_text:set_top(anchor:top())
		low_blow_ace_label_text:set_top(anchor:top())
		low_blow_ace_value_text:set_top(anchor:top())
	end

	-- Management / Hooks
	local function ensure_indicator(self)
		if not alive(self._panel) then return end

		local parent = self._panel
		local anchor = get_indicator_anchor(self)
		if not (anchor and alive(anchor)) then anchor = find_anchor(parent); set_indicator_anchor(self, anchor) end

		if get_detection_text(self) and alive(get_detection_text(self)) then return end

		local detection_text = create_text(parent, "std_detection_text", detection_label() .. " 0")
		local low_blow_basic_label_text = create_text(parent, "std_low_blow_basic_label", low_blow_ace_label())
		local low_blow_basic_value_text = create_text(parent, "std_low_blow_basic_value", "0%")
		local low_blow_ace_label_text = create_text(parent, "std_low_blow_ace_label", low_blow_basic_label())
		local low_blow_ace_value_text = create_text(parent, "std_low_blow_ace_value", "0%")

		set_detection_text(self, detection_text)
		set_low_blow_basic_label_text(self, low_blow_basic_label_text)
		set_low_blow_basic_value_text(self, low_blow_basic_value_text)
		set_low_blow_ace_label_text(self, low_blow_ace_label_text)
		set_low_blow_ace_value_text(self, low_blow_ace_value_text)
		set_last_detection_value(self, nil)
		layout_indicator(self)
	end

	local function update_indicator(self)
		local detection_text = get_detection_text(self)
		if not detection_text or not alive(detection_text) then return end
		if not managers.blackmarket or not tweak_data or not tweak_data.player then return end

		local lerp = tweak_data.player.SUSPICION_OFFSET_LERP or 0.75
		local risk = managers.blackmarket:get_suspicion_offset_of_local(lerp) or 0
		local detection_value = math.floor(risk * 100 + 0.5)
		if get_last_detection_value(self) ~= detection_value then
			set_last_detection_value(self, detection_value)
			set_text_and_resize(detection_text, detection_label() .. " " .. tostring(detection_value))
			detection_text:set_color(color_for_detection(detection_value))
		end

		local crit_basic, crit_ace = low_blow_crit_from_detection(detection_value)
		local low_blow_basic_label_text = get_low_blow_basic_label_text(self)
		local low_blow_basic_value_text = get_low_blow_basic_value_text(self)
		local low_blow_ace_label_text = get_low_blow_ace_label_text(self)
		local low_blow_ace_value_text = get_low_blow_ace_value_text(self)

		set_text_and_resize(low_blow_basic_label_text, low_blow_ace_label())
		low_blow_basic_label_text:set_color(Color.white)
		set_text_and_resize(low_blow_basic_value_text, tostring(crit_ace) .. "%")
		low_blow_basic_value_text:set_color(color_for_crit(crit_ace))

		set_text_and_resize(low_blow_ace_label_text, low_blow_basic_label())
		low_blow_ace_label_text:set_color(Color.white)
		set_text_and_resize(low_blow_ace_value_text, tostring(crit_basic) .. "%")
		low_blow_ace_value_text:set_color(color_for_crit(crit_basic))
		layout_indicator(self)
	end

	Hooks:PostHook(NewSkillTreeGui, "init", "STD_NewSkillTreeGui_init", function(self) ensure_indicator(self); update_indicator(self) end)
	Hooks:PostHook(NewSkillTreeGui, "update", "STD_NewSkillTreeGui_update", function(self) ensure_indicator(self); update_indicator(self) end)
end
