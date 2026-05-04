local validator = {}
local types = require('questlib.types')

---------------------------------------------------------------------
-- error helper (prints only on error)
---------------------------------------------------------------------
local function fail(path, msg, value)
	local full = path .. ": " .. msg
	if value ~= nil then
		full = full .. " (got: " .. tostring(value) .. ")"
	end
	print("[VALIDATION ERROR] " .. full)
	return full
end

---------------------------------------------------------------------
-- expression validation (context-aware)
---------------------------------------------------------------------
local function validate_expr(expr, path, context)
	if type(expr) ~= 'table' then return nil end

	local etype = types.get_expr_type(expr)
	if etype == 'unknown' then return fail(path, "unsupported expr") end

	if etype == 'cte' then
		if #expr < 3 or #expr > 4 then return fail(path, "cte bad length") end
		for i = 2, #expr do
			local err = validate_expr(expr[i], path .. ".cte_arg" .. i, "visibility")
			if err then return err end
		end
		return nil
	end

	if types.assi_ops[expr[2]] then
		if context and context ~= "effect" then
			return fail(path, "assignment used outside effect")
		end
		if #expr ~= 3 then return fail(path, "assignment bad length") end

		local err1 = validate_expr(expr[1], path .. ".assign_target", "effect")
		if err1 then return err1 end

		local err2 = validate_expr(expr[3], path .. ".assign_value", "effect")
		if err2 then return err2 end

		return nil
	end

	if #expr ~= 3 then return fail(path, "expr bad length") end

	local left = validate_expr(expr[1], path .. ".left", context)
	if left then return left end

	local right = validate_expr(expr[3], path .. ".right", context)
	if right then return right end

	return nil
end

---------------------------------------------------------------------
-- text validation (markdown + cte injection)
---------------------------------------------------------------------
local function validate_text(segments, path, cte_map)
	if type(segments) ~= 'table' then return fail(path, "not table") end

	for i, seg in ipairs(segments) do
		if type(seg) == 'table' then
			if seg[1] == 'cte' then
				if not cte_map[seg[2]] then
					return fail(path, "cte ref not found", seg[2])
				end
			else
				local err = validate_expr(seg, path .. "[" .. i .. "]", "visibility")
				if err then return err end
			end
		elseif type(seg) ~= 'string' then
			return fail(path, "seg not string/expr", seg)
		end
	end

	return nil
end

---------------------------------------------------------------------
-- choice validation
---------------------------------------------------------------------
local function validate_choice_obj(c, path, maps)
	if not c.label then return fail(path, "choice missing label") end

	-- visibility / enabled
	for _, field in ipairs({ "visible", "enabled" }) do
		local val = c[field]
		if val then
			if type(val) == 'string' then
				if not maps.conditions[val] then
					return fail(path .. "." .. field, "ref not found", val)
				end
			else
				local err = validate_expr(val, path .. "." .. field, "visibility")
				if err then return err end
			end
		end
	end

	-- flags
	local flags = 0
	if c.once then flags = flags + 1 end
	if c.consumed then flags = flags + 1 end
	if c.repeatable then flags = flags + 1 end
	if flags > 1 then return fail(path, "only one of once/consumed/repeatable allowed") end

	if c.priority and type(c.priority) ~= 'number' then
		return fail(path .. ".priority", "must be number", c.priority)
	end

	-----------------------------------------------------------------
	-- transition validation
	-----------------------------------------------------------------
	if c.transition then
		if type(c.transition) == 'string' then
			if not maps.transitions[c.transition] then
				return fail(path .. ".transition", "ref not found", c.transition)
			end
		elseif type(c.transition) == 'table' then
			if c.transition.text then
				if type(c.transition.text) == 'table' then
					local err = validate_text(c.transition.text, path .. ".transition.text", maps.ctes)
					if err then return err end
				elseif type(c.transition.text) ~= 'string' then
					return fail(path .. ".transition.text", "must be string or table")
				end
			end

			if c.transition.target and type(c.transition.target) ~= 'string' then
				return fail(path .. ".transition.target", "must be string", c.transition.target)
			end
		else
			return fail(path .. ".transition", "must be string or table")
		end
	end

	-- effects
	if c.effects then
		local eff_list = type(c.effects) == 'string' and { c.effects } or c.effects
		for i, eff in ipairs(eff_list) do
			local epath = path .. ".effects[" .. i .. "]"

			if type(eff) == 'string' then
				if not maps.effects[eff] then
					return fail(epath, "effect ref not found", eff)
				end
			else
				if types.get_expr_type(eff) ~= 'assi' then
					return fail(epath, "effect must be assignment", eff)
				end
			end
		end
	end

	return nil
end

---------------------------------------------------------------------
-- node validation
---------------------------------------------------------------------
function validator.validate_node(node, path, maps)
	if not node.id then return fail(path, "node missing id") end

	for _, field in ipairs({ "visible", "condition" }) do
		local val = node[field]
		if val then
			if type(val) == 'string' then
				if not maps.conditions[val] then
					return fail(path .. "." .. field, "ref not found", val)
				end
			else
				local err = validate_expr(val, path .. "." .. field, "visibility")
				if err then return err end
			end
		end
	end

	if not node.text or type(node.text) ~= 'table' then
		return fail(path .. ".text", "must be table")
	end

	local err = validate_text(node.text, path .. ".text", maps.ctes)
	if err then return err end

	if node.stats then
		for i, item in ipairs(node.stats) do
			local line_err = validate_text({ item }, path .. ".stats[" .. i .. "]", maps.ctes)
			if line_err then return line_err end
		end
	end

	if node.choices then
		for i, c_ref in ipairs(node.choices) do
			local c_path = path .. ".choices[" .. i .. "]"

			if type(c_ref) == 'string' then
				if not maps.shared_choices[c_ref] then
					return fail(c_path, "choice ref not found", c_ref)
				end
			else
				local err = validate_choice_obj(c_ref, c_path, maps)
				if err then return err end
			end
		end
	end

	return nil
end

---------------------------------------------------------------------
-- main quest validation entrypoint
---------------------------------------------------------------------
function validator.validate_quest(data)
	if not data.start_node then return fail("root.start_node", "missing") end
	if not data.nodes then return fail("root.nodes", "missing") end

	local maps = {
		ctes = {},
		conditions = {},
		effects = {},
		transitions = {},
		shared_choices = {}
	}

	if data.ctes then
		for i, c in ipairs(data.ctes) do
			local path = "ctes[" .. i .. "]"

			if not c.id then return fail(path, "missing id") end
			maps.ctes[c.id] = c

			if not c.condition then return fail(path .. ".condition", "missing") end
			if not c["then"] then return fail(path .. ".then", "missing") end
		end
	end

	if data.conditions then
		for i, c in ipairs(data.conditions) do
			local path = "conditions[" .. i .. "]"

			if not c.id then return fail(path, "missing id") end
			maps.conditions[c.id] = c

			local err = validate_expr(c.expr, path .. ".expr", "condition")
			if err then return err end
		end
	end

	if data.effects then
		for i, e in ipairs(data.effects) do
			local path = "effects[" .. i .. "]"

			if not e.id then return fail(path, "missing id") end
			maps.effects[e.id] = e

			if not e.actions then return fail(path .. ".actions", "missing") end

			for j, act in ipairs(e.actions) do
				if types.get_expr_type(act) ~= 'assi' then
					return fail(path .. ".actions[" .. j .. "]", "must be assignment", act)
				end
			end
		end
	end

	if data.transitions then
		for i, t in ipairs(data.transitions) do
			local path = "transitions[" .. i .. "]"

			if not t.id then return fail(path, "missing id") end
			maps.transitions[t.id] = t

			if t.text and type(t.text) == 'table' then
				local err = validate_text(t.text, path .. ".text", maps.ctes)
				if err then return err end
			end

			if t.target and type(t.target) ~= 'string' then
				return fail(path .. ".target", "must be string", t.target)
			end
		end
	end

	if data.shared_choices then
		for i, c in ipairs(data.shared_choices) do
			local path = "shared_choices[" .. i .. "]"

			if not c.id then return fail(path, "missing id") end
			maps.shared_choices[c.id] = c

			local err = validate_choice_obj(c, path, maps)
			if err then return err end
		end
	end

	local start_found = false
	for _, n in ipairs(data.nodes) do
		if n.id == data.start_node then start_found = true break end
	end

	if not start_found then
		return fail("start_node", "not found", data.start_node)
	end

	for i, node in ipairs(data.nodes) do
		local err = validator.validate_node(node, "nodes[" .. i .. "]", maps)
		if err then return err end
	end

	return nil
end

return validator