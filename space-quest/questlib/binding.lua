local binding = {}

-- =========================================
-- CONFIG
-- =========================================

binding.debug = false

-- =========================================
-- INTERNAL HELPERS
-- =========================================

local function isToken(v)
	return type(v) == "string"
	and v:sub(1, 1) == "<"
	and v:sub(-1) == ">"
end

local function unwrap(v)
	return v:sub(2, -2)
end

-- =========================================
-- VALUE RESOLUTION
-- =========================================

-- resolves single value (<var> or raw)
function binding.resolve(v, state)
	if isToken(v) then
		local key = unwrap(v)
		local val = state[key]

		if val == nil and binding.debug then
			print("[binding] undefined variable: " .. key)
		end

		return val
	end

	return v
end

-- resolves full expression tree (for evaluator)
function binding.resolveExpr(expr, state)
	if type(expr) ~= "table" then
		return binding.resolve(expr, state)
	end

	local out = {}
	for i, v in ipairs(expr) do
		out[i] = binding.resolveExpr(v, state)
	end
	return out
end

-- =========================================
-- MARKDOWN TEXT PIPELINE
-- =========================================

-- IMPORTANT:
-- we keep markdown untouched, only replace <var> BEFORE parsing

function binding.interpolate(str, state)
	return (str:gsub("<([%w_]+)>", function(key)
				local val = state[key]
				return tostring(val ~= nil and val or "")
			end))
end

-- applies interpolation to mixed segment arrays (pre-markdown step)
function binding.interpolateSegments(segments, state)
	local out = {}

	for i, seg in ipairs(segments) do
		if type(seg) == "string" then
			out[i] = binding.interpolate(seg, state)
		else
			out[i] = seg
		end
	end

	return out
end

-- =========================================
-- STATE ACCESS (optional sugar)
-- =========================================

function binding.get(state, key)
	return state[key]
end

function binding.set(state, key, value)
	state[key] = value
end

-- =========================================
-- TOKENS API
-- =========================================

function binding.isToken(v)
	return isToken(v)
end

function binding.unwrap(v)
	return unwrap(v)
end

return binding