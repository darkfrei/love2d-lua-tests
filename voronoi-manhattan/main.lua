-- main.lua

-- screen size
local screenWidth, screenHeight = 1280, 800

-- list of sites (example coordinates)
local sites = {
	{200, 300},
	{800, 200},
	{400, 600},
	{1000, 700}
}

-- grid resolution for better rendering of Voronoi regions
local gridResolution = 2

-- [calculates Manhattan distance between two points]
function manhattanDistance(x1, y1, x2, y2)
	return math.abs(x1 - x2) + math.abs(y1 - y2)
end

-- [determines the closest site for a given point]
function findClosestSite(x, y, sites)
	local minDistance = math.huge
	local closestSite = nil

	for _, site in ipairs(sites) do
		local distance = manhattanDistance(x, y, site[1], site[2])
		if distance < minDistance then
			minDistance = distance
			closestSite = site
		end
	end

	return closestSite
end

-- [Love2D load function]
function love.load()
	love.window.setMode(screenWidth, screenHeight)
	love.window.setTitle("Manhattan Voronoi Diagram")
end

-- [Love2D draw function]
function love.draw()
	-- draw Voronoi regions
	for x = 0, screenWidth, gridResolution do
		for y = 0, screenHeight, gridResolution do
			local closestSite = findClosestSite(x, y, sites)
			if closestSite then
				local r, g, b = closestSite[1] / screenWidth, closestSite[2] / screenHeight, 0.5
				love.graphics.setColor(r, g, b)
				love.graphics.rectangle("fill", x, y, gridResolution, gridResolution)
			end
		end
	end

	-- draw sites
	for _, site in ipairs(sites) do
		love.graphics.setColor(1, 0, 0) -- red for sites
		love.graphics.circle("fill", site[1], site[2], 5)
	end
end
