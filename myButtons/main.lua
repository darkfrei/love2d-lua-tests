--[[
Copyright 2023 darkfrei

The MIT License
https://opensource.org/license/mit/

Permission is hereby granted, free of charge, to any person obtaining 
a copy of this software and associated documentation files (the “Software”), 
to deal in the Software without restriction, including without limitation 
the rights to use, copy, modify, merge, publish, distribute, sublicense, 
and/or sell copies of the Software, and to permit persons to whom 
the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included 
in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, 
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES 
OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, 
DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH 
THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
--]]

myButtons = require ('myButtons')


function love.load()
	local color = {1,1,1}
	local function onButtonHovered (button)
		button.lineWidth = 4
	end
	
	local function onButtonNotHovered (button)
		button.lineWidth = 2
	end
	
	local function onToggle (button)
		button.toggled = not button.toggled
		if button.toggled then
			button.color = {0,1,0}
		else
			button.color = {1,0,0}
		end
	end
	
	local function drawButton (button)
		love.graphics.setColor (button.color)
		love.graphics.setLineWidth (button.lineWidth)
		love.graphics.rectangle ('line', button.x, button.y, button.w, button.h)
		
		if button.textColor  then
			love.graphics.setColor (button.textColor)
		end
		if button.text then
			love.graphics.print (button.text, button.x, button.y)
		end
	end
	
	myButtons:new {x=10, y=10, w=100, h=100, color=color, 
		drawButton=drawButton, 
		onButtonHovered=onButtonHovered, 
		onButtonNotHovered=onButtonNotHovered,
		onToggle = onToggle,
		text = "First",
		textColor = {1,1,1},
		}
	myButtons:new {x=150, y=10, w=100, h=100, color=color, 
		drawButton=drawButton, 
		onButtonHovered=onButtonHovered, 
		onButtonNotHovered=onButtonNotHovered,
		onToggle = onToggle,
		text = "Second"}
end


function love.update(dt)
	myButtons.update (dt)
end


function love.draw()
	myButtons.draw ()
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	myButtons.mousepressed(x, y, button)
end

function love.mousemoved( x, y, dx, dy, istouch )
	myButtons.mousemoved (x, y, dx, dy)
end

function love.mousereleased( x, y, button, istouch, presses )
	myButtons.mousereleased(x, y, button)
end