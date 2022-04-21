-- License CC0 (Creative Commons license) (c) darkfrei, 2022

function love.load()
	trail = {}
	maxTrailLength = 32
	trailDuration = 0.05
	trailTimer = 0
end

 
function love.update(dt)
	trailTimer = trailTimer + dt
--	if trailTimer > trailDuration then
	while trailTimer > trailDuration do
		trailTimer = trailTimer - trailDuration
		-- remove two last coordinates:
		trail[#trail] = nil
		trail[#trail] = nil
	end
end

function love.draw()
	if trail[1] then
		love.graphics.circle ('fill', trail[1], trail[2], #trail/2)
	end
	for i = 3, #trail-1, 2 do
		local w = #trail-i
		love.graphics.setLineWidth (w)
		love.graphics.line (trail[i-2], trail[i-1], trail[i], trail[i+1])
		love.graphics.circle ('fill', trail[i], trail[i+1], w/2)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
	table.insert (trail, 1, y)
	table.insert (trail, 1, x)
	if #trail > maxTrailLength*2 then
		for i = #trail, maxTrailLength*2+1, -1 do -- backwards
			trail[i] = nil
		end
	end
end