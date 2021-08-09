local menu = {}


local black = {0,0,0}
local white = {1,1,1}
local gray_90 = {229/255, 229/255, 229/255}
local gray_70 = {178/255, 178/255, 178/255}
local yellow = {1, 220/255, 60/255}

local fonts = {}

menu.background_color = black

menu.main_buttons = {
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


menu.settings_buttons = {
	{
		name = "change_color_white",
		text = "White",
		x = 80/800,
		y = 180/600,
		w = 280/800,
		h = 50/600
	},
	{
		name = "change_color_black",
		text = "Black",
		x = 420/800,
		y = 180/600,
		w = 280/800,
		h = 50/600
	},
	{
		name = "change_color_gray_70",
		text = "Gray 70",
		x = 80/800,
		y = 240/600,
		w = 280/800,
		h = 50/600
	},
	{
		name = "change_color_gray_90",
		text = "Gray 90",
		x = 420/800,
		y = 240/600,
		w = 280/800,
		h = 50/600
	},
	{
		name = "go_to_main_menu",
		text = "Back",
		x = 150/800,
		y = 320/600,
		w = 500/800,
		h = 50/600
	},
}

menu.credits_buttons = {
	{
		name = "text-field",
		text = [[Many thanks to
all Löve creators, 
specially for every
and every
and every
and every
and every
and every
and every
and every
and every
and every
and every
and every
and another good people]],
		x = 150/800,
		y = 180/600,
		w = 500/800,
		h = 280/600
	},
	
	{
		name = "go_to_main_menu",
		text = "Back",
		x = 150/800,
		y = 480/600,
		w = 500/800,
		h = 50/600
	},
}


menu.buttons = menu.main_buttons

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

function get_right_font (button, max_w, max_h, max_h2)
	local font = love.graphics.newFont(5)
	
	local text = button.text
	
	local tw = font:getWidth (text)
	local th = font:getHeight()
	local width, wrappedtext = font:getWrap( text, max_w)
	local n_lines = #wrappedtext
	
	for i = 1, 100 do
		
		local newfont = love.graphics.newFont(th+i)
		if newfont:getWidth (text) > max_w then
			-- not enough width
			button.text_size = th + i-1
			local prev_font = love.graphics.newFont(th+i-1)
--			print (prev_font:getWidth (text), prev_font:getHeight())
			return prev_font
		elseif n_lines > 1 and (th+i) > (max_h2-3*(th+i+1))/(n_lines) then
			-- multiline, not enough height
			button.text_size = th + i-1
			local prev_font = love.graphics.newFont(th+i-1)
--			print (prev_font:getWidth (text), prev_font:getHeight())
			return prev_font
		elseif (th+i) > max_h then
			-- one line, not enough height
			button.text_size = th + i-1
			local prev_font = love.graphics.newFont(th+i-1)
--			print (prev_font:getWidth (text), prev_font:getHeight())
			return prev_font
		end
	end
	
end

function draw_button_text (x, y, w, h, button)
	if not button.font then
		button.font = get_right_font (button, w, 0.6*h, h)
	end
	
	local text = button.text
	local font = button.font
	local tw = font:getWidth (text)
	local th = font:getHeight()
	local width, wrappedtext = font:getWrap( text, w )
--	print (text, tw, th, width, #wrappedtext)

	love.graphics.setFont( font )
--	love.graphics.print( text, x+w/2-tw/2, y+h/2-th/2, 0, 1, 1, 0, 0)
	love.graphics.print( text, x+w/2-tw/2, y+h/2+th*(-#wrappedtext)/2, 0, 1, 1, 0, 0)
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
	
	love.graphics.setBackgroundColor (menu.background_color)
	
--	love.graphics.setColor(black)
	local width, height = love.graphics.getDimensions( )
	draw_logo (width, height)
	
	
	local mx, my = love.mouse.getPosition()
	for i, button in pairs (menu.buttons) do
		local x = math.floor (button.x*width)
		local y = math.floor (button.y*height)
		local w = math.floor (button.w*width)
		local h = math.floor (button.h*height)
		if is_button_selected (x, y, w, h, mx, my) and not (button.name == "text-field") then
--			love.graphics.setColor(gray_90)
			love.graphics.setColor(yellow)
			love.graphics.rectangle('fill', x, y, w, h)
			love.graphics.setColor(black)
			draw_button_text (x, y, w, h, button)
		else
			love.graphics.setColor(black)
			love.graphics.rectangle('fill', x, y, w, h)
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
			elseif button.name == 'settings' then
				menu.buttons = menu.settings_buttons
			elseif button.name == 'change_color_white' then
				menu.background_color = white
			elseif button.name == 'change_color_black' then
				menu.background_color = black
			elseif button.name == 'change_color_gray_70' then
				menu.background_color = gray_70
			elseif button.name == 'change_color_gray_90' then
				menu.background_color = gray_90
			elseif button.name == 'credits' then
				menu.buttons = menu.credits_buttons
			elseif button.name == 'go_to_main_menu' then
				menu.buttons = menu.main_buttons
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