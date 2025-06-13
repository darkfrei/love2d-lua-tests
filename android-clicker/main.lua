local utf8 = require("utf8")

function love.load()
--    text = ""
	
	input = ""
	text = ""
	keys=""
	scancodes=""
	message=""
	
	filename = "textfile-01.txt"
	
	path = love.filesystem.getUserDirectory( )
	
	file = love.filesystem.newFile(filename)
	file:open("r")
	text = file:read()
	file:close()

	exists = love.filesystem.getInfo( filename ) ~= nil

	love.keyboard.setTextInput( true )
	love.keyboard.setKeyRepeat(true)
	
end

function love.update()

end

function love.draw()
--    love.graphics.print(text, 100, 10)
    love.graphics.print('input: '..input, 32, 32)
    love.graphics.print('keys:          '..keys, 32, 150)
    love.graphics.print('scancodes: '..scancodes, 32, 170)
    love.graphics.print('message: '..tostring(message), 32, 190)
    love.graphics.print('path: '..tostring(path), 32, 210)
    love.graphics.print('text: '..tostring(text), 32, 230)
    love.graphics.print('exists: '..tostring(exists), 32, 250)
end

--function love.keypressed(key)
--    if key == "a" or "b" or "c" then -- and so on
--        text = key
--    end
--end


--function love.keypressed(key)
--     if key and key:match( '^[%w%s]$' ) then input = input..key end
--end

function love.keypressed(key, scancode, isrepeat)
	keys=key
	scancodes=scancode
	if key and key:match( '^[%w%s]$' ) then input = input..key end
	if key == "space" then input = input..' ' end
	if key == "return" then 
		text = input
		input = ""
		message = love.filesystem.write(filename, text)
--		input = input..'\n' 
	end
    if key == "backspace" then
        -- get the byte offset to the last UTF-8 character in the string.
        local byteoffset = utf8.offset(input, -1)
 
        if byteoffset then
            -- remove the last UTF-8 character.
            -- string.sub operates on bytes rather than UTF-8 characters, so we couldn't do string.sub(text, 1, -2).
            input = string.sub(input, 1, byteoffset - 1)
        end
    end
--	print ('key:'..key..' scancode:'..scancode)
end

function love.touchpressed( id, x, y, dx, dy, pressure )
	love.system.vibrate(0.1)
	if not love.keyboard.hasTextInput( ) then
		love.keyboard.setTextInput( true )
	end
end