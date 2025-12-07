-- main.lua
-- example usage of luaml.lua inside love2d


local luaml = require("parser-luaml")

local decodedTable = {}
local encodedAsGlobal = ''




local function deepCompare(a,b)
	if type(a) ~= type(b) then return false end
	if type(a) ~= "table" then return a==b end

	for k,v in pairs(a) do
		if not deepCompare(v,b[k]) then return false end
	end
	for k,v in pairs(b) do
		if not deepCompare(v,a[k]) then return false end
	end
	return true
end


function love.load()
	-- 1. Load the string and parse as table:
	local file1 = io.open("test_data_load.luaml", "r")
	decodedTable = luaml.decode(file1:read("*a"))
	file1:close()

	if not decodedTable then

		error ('no table')
	end

-- 2. Save the table as serialized string to the file:
	local file2 = io.open("test-data-saved-global.luaml", "w")
	encodedAsGlobal = luaml.encode(decodedTable)
	file2:write(encodedAsGlobal)
	file2:close()
	print("Saved big table to test-data-saved-global.luaml")

	-- 3. Save the table as serialized string to the file:
	local file3 = io.open("test-data-saved-table.luaml", "w")
	local encodedAsTable = luaml.encode(decodedTable, true)
	file3:write(encodedAsTable) -- table
	file3:close()
	print("Saved big table to test-data-saved-table.luaml")

	love.graphics.setFont(love.graphics.newFont (20))
	love.window.setMode(1280, 800)
end

local function drawTable(tbl, x, y, dy, indent)
	indent = indent or 0
	local prefix = string.rep("  ", indent+1)

	if indent == 0 then
		love.graphics.print("{", x, y)
		y = y + dy
	end

	for k,v in pairs(tbl) do
		if type(v) == "table" then
			love.graphics.print(prefix .. tostring(k) .. " = {", x, y)
			y = y + dy
			y = drawTable(v, x, y, dy, indent + 1)
			love.graphics.print(prefix .. "}", x, y)
			y = y + dy
		else
			local key = tostring(k)
			if type (k) == "number" then
				key = '['..key..']'
			end
			love.graphics.print(prefix .. key .. " = " .. tostring(v), x, y)
			y = y + dy
		end
	end

	if indent == 0 then
		love.graphics.print("}", x, y)
		y = y + dy
	end

	return y
end

function love.draw()
	love.graphics.setColor(1, 1, 1)

	love.graphics.print("encoded LuaML table to string:", 20, 20)
	love.graphics.printf(encodedAsGlobal, 20, 50, 860)

	local x = 400
	local y = 20
	local dy = 24

	love.graphics.print("decoded LuaML string to table:", x, y)

	y = y + dy
	drawTable(decodedTable, x, y, dy, 0, true)
end

