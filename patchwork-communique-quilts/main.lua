--[[
patchwork-rectangles
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

love.window.setMode(1280, 800) -- Steam Deck resolution



local function updatePatches ()

	local index = math.random(#queue)
--		print ('index', index)
	local point = table.remove (queue, index)

	local rnew = {x=point.x,y=point.y}
	
	rnew.w = math.random (3, 5)
	rnew.h = math.random (3, 5)
	

	local lastW = false
	if rnew.x+rnew.w > gridW then
		rnew.w = gridW - rnew.x
--		lastW = true
	end
	local lastH = false
	if rnew.y+rnew.h > gridH then 
		rnew.h = gridH - rnew.y
--		lastH = true
	end

	local cols = {}

	for i, r in ipairs (rectangles) do
		if r.x+r.w > rnew.x and r.y+r.h > rnew.y 
		and rnew.x + rnew.w > r.x and rnew.y + rnew.h > r.y then
			table.insert (cols, r)
		end
	end

	for i, r in ipairs (cols) do
		if r.x > rnew.x then
			if rnew.x + rnew.w > r.x then
				rnew.w = r.x - rnew.x
			end
--		elseif r.y > rnew.y and rnew.y + rnew.h > r.y then
		elseif r.y > rnew.y then
			-- exception: do nothing
		else
			rnew.w = 0
		end
		if r.y > rnew.y then
			if rnew.y + rnew.h > r.y then
				rnew.h = r.y - rnew.y
			end
--		elseif r.x > rnew.x and rnew.x + rnew.w > r.x then
		elseif r.x > rnew.x then
			-- do nothing
		else
			rnew.h = 0
		end
	end

	if (rnew.w > 0) and (rnew.h > 0) then
		if lastW and lastH then
			-- do nothing
		elseif lastW then
			table.insert (queue, {x=rnew.x, y=rnew.y+rnew.h})
		elseif lastH then
			table.insert (queue, {x=rnew.x+rnew.w, y=rnew.y})
		else
			table.insert (queue, {x=rnew.x, y=rnew.y+rnew.h})
			table.insert (queue, {x=rnew.x+rnew.w, y=rnew.y})
--			table.insert (queue, {x=rnew.x+rnew.w, y=rnew.y+rnew.h})
		end
		table.insert (rectangles, rnew)
		return true
	end
end



function love.load()
--	math.randomseed( 10 )
	queue = {{x=0,y=0}}
	gridW, gridH, size = 32*2, 20*2, 40/2

	rectangles = {}
	step = 0.05
	time = 0
	pause = false
end


function love.update(dt)
	if not pause then
		time = time + dt
		while time > step do
			time = time-step
			if #queue > 0 then
				if not updatePatches () then
					time = time+step
				end
				love.window.setTitle ('queue: '.. #queue)
			end
		end
	end
end


function love.draw()
	for i, r in ipairs (rectangles) do
		love.graphics.setColor (1,1,1,0.75)
		love.graphics.rectangle ('fill', r.x*size, r.y*size, r.w*size, r.h*size)
		love.graphics.setColor (0,0,0)
		love.graphics.rectangle ('line', r.x*size, r.y*size, r.w*size, r.h*size)
	end

	love.graphics.setColor (0,1,0)
	for i, p in ipairs (queue) do
		love.graphics.circle ('line', p.x*size, p.y*size, 4)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "space" then
		pause = not pause
	elseif key == "escape" then
		love.event.quit()
	end
end
