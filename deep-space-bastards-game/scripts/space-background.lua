-- space background module
local spaceBackground = {}

local galaxyPrototypes = {
	"graphics/backgrounds/galaxies/galaxy-1.png",
}

local nebulaPrototypes = {
	"graphics/backgrounds/nebulae/nebula-1.png",
	"graphics/backgrounds/nebulae/nebula-2.png",
	"graphics/backgrounds/nebulae/nebula-3.png",
	"graphics/backgrounds/nebulae/nebula-4.png",
}

-- physical constants
local Z_MIN_GALAXY = 0.03  -- minimum galaxy depth (far)
local Z_MAX_GALAXY = 0.09   -- maximum galaxy depth (near)
local Z_MIN_STAR = 0.01     -- minimum star depth
local Z_MAX_STAR = 0.4     -- maximum star depth



local function getStarColorByTemperature(tempK) -- range 1000 to 40000
	local r, g, b
	if tempK <= 6600 then
		r = 1.0
		g = 0.390081972 * math.log(tempK) - 2.427925631
		b = 0.543206396 * math.log(tempK - 1000) - 3.698136688
	else
		r = 2.4054 * math.pow(tempK - 6000, -0.1332047592)
		g = 1.6 * math.pow(tempK - 6000, -0.0755148492)
		b = 1.0
	end
	return r, g, b -- range 0 to 1
end

-- initialize galaxy decals using z-depth
function spaceBackground.initGalaxyDecals()
	spaceBackground.decals = {}
	local numDecals = 50
	local systemRadius = 5000

	for i = 1, numDecals do
		-- generate z depth (higher z = closer object)
		local z = math.random() * (Z_MAX_GALAXY - Z_MIN_GALAXY) + Z_MIN_GALAXY

		-- calculate parameters based on z depth
		local scale = z * 4.0  -- scale proportional to depth

		-- physically correct brightness attenuation (inverse square law)
		local brightness = 1 / ((1 - z)^2 + 0.1)
		local r = math.random(0.9, 1.0) * brightness
		local g = math.random(0.99, 1.0) * brightness
		local b = math.random(0.9, 1.0) * brightness

		local decal = {
			x = math.random(-systemRadius, systemRadius),
			y = math.random(-systemRadius, systemRadius),
			z = z,  -- main depth parameter
			scale = scale,
			texture = galaxyPrototypes[math.random(1, #galaxyPrototypes)],
			color = {r, g, b, 1},
		}

		-- load texture
		local success, image = pcall(love.graphics.newImage, decal.texture)
		if success and image then
			decal.image = image
			decal.width = image:getWidth()
			decal.height = image:getHeight()
		else
			print("failed to load background texture: " .. decal.texture)
			decal.image = nil
			decal.width = 50
			decal.height = 50
		end
		table.insert(spaceBackground.decals, decal)
	end
end

function spaceBackground.initNebulaDecals()
	local numNebulae = 20
	local systemRadius = 5000

	for i = 1, numNebulae do
		local z = math.random() * (Z_MAX_GALAXY - Z_MIN_GALAXY) + Z_MIN_GALAXY
		local scale = z * 6.0
		local baseAlpha = 0.6 + math.random() * 0.4
		local color = {1,1,1, baseAlpha}
		local baseTexture = nebulaPrototypes[math.random(1, #nebulaPrototypes)]

		for rot = 0, 3 do
			for reflect = 0, 1 do
				local rotation = math.rad(90 * rot)
				local sx = reflect == 1 and -1 or 1

				local decal = {
					x = math.random(-systemRadius, systemRadius),
					y = math.random(-systemRadius, systemRadius),
					z = z,
					scale = scale * 8,
					rotation = rotation,
					sx = sx,
					sy = 1,
					texture = baseTexture,
					color = color,
					type = "nebula"
				}

				local success, image = pcall(love.graphics.newImage, decal.texture)
				if success and image then
					decal.image = image
					decal.width = image:getWidth()
					decal.height = image:getHeight()
				else
					print("failed to load nebula texture: " .. decal.texture)
					decal.image = nil
					decal.width = 50
					decal.height = 50
				end
				table.insert(spaceBackground.decals, decal)
			end
		end
	end
end


-- initialize stars using z-depth
function spaceBackground.initCircleStars(systemRadius)
	spaceBackground.stars = {}
	local numStars = 1500

	for i = 1, numStars do
		-- generate z depth
		local z = math.random() * (Z_MAX_STAR - Z_MIN_STAR) + Z_MIN_STAR

		-- calculate parameters based on z depth
		local angle = math.random() * math.pi * 2
		local distance = math.random() * systemRadius

		-- generate random temperature between 1000K and 12000K
		local temperature = math.random(1000, 12000)
		-- get color from temperature
		local r, g, b = getStarColorByTemperature(temperature)
		local baseBrightness = math.random(0.8, 1.0)
		local brightness = 0.2*baseBrightness / ((1 - z)^2 + 0.05)
		local color = {r, g, b, brightness}

		-- physically correct brightness
		

		-- apply brightness to color
--		local r = color[1] * brightness
--		local g = color[2] * brightness
--		local b = color[3] * brightness

		local star = {
			x = math.cos(angle) * distance,
			y = math.sin(angle) * distance,
			z = z,  -- main depth parameter
			size = (0.5 + z * 1.5)*4,  -- size proportional to depth
			brightness = brightness,
			twinkleSpeed = math.random() * 0.5 + 0.1,
			twinklePhase = math.random() * math.pi * 2,
--			color = {r, g, b, 1}
			color = color
		}
		table.insert(spaceBackground.stars, star)
	end
end



function spaceBackground.createTemperatureBar()
	-- test
	local width = 400  -- bar width
	local height = 15  -- bar height

	-- create canvas for temperature bar
	local canvas = love.graphics.newCanvas(width, height)

	-- start drawing on canvas
	love.graphics.setCanvas(canvas)
	-- draw temperature gradient
	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(1)
	for x = 0, width - 1, 1 do
		-- calculate temperature for current pixel
		local tempK = 1000 + (x / width) * 11000

		-- get color from temperature
		local r, g, b = getStarColorByTemperature(tempK)
		local color = {r, g, b, 1}

		-- set color
		love.graphics.setColor(color)

		-- draw vertical line
		love.graphics.line(x, 0, x, height)
	end

	-- add labels
	love.graphics.setColor(0,0,0, 1)
	love.graphics.print("1000K", 5, 0)
	love.graphics.print("12000K", width - 55, 0)
	love.graphics.print("6600K", width/2 - 10, 0)

	-- draw border
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("line", 0.5, 0.5, width-1, height-1)
	love.graphics.setCanvas()

	return canvas
end

function spaceBackground.init(systemRadius)
	spaceBackground.initGalaxyDecals()
	spaceBackground.initNebulaDecals()
	spaceBackground.initCircleStars(systemRadius)
	spaceBackground.temperatureBar = spaceBackground.createTemperatureBar()
end

function spaceBackground.drawDecals()
	for _, decal in ipairs(spaceBackground.decals) do
		local dx = spaceCamera.x * decal.z
		local dy = spaceCamera.y * decal.z
		local drawX = decal.x - dx
		local drawY = decal.y - dy

		if decal.image then
			love.graphics.setColor(decal.color)
			love.graphics.draw(
				decal.image,
				drawX, drawY,
				decal.rotation or 0,
				decal.scale * (decal.sx or 1),
				decal.scale * (decal.sy or 1),
				decal.width / 2,
				decal.height / 2
			)
		end
	end
end

function spaceBackground.drawCircleStars(cameraX, cameraY)
	local time = love.timer.getTime()

	for _, star in ipairs(spaceBackground.stars) do
		-- parallax: directly proportional to z depth
		local dx = cameraX * star.z
		local dy = cameraY * star.z
		local drawX = star.x - dx
		local drawY = star.y - dy

		-- twinkle effect with base brightness
		local twinkle = 0.7 + 0.3 * math.sin(time * star.twinkleSpeed + star.twinklePhase)
--		print (twinkle)
		local currentBrightness = star.brightness * twinkle

		-- draw with brightness applied
--		love.graphics.setColor(
--			star.color[1] * currentBrightness, 
--			star.color[2] * currentBrightness, 
--			star.color[3] * currentBrightness,
--			currentBrightness
--		)		
		love.graphics.setColor(star.color)
		love.graphics.circle('fill', drawX, drawY, star.size)
	end
end

function spaceBackground.draw(cameraX, cameraY)
	spaceBackground.drawDecals()
	spaceBackground.drawCircleStars(cameraX, cameraY)
end

function spaceBackground.drawGUI()
	-- draw temperature bar
	love.graphics.setColor(1,1,1,1)
	love.graphics.draw(spaceBackground.temperatureBar, 10, 10)
end

return spaceBackground