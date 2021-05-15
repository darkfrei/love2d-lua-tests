local utf8 = require("utf8")


function love.load()
	
	love.window.setMode(480,640)
	Font = love.graphics.getFont( )
	font_height = Font:getHeight( )


	local date = os.date("*t")
	local year = date.year
	local month = 	string.format("%02d", date.month) 	-- 01 to 12
	local day = 	string.format("%02d", date.day) 	-- 01 to 31
	local yday = 	string.format("%03d", date.yday) 	-- 001 to 366
	local hour = 	string.format("%02d", date.hour) 	-- 00 to 24
	local min = 	string.format("%02d", date.min) 	-- 00 to 60
	filename = year..'-'..month..'-'..day
	print(filename)
	love.filesystem.write(filename..'.csv', "")
	
	screen={x=0, y=0}
	tabl = {}
	button_add = {radius = 20, plus = "+", x=50, y=50, text="Toyota", temp_text="temp_text", pressed = false}
	
end
 
 
function love.update(dt)
	
end
 
 
function love.draw()
    local touches = love.touch.getTouches()
 
    for i, id in ipairs(touches) do
        local x, y = love.touch.getPosition(id)
        love.graphics.circle("fill", x, y, 20)
		love.graphics.print('x: '..x..' y: '..y, x+20, y-font_height/2)
    end
	
	pixelwidth, pixelheight = love.graphics.getPixelDimensions( )
	love.graphics.print('pixelwidth: '..pixelwidth..' pixelheight: '..pixelheight, 64, 64)
	
	width, height = love.graphics.getDimensions( )
	love.graphics.print('width: '..width..' height: '..height, 64, 100)
	
	love.graphics.circle("line", width/2, height/2, math.min(width/2, height/2))
	
	--
	if button_add.pressed then
--		button_add.pressed = false
		love.graphics.circle("fill", button_add.x, button_add.y, button_add.radius)
	else
		love.graphics.circle("line", button_add.x, button_add.y, button_add.radius)
		local xshift = Font:getWidth(button_add.plus)
		love.graphics.print(button_add.plus, button_add.x-xshift/2, button_add.y-font_height/2)
	end
	love.graphics.print(button_add.text, button_add.x+button_add.radius+5, button_add.y-font_height/2)
end

function love.textinput(t)
    button_add.text = button_add.text .. t
end

function do_click(click)
	local sq_dist = (click.x-button_add.x)^2+(click.y-button_add.y)^2
	if sq_dist <  400 then
		if button_add.pressed then
			button_add.pressed = false
			love.keyboard.setTextInput( false, 
				button_add.x+button_add.radius+5, button_add.y-font_height,
				200, 2*font_height)
			love.textinput( button_add.temp_text )
		else
			button_add.pressed = true
			love.keyboard.setTextInput( true, button_add.x+button_add.radius+5, button_add.y-font_height,
				200, 2*font_height)
--			love.textinput( button_add.temp_text )
		end
	end

end

function love.touchpressed( id, x, y, dx, dy, pressure )
	love.system.vibrate(0.1)
end

function love.touchreleased( id, x, y, dx, dy, pressure )
	do_click({id=id,x=x,y=y,dx=dx,dy=dy})
end

--function love.mousepressed(x, y, button, istouch, presses)
function love.mousereleased(x, y, button)
	if button == 1 then
		do_click({button ,x=x,y=y,istouch=istouch, presses=presses})
	end
end

function love.keypressed(key)
    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(button_add.text, -1)
 
        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            button_add.text = string.sub(button_add.text, 1, byteoffset - 1)
        end
    end
end