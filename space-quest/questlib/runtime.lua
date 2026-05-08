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
local _condition_map = {}
local _effect_map = {}
local _snippet_map = {}
local _stats_map = {}
local _choice_map = {}
local _choice_usage = {}

local function resolve_condition_ref(expr)
	if type(expr) == 'string' and _condition_map[expr] then
		return _condition_map[expr]
	end
	return expr
end

local function resolve_choice_refs(c_data)
	local resolved = {}
	for k, v in pairs(c_data) do
		if k == 'enabled' or k == 'visible' then
			resolved[k] = resolve_condition_ref(v)
		elseif k == 'effects' and type(v) == 'string' and _effect_map[v] then
			resolved[k] = _effect_map[v]
		else
			resolved[k] = v
		end
	end
	return resolved
end

local function preprocess_stats_item(item)
	if type(item) ~= 'table' then return item end
	if item[1] == '?' then
		return {"?", resolve_condition_ref(item[2]), item[3], item[4]}
	end
--	if item[1] == 'snippet' then
--		local expr = _snippet_map[item[2]]
--		if expr then
--			return {"?", resolve_condition_ref(expr[2]), expr[3], expr[4]}
--		end
--	end
	if item[1] == 'snippet' then
		local expr = _snippet_map[item[2]]
		if expr then
			if type(expr) == 'table' then
				return {"?", resolve_condition_ref(expr[2]), expr[3], expr[4]}
			else
				return expr
			end
		end
	end
	return item
end

function runtime.reset(init_vars)
	values = init_vars and deep_copy(init_vars) or {}
	quest = nil; current_node_id = nil; current_choices = {}; after_text = nil
	_node_map = {}; _condition_map = {}; _effect_map = {}; _snippet_map = {}
	_stats_map = {}; _choice_map = {}; _choice_usage = {}
end

function runtime.load_quest(data)
	quest = deep_copy(data)
	values = data.variables and deep_copy(data.variables) or {}
	current_node_id = data.start_node
	current_choices = {}; after_text = nil; _choice_usage = {}

	-- Загружаем словари напрямую (они не мутируют в рантайме)
	_condition_map = data.shared_conditions or {}
	_effect_map    = data.shared_effects    or {}
	_snippet_map   = data.shared_snippets   or {}
	_stats_map     = data.shared_stats      or {}

	-- Явно инжектим id в каждый выбор для корректной работы once/consumed
	_choice_map = {}
	if data.shared_choices then
		for id, c in pairs(data.shared_choices) do
			local entry = deep_copy(c)
			entry.id = id
			_choice_map[id] = entry
		end
	end

	_node_map = {}
	if quest.nodes then
		for _, n in ipairs(quest.nodes) do
			if n.id then _node_map[n.id] = n end
		end
	end
end

function runtime.enter_node(id)
	if not quest or not _node_map[id] then return nil end
	local node = _node_map[id]

--	local flag_expr = resolve_condition_ref(node.visible)
--	if flag_expr then
--		local flag_val = evaluator.resolve(flag_expr, values)
--		if flag_val == false then return nil end
--	end

	local list = {}
	if node.choices then
		for _, c_ref in ipairs(node.choices) do
			local c_data = type(c_ref) == 'string' and _choice_map[c_ref] or c_ref
			if c_data then
				local c = resolve_choice_refs(c_data)
				local vis_expr = resolve_condition_ref(c.visible)
				local is_visible = true
				if vis_expr then is_visible = evaluator.resolve(vis_expr, values) ~= false end
				if is_visible and c.id and (c.once or c.consumed) and _choice_usage[c.id] then
					is_visible = false
				end

				if is_visible then
					local ena_expr = resolve_condition_ref(c.enabled)
					local is_enabled = true
					if ena_expr then is_enabled = evaluator.resolve(ena_expr, values) ~= false end
					local prio = c.priority or 0
					if not is_enabled then prio = prio + 100 end

					table.insert(list, {
							data = c, enabled = is_enabled, priority = prio,
							resolved_effects = type(c.effects) == 'table' and c.effects or {},
							resolved_transition = c.transition
						})
				end
			end
		end
	end

	table.sort(list, function(a, b)
			if a.priority == b.priority then return (a.data.id or " ") < (b.data.id or " ") end
			return a.priority < b.priority
		end)

	current_choices = list
	local ui_choices = {}
	for i, ch in ipairs(current_choices) do
		table.insert(ui_choices, {
				index = i, id = ch.data.id, label = ch.data.label or " ",
				enabled = ch.enabled, target = ch.resolved_transition and ch.resolved_transition.target
			})
	end

	local raw_text = node.text or {}
	local processed_text = {}
	for _, seg in ipairs(raw_text) do
		if type(seg) == 'table' and seg[1] == 'snippet' then
			local snippet_expr = _snippet_map[seg[2]]
			if snippet_expr then
				local cond = resolve_condition_ref(snippet_expr[2])
				table.insert(processed_text, {"?", cond, snippet_expr[3], snippet_expr[4]})
			else
				table.insert(processed_text, seg)
			end
		else
			table.insert(processed_text, seg)
		end
	end

	local raw_stats = {}
	if node.stats then
--		for _, item in ipairs(node.stats) do
--			if type(item) == 'string' and _stats_map[item] then
--				for _, seg in ipairs(_stats_map[item]) do table.insert(raw_stats, seg) end
--			else
--				table.insert(raw_stats, item)
--			end
--		end

		for _, item in ipairs(node.stats) do
			if type(item) == 'string' and _stats_map[item] then
				for _, seg in ipairs(_stats_map[item]) do
					table.insert(raw_stats, preprocess_stats_item(seg))
				end
			else
				table.insert(raw_stats, preprocess_stats_item(item))
			end
		end
	end

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

	if ch.resolved_effects then
		for _, eff in ipairs(ch.resolved_effects) do evaluator.resolve(eff, values) end
	end

	if ch.resolved_transition then
		if ch.resolved_transition.text then after_text = evaluator.parse_text(ch.resolved_transition.text, values) end
		if ch.resolved_transition.target then current_node_id = ch.resolved_transition.target end
	end

	if ch.data.id and (ch.data.once or ch.data.consumed) then _choice_usage[ch.data.id] = true end
	return runtime.enter_node(current_node_id)
end

function runtime.get_state() return deep_copy(values) end
function runtime.set_state(t) values = deep_copy(t) end
function runtime.get_current_id() return current_node_id end

return runtime