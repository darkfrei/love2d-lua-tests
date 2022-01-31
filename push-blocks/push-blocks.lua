-- License CC0 (Creative Commons license) (c) darkfrei, 2022
-- push-blocks

local pb = {}

pb.grigSize = 40 -- pixels or units
pb.grigWidth = 48-2 -- tiles
pb.grigHeight = 24  -- tiles

local white = {1,1,1}
local lightgreen = {0.75,1,0.75}
local green = {0,1,0}
local yellow = {1,1,0}
local red = {1,0,0}


pb.blocks = {
	{	
		tx = 10,  -- position horizontal position in tiles
		ty = 12,
		name = 't-block-3x3',
		form = {
			{1,1,1}, -- y=1
			{0,1,0}, -- y=2
			{0,1,0}, -- y=3
		},
		w = 3,
		h = 3,
		movable = true,
		color = yellow,
	},
	{	
		tx = 14,  -- position horizontal position in tiles
		ty = 12,
		name = 'plus-block-3x3',
		form = {
			{0,1,0}, -- y=1
			{1,1,1}, -- y=2
			{0,1,0}, -- y=3
		},
		w = 3,
		h = 3,
		movable = true,
		color = yellow,
	},
	{	
		tx = 6,  -- position horizontal position in tiles
		ty = 16,
		name = 'H-block-3x3',
		form = {
			{1,1,1}, -- y=1
			{0,1,0}, -- y=2
			{1,1,1}, -- y=3
		},
		w = 3,
		h = 3,
		movable = true,
		color = yellow,
	},
}


-- create random static tiles
pb.staticTilesMap = {}

local function createMapTile (map, y, x)
	if not pb.staticTilesMap[y] then pb.staticTilesMap[y] = {} end
	pb.staticTilesMap[y][x] = 1
end

for i = 1, 30 do
	local x = math.random(pb.grigWidth)
	local y = math.random(pb.grigHeight)
	createMapTile (pb.staticTilesMap, y, x)
end

-- horizontal border
for x = 1, pb.grigWidth do
	local y1 = 1
	local y2 = pb.grigHeight
	createMapTile (pb.staticTilesMap, y1, x)
	createMapTile (pb.staticTilesMap, y2, x)
end

-- vertical border
for y = 1, pb.grigHeight do
	if not pb.staticTilesMap[y] then pb.staticTilesMap[y] = {} end
	local x1 = 1
	local x2 = pb.grigWidth
	createMapTile (pb.staticTilesMap, y, x1)
	createMapTile (pb.staticTilesMap, y, x2)
end

createMapTile (pb.staticTilesMap, 2, 6)
createMapTile (pb.staticTilesMap, 3, 5)
createMapTile (pb.staticTilesMap, 4, 4)
createMapTile (pb.staticTilesMap, 5, 3)
createMapTile (pb.staticTilesMap, 6, 2)



local function isMapCollision (x1, y1, w1, h1, x2, y2, w2, h2)
--	thanks to https://love2d.org/wiki/BoundingBox.lua
	return x1<x2+w2
		and x2<x1+w1
		and y1<y2+h2
		and y2<y1+h1
end

function pb.isRoughCollisionWithMap (x1, y1, w, h)
	local map = pb.staticTilesMap
	local x2 = x1+w+1
	local y2 = y1+h+1
	for y = y1, y2 do
		for x = x1, x2 do
			local x3 = math.floor(x)
			local y3 = math.floor(y)
			if map[y3] and map[y3][x3] then
				-- beware of +1!
				if isMapCollision (x1+1, y1+1, w, h, x3, y3, 1, 1) then
					return true
				end
			end
		end
	end
	return false
end



pb.agent = {
	tx = 10, -- position horizontal position in tiles
	ty = 10,
	x = 10*pb.grigSize, -- smooth position
	y = 10*pb.grigSize, -- smooth position
	vx = 8, -- horizontal speed, tiles per second
	vup = 5,
	vdown = 6,
	form = {
		{1,1,1},
	},
	w = 3,
	h = 1,
}


local function isCollision (x1, y1, x2, y2)
--	thanks to https://love2d.org/wiki/BoundingBox.lua
	return x1<x2+1 and x2<x1+1 and y1<y2+1 and y2<y1+1
end



local function isRoughAgentBlockCollision (agent, block, dx, dy)
--	if bounding boxes can overlap
	return	agent.tx+dx < block.tx+block.w and
			block.tx < agent.tx+dx+agent.w and
			agent.ty+dy < block.ty+block.h and
			block.ty < agent.ty+dy+agent.h
end

local function isFineAgentBlockCollision (agent, block, dx, dy)
--	if any of tiles of agent has collision with any tile of block
	for aty, atxs in ipairs (agent.form) do
		for atx, value in ipairs (atxs) do
			if value == 1 then
				for bty, btxs in ipairs (block.form) do
					for btx, bvalue in ipairs (btxs) do
						if bvalue == 1 then
							if isCollision (agent.tx+atx+dx, agent.ty+aty+dy, block.tx+btx, block.ty+bty) then
								return true
							end
						end
					end
				end
			end
		end
	end
end

function pb:canMoveBlock (blockA, dx, dy)
	if self.isRoughCollisionWithMap (blockA.tx+dx, blockA.ty+dy, blockA.w, blockA.h) then
		return false, nil
	end
	for i, block in ipairs (self.blocks) do
		if not (blockA == block) then
			if isRoughAgentBlockCollision (blockA, block, dx, dy) then
				block.color = lightgreen
				if isFineAgentBlockCollision (blockA, block, dx, dy) then
					block.color = green
					return false, block
				end
			else
				block.color = white
			end
		end
	end
	return true
end
	
function pb:canMove (agent, dx, dy)
	if self.isRoughCollisionWithMap (agent.tx+dx, agent.ty+dy, agent.w, agent.h) then
		-- collision with map tiles
--		print ('collision with map')
		return false, nil
	end
	for i, block in ipairs (self.blocks) do
		if isRoughAgentBlockCollision (agent, block, dx, dy) then
			block.color = lightgreen
			if isFineAgentBlockCollision (agent, block, dx, dy) then
				if pb:canMoveBlock (block, dx, dy) then
					block.color = green
					return false, block
				else
					block.color = red
					return false, nil
				end
			end
		else
			block.color = white
		end
	end
	return true
end

function pb:updateAgents (dt)
	local up =    love.keyboard.isScancodeDown('w', 'up')
	local down =  love.keyboard.isScancodeDown('s', 'down')
	local right = love.keyboard.isScancodeDown('d', 'right')
	local left =  love.keyboard.isScancodeDown('a', 'left')
	
	if up and not (down or right or left) then
		-- move up
		local tdy = - dt*self.agent.vup -- delta Y in tiles
		local canMove, block = pb:canMove (self.agent, 0, tdy)
		if canMove then
			self.agent.y = self.agent.y + tdy*pb.grigSize
			self.agent.ty = math.floor(self.agent.y*4/self.grigSize+0.5)/4
		elseif block and block.movable then
			self.agent.y = self.agent.y + tdy*pb.grigSize
			local ty = self.agent.ty
			self.agent.ty = math.floor(self.agent.y*4/self.grigSize+0.5)/4
			block.ty = block.ty + self.agent.ty - ty
		end
	elseif down and not (up or right or left) then
		-- move down
		local tdy = dt*self.agent.vdown -- delta Y in tiles
		local canMove, block = pb:canMove (self.agent, 0, tdy)
		if canMove then
			self.agent.y = self.agent.y + tdy*pb.grigSize
			self.agent.ty = math.floor(self.agent.y*4/self.grigSize+0.5)/4
		elseif block and block.movable then
			self.agent.y = self.agent.y + tdy*pb.grigSize
			local ty = self.agent.ty
			self.agent.ty = math.floor(self.agent.y*4/self.grigSize+0.5)/4
			block.ty = block.ty + self.agent.ty - ty
		end
	elseif right and not (up or down or left) then
		-- move right
		local tdx = dt*self.agent.vx -- delta X in tiles
		local canMove, block = pb:canMove (self.agent, tdx, 0)
		if canMove then
			self.agent.x = self.agent.x + tdx*pb.grigSize
			self.agent.tx = math.floor(self.agent.x*4/self.grigSize+0.5)/4
		elseif block and block.movable then
			self.agent.x = self.agent.x + tdx*pb.grigSize
			local tx = self.agent.tx
			self.agent.tx = math.floor(self.agent.x*4/self.grigSize+0.5)/4
			block.tx = block.tx + self.agent.tx-tx
		end
	elseif left and not (up or down or right) then
		-- move left
		local tdx = -dt*self.agent.vx -- delta X in tiles
		local canMove, block = pb:canMove (self.agent, tdx, 0)
		if canMove then
			self.agent.x = self.agent.x + tdx*pb.grigSize
			self.agent.tx = math.floor(self.agent.x*4/self.grigSize+0.5)/4
		elseif block and block.movable then
			self.agent.x = self.agent.x + tdx*pb.grigSize
			local tx = self.agent.tx
			self.agent.tx = math.floor(self.agent.x*4/self.grigSize+0.5)/4
			block.tx = block.tx + self.agent.tx-tx
		end
	end
end

function pb:update (dt)
	pb:updateAgents (dt)
end


function pb:drawBackgroundGrid ()
	local grigSize = self.grigSize
	local grigWidth = self.grigWidth
	local grigHeight = self.grigHeight
	love.graphics.setLineWidth(1)
	love.graphics.setColor(0.3,0.4,0.4)
	for i = 1, grigWidth+1 do
		love.graphics.line (i*grigSize, grigSize, i*grigSize, grigHeight*grigSize)
	end
	for i = 1, grigHeight do
		love.graphics.line (grigSize, i*grigSize, grigWidth*grigSize, i*grigSize)
	end
end

function pb:drawMap ()
	local map = self.staticTilesMap
	local tileSize = self.grigSize
	love.graphics.setLineWidth(2)
	love.graphics.setColor(yellow)
	for y, xs in pairs (map) do
		for x, value in pairs (xs) do
			love.graphics.rectangle ('fill', x*tileSize, y*tileSize, tileSize, tileSize)
		end
	end
end

function pb:drawBlocks ()
	love.graphics.setLineWidth(2)
	
	local tileSize = self.grigSize
	for i, block in ipairs (self.blocks) do
		local btx = block.tx
		local bty = block.ty 
		love.graphics.setColor(block.color)
		for ty, txs in ipairs (block.form) do
			for tx, value in ipairs (txs) do
				if value == 1 then
					love.graphics.rectangle ('fill', (btx+tx)*tileSize, (bty+ty)*tileSize, tileSize, tileSize)
				end
			end
		end
	end
end

function pb:drawAgent ()
	love.graphics.setLineWidth(2)
	love.graphics.setColor(0,1,0)
	local tileSize = self.grigSize
	local agent = self.agent
	local atx = agent.tx
	local aty = agent.ty 
	love.graphics.print(atx..' '..aty, (atx+1)*tileSize, (aty+1)*tileSize-20)
	for ty, txs in ipairs (agent.form) do
		for tx, value in ipairs (txs) do
			if value == 1 then
--				love.graphics.setColor(1,1,1)
--				love.graphics.rectangle ('line', agent.x+tx*tileSize, agent.y+ty*tileSize, tileSize, tileSize)
				love.graphics.setColor(0,1,0)
				love.graphics.rectangle ('fill', (atx+tx)*tileSize, (aty+ty)*tileSize, tileSize, tileSize)
			end
		end
	end
end




return pb
