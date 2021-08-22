-- License CC0 (Creative Commons license) (c) darkfrei, 2021

local tools = require('tools')


--tool = tools.line
tool = tools.free

grid_size = 20
--grid_enabled = true
grid_enabled = false

function to_grid (x, y)
	return math.floor(x/grid_size+0.5)*grid_size, math.floor(y/grid_size+0.5)*grid_size
end

function love.load()
	lines = {}
	
end

 
function love.update(dt)
	
end

function draw_grid ()
	love.graphics.setLineWidth (1)
	love.graphics.setColor(0.25,0.25,0.25)
	local width, height = love.graphics.getDimensions( )
	for x = grid_size, width-1, grid_size do
		love.graphics.line(x, 0, x, height)
	end
	for y = grid_size, height-1, grid_size do
		love.graphics.line(0, y, width, y)
	end
end

function love.draw()
	if grid_enabled then
		draw_grid ()
	end
	
	love.graphics.setColor(1,1,1)
	love.graphics.print ('tools: ', 0, 40)
	love.graphics.print ('press q to line ', 0, 60)
	love.graphics.print ('press w to free ', 0, 80)
	love.graphics.print ('press e to remove ', 0, 100)
	love.graphics.print (tools.ggap, 150, 100)
	love.graphics.print ('press g for grid ', 0, 120)
	if tool then
		love.graphics.print ('tool: '..tool.name, 0, 140)
	else
		love.graphics.print ('no tool', 0, 120)
	end
	

	
	love.graphics.setLineWidth (3)
	
	for i, line in pairs (lines) do
		if selected_line and selected_line == i then
			love.graphics.setColor(1,0,0)
			love.graphics.line(line)
			love.graphics.print(#line/2, line[#line-1], line[#line])
		else
			love.graphics.setColor(1,1,1)
			love.graphics.line(line)
			love.graphics.print(#line/2, line[#line-1], line[#line])
		end
	end
	
	-- draw the tool line and last line point to mouse
	if tool and tool.line then
		love.graphics.setLineWidth (1)
		if #tool.line > 2 then
			love.graphics.line(tool.line)
		end
		local mx, my = love.mouse.getPosition()
		if grid_enabled then
			mx, my = to_grid (mx, my)
		end
		love.graphics.line(tool.line[#tool.line-1], tool.line[#tool.line], mx, my)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if key == "q" then
		if tool and tool == tools.line then
			tool = nil
		else 
			tool = tools.line
		end
	elseif key == "w" then
		if tool and tool == tools.free then
			tool = nil
		else 
			tool = tools.free
		end
	elseif key == "e" then
		if tool and tool == tools.remove then
			tool = nil
		else 
			tool = tools.remove
		end
	elseif key == "g" then
		grid_enabled = not grid_enabled
	elseif key == "escape" then
		love.event.quit()
	end
end


function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		if tool then
			tool.mousepressed( x, y, button, istouch, presses )
		end
	elseif button == 2 then -- right mouse button
		
	elseif button == 3 then -- middle mouse button
		
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
	if tool then
		tool.mousemoved( x, y, dx, dy, istouch )
	end
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
		if tool then
			tool.mousereleased( x, y, button, istouch, presses )
		end
	elseif button == 2 then -- right mouse button
		
	elseif button == 3 then -- middle mouse button
		
	end
end