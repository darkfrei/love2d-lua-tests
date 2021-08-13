

local game = {}

function game.create_level ()
	local level = {}
	level.buildings = {}
	local building = {}
	building.color = {0.4, 0.8, 0.3}
--	building.vertices = {100,100, 200,100, 200,200, 300,200, 300,300, 100,300}
	building.vertices = {800,400, 880,320, 1040,320, 1120,400, 1120,560, 1040,640, 880,640, 800,560}
	table.insert (level.buildings, building)
	return level
end

function get_screen_values ()
	local width, height = love.graphics.getDimensions( )
	local vrez = 40 -- virtual resolution, no scale (scale=1) on fullHD
	local n_cols, n_rows = 48, 27
	local rez = math.min(width/48, height/27)
	
	local scale = rez/vrez
	local dx, dy = (width-n_cols*rez)/2, (height-n_rows*rez)/2
	n_rows = 24 -- two rows for GUI
	return {dx=dx, dy=dy, scale=scale, vrez=vrez, rez=rez, n_cols=n_cols, n_rows=n_rows}
end

function game.new_game ()
	game.world = {}
	
--	game.levels = {}
--	game.n_level = 1
	
	game.level = game.create_level ()
	
--	screen = {dx=0, dy=0, scale=1, vrez=40}
	screen = get_screen_values ()
	
end

local gui_img = love.graphics.newImage( 'graphics/game-buttons.png' )
game.gui = {x=320, y=1000, w=gui_img:getWidth( ), h=gui_img:getHeight( ), image = gui_img}
game.gui.buttons = {}
local button_size = 80
for i = 1, 16 do
	local button = {x=game.gui.x+(i-1)*button_size, y=game.gui.y, w=button_size, h=button_size}
	table.insert (game.gui.buttons, button)
end


function game.update (dt)
	
end

local function draw_polygone (vertices)
	local triangles = love.math.triangulate(vertices)
	for i, triangle in ipairs(triangles) do
		love.graphics.polygon("fill", triangle)
	end
end

function game.draw_grid ()
	love.graphics.setLineWidth (1)
	love.graphics.setColor (0.1, 0.1, 0.1)
	local vrez = screen.vrez
	for i = 1, screen.n_cols do
		for j = 1, screen.n_rows do
			love.graphics.rectangle('line', (i-1)*vrez, (j-1)*vrez, vrez, vrez)
		end
	end
end

function game.draw_buildings ()
	local buildings = game.level.buildings
	for i, building in pairs (buildings) do
		love.graphics.setColor (building.color)
		draw_polygone (building.vertices)
	end
end


function game.draw_mouse (vrez)
	local mx, my = love.mouse.getPosition ()
	love.graphics.setColor (1,1,1)
	love.graphics.circle('line', mx, my, screen.rez/2)
	love.graphics.print(mx..' '..my, mx, my)
end

function draw_gui ()
	love.graphics.setColor(1,1,1)
	local x = game.gui.x
	local y = game.gui.y
--	local sx = 
	local sx = game.gui.w/game.gui.image:getWidth()
	local sy = game.gui.h/game.gui.image:getHeight()
	love.graphics.draw(game.gui.image, x, y, 0, sx, sy)
	
	love.graphics.setColor(1,1,1)
	love.graphics.setLineWidth(3)
	for i, button in pairs (game.gui.buttons) do
		if button.selected then
			love.graphics.rectangle('line', button.x, button.y, button.w, button.h)
		end
	end
end

function game.draw ()
	love.graphics.push()
	love.graphics.scale (screen.scale)
	love.graphics.translate(screen.dx, screen.dy)
	
	
	game.draw_grid ()
	
	game.draw_buildings ()
	
	draw_gui ()
	
	love.graphics.pop()
	
	game.draw_mouse ()
	
	love.graphics.print (screen.scale)
	love.graphics.print (screen.dx..' '..screen.dy,0, 40)
end

------------------------------------------------------------

function game.mousepressed(x, y, button, istouch, presses)
	
end

function game.mousemoved( x, y, dx, dy, istouch )
	for i, button in pairs (game.gui.buttons) do
		local sdx, sdy = screen.dx, screen.dy
		local s = screen.scale
		local bx = (button.x + sdx)*s
		local by = (button.y + sdy)*s
		local bw = button.w*s
		local bh = button.h*s
		if is_button_selected (bx, by, bw, bh, x, y) then
			button.selected = true
		else
			button.selected = false
		end
	end
end

function game.mousereleased (x, y, button, istouch, presses)
	
end

function game.keypressed (key, scancode, isrepeat)
	
end

function game.resize()
	screen = get_screen_values ()
end

return game