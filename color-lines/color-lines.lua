
-- game about circles and field 9x9 tiles for them

-- License CC0 (Creative Commons license) (c) darkfrei, 2022

local pf = require ('pathfinding')

local beep = require ('beep')


-- color lines, lib table
local cl = {}

-- states
local menu = {}
local game = {}



-----------------------------------------
-------- draw special functions ---------
-----------------------------------------

local function drawField (x, y, w, h, isPressed)
	if isPressed then
		love.graphics.setColor (0,0,0)
		love.graphics.rectangle ('fill', x, y, w, h)
		
		love.graphics.setColor (0.45,0.45,0.45)
		love.graphics.rectangle ('fill', x+1, y+1, w-2, h-2)
		
		love.graphics.setColor (1,1,1)
		love.graphics.rectangle ('fill', x+3, y+3, w-4, h-4)
		love.graphics.setColor (0.70,0.70,0.65)
		love.graphics.rectangle ('fill', x+3, y+3, w-6, h-6)
	else
		love.graphics.setColor (0,0,0)
		love.graphics.rectangle ('fill', x, y, w, h)
		love.graphics.setColor (1,1,1)
		love.graphics.rectangle ('fill', x+1, y+1, w-2, h-2)
		love.graphics.setColor (0.45,0.45,0.45)
		love.graphics.rectangle ('fill', x+3, y+3, w-4, h-4)
		love.graphics.setColor (0.65,0.65,0.65)
		love.graphics.rectangle ('fill', x+3, y+3, w-6, h-6)
	end
end

local function hexadecagon (mode, x, y, radius) -- same as love.graphics.circle
	local w1, w2 = math.atan(0.21), math.atan(0.72) -- magic values
	local a = radius
	local b = radius*math.sin (w1)
	local c = radius*math.cos (w2)
	local d = radius*math.sin (w2)
	local vertices = {
		 a, b,  c, d,  d, c,  b, a, 
		-b, a, -d, c, -c, d, -a, b, 
		-a,-b, -c,-d, -d,-c, -b,-a, 
		 b,-a,  d,-c,  c,-d,  a,-b}
	love.graphics.translate (x+0.5, y+0.5)
	love.graphics.polygon (mode, vertices)
	love.graphics.translate (-x-0.5, -y-0.5)
end

local function drawFilledPolygon (vertices)
	local triangles = love.math.triangulate(vertices)
	for i, triangle in ipairs(triangles) do
		love.graphics.polygon("fill", triangle)
	end
end

local function hexadecagonMoon (mode, x, y, radius) -- same as love.graphics.circle
	local w1, w2 = math.atan(0.21), math.atan(0.72) -- magic values
	local a = radius
	local b = radius*math.sin (w1)
	local c = radius*math.cos (w2)
	local d = radius*math.sin (w2)
	local vertices = {
		
		 c-b*2.5/2,-d/2+b*2.5,
		 c,-d/2,
		 c,-d,  
		 a,-b,
		 a, b,  c, d,  
		 d, c,  b, a, 
		-b, a, 
		-d, c,
		 -d/2, c,
		 -d/2+b*2.5, c-b*2.5/2,
		 }
	love.graphics.translate (x+0.5, y+0.5)
--	love.graphics.polygon (mode, vertices)
	drawFilledPolygon (vertices)
	love.graphics.translate (-x-0.5, -y-0.5)
end

local function drawCircle (x, y, tileSize, color, isPressed)
	
	local dy = 0
	if isPressed then
		dy = 1
	end
	love.graphics.setColor (0,0,0)
	hexadecagon ('fill', x, y+dy, 0.4*tileSize+0.9)
	love.graphics.setColor (color)
	hexadecagon ('fill', x, y+dy, 0.4*tileSize)
	
	love.graphics.setColor (color[1]*2/3, color[2]*2/3, color[3]*2/3)
	hexadecagonMoon ('fill', x, y+dy, 0.4*tileSize)
	
	love.graphics.setColor ((color[1]+0.5)/1.5, (color[2]+0.5)/1.5, (color[3]+0.5)/1.5)
	hexadecagon ('fill', x-tileSize/8, y-tileSize/8+dy, 0.16*tileSize)
	
	love.graphics.setColor ((color[1]+7)/8, (color[2]+7)/8, (color[3]+7)/8)
	hexadecagon ('fill', x-tileSize/8, y-tileSize/8+dy, 0.1*tileSize)
	
--	love.graphics.setColor (1,1,1)
--	hexadecagon ('fill', x-tileSize/8, y-tileSize/8, 0.1*tileSize)
--	hexadecagonMoon ('fill', x-0.1*tileSize, y-0.1*tileSize, 0.1*tileSize)
	
end

local function drawCenteredText(rectX, rectY, rectWidth, rectHeight, text, isPressed)
	local font = love.graphics.getFont()
	local textWidth  = math.floor(font:getWidth(text))+0.5
	local textHeight = math.floor(font:getHeight())
	local dxy = 0
	if isPressed then 
		rectX = rectX + 2
		rectY = rectY + 2
	end
	love.graphics.print(text, rectX+rectWidth/2, rectY+rectHeight/2, 0, 1, 1, textWidth/2, textHeight/2)
end

--local colors = {
--	[0] = {1, 1, 1}, -- 0
--	{1, 0, 0}, -- 1
--	{1, 1, 0}, -- 2
--	{0, 1, 0}, -- 3
--	{0, 1, 1}, -- 4
--	{0, 0, 1}, -- 5
--	{1, 0, 1}, -- 6
--}

local colors = {
	[0] = {1, 1, 1}, -- 0
	{220/255,  40/255,  50/255}, -- 1 red
	{100/255, 200/255, 200/255}, -- 5 cyan
	
	{60/255,  170/255,  80/255}, -- 4 green
	{230/255, 220/255,  40/255}, -- 3 yellow
	{60/255,   70/255, 130/255}, -- 6 blue
	{230/255, 170/255,  40/255}, -- 2 orange
	{160/255,  70/255, 120/255}, -- 7 magenta
	{100/255,  50/255,  80/255}, -- 8 brown
}


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
			menu.hoveredButton = nil
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
------------- state "game" --------------
-----------------------------------------



local function getMouseTile (x, y)
	local field = game.field
	local fTileSize = field.tileSize
	local tx = math.floor ((x-field.x)/fTileSize)+1
	local ty = math.floor ((y-field.y)/fTileSize)+1
	if tx >= 1 and ty >= 1 and tx <= 9 and ty <=9 then
		return tx, ty
	end
end

local function getSafeMouseTile (x, y)
	local field = game.field
	local tx, ty = getMouseTile (x, y)
	
	if tx then
		field.tx, field.ty = tx, ty
	end
	return field.tx, field.ty
end

local function addBalls (amount, nColors)
	local emptyList = {}
	local field = game.field
	for y, xs in ipairs (field) do
		for x, value in ipairs (xs) do
			if value == 0 then
				table.insert (emptyList, {x=x, y=y})
			end
		end
	end
	
	if #emptyList <  amount then
		amount = #emptyList
	end
	print ('added ' .. amount .. ' balls' )
	
	for i = 1, amount do
		local iColor = math.random (nColors)
		local emptyCell = table.remove (emptyList, math.random(#emptyList))
		local x, y = emptyCell.x, emptyCell.y
		field[y][x] = iColor
	end
end

game.load = function ()
	cl.update = game.update 
	cl.draw = game.draw
	cl.mousepressed = game.mousepressed
	cl.mousemoved = game.mousemoved
	cl.mousereleased = game.mousereleased
	
	local w, h = love.graphics.getDimensions()
--	game.test1 = {x=0, y=0, w=w/8, h=h/8, text = "Game"}
--	game.test1.font = love.graphics.newFont(0.6*h/8)
	
	game.buttons = {
		{name = "exit", x=w*7/8, y=16, w=128+16, h=64+16, text='Exit'},
	}
	
	game.w, game.h = w, h
	
	game.nColors = 3
	
	game.field = {}
	game.field.x = 64*5.5
	game.field.y = 64*2
	game.field.tileSize = 64
	game.field.tx, game.field.ty = 0, 0
	
	for y = 1, 9 do
		game.field[y] = {}
		for x = 1, 9 do
			game.field[y][x] = 0
		end
	end
	
	addBalls (25, game.nColors) -- amount, nColors

	game.font = love.graphics.newFont(0.6*h/8)
end

local function checkSituation ()
	-- too complicated, but we can make cross!
	local results = {}
	
	-- horizontal
	for y = 1, #game.field do
		local c, list = nil, {}
		for x = 1, #game.field[1] do
			local color = game.field[y][x]
			if color == 0 then
				if #list >=5 then
					for i, v in ipairs (list) do
						table.insert (results, v)
					end
				end
			else
				
			end
		end
	end
end

game.update = function (dt)

	
	if game.animation then
--		local field = game.field
--		local fx, fy, fTileSize = field.x, field.y, field.tileSize
		local pathNodes = game.animation.path
		local node1 = pathNodes[1]
		local node2 = pathNodes[2]
		if node2 then
			if not node1.t then 
				node1.t = 0 
				beep ()
			end
			node1.t = node1.t + 4*dt
			if node1.t >= 1 then
				-- node is done
				node2.t = 0
				table.remove (pathNodes, 1)
				beep ()
			else
				-- (draw animation)
			end
		else
			-- no node2
			local x, y = node1.x, node1.y
			game.field[y][x] = game.animation.color
			
			game.animation = nil
			game.pathNodes = nil
			beep ()
			-- check the situation
			
		end
	end
end

local function isTilePressed (x, y)
	local pressed = false
	local hoveredTile = game.hoveredTile
	
	if game.selectedBall and game.selectedBall.x == x and game.selectedBall.y == y then
		pressed = true
	elseif game.pathNodes then
		for i, node in ipairs (game.pathNodes) do
			if node.x == x and node.y == y then
				pressed = true
				break
			end
		end
	elseif hoveredTile and hoveredTile.x == x and hoveredTile.y == y then
		pressed = true
	elseif game.nodeMap and game.nodeMap[y][x] then
		pressed = true
	end
	return pressed
end



local function drawAnimation ()
	local field = game.field
	local fx, fy, fTileSize = field.x, field.y, field.tileSize

	local animation = game.animation
	local pathNodes = animation.path
	
	local node1 = pathNodes[1]
	local node2 = pathNodes[2]
	local color = animation.color
	local t = node1.t or 0
	local dy = 4*(t-0.5)*(t-0.5)-1
	if node2 then
		local x = node1.x + t*(node2.x-node1.x)
		local y = node1.y + t*(node2.y-node1.y) + dy/4
		local rectX, rectY, rectWidth, rectHeight = fx+(x-1)*fTileSize, fy+(y-1)*fTileSize, fTileSize, fTileSize
		drawCircle (rectX+fTileSize/2, rectY+fTileSize/2, fTileSize, colors[color], false) 
	else
		local x = node1.x
		local y = node1.y
		local rectX, rectY, rectWidth, rectHeight = fx+(x-1)*fTileSize, fy+(y-1)*fTileSize, fTileSize, fTileSize
		drawCircle (rectX+fTileSize/2, rectY+fTileSize/2, fTileSize, colors[color], false) 
	end
end

game.draw = function ()
	local field = game.field
	local fx, fy, fTileSize = field.x, field.y, field.tileSize
	
	drawField (0, 0, game.w, fy-16)
	
	love.graphics.setFont(game.font)
--	drawCenteredText(100,100,100,100, "aAa " .. #game.buttons .. ' ' .. game.buttons[1].text)
	for i, button in ipairs (game.buttons) do
		drawField (button.x, button.y, button.w, button.h, button.hovered)
		
		love.graphics.setColor (0,0,0)
		drawCenteredText(button.x, button.y, button.w, button.h, button.text, button.hovered)
	end

	drawField (fx-8, fy-8, 9*fTileSize+16, 9*fTileSize+16)
	
	for y, xs in ipairs (game.field) do
		for x, value in ipairs (xs) do
			local rectX, rectY, rectWidth, rectHeight = fx+(x-1)*fTileSize, fy+(y-1)*fTileSize, fTileSize, fTileSize
			local pressed = isTilePressed (x, y)
			drawField (rectX, rectY, rectWidth, rectHeight, pressed)
		end
	end
	
	for y, xs in ipairs (game.field) do
		for x, value in ipairs (xs) do
			local rectX, rectY, rectWidth, rectHeight = fx+(x-1)*fTileSize, fy+(y-1)*fTileSize, fTileSize, fTileSize
			local pressed = isTilePressed (x, y)
			if value > 0 then
				drawCircle (rectX+fTileSize/2, rectY+fTileSize/2, fTileSize, colors[value], pressed) 
			end
		end
	end
	
	if game.animation then 
		drawAnimation ()
	end
	
	local tx, ty = getSafeMouseTile (love.mouse.getPosition())
	love.graphics.print (tx .. ' ' .. ty, 0, 50)
end



function game.mousepressed( x, y, button, istouch, presses )
	if game.hoveredButton then
		local name = game.hoveredButton.name
		if name == "start" then
			-- (not ready)
		elseif name == "exit" then
			-- set state to "menu"
			game.hoveredButton = nil
			menu.load ()
		end
	end
	
	local tx = game.hoveredTile and game.hoveredTile.x
	local ty = game.hoveredTile and game.hoveredTile.y
	
	if tx then
		local isBall = not (game.field[ty][tx] == 0)
		if isBall then
			-- selected ball
			if not game.selectedBall then
				game.selectedBall = {x=tx, y=ty, color=game.field[ty][tx]}
				local nodeMap, solutionFound = pf.getNodeMap (game.field, tx, ty, 1, 1)
				game.nodeMap = nodeMap
			elseif not (game.selectedBall.x == tx and game.selectedBall.y == ty) then
				-- new selected ball
				game.selectedBall = {x=tx, y=ty, color=game.field[ty][tx]}
				local nodeMap, solutionFound = pf.getNodeMap (game.field, tx, ty, 1, 1)
				game.nodeMap = nodeMap
				game.pathNodes = nil
			else

			end
		else
			-- selected free tile
			local gsb = game.selectedBall
			local gpn = game.pathNodes
			if gpn and #gpn > 1 then
				-- do the move
				local x1, y1 = gsb.x, gsb.y
				local color = game.field[y1][x1]
				game.field[y1][x1] = 0
--				game.field[ty][tx] = color
				game.animation = {path = game.pathNodes, color = color}
				-- move is done
				game.selectedBall = nil
--				game.pathNodes = nil
				game.nodeMap = nil
			end
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
	
	local tx, ty = getMouseTile (x, y)
	if tx then 
		game.hoveredTile = {x=tx, y=ty}
		local gsb = game.selectedBall
		if gsb and not (gsb.x == tx and gsb.y == ty) then
			local nodeMap = game.nodeMap
			if nodeMap[ty][tx] then
				local pathNodes = pf.getBackTrack (nodeMap, gsb.x, gsb.y, tx, ty)
				game.pathNodes = pathNodes
			else
				game.pathNodes = {}
			end
		end
	else
		game.hoveredTile = nil
	end
end

function game.mousereleased( x, y, button, istouch, presses )
	
end



-----------------------------------------
----------- load menu state -------------
-----------------------------------------
function cl.load ()
	menu.load ()
end


return cl