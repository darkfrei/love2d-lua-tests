-- test_formula.lua
-- run: luajit test_formula.lua

local Formula = {}
local FORMULA_DEBUG = false


-- ===== Formula implementation (copy from engine) =====

function Formula.replaceParams(str, params)
	if not str then return "0" end
	return string.gsub(str, "%[p(%d+)%]", function(n)
			return tostring(params[tonumber(n)] or 0)
		end)
end

function Formula.convertOperators(str)
	-- 1. логические операторы (сначала!)
	str = string.gsub(str, "&&", " and ")
	str = string.gsub(str, "%|%|", " or ")

	str = string.gsub(
		str,
		"!%s*([%w%[%]%(%)+%-%*/%%%.]+)",
		"(%1)==0"
	)

	-- унарное отрицание: !expr  -> not expr
	-- но НЕ трогаем ~= и !=
--	str = string.gsub(str, "!(%s*[%(%[])", " not %1")
	str = string.gsub(str, "!%s*", "not ")


	-- 2. сравнения
	str = string.gsub(str, "<>", "~=")
	str = string.gsub(str, "([^<>~=])=([^=])", "%1==%2")

	-- 3. div
	str = string.gsub(
		str,
		"([%w%]%[%+%-%*/%%%(%)%.]+)%s+div%s+([%w%]%[%+%-%*/%%%(%)%.]+)",
		"math.floor(%1 / %2)"
	)

	-- 4. mod
	str = string.gsub(
		str,
		"([%w%]%[%+%-%*/%%%(%)%.]+)%s+mod%s+([%w%]%[%+%-%*/%%%(%)%.]+)",
		"(%1 %% %2)"
	)

	return str
end


function Formula.eval(formula, params)
	if not formula or formula == "" then
		return 0
	end

	if FORMULA_DEBUG then
		print("[FORMULA] src:", formula)
	end

	local expr = Formula.replaceParams(formula, params)
	if FORMULA_DEBUG then
		print("[FORMULA] after replaceParams:", expr)
	end

	expr = Formula.convertOperators(expr)
	if FORMULA_DEBUG then
		print("[FORMULA] after convertOperators:", expr)
	end

	local f, err = load("return " .. expr)
	if not f then
		if FORMULA_DEBUG then
			print("[FORMULA] load error:", err)
		end
		return false, "parse error: " .. err
	end

	local ok, res = pcall(f)
	if not ok then
		if FORMULA_DEBUG then
			print("[FORMULA] runtime error:", res)
		end
		return false, "runtime error: " .. res
	end

	if FORMULA_DEBUG then
		print("[FORMULA] raw result:", res, type(res))
	end

	if type(res) == "boolean" then
		local v = res and 1 or 0
		if FORMULA_DEBUG then
			print("[FORMULA] bool -> int:", v)
		end
		return v
	end

	if type(res) == "number" then
		local v = math.floor(res)
		if FORMULA_DEBUG then
			print("[FORMULA] number -> int:", v)
		end
		return v
	end

	if FORMULA_DEBUG then
		print("[FORMULA] unsupported result type")
	end

	return 0
end



function Formula.check(formula, params)
	local r, err = Formula.eval(formula, params)
	if err then return false, err end
	return r ~= 0
end


-- ===== Test helpers =====

local function testEval(name, formula, params, expected)
	local res, err = Formula.eval(formula, params)
	if err or res ~= expected then
		print("[FAIL]", name, formula, "=>", res, "expected", expected, err or "")
	else
		print("[OK]  ", name)
	end
end

local function testCheck(name, formula, params, expected)
	local res, err = Formula.check(formula, params)
	if err or res ~= expected then
		print("[FAIL]", name, formula, "=>", res, "expected", expected, err or "")
	else
		print("[OK]  ", name)
	end
end

-- ===== Params =====

local testParams = {
	[1] = 513,
	[2] = 47,
	[3] = 0,
	[4] = 3,
}

-- ===== Tests =====

-- arithmetic
testEval("add", "1+2", {}, 3)
testEval("mul", "2*3+1", {}, 7)
testEval("brackets", "2*(3+1)", {}, 8)

-- params
testEval("param", "[p1]", testParams, 513)
testEval("missing param", "[p99]", testParams, 0)

-- div / mod
testEval("div", "[p1] div 256", testParams, 2)
testEval("mod", "[p1] mod 256", testParams, 1)
testEval("nested div", "([p1]+255) div 256", testParams, 3)

-- comparisons
testCheck("eq", "[p2]=47", testParams, true)
testCheck("neq", "[p2]<>47", testParams, false)
testCheck("gt", "[p4]>2", testParams, true)
testCheck("le", "[p4]<=2", testParams, false)

-- logic
testCheck("and", "[p4]>2 && [p2]=47", testParams, true)
testCheck("or", "[p4]<2 || [p2]=47", testParams, true)
testCheck("not", "![p3]", testParams, true)

-- real quest formula
testCheck("quest mod", "([p1] mod 256)=1", testParams, true)
testEval("quest div", "[p1] div 256", testParams, 2)

print("DONE")
