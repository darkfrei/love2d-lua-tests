-- system loader module
local systemLoader = {}

-- load images and initialize runtime properties
function systemLoader.loadSystem(system)
	-- create a copy of the prototype
	local loadedSystem = {}
	for k, v in pairs(system) do
		if type(v) == "table" then
			loadedSystem[k] = systemLoader.shallowCopy(v)
		else
			loadedSystem[k] = v
		end
	end

	-- load star
	if loadedSystem.star then
		systemLoader.loadStar(loadedSystem.star)
	end

	-- load planets
	if loadedSystem.planets then
		for _, planet in ipairs(loadedSystem.planets) do
			systemLoader.loadPlanet(planet)
		end
	end

	-- initialize animation state
	if loadedSystem.star then
		loadedSystem.star.animationTimer = 0
	end

	return loadedSystem
end

-- helper function to copy tables
function systemLoader.shallowCopy(orig)
	local copy = {}
	for k, v in pairs(orig) do
		copy[k] = v
	end
	return copy
end

-- load star resources
function systemLoader.loadStar(star)
	-- load main star image
	if star.filename then
		local success, image = pcall(love.graphics.newImage, star.filename)
		if success and image then
			star.image = image
		else
			print("failed to load star image: " .. star.filename)
		end
	end

	-- load animation frames
	star.frames = {}
	if star.animationFrames then
		for i, path in ipairs(star.animationFrames) do
			local success, image = pcall(love.graphics.newImage, path)
			if success and image then
				local frame = {
					image = image,
					alpha = 1,
					scaleX = star.radius * 2 * star.scale / image:getWidth(),
					scaleY = star.radius * 2 * star.scale / image:getHeight(),
					offsetX = image:getWidth() / 2,
					offsetY = image:getHeight() / 2,
					rotation = 0
				}
				table.insert(star.frames, frame)
			else
				print("failed to load star frame: " .. path)
			end
		end
	end
end

-- load planet resources
function systemLoader.loadPlanet(planet)
	if planet.filename then
		local success, image = pcall(love.graphics.newImage, planet.filename)
		if success and image then
			planet.image = image
			planet.scaleX = planet.radius * 2 * planet.scale / image:getWidth()
			planet.scaleY = planet.radius * 2 * planet.scale / image:getHeight()
			planet.offsetX = image:getWidth() / 2
			planet.offsetY = image:getHeight() / 2
		else
			print("failed to load planet image: " .. planet.filename)
		end
	end
end

return systemLoader