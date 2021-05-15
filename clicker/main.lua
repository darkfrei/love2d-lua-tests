local font = love.graphics.getFont()
local h_text = font:getHeight( )

local filename = 'clicker-table-01.tsv'

function open_tsv (filename)
	local tabl = {}
	local info = love.filesystem.getInfo(filename)
	local file
	if info then
		print ('file exists')
		lines = love.filesystem.lines(filename)
		local j = 1
		local names = {}
		for line in lines do
			local i = 1
			for value in (string.gmatch(line, "[^%s]+")) do -- tab separated values
				if (j == 1) then
					tabl[value]={}
					names[i]=value
					print ('i:'..i..' name: '..value)
				else
					local name = names[i]
					print ('i'..i)
					local n = #tabl[name]+1
					tabl[name][n]=value
				end
				i=i+1
			end
			j=j+1
		end
	else
		local success, message =love.filesystem.write( filename, "")
		if success then 
			print ('file created')
		else 
			print ('file not created: '..message)
		end
	end
	
	return tabl
end

local tabl = open_tsv (filename)

for i,j in pairs (tabl) do
	for k,l in pairs (j) do
		print (i..'	'..l)
	end
end


function love.load()
	c = {x=0, y=0, t=0} -- cursor position, time to live
	
	love.window.setMode(360,640) -- phone
	
	t = -- translate
	{
		y=0,
		dy=0,
		mouse_pressed = false
	}
end
 
 
function love.update(dt)
	local mx = love.mouse.getX()
	local my = love.mouse.getY()
	if love.mouse.isDown(1) then
		if t.mouse_pressed then
			t.y=my+t.dy
			if t.y > 0 then t.y = 0 end
		else
			t.dy=t.y-my
			t.mouse_pressed = true
		end
		love.graphics.line (c.x, c.y, mx, my)
	elseif t.mouse_pressed then
		c.x, c.y = mx, my
		t.mouse_pressed = false
	end
end

function update_Y ()

	love.graphics.print(t.y)
	love.graphics.translate(0, t.y)
	
end
 
 
function love.draw()
	love.graphics.circle('fill', c.x, c.y, 4)
	if t.mouse_pressed then
		love.graphics.line (c.x, c.y, love.mouse.getX(), love.mouse.getY())
		love.graphics.circle('fill', love.mouse.getX(), love.mouse.getY(), 4)
	end
	update_Y ()
--	love.graphics.print(gui.input, gui.x, gui.y)
	
	
	--gui.draw()
	
end


--function love.touchpressed( id, x, y, dx, dy, pressure )
--	love.system.vibrate(0.1)
	
--end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- Versions prior to 0.10.0 use the MouseConstant 'l'
		c.x = x
		c.y = y
--		gui.button_pressed ( x, y, button, istouch, presses )
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key and key:match( '^[%w%s]$' ) then gui.input = gui.input..key end
	if key == "space" then gui.input = gui.input..' ' end
	if key == "return" then 
		print (gui.input)
		gui.add_button(gui.input)
		gui.input = ""
	end
    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
--        local byteoffset = utf8.offset(input, -1)
 
--        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            gui.input = string.sub(gui.input, 1, -2)
--        end
    end
--	print ('key:'..key..' scancode:'..scancode)
end