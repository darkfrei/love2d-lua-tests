local runtime = {}
local evaluator = require('questlib.evaluator')

local function deep_copy(o)
	if type(o) ~= 'table' then return o end
	local c = {}
	for k, v in pairs(o) do c[deep_copy(k)] = deep_copy(v) end
	return c
end

local values = {}
local quest = nil
local current_node_id = nil
local current_choices = {}
local after_text = nil
local _node_map = {}
local _shared_choice_map = {}
local _choice_usage = {}
local _condition_map = {}
local _effect_map = {}
local _transition_map = {}
local _cte_map = {}

local function resolve_flag_expr(val)
	if type(val) == 'string' and _condition_map[val] then
		return _condition_map[val].expr
	end
	return val
end

local function resolve_choice(c_ref)
	if type(c_ref) == 'string' then return _shared_choice_map[c_ref] end
	return c_ref
end

local function resolve_transition(val)
	if not val then return nil end
	local text_part, target_part
	if type(val) == 'string' then
		local ref = _transition_map[val]
		if ref then
			text_part = ref.text
			target_part = ref.target
		else
			text_part = { val }
		end
	elseif type(val) == 'table' then
		text_part = val.text
		target_part = val.target
		if type(text_part) == 'string' and _transition_map[text_part] then
			text_part = _transition_map[text_part].text
		end
	end
	if text_part and type(text_part) ~= 'table' then
		text_part = { tostring(text_part) }
	end
	return { text = text_part, target = target_part }
end

local function resolve_effects_list(val)
	if not val then return {} end
	local raw = type(val) == 'string' and { val } or val
	local final = {}
	for _, eff in ipairs(raw) do
		if type(eff) == 'string' and _effect_map[eff] then
			for _, act in ipairs(_effect_map[eff].actions) do table.insert(final, act) end
		else table.insert(final, eff) end
	end
	return final
end

local function resolve_text_ctes(text_array)
	local resolved = {}
	for _, seg in ipairs(text_array) do
		if type(seg) == 'table' and seg[1] == 'cte' then
			local cte = _cte_map[seg[2]]
			if cte then table.insert(resolved, {"?", cte.condition, cte["then"], cte["else"]})
			else table.insert(resolved, seg) end
		else table.insert(resolved, seg) end
	end
	return resolved
end

function runtime.reset(init_vars)
	values = init_vars and deep_copy(init_vars) or {}
	quest = nil; current_node_id = nil; current_choices = {}; after_text = nil
	_node_map = {}; _shared_choice_map = {}; _choice_usage = {}
	_condition_map = {}; _effect_map = {}; _transition_map = {}; _cte_map = {}
end

function runtime.load_quest(data)
	quest = deep_copy(data)
	values = data.variables and deep_copy(data.variables) or {}
	current_node_id = data.start_node
	current_choices = {}; after_text = nil; _choice_usage = {}
	_node_map = {}; _shared_choice_map = {}
	_condition_map = {}; _effect_map = {}; _transition_map = {}; _cte_map = {}

	if quest.nodes then for _, n in ipairs(quest.nodes) do if n.id then _node_map[n.id] = n end end end
	if quest.shared_choices then for _, c in ipairs(quest.shared_choices) do if c.id then _shared_choice_map[c.id] = c end end end
	if quest.conditions then for _, c in ipairs(quest.conditions) do if c.id then _condition_map[c.id] = c end end end
	if quest.effects then for _, e in ipairs(quest.effects) do if e.id then _effect_map[e.id] = e end end end
	if quest.transitions then for _, t in ipairs(quest.transitions) do if t.id then _transition_map[t.id] = t end end end
	if quest.ctes then for _, c in ipairs(quest.ctes) do if c.id then _cte_map[c.id] = c end end end
end

function runtime.enter_node(id)
	if not quest or not _node_map[id] then return nil end
	local node = _node_map[id]

	local flag_expr = resolve_flag_expr(node.visible or node.condition)
	if flag_expr then
		local flag_val = evaluator.resolve(flag_expr, values)
		if flag_val == false then return nil end
	end

	local list = {}
	if node.choices then
		for _, c_ref in ipairs(node.choices) do
			local c = resolve_choice(c_ref)
			if c then
				local vis_expr = resolve_flag_expr(c.visible)
				local is_visible = true
				if vis_expr then is_visible = evaluator.resolve(vis_expr, values) ~= false end

				if is_visible and c.id and (c.once or c.consumed) and _choice_usage[c.id] then
					is_visible = false
				end

				if is_visible then
					local ena_expr = resolve_flag_expr(c.enabled)
					local is_enabled = true
					if ena_expr then is_enabled = evaluator.resolve(ena_expr, values) ~= false end

					local prio = c.priority or 0
					if not is_enabled then prio = prio + 100 end

					table.insert(list, {
							data = c,
							enabled = is_enabled,
							priority = prio,
							resolved_effects = resolve_effects_list(c.effects),
							resolved_transition = resolve_transition(c.transition)
						})
				end
			end
		end
	end

	table.sort(list, function(a, b)
			if a.priority == b.priority then return (a.data.id or "") < (b.data.id or "") end
			return a.priority < b.priority
		end)

	local i = 1
	while i <= #list do
		local j = i + 1
		while j <= #list and list[j].priority == list[i].priority do j = j + 1 end
		for k = j - 1, i + 1, -1 do
			local r = math.random(i, k)
			list[k], list[r] = list[r], list[k]
		end
		i = j
	end

	current_choices = list

	local ui_choices = {}
	for i, ch in ipairs(current_choices) do
		table.insert(ui_choices, {
				index = i,
				id = ch.data.id,
				label = ch.data.label or "",
				enabled = ch.enabled,
				target = ch.resolved_transition and ch.resolved_transition.target
			})
	end

	local raw_text = node.text or {}
	local processed_text = resolve_text_ctes(raw_text)

	-- NEW: merge global + node stats
	local raw_stats = {}
	for _, item in ipairs(quest.global_stats or {}) do table.insert(raw_stats, item) end
	for _, item in ipairs(node.stats or {}) do table.insert(raw_stats, item) end

	local processed_stats = {}
	for _, item in ipairs(raw_stats) do
		table.insert(processed_stats, evaluator.parse_text({item}, values))
	end

	local result = {
		id = node.id,
		text = evaluator.parse_text(processed_text, values),
		stats = processed_stats,
		after_text = after_text,
		choices = ui_choices
	}

	after_text = nil
	current_node_id = id
	return result
end

function runtime.choose(index)
	local ch = current_choices[index]
	if not ch or not ch.enabled then return nil end

	print("[runtime] CHOICE triggered:", ch.data.id)
	print("[runtime] STATE BEFORE effects:", "threat=" .. tostring(values.threat_level), "key=" .. tostring(values.has_override_key))

	if ch.resolved_effects then
		for _, eff in ipairs(ch.resolved_effects) do
			evaluator.resolve(eff, values)
		end
	end

	print("[runtime] STATE AFTER effects:", "threat=" .. tostring(values.threat_level), "key=" .. tostring(values.has_override_key))

	if ch.resolved_transition then
		if ch.resolved_transition.text then
			after_text = evaluator.parse_text(ch.resolved_transition.text, values)
		end
		if ch.resolved_transition.target then
			current_node_id = ch.resolved_transition.target
		end
	end

	if ch.data.id and (ch.data.once or ch.data.consumed) then _choice_usage[ch.data.id] = true end

	return runtime.enter_node(current_node_id)
end

function runtime.get_state() return deep_copy(values) end
function runtime.set_state(t) values = deep_copy(t) end
function runtime.get_current_id() return current_node_id end

return runtime