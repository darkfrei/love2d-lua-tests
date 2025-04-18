local Data = {}

local zoneColorList =  {
	-- [red with a hint of orange]
	{0.85, 0.3, 0.25},

	-- [muted green with a touch of blue]
	{0.2, 0.6, 0.5},

	-- [deep blue with slight purple undertone]
	{0.35, 0.2, 0.7},

	-- [soft yellow with reduced saturation]
	{0.9, 0.8, 0.4},

	-- [vivid magenta with slight pink shade]
	{0.85, 0.3, 0.55},

	-- [earthy brown with a red undertone]
	{0.6, 0.35, 0.25},

	-- [cool cyan with low saturation]
	{0.3, 0.7, 0.75},

	-- [dark purple with a touch of blue]
	{0.4, 0.25, 0.6},

	-- [soft orange with low contrast]
	{0.9, 0.5, 0.3},

	-- [forest green with muted tones]
	{0.25, 0.5, 0.3},
}
Data.zoneColorList = zoneColorList


local zoneArtList = {
	-- [example for 40x40 tiles]

	{
		size = 40,
		f = function(x, y)
			love.graphics.rectangle("line", x + 5, y + 5, 30, 30) -- outline rectangle
			love.graphics.circle("fill", x + 20, y + 20, 10) -- filled circle
		end
	},

	{
		size = 40,	
		f = function(x, y)
			love.graphics.polygon("line", x + 10, y + 30, x + 30, y + 30, x + 20, y + 10) -- triangle
		end
	},

	{
		size = 80,
		f = function(x, y)
			love.graphics.rectangle("line", x + 10, y + 10, 60, 60) -- outline rectangle
			love.graphics.line(x + 10, y + 10, x + 70, y + 70) -- diagonal line
			love.graphics.line(x + 70, y + 10, x + 10, y + 70) -- diagonal line
		end},

	{ 
		size = 80,
		f = function(x, y)
			love.graphics.circle("line", x + 40, y + 40, 30) -- large circle
			love.graphics.rectangle("fill", x + 25, y + 25, 30, 30) -- filled square in the center
		end
	},
	{ 
		size = 80,
		f = function(x, y)
			-- factory
			love.graphics.polygon("line", 
				x + 10, y + 10, 
				x + 25, y + 10, 
				x + 25, y + 20,
				x + 50, y + 20,
				x + 50, y + 25,
				x + 70, y + 25,
				x + 70, y + 70,
				x + 10, y + 70
				)
		end
	},
}
Data.zoneArtList = zoneArtList

local routes = {
	{number = 101, type = 'Route', directions = {'Route 101', 'Route 101'}},
	{number = 66, type = 'Highway', directions = {'Highway 66', 'Highway 66'}},
	{number = 25, type = 'Route', directions = {'Route 25 North', 'Route 25 South'}},
	{number = 12, type = 'Route', directions = {'Route 12 East', 'Route 12 West'}},
	{number = 75, type = 'Highway', directions = {'Highway 75', 'Highway 75'}},
	{number = 42, type = 'Route', directions = {'Route 42 West', 'Route 42 East'}},
	{number = 60, type = 'Route', directions = {'Route 60', 'Route 60'}},
	{number = 9, type = 'Route', directions = {'Route 9 South', 'Route 9 North'}},
	{number = 88, type = 'Route', directions = {'Route 88 North', 'Route 88 South'}},
	{number = 50, type = 'Route', directions = {'Route 50 West', 'Route 50 East'}},
--	{number = 29, type = 'Expressway', directions = {'Expressway 29', 'Expressway 29'}},
	{number = 14, type = 'Route', directions = {'Route 14 East', 'Route 14 West'}},
	{number = 37, type = 'Highway', directions = {'Highway 37 South', 'Highway 37 North'}},
	{number = 11, type = 'Route', directions = {'Route 11', 'Route 11'}},
	{number = 22, type = 'Route', directions = {'Route 22 North', 'Route 22 South'}},
	{number = 33, type = 'Route', directions = {'Route 33 East', 'Route 33 West'}},
	{number = 5, type = 'Route', directions = {'Route 5 West', 'Route 5 East'}},
	{number = 4, type = 'Route', directions = {'Route 4 South', 'Route 4 North'}},
	{number = 21, type = 'Highway', directions = {'Highway 21', 'Highway 21'}},
	{number = 70, type = 'Route', directions = {'Route 70 East', 'Route 70 West'}},
	{number = 15, type = 'Route', directions = {'Route 15 North', 'Route 15 South'}},
	{number = 18, type = 'Route', directions = {'Route 18 South', 'Route 18 North'}},
	{number = 45, type = 'Highway', directions = {'Highway 45', 'Highway 45'}},
	{number = 13, type = 'Route', directions = {'Route 13 West', 'Route 13 East'}},
	{number = 17, type = 'Route', directions = {'Route 17', 'Route 17'}},
	{number = 26, type = 'Route', directions = {'Route 26 East', 'Route 26 West'}},
	{number = 41, type = 'Route', directions = {'Route 41 North', 'Route 41 South'}},
	{number = 30, type = 'Route', directions = {'Route 30 West', 'Route 30 East'}},
	{number = 80, type = 'Highway', directions = {'Highway 80 South', 'Highway 80 North'}},
	{number = 28, type = 'Route', directions = {'Route 28', 'Route 28'}},
	{number = 67, type = 'Route', directions = {'Route 67 West', 'Route 67 East'}},
	{number = 20, type = 'Route', directions = {'Route 20 North', 'Route 20 South'}},
	{number = 52, type = 'Route', directions = {'Route 52 East', 'Route 52 West'}},
	{number = 90, type = 'Highway', directions = {'Highway 90', 'Highway 90'}},
	{number = 8, type = 'Route', directions = {'Route 8 South', 'Route 8 North'}},
	{number = 35, type = 'Route', directions = {'Route 35 North', 'Route 35 South'}},
	{number = 16, type = 'Route', directions = {'Route 16', 'Route 16'}},
--	{number = 60, type = 'Highway', directions = {'Highway 60 West', 'Highway 60 East'}},
	{number = 38, type = 'Route', directions = {'Route 38 South', 'Route 38 North'}},
	{number = 72, type = 'Route', directions = {'Route 72 East', 'Route 72 West'}},
	{number = 10, type = 'Route', directions = {'Route 10', 'Route 10'}},
	{number = 29, type = 'Highway', directions = {'Highway 29 North', 'Highway 29 South'}},
	{number = 44, type = 'Route', directions = {'Route 44 West', 'Route 44 East'}},
	{number = 24, type = 'Route', directions = {'Route 24 South', 'Route 24 North'}},
	{number = 3, type = 'Route', directions = {'Route 3', 'Route 3'}},
	{number = 39, type = 'Highway', directions = {'Highway 39 East', 'Highway 39 West'}},
	{number = 31, type = 'Route', directions = {'Route 31 North', 'Route 31 South'}},
	{number = 51, type = 'Route', directions = {'Route 51 South', 'Route 51 North'}},
	{number = 63, type = 'Route', directions = {'Route 63 West', 'Route 63 East'}},
	{number = 74, type = 'Route', directions = {'Route 74 East', 'Route 74 West'}},
	{number = 19, type = 'Route', directions = {'Route 19 North', 'Route 19 South'}},
--	{number = 50, type = 'Highway', directions = {'Highway 50', 'Highway 50'}},
	{number = 27, type = 'Route', directions = {'Route 27 South', 'Route 27 North'}},
	{number = 34, type = 'Route', directions = {'Route 34 East', 'Route 34 West'}},
	{number = 6, type = 'Route', directions = {'Route 6 West', 'Route 6 East'}},
	{number = 68, type = 'Route', directions = {'Route 68', 'Route 68'}},
	{number = 23, type = 'Route', directions = {'Route 23 North', 'Route 23 South'}},



	{number = 100, type = 'Highway', directions = {'Highway 100 South', 'Highway 100 North'}},
	{number = 2, type = 'Route', directions = {'Route 2', 'Route 2'}},
	{number = 59, type = 'Route', directions = {'Route 59 North', 'Route 59 South'}},
	{number = 43, type = 'Route', directions = {'Route 43 East', 'Route 43 West'}},
	{number = 55, type = 'Route', directions = {'Route 55', 'Route 55'}},
	{number = 32, type = 'Route', directions = {'Route 32 West', 'Route 32 East'}},
	{number = 53, type = 'Highway', directions = {'Highway 53', 'Highway 53'}},
	{number = 36, type = 'Route', directions = {'Route 36 North', 'Route 36 South'}},
	{number = 69, type = 'Route', directions = {'Route 69', 'Route 69'}},
	{number = 62, type = 'Highway', directions = {'Highway 62 North', 'Highway 62 South'}},
	{number = 48, type = 'Route', directions = {'Route 48 South', 'Route 48 North'}},
	{number = 58, type = 'Route', directions = {'Route 58', 'Route 58'}},
}

local hache = {}
for i, route in ipairs (routes) do
	local number = route.number
	if hache[number] then 
		print (number)
	else
		hache[number] = true
	end
end


Data.routes = routes


return Data