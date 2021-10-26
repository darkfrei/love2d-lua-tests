-- License CC0 (Creative Commons license) (c) darkfrei, 2021



function draw_tree (x,y,r)
	local agents = {}
	for i = 1, 150 do
		local radius = r*math.random()^(1/3)
		local angle = 2*math.pi*math.random()
		local ax = x+radius*math.cos(angle)
		local ay = y+radius*math.sin(angle)
		local agent = {x=ax,y=ay,angle=angle, weight = 1}
		table.insert(agents, agent)
	end
	
	for _ = 1, 16 do
		for i, agent1 in pairs (agents) do
			local ax, ay =  agent1.x, agent1.y
--			love.graphics.circle('line', agent1.x,agent1.y,agent1.weight/2)
			local index, nearest_agent, min_sqdist
			for j, agent2 in pairs (agents) do
				if not (i==j) then
					local sqdist = (agent2.x-agent1.x)^2+(agent2.y-agent1.y)^2
					if (not min_sqdist) or (min_sqdist > sqdist) then
						index = j
						nearest_agent=agent2
						min_sqdist=sqdist
					end
				end
			end
			if nearest_agent then
				local x1, y1 = agent1.x, agent1.y
				local x2, y2 = nearest_agent.x, nearest_agent.y
--				love.graphics.setLineWidth(1)
--				love.graphics.setColor(1,1,0)
--				love.graphics.line(x1,y1,x2,y2)
				
				agent1.x, agent1.y = 				0.5*x1+0.4*x2+0.1*x, 0.5*y1+0.4*y2+0.1*y
--				nearest_agent.x, nearest_agent.y = 	0.5*x2+0.4*x1+0.1*x, 0.5*y2+0.4*y1+0.1*y
--				agent1.x, agent1.y = 0.8*x1+0.2*x2, 0.8*y1+0.2*y2
				if min_sqdist < (2*agent1.weight)^2 then
--					agent1.weight = agent1.weight + nearest_agent.weight
					love.graphics.setColor(1,1,1)
					love.graphics.setLineWidth(nearest_agent.weight)
					love.graphics.line(agent1.x, agent1.y, nearest_agent.x, nearest_agent.y)
					agents[index] = nil
				else
					agent1.weight = agent1.weight + 1
--					nearest_agent.weight = agent1.weight + 1
				end
			end
			agent1.weight = math.min(15,agent1.weight)
			
--			love.graphics.setColor(1,1,1)
--			love.graphics.circle('line', agent1.x,agent1.y,agent1.weight/2)
			love.graphics.setLineWidth(agent1.weight)
			love.graphics.line(ax,ay, agent1.x, agent1.y)
			
			love.graphics.setLineWidth(1)
			love.graphics.circle('fill', agent1.x,agent1.y,agent1.weight/2)
		end
	end
	local maxW
	for i, agent1 in pairs (agents) do
		love.graphics.setLineWidth(agent1.weight)
		love.graphics.line(x,y, agent1.x, agent1.y)
		if not maxW or maxW < agent1.weight then
			maxW = agent1.weight
		end
	end
	love.graphics.setLineWidth(1)
	love.graphics.circle('fill', x,y,maxW/2)
end

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1080, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )

	canvas = love.graphics.newCanvas(width,height, {msaa=8})
	
	love.graphics.setCanvas(canvas)
		draw_tree (width/2, height/2, math.min (width, height)/2)
	love.graphics.setCanvas()
end

 
function love.update(dt)
	
end


function love.draw()
	love.graphics.setBackgroundColor(1,1,1)
--	love.graphics.setColor(1,1,1)
	love.graphics.setColor(0,0,0)
	love.graphics.setLineWidth(1)
	love.graphics.circle('line', width/2, height/2, math.min (width, height)/2)
	
	love.graphics.draw(canvas)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "space" then
		love.graphics.setCanvas(canvas)
			love.graphics.clear( )
			draw_tree (width/2, height/2, math.min (width, height)/2)
		love.graphics.setCanvas()
	elseif key == "return" then
		local filename = tostring(os.tmpname ())
		local time = tostring(os.time ())
--		filename = filename:sub(2) -- removing first character
		filename = filename:sub(2, -2) -- removing first and last characters
		
		print(filename, time)
		canvas:newImageData():encode("png",time..'-'..filename..".png")
		
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end