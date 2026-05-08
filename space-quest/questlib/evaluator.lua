local evaluator = {}
local types = require('questlib.types')
local markdown = require('questlib.markdown')

-- resolve expression against state. mutates state for assignments only.
function evaluator.resolve(expr, state)
	if type(expr) ~= 'table' then
		if type(expr) == 'string' and expr:sub(1, 1) == '<' and expr:sub(-1) == '>' then
			local key = expr:sub(2, -2)
			return state[key] ~= nil and state[key] or false
		end
		return expr
	end

	-- 1. Handle ternary operator: {"?", condition, then_val, else_val}
	if expr[1] == '?' then
		local cond = evaluator.resolve(expr[2], state)
		if cond then
			return evaluator.resolve(expr[3], state)
		else
			return expr[4] and evaluator.resolve(expr[4], state) or nil
		end
	end

	local etype = types.get_expr_type(expr)

	-- 2. Handle CTE / Snippet injection
	if etype == 'cte' or etype == 'snippet' then
		local cond = evaluator.resolve(expr[2], state)
		if cond then
			return evaluator.resolve(expr[3], state)
		else
			return expr[4] and evaluator.resolve(expr[4], state) or nil
		end
	end

	local left = evaluator.resolve(expr[1], state)
	local op = expr[2]
	local right = evaluator.resolve(expr[3], state)

	-- Fallback for nil operands in comparisons/math
	if left == nil then left = (types.comp_ops[op] or types.expr_ops[op]) and 0 or false end
	if right == nil then right = (types.comp_ops[op] or types.expr_ops[op]) and 0 or false end

	if types.comp_ops[op] then
		if op == '==' then return left == right end
		if op == '!=' then return left ~= right end
		if op == '<'  then return left <  right end
		if op == '>'  then return left >  right end
		if op == '<=' then return left <= right end
		if op == '>=' then return left >= right end
	end

	if types.expr_ops[op] then
		if op == '+' then return left + right end
		if op == '-' then return left - right end
		if op == '*' then return left * right end
		if op == '/' then return right ~= 0 and left / right or 0 end
		if op == '%' then return right ~= 0 and left % right or 0 end
	end

	if types.assi_ops[op] then
		local key = types.is_var(expr[1]) and types.unwrap_var(expr[1])
		if not key then
			print("[evaluator] WARN: assignment target not recognized:", tostring(expr[1]))
			return nil
		end
		local cur = state[key] or 0

		print("[evaluator] ASSIGN BEFORE:", key, "=", cur, "| op:", op, "| val:", right)

		if op == '=' then
			state[key] = right
		elseif op == '+=' then
			state[key] = cur + right
		elseif op == '-=' then
			state[key] = cur - right
		elseif op == '*=' then
			state[key] = cur * right
		elseif op == '/=' then
			state[key] = right ~= 0 and cur / right or cur
		end

		print("[evaluator] ASSIGN AFTER:", key, "=", state[key])
		return nil
	end

	return nil
end

-- pipeline: string -> split vars -> markdown per segment -> merge
-- safe against raw string inputs
function evaluator.parse_text(raw_segments, state)
	if type(raw_segments) == 'string' then
		raw_segments = { raw_segments }
	end
	local final = {}

	for _, seg in ipairs(raw_segments) do
		local str = tostring(evaluator.resolve(seg, state) or "")
		local i = 1

		while true do
			local s, e, key = str:find("<([%w_]+)>", i)

			if not s then
				local tail = str:sub(i)
				if #tail > 0 then
					for _, m in ipairs(markdown.parse(tail)) do
						table.insert(final, m)
					end
				end
				break
			end

			if s > i then
				for _, m in ipairs(markdown.parse(str:sub(i, s - 1))) do
					table.insert(final, m)
				end
			end

			table.insert(final, {
				text = tostring(state[key] or ""),
				highlight = true
			})

			i = e + 1
		end
	end

	return final
end

return evaluator