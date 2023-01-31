-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local ST = require ('save-tsv')

function love.load()
	NiceTable = ST.load ("savegame")
end
 
function love.update(dt)
	
end

function love.draw()
	love.graphics.print ('press A or C to change the value and save the file', 0, 0)
	love.graphics.print ('press X to restore file', 0, 20)
	local i = 1
	for index, strtabl in pairs (NiceTable) do
		ST.print (index, strtabl, 0, (i+1)*20)
		i = i+1
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif scancode == "x" then
		ST.remove ("savegame")
		NiceTable = ST.load ("savegame")
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
