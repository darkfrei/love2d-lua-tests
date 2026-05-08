local validator = {}
local types = require('questlib.types')

local function fail(path, msg, value)
	local full = path .. ": " .. msg
	if value ~= nil then
		local debug_val = type(value) == 'table' and (value[1] or tostring(value)) or tostring(value)
		full = full .. " (got: " .. debug_val .. ")"
	end
	print("[VALIDATION ERROR] " .. full)
	return full
end

local function validate_expr(expr, path, context)
	if type(expr) ~= 'table' then return nil end

	if expr[1] == '?' then
		if #expr < 3 or #expr > 4 then return fail(path, "ternary bad length", #expr) end
		local err = validate_expr(expr[2], path .. ".cond", context)
		if err then return err end
		local err2 = validate_expr(expr[3], path .. ".then", context)
		if err2 then return err2 end
		if expr[4] then
			local err3 = validate_expr(expr[4], path .. ".else", context)
			if err3 then return err3 end
		end
		return nil
	end

	local etype = types.get_expr_type(expr)
	if etype == 'unknown' then return fail(path, "unsupported expr", expr[1]) end

	if types.assi_ops[expr[2]] then
		if context and context ~= "effect" then return fail(path, "assignment used outside effect", expr[2]) end
		if #expr ~= 3 then return fail(path, "assignment bad length", #expr) end
		local err1 = validate_expr(expr[1], path .. ".target", "effect")
		if err1 then return err1 end
		local err2 = validate_expr(expr[3], path .. ".value", "effect")
		if err2 then return err2 end
		return nil
	end

	if #expr ~= 3 then return fail(path, "expr bad length", #expr) end
	local left = validate_expr(expr[1], path .. ".left", context)
	if left then return left end
	local right = validate_expr(expr[3], path .. ".right", context)
	if right then return right end
	return nil
end

local function validate_text(segments, path, snippet_map)
	if type(segments) ~= 'table' then return fail(path, "not table", type(segments)) end
	for i, seg in ipairs(segments) do
		if type(seg) == 'table' then
			if seg[1] == 'snippet' then
				if not snippet_map or not snippet_map[seg[2]] then
					return fail(path, "snippet ref not found", seg[2])
				end
			else
				local err = validate_expr(seg, path .. "[" .. i .. "]", "visibility")
				if err then return err end
			end
		elseif type(seg) ~= 'string' then
			return fail(path, "seg not string/expr", type(seg))
		end
	end
	return nil
end

local function validate_choice_obj(c, path, cond_map, snippet_map)
	if not c.label then return fail(path, "choice missing label") end
	for _, field in ipairs({ "visible", "enabled" }) do
		local val = c[field]
		if val then
			if type(val) == 'string' then
				if not cond_map[val] then return fail(path .. "." .. field, "cond ref not found", val) end
			else
				local err = validate_expr(val, path .. "." .. field, "visibility")
				if err then return err end
			end
		end
	end

	local flags = 0
	if c.once then flags = flags + 1 end
	if c.consumed then flags = flags + 1 end
	if c.repeatable then flags = flags + 1 end
	if flags > 1 then return fail(path, "only one of once/consumed/repeatable allowed") end
	if c.priority and type(c.priority) ~= 'number' then return fail(path .. ".priority", "must be number", c.priority) end

	if c.transition then
		if type(c.transition) == 'table' then
			if c.transition.text and type(c.transition.text) == 'table' then
				local err = validate_text(c.transition.text, path .. ".transition.text", snippet_map)
				if err then return err end
			end
			if c.transition.target and type(c.transition.target) ~= 'string' then
				return fail(path .. ".transition.target", "must be string", c.transition.target)
			end
		elseif type(c.transition) ~= 'string' then
			return fail(path .. ".transition", "must be string or table", type(c.transition))
		end
	end

	if c.effects then
		local eff_list = type(c.effects) == 'string' and { c.effects } or c.effects
		for i, eff in ipairs(eff_list) do
			local epath = path .. ".effects[" .. i .. "]"
			if type(eff) ~= 'string' and types.get_expr_type(eff) ~= 'assi' then
				return fail(epath, "effect must be assignment", eff[1])
			end
		end
	end
	return nil
end

function validator.validate_node(node, path, maps)
	if not node.id then return fail(path, "node missing id") end
	
--	if node.visible then
--		if type(node.visible) == 'string' and not maps.conditions[node.visible] then
--			return fail(path .. ".visible", "cond ref not found", node.visible)
--		elseif type(node.visible) == 'table' then
--			local err = validate_expr(node.visible, path .. ".visible", "visibility")
--			if err then return err end
--		end
--	end

	if not node.text or type(node.text) ~= 'table' then return fail(path .. ".text", "must be table", type(node.text)) end
	local err = validate_text(node.text, path .. ".text", maps.snippets)
	if err then return err end

	if node.stats then
		for i, item in ipairs(node.stats) do
			if type(item) ~= 'string' then
				local line_err = validate_text({ item }, path .. ".stats[" .. i .. "]", maps.snippets)
				if line_err then return line_err end
			end
			-- строки в stats пропускаем (литерал или опциональная ссылка)
		end
	end

	if node.choices then
		for i, c_ref in ipairs(node.choices) do
			local c_path = path .. ".choices[" .. i .. "]"
			if type(c_ref) == 'string' then
				if not maps.choices[c_ref] then return fail(c_path, "choice ref not found", c_ref) end
			else
				local err = validate_choice_obj(c_ref, c_path, maps.conditions, maps.snippets)
				if err then return err end
			end
		end
	end
	return nil
end

function validator.validate_quest(data)
	if not data.start_node then return fail("root.start_node", "missing") end
	if not data.nodes then return fail("root.nodes", "missing") end

	local maps = { conditions = {}, effects = {}, snippets = {}, stats = {}, choices = {} }

	if data.shared_conditions then
		for id, expr in pairs(data.shared_conditions) do
			local err = validate_expr(expr, "shared_conditions." .. id, "condition")
			if err then return err end
			maps.conditions[id] = expr
		end
	end

	if data.shared_effects then
		for id, arr in pairs(data.shared_effects) do
			local p = "shared_effects." .. id
			if type(arr) ~= 'table' then return fail(p, "must be array", type(arr)) end
			for i, act in ipairs(arr) do
				if types.get_expr_type(act) ~= 'assi' then return fail(p .. "[" .. i .. "]", "must be assignment", act[1]) end
			end
			maps.effects[id] = arr
		end
	end

	if data.shared_snippets then
		for id, expr in pairs(data.shared_snippets) do
			local err = validate_expr(expr, "shared_snippets." .. id, "visibility")
			if err then return err end
			maps.snippets[id] = expr
		end
	end

	if data.shared_stats then
		for id, arr in pairs(data.shared_stats) do
			local p = "shared_stats." .. id
			if type(arr) ~= 'table' then return fail(p, "must be array", type(arr)) end
			local err = validate_text(arr, p, maps.snippets)
			if err then return err end
			maps.stats[id] = arr
		end
	end

	if data.shared_choices then
		for id, c in pairs(data.shared_choices) do
			local err = validate_choice_obj(c, "shared_choices." .. id, maps.conditions, maps.snippets)
			if err then return err end
			maps.choices[id] = c
		end
	end

	local start_found = false
	for _, n in ipairs(data.nodes) do
		if n.id == data.start_node then start_found = true end
		local err = validator.validate_node(n, "nodes." .. n.id, maps)
		if err then return err end
	end
	if not start_found then return fail("start_node", "not found", data.start_node) end

	return nil
end

return validator