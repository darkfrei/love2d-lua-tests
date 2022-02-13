local level = {}

level.name = 'level-1'

-- first cell is map[1][1], top left corner
level.map = 
{	-- 0 is empty, 1 is full,
	-- 2 an higher are empty, but you can use it as placeholders
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,},
	{1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,1,},
	{1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,1,},
	{1,1,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,1,1,},
	{1,1,0,0,0,0,1,0,0,0,0,0,0,0,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,},
	
	{1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,},
	{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,},
	{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,},
	{1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,},
	{1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,},
	
	{1,0,0,0,0,1,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,},
	{1,0,0,0,0,0,0,0,0,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,},
	{1,1,0,0,0,0,0,0,0,1,1,1,1,1,1,1,1,1,1,0,0,0,0,0,0,0,0,0,0,0,1,1,},
	{1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,},
	{1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,},
	
	{1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,},
	{1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,},
	{1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,},
}

level.blocks = 
{
	{name = 'square',
	heavy = false,
	x = 5,
	y = 9,
	form = 
		{
			{1,1},
			{1,1},
		},
	},
	
	{name = 'square',
	heavy = false,
	x = 10,
	y = 7,
	form = 
		{
			{1,1},
			{1,1},
		},
	},
	
	{name = 'u-pipe-6x3',
	heavy = true,
	x = 8,
	y = 3,
	form = 
		{
			{1,0,0,0,0,1},
			{1,0,0,0,0,1},
			{1,1,1,1,1,1},
		},
	},
}

level.agents = 
{
	{name = 'fish-3x1',
	fish = true,
	heavy = false,
	x = 8,
	y = 6,
	form = 
		{
			{1,1,1},
		},
	},
	
	
	{name = 'fish-4x2',
	fish = true,
	heavy = true,
	x = 16,
	y = 8,
	form = 
		{
			{1,1,1,1},
			{1,1,1,1},
		},
	},
}


-- prepare level

-- prepare map

level.w = 0 -- map width in tiles (same as highest x)
level.h = #level.map -- map height in tiles
for y, xs in ipairs (level.map) do
	for x, value in ipairs (xs) do
		if value == 1 then
			-- now value is true
			level.map[y][x] = true
			if level.w < x then level.w = x end
		else
			-- now value is false
			level.map[y][x] = false
		end
	end
end

for i, block in ipairs (level.blocks) do
	local w, h = 0, 0
	block.tiles = {}
	for y, xs in ipairs (block.form) do
		for x, value in ipairs (xs) do
			if value == 1 then
				table.insert (block.tiles, x-1) -- beware of -1
				table.insert (block.tiles, y-1)
				if w < x then w = x end
				if h < y then h = y end
			end
		end
	end
	block.w = w
	block.h = h
end

for i, agent in ipairs (level.agents) do
	local w, h = 0, 0
	agent.tiles = {}
	for y, xs in ipairs (agent.form) do
		for x, value in ipairs (xs) do
			if value == 1 then
				table.insert (agent.tiles, x-1) -- beware of -1
				table.insert (agent.tiles, y-1)
				if w < x then w = x end
				if h < y then h = y end
			end
		end
	end
	agent.w = w
	agent.h = h
end



return level
