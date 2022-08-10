-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local ST = require ('save-tsv')

function love.load()
	NiceTable = ST.load ("savegame")
	button = {name = "a", value = NiceTable.a}
end

 
function love.update(dt)
	
end


function love.draw()
	love.graphics.print ('press A or C to save the file', 0, 0)
	
--	love.graphics.print ('a	' .. tostring(NiceTable.a), 0, 20)
--	love.graphics.print ('c	' .. tostring(NiceTable.c), 0, 40)
	local i = 1
	for index, strtabl in pairs (NiceTable) do
		ST.print (index, strtabl, 0, i*20)
		i = i+1
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif scancode == "a" then
		NiceTable.a = not NiceTable.a
		ST.save ("savegame", NiceTable)
	elseif scancode == "c" then
		NiceTable.c = not NiceTable.c
		ST.save ("savegame", NiceTable)
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end