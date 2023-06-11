-- License CC0 (Creative Commons license) (c) darkfrei, 2023

local function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
  return x1 < x2+w2 and
         x2 < x1+w1 and
         y1 < y2+h2 and
         y2 < y1+h1
end

local function separateRectangles (agent, box)
	local x1, y1 = agent.x, agent.y
	local w1, h1 = agent.w, agent.h

  local x2, y2 = box.x, box.y
  local w2, h2 = box.w, box.h
	
	if checkCollision(x1,y1,w1,h1, x2,y2,w2,h2) then
		-- collision exists!
		local dx, dy = 0, 0
		if x1+w1/2 < x2+w2/2 then
			-- middle point of agent is more left than by the box
			dx = -w1+(x2-x1)
		else
			dx = w2-(x1-x2)
		end
		
		if y1+h1/2 < y2+h2/2 then
			-- middle point of agent is higher than by the box
			dy = -h1+(y2-y1)
		else
			dy = h2-(y1-y2)
		end
		
		if math.abs (dx) < math.abs (dy) then
			-- horizontal solution is shorter
			return dx, 0
		else	
			return 0, dy
		end
	end

	return 0, 0
end

function love.load()
	Agent = {x=0, y=0, w=100, h=120}
	Box = {x=300, y=250, w=120, h=100}	
end

function love.draw()
	love.graphics.rectangle ('line', Agent.x, Agent.y, Agent.w, Agent.h)
	love.graphics.rectangle ('line', Box.x, Box.y, Box.w, Box.h)
end

function love.mousemoved( x, y, dx, dy, istouch )
	Agent.x = x
	Agent.y = y
	local dx1, dy1 = separateRectangles (Agent, Box)
	Agent.x = Agent.x + dx1
	Agent.y = Agent.y + dy1
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
