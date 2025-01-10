-- main.lua

-- screen size
local screenWidth, screenHeight = 1280, 800

-- list of sites (example coordinates)
local sites = {
	{200, 300},
	{800, 200},
	{400, 600},
	{1000, 700},
	{730, 550},
	
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
	local isBorder = false

	for _, site in ipairs(sites) do
		local distance = manhattanDistance(x, y, site[1], site[2])
		if distance < minDistance then
			minDistance = distance
			closestSite = site
			isBorder = false
		elseif distance == minDistance then
			isBorder = true
		elseif distance == minDistance + 1 then
			isBorder = true
		end
	end


	return closestSite, isBorder
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
			local closestSite, black = findClosestSite(x, y, sites)
			if black then
				love.graphics.setColor(0,0,0)
				love.graphics.rectangle("fill", x, y, gridResolution, gridResolution)
			elseif closestSite then
				local r, g, b = closestSite[1] / screenWidth, closestSite[2] / screenHeight, 0.5
				love.graphics.setColor(r, g, b)
				love.graphics.rectangle("fill", x, y, gridResolution, gridResolution)
			end
		end
	end

	-- draw sites
	for _, site in ipairs(sites) do
		love.graphics.setColor(1, 0, 0) -- red for sites
		love.graphics.circle("fill", site[1], site[2], 6)
		love.graphics.setColor(0,0,0)
		love.graphics.circle("fill", site[1], site[2], 3)
		
	end
end


function love.mousepressed (x, y)
	local x1 = math.floor(x/4+0.5)*4
	local y1 = math.floor(y/4+0.5)*4
	print (x, y, x1, y1)
	table.insert (sites, {x1, y1})
end