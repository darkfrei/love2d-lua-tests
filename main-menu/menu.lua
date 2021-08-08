local menu = {}


local black = {0,0,0}
local white = {1,1,1}
local gray_90 = {229/255, 229/255, 229/255}
local gray_70 = {178/255, 178/255, 178/255}
local yellow = {1, 220/255, 60/255}

local fonts = {}


menu.buttons = {
	{
		name = "new",
		text = "New game",
		x = 150/800,
		y = 180/600,
		w = 500/800,
		h = 50/600
	},
	{
		name = "load",
		text = "Load",
		x = 150/800,
		y = 240/600,
		w = 500/800,
		h = 50/600
	},
	{
		name = "save",
		text = "Save",
		x = 150/800,
		y = 300/600,
		w = 500/800,
		h = 50/600
	},
	{
		name = "settings",
		text = "Settings",
		x = 150/800,
		y = 360/600,
		w = 500/800,
		h = 50/600
	},
	{
		name = "credits",
		text = "Credits",
		x = 150/800,
		y = 420/600,
		w = 500/800,
		h = 50/600
	},
	
	{
		name = "exit",
		text = "Exit",
		x = 150/800,
		y = 480/600,
		w = 500/800,
		h = 50/600
	},
}

menu.logo = {
	x = 150/800,
	y = 20/600,
	w = 500/800,
	h = 140/600,
	image = love.graphics.newImage( 'menu-background.png' )
}

function menu.load()
--	menu_background = love.image.newImageData( 'menu-background.png' )
--	menu_background = 
end

function menu.update()
	
end

function get_right_font (button, max_w, max_h)
	local font = love.graphics.newFont(10)
	
	local text = button.text
	
	local tw = font:getWidth (text)
	local th = font:getHeight()
	
	for i = 1, 100 do
		
		local newfont = love.graphics.newFont(th+i)
		if newfont:getWidth (text) > max_w then
			button.text_size = th + i-1
			local prev_font = love.graphics.newFont(th+i-1)
--			print (prev_font:getWidth (text), prev_font:getHeight())
			return prev_font
		elseif th+i > max_h then
			button.text_size = th + i-1
			local prev_font = love.graphics.newFont(th+i-1)
--			print (prev_font:getWidth (text), prev_font:getHeight())
			return prev_font
		end
	end
	
end

function draw_button_text (x, y, w, h, button)
	if not button.font then
		button.font = get_right_font (button, w, 0.6*h)
	end
	
	local text = button.text
	local font = button.font
	local tw = font:getWidth (text)
	local th = font:getHeight()
	love.graphics.setFont( font )
	love.graphics.print( text, x+w/2-tw/2, y+h/2-th/2, 0, 1, 1, 0, 0)
end

function is_button_selected (x, y, w, h, mx, my)
	if mx >= x and mx <= (x+w) and my >= y and my <= (y+h) then
		return true
	end
	return false
end

function draw_logo (width, height)
	love.graphics.setColor(white)
	local x = menu.logo.x*width
	local y = menu.logo.y*height
	local sx = menu.logo.w*width/menu.logo.image:getWidth()
	local sy = menu.logo.h*height/menu.logo.image:getHeight()
	love.graphics.draw(menu.logo.image, x, y, 0, sx, sy)
end

function menu.draw()
	
	
	
--	love.graphics.setColor(black)
	local width, height = love.graphics.getDimensions( )
	draw_logo (width, height)
	
	
	local mx, my = love.mouse.getPosition()
	for i, button in pairs (menu.buttons) do
		local x = math.floor (button.x*width)
		local y = math.floor (button.y*height)
		local w = math.floor (button.w*width)
		local h = math.floor (button.h*height)
		if is_button_selected (x, y, w, h, mx, my) then
--			love.graphics.setColor(gray_90)
			love.graphics.setColor(yellow)
			love.graphics.rectangle('fill', x, y, w, h)
			love.graphics.setColor(black)
			draw_button_text (x, y, w, h, button)
		else
--			love.graphics.setColor(white)
			love.graphics.setColor(yellow)
			love.graphics.rectangle('line', x, y, w, h)
			love.graphics.setColor(yellow)
			draw_button_text (x, y, w, h, button)
		end
		
	end
end




function menu.mousepressed(x, y, button, istouch, presses)
	local width, height = love.graphics.getDimensions( )
	
	
	
	for i, button in pairs (menu.buttons) do
		local bx = math.floor (button.x*width)
		local by = math.floor (button.y*height)
		local bw = math.floor (button.w*width)
		local bh = math.floor (button.h*height)
		if is_button_selected (bx, by, bw, bh, x, y) then
			if button.name == 'exit' then
				love.event.quit()
			end
		end
	end
end

function menu.resize()
	for i, button in pairs (menu.buttons) do
		button.font = nil
	end
end

------------------------------------------------------------
-- not used
------------------------------------------------------------

function menu.mousemoved( x, y, dx, dy, istouch )
	
end

function menu.mousereleased (x, y, button, istouch, presses)
	
end

function menu.keypressed (key, scancode, isrepeat)
	
end



return menu