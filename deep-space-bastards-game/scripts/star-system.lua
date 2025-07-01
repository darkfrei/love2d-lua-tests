-- star system module
local starSystem = {}
local system = nil  -- current loaded system

-- load a star system from prototype
function starSystem.load(systemPrototype)
	system = systemLoader.loadSystem(systemPrototype)

	-- initialize camera
	print ('system.radius', system.radius)
	spaceCamera.init()

	-- initialize background
	spaceBackground.init(system.radius)
end

-- update entire star system
function starSystem.updateStar(dt)

	-- update star animation
	if system.star and system.star.animationDuration then
		local star = system.star
		star.animationTimer = star.animationTimer + dt
		local cycleDuration = star.animationDuration
		local phaseShift = 2 * math.pi / 3

		if star.animationTimer >= cycleDuration then
			star.animationTimer = star.animationTimer % cycleDuration
		end

		local t = star.animationTimer / cycleDuration * 2 * math.pi
		if star.frames and #star.frames >= 2 then
			star.frames[2].alpha = (math.sin(t) + 1) / 2
		end
		if star.frames and #star.frames >= 3 then
			star.frames[3].alpha = (math.sin(t + phaseShift) + 1) / 2
		end
	end

	-- update planet positions
	if system.planets then
		for _, planet in ipairs(system.planets) do
			planet.orbitAngle = (planet.orbitAngle or 0) + (2 * math.pi / planet.orbitPeriod) * dt
			planet.x = math.cos(planet.orbitAngle) * planet.orbitRadius
			planet.y = math.sin(planet.orbitAngle) * planet.orbitRadius
		end
	end
end

-- update entire star system
function starSystem.updatePlanets(dt)


	-- update planet positions
	if system.planets then
		for _, planet in ipairs(system.planets) do
			planet.orbitAngle = (planet.orbitAngle or 0) + (2 * math.pi / planet.orbitPeriod) * dt
			planet.x = math.cos(-planet.orbitAngle) * planet.orbitRadius
			planet.y = math.sin(-planet.orbitAngle) * planet.orbitRadius
		end
	end
end

function starSystem.update(dt)
	if not system then return end

	starSystem.updateStar(dt)
	starSystem.updatePlanets(dt)
end

-- draw coordinate grid
local function drawGrid()
	if not system then return end

	local systemRadius = system.radius
	local gridStep = 100
	local halfSystem = systemRadius / 2

	-- draw vertical grid lines
	for x = -halfSystem, halfSystem, gridStep do
		if x % 1000 == 0 then
			love.graphics.setColor(1, 1, 1, 0.2)
			love.graphics.setLineWidth(2)
		elseif x % 500 == 0 then
			love.graphics.setColor(1, 1, 1, 0.2)
			love.graphics.setLineWidth(1)
		else
			love.graphics.setColor(1, 1, 1, 0.1)
			love.graphics.setLineWidth(1)
		end
		love.graphics.line(x, -halfSystem, x, halfSystem)
	end

	-- draw horizontal grid lines
	for y = -halfSystem, halfSystem, gridStep do
		if y % 1000 == 0 then
			love.graphics.setColor(1, 1, 1, 0.2)
			love.graphics.setLineWidth(2)
		elseif y % 500 == 0 then
			love.graphics.setColor(1, 1, 1, 0.2)
			love.graphics.setLineWidth(1)
		else
			love.graphics.setColor(1, 1, 1, 0.1)
			love.graphics.setLineWidth(1)
		end
		love.graphics.line(-halfSystem, y, halfSystem, y)
	end
end

-- draw star
local function drawStar()
	if not system or not system.star then return end

	local star = system.star

	-- draw main star image
	if star.image then
		love.graphics.setColor(1, 1, 1, 1)
		love.graphics.draw(
			star.image,
			0, 0,
			0,
			star.radius * 2 * star.scale / star.image:getWidth(),
			star.radius * 2 * star.scale / star.image:getHeight(),
			star.image:getWidth() / 2,
			star.image:getHeight() / 2
		)
	end

	-- draw animation frames
	if star.frames and #star.frames > 0 then
		for _, frame in ipairs(star.frames) do
			love.graphics.setColor(1, 1, 1, frame.alpha)
			love.graphics.draw(
				frame.image,
				0, 0,
				frame.rotation,
				frame.scaleX,
				frame.scaleY,
				frame.offsetX,
				frame.offsetY
			)
		end
	end


	love.graphics.setColor (1,1,1)
--	love.graphics.circle ('line', 0, 0, star.radius)
end

-- draw all planets
local function drawPlanets()
	if not system or not system.planets then return end

	for _, planet in ipairs(system.planets) do
		love.graphics.setColor(1, 1, 1, 0.2)
		love.graphics.circle ('line', 0,0, planet.orbitRadius)
		love.graphics.setColor(1, 1, 1, 1)
		if planet.image then
			love.graphics.draw(
				planet.image,
				planet.x, planet.y,
				0,
				planet.scaleX,
				planet.scaleY,
				planet.offsetX,
				planet.offsetY
			)

		else
			love.graphics.circle("fill", planet.x, planet.y, planet.radius)
		end
	end
end

-- draw entire star system
function starSystem.draw()
	if not system then return end

	-- set background color
	love.graphics.setBackgroundColor(0, 0, 0.1)

	-- apply camera transformation
--	spaceCamera.applyTransform(windowWidth, windowHeight)
	spaceCamera.applyTransform()

	spaceBackground.draw(spaceCamera.x, spaceCamera.y)
	drawGrid()
	drawStar()
	drawPlanets()

	spaceCamera.removeTransform()

	spaceCamera.draw()
	spaceBackground.drawGUI()
end

return starSystem