
-- game about circles and field 9x9 tiles for them

-- License CC0 (Creative Commons license) (c) darkfrei, 2022


-- color lines, lib table
local cl = {}


local menu = {}
local game = {}



-----------------------------------------
-------- draw special functions ---------
-----------------------------------------

local function drawCenteredText(rectX, rectY, rectWidth, rectHeight, text, font)
	font       = font or love.graphics.getFont()
	local textWidth  = math.floor(font:getWidth(text))+0.5
	local textHeight = math.floor(font:getHeight())
	love.graphics.line (rectX, rectY, rectX+rectWidth, rectY+rectHeight)
	love.graphics.line (rectX+rectWidth, rectY, rectX, rectY+rectHeight)
	love.graphics.print(text, rectX+rectWidth/2, rectY+rectHeight/2, 0, 1, 1, textWidth/2, textHeight/2)
end


-----------------------------------------
------------- state "game" --------------
-----------------------------------------

game.load = function ()
	cl.update = game.update 
	cl.draw = game.draw
	cl.mousepressed = game.mousepressed
	cl.mousemoved = game.mousemoved
	cl.mousereleased = game.mousereleased
	
	local w, h = love.graphics.getDimensions()
	game.test1 = {x=0, y=0, w=w/8, h=h/8, text = "test1"}
	game.test1.font = love.graphics.newFont(0.6*h/8)
	
	game.buttons = {
	{name = "exit", x=w*7/8, y=0, w=w*1/8, h=h/8, text='Exit'},
	}
	game.font = love.graphics.newFont(0.6*h/8)
end

game.update = function (dt)
	
end

game.draw = function ()
	love.graphics.setFont(game.test1.font)
	drawCenteredText(game.test1.x, game.test1.y, game.test1.w, game.test1.h, game.test1.text)

	love.graphics.setFont(game.font)
--	drawCenteredText(100,100,100,100, "aAa " .. #game.buttons .. ' ' .. game.buttons[1].text)
	for i, button in ipairs (game.buttons) do
		if button.hovered then
			love.graphics.setColor (0.3, 0.4, 0.5)
			love.graphics.rectangle ('fill', button.x, button.y, button.w, button.h)
		end
		love.graphics.setColor (1,1,1)
		love.graphics.rectangle ('line', button.x, button.y, button.w, button.h)
		
		drawCenteredText(button.x, button.y, button.w, button.h, button.text)
		
	end
end

function game.mousepressed( x, y, button, istouch, presses )
	if game.hoveredButton then
		local name = game.hoveredButton.name
		if name == "start" then
			-- (not ready)
			game.load () -- set state to "game"
		elseif name == "exit" then
			menu.load ()
		end
	end
end

function game.mousemoved( x, y, dx, dy, istouch )
	for i, button in ipairs (game.buttons) do
		button.hovered = false
	end
	game.hoveredButton = nil
	for i = #game.buttons, 1, -1 do
		local button = game.buttons[i]
		if (x>button.x and x<button.x+button.w)
			and (y>button.y and y<button.y+button.h) then
			if not istouch then button.hovered = true end
			game.hoveredButton = button
			return
		end
	end
end

function game.mousereleased( x, y, button, istouch, presses )
	
end


-----------------------------------------
------------- state "menu" --------------
-----------------------------------------

menu.load = function ()
	cl.update = menu.update 
	cl.draw = menu.draw
	cl.mousepressed = menu.mousepressed
	cl.mousemoved = menu.mousemoved
	cl.mousereleased = menu.mousereleased
	
	
	local w, h = love.graphics.getDimensions()
	menu.buttons = {
	{name = "start", x=w/4, y=h/2,   w=w/2, h=h/8, text='Start'},
	{name = "exit",  x=w/4, y=h*3/4, w=w/2, h=h/8, text='Exit'},
	}
	menu.font = love.graphics.newFont(0.6*h/8)
end

menu.update = function (dt)
	
end

menu.draw = function ()
	love.graphics.setFont(menu.font)
	for i, button in ipairs (menu.buttons) do
		if button.hovered then
			love.graphics.setColor (0.3, 0.4, 0.5)
			love.graphics.rectangle ('fill', button.x, button.y, button.w, button.h)
		end
		love.graphics.setColor (1,1,1)
		love.graphics.rectangle ('line', button.x, button.y, button.w, button.h)
		drawCenteredText(button.x, button.y, button.w, button.h, button.text)
	end
end

function menu.mousepressed( x, y, button, istouch, presses )
	if menu.hoveredButton then
		local name = menu.hoveredButton.name
		if name == "start" then
			-- (not ready)
			game.load () -- set state to "game"
		elseif name == "exit" then
			love.event.quit()
		end
	end
end

function menu.mousemoved( x, y, dx, dy, istouch )
	for i, button in ipairs (menu.buttons) do
		button.hovered = false
	end
	menu.hoveredButton = nil
	for i = #menu.buttons, 1, -1 do
		local button = menu.buttons[i]
		if (x>button.x and x<button.x+button.w)
			and (y>button.y and y<button.y+button.h) then
			if not istouch then button.hovered = true end
			menu.hoveredButton = button
			return
		end
	end
end

function menu.mousereleased( x, y, button, istouch, presses )
	
end






-----------------------------------------
----------- load menu state -------------
-----------------------------------------
function cl.load ()
	menu.load ()
end


return cl