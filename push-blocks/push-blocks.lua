-- License CC0 (Creative Commons license) (c) darkfrei, 2022
-- push-blocks

local pb = {}

function pb:load (level)
--	print (level.name)
	local width, height = love.graphics.getDimensions()
	self.map = level.map
	self.gridWidth = level.w
	self.gridHeight = level.h
	self.gridSize = math.min(width/(level.w), height/(level.h))
	print ('self.gridWidth', self.gridWidth)
	
	self.blocks = level.blocks
	self.agents = level.agents
	self.activeAgentIndex = 1
	self.agent = self.agents[self.activeAgentIndex]
	self.agent.active = true
end

function pb:switchAgent ()
	self.agent.active = false
	local index = self.activeAgentIndex + 1
	if index > #self.agents then
		index = 1
	end
	self.activeAgentIndex = index
	self.agent = self.agents[self.activeAgentIndex]
	self.agent.active = true
end

local function checkCollision(x1,y1,w1,h1, x2,y2,w2,h2)
--	thanks to https://love2d.org/wiki/BoundingBox.lua
	return x1<x2+w2 and x2<x1+w1 and y1<y2+h2 and y2<y1+h1
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
	
--function pb:canMove (dx, dy)
--	if self.isRoughCollisionWithMap (agent.tx+dx, agent.ty+dy, agent.w, agent.h) then
--		-- collision with map tiles
----		print ('collision with map')
--		return false, nil
--	end
--	for i, block in ipairs (self.blocks) do
--		if isRoughAgentBlockCollision (agent, block, dx, dy) then
--			block.color = lightgreen
--			if isFineAgentBlockCollision (agent, block, dx, dy) then
--				if pb:canMoveBlock (block, dx, dy) then
--					block.color = green
--					return false, block
--				else
--					block.color = red
--					return false, nil
--				end
--			end
--		else
--			block.color = white
--		end
--	end
--	return true
--end

local function isValueInList (value, list)
	for i, element in ipairs (list) do
		if element == value then return true end
	end
	return false
end

function pb:isBlockToMapCollision (block, dx, dy)
	local x, y = block.x, block.y
	local map = self.map
	for i = 1, #block.tiles-1, 2 do
		local mapX = x + block.tiles[i]   + dx
		local mapY = y + block.tiles[i+1] + dy
		if map[mapY][mapX] then return true end
	end
end

function pb:isBlockToBlockCollision (blockA, blockB, dx, dy)
	-- fine tile to tile collision detection
	-- check if blockA moves to dx, dy an collides with blockB
	local xA, yA = blockA.x + dx, blockA.y + dy
	local xB, yB = blockB.x, blockB.y
	local tilesA = blockA.tiles
	local tilesB = blockB.tiles
	for i = 1, #tilesA-1, 2 do
		local dXA, dYA = tilesA[i], tilesA[i+1]
		for j = 1, #tilesB-1, 2 do
			local dXB, dYB = tilesB[j], tilesB[j+1]
			if (xA+dXA == xB+dXB) and (yA+dYA == yB+dYB) then
				-- same x AND same y means collision
				return true
			end
		end
	end
	return false
end


	
function pb:getCollisionBlocks (blockA, blocks, dx, dy)
	-- agent to map or block to map collision
	if self:isBlockToMapCollision (blockA, dx, dy) then
		return false
	end
	
	for i, agent in ipairs (self.agents) do
		if not (agent == blockA) 
		and self:isBlockToBlockCollision (blockA, agent, dx, dy) then
			return false -- cannot move any agent
		end
	end
	
	for i, block in ipairs (self.blocks) do
		if block == blockA then
			-- self collision: do nothing
		elseif isValueInList (block, blocks) then
			-- block is already in list: do nothing
		elseif self:isBlockToBlockCollision (blockA, block, dx, dy) then
			table.insert (blocks, block)
			if not self:getCollisionBlocks (block, blocks, dx, dy) then
				return false
			end
--			return false -- cannot move any block
			
--			pb:getCollisionBlocks (block, blocks, dx, dy)
			
		end
	end
	return true
end



function pb:getBlocksToMove (agent, dx, dy)
	local blocks = {}
	local canMove = self:getCollisionBlocks (agent, blocks, dx, dy)
	return blocks, canMove
end


function pb:moveAgent (agent, dx, dy)
	self.agent.x = self.agent.x + dx
	self.agent.y = self.agent.y + dy
end

function pb:moveBlocks (blocks, dx, dy)
	for i, block in ipairs (blocks) do
		block.x = block.x + dx
		block.y = block.y + dy
	end
end

function pb:isCollisionBlockToAllBlocks (blockA, dx, dy)
	for i, block in ipairs (self.blocks) do
		if not (block == blockA) 
		and self:isBlockToBlockCollision (blockA, block, dx, dy) then
			return true
		end
	end
	return false
end

function pb:isCollisionBlockToAllAgents (blockA, dx, dy)
	for i, agent in ipairs (self.agents) do
		if self:isBlockToBlockCollision (blockA, agent, dx, dy) then
			return agent -- dead agent :(
		end
	end
	return false
end

function pb:fallBlocks (blocks)
	local dx, dy = 0, 1 -- no horizontal speed, but positive (down) vertical
	for i = 1, self.gridWidth do
		for i, block in ipairs (blocks) do
			if self:isBlockToMapCollision (block, dx, dy) then
				-- not falling
				block.deadly = false
--				table.remove (blocks, i)
			elseif self:isCollisionBlockToAllBlocks (block, dx, dy) then
				block.deadly = false
				-- collision to block: probably not falling
			elseif block.deadly and self:isCollisionBlockToAllAgents (block, dx, dy) then
				local deadAgent = self:isCollisionBlockToAllAgents (block, dx, dy)
				deadAgent.dead = true
				block.deadly = false
--				table.remove (blocks, i)
			elseif self:isCollisionBlockToAllAgents (block, dx, dy) then
				-- the block is on fish
			else
				-- sure falling
				block.x = block.x + dx -- never changes
				block.y = block.y + dy
				block.deadly = true
			end
		end
	end
end

function pb:mainMoving (dx, dy)
	local agent = self.agent -- active agent
	local blocks, canMove = self:getBlocksToMove (agent, dx, dy)
	if canMove then
		self:moveAgent (agent, dx, dy)
		self:moveBlocks (blocks, dx, dy)
		self:fallBlocks (self.blocks, dx, dy)
	end
end


function pb:keypressedMoving (scancode)
	if scancode == 'w' or scancode == 'a' or scancode == 's' or scancode == 'd' then
		-- d means 1; a means -1; otherwise 0
		local dx = scancode == 'd' and 1 or scancode == 'a' and -1 or 0
		-- s means 1; w means -1; otherwise 0
		local dy = scancode == 's' and 1 or scancode == 'w' and -1 or 0
		pb:mainMoving (dx, dy)
	end
end

---------------------------------------------------------------------------------------------------
-- draw
---------------------------------------------------------------------------------------------------

function pb:drawBackgroundGrid ()
	local gridSize = self.gridSize
	local gridWidth = self.gridWidth
	local gridHeight = self.gridHeight
	love.graphics.setLineWidth(1)
	love.graphics.setColor(0.3,0.4,0.4)
	for i = 0, gridWidth do
		love.graphics.line (i*gridSize, gridSize, i*gridSize, gridHeight*gridSize)
	end
	for i = 0, gridHeight do
		love.graphics.line (gridSize, i*gridSize, gridWidth*gridSize, i*gridSize)
	end
end

function pb:drawMap ()
	local map = self.map
	local tileSize = self.gridSize
	love.graphics.setLineWidth(2)
	
	for y, xs in ipairs (map) do
		for x, value in ipairs (xs) do
			-- value is boolean: true or false
			if value then -- map tile
				-- beware of -1
				love.graphics.setColor(0.5,0.5,0.5)
				love.graphics.rectangle ('fill', (x-1)*tileSize, (y-1)*tileSize, tileSize, tileSize)
				
				love.graphics.setColor(0,0,0)
				love.graphics.print ((x)..' '..(y), (x-1)*tileSize, (y-1)*tileSize)
			end
		end
	end
end

function pb:drawBlock (block)
	local x, y = block.x, block.y
	local tileSize = self.gridSize
	for i = 1, #block.tiles-1, 2 do
		local dx, dy = block.tiles[i], block.tiles[i+1]
		-- beware of -1
		love.graphics.rectangle ('fill', (x+dx-1)*tileSize, (y+dy-1)*tileSize, tileSize, tileSize)
	end
end

function pb:drawBlocks ()
	love.graphics.setLineWidth(2)
	love.graphics.setColor(1,1,0.5)
	for i, block in ipairs (self.blocks) do
		self:drawBlock (block)
	end
end

function pb:drawDeadAgent (agent)
	local tileSize = self.gridSize 
	local x = (agent.x-1)*tileSize
	local y = (agent.y-1)*tileSize
	local w = agent.w*tileSize
	local h = agent.h*tileSize
	
	love.graphics.line (x, y, x+w, y+h)
	love.graphics.line (x, y+h, x+w, y)
end

function pb:drawAgents ()
	local activeAgent = self.agent
	local tileSize = self.gridSize 
	for i, agent in ipairs (self.agents) do
		if agent == activeAgent then
			love.graphics.setColor(1,1,1)
			self:drawBlock (agent)
			local x, y = agent.x, agent.y
			love.graphics.setColor (0, 0, 0)
			love.graphics.print (agent.x..' '..agent.y, (agent.x-1)*tileSize, (agent.y-1)*tileSize)
		else
			love.graphics.setColor(0.75,0.75,0.5)
			self:drawBlock (agent)
		end
		if agent.dead then
			love.graphics.setColor(0,0,0)
			self:drawDeadAgent (agent)
		end
	end
end

function pb:drawMouse ()
	local mx, my = love.mouse.getPosition()
	local tileSize = self.gridSize 
	local x = math.floor(mx/tileSize)+1
	local y = math.floor(my/tileSize)+1
	love.graphics.setColor (0, 1, 0)
	love.graphics.print (x..' '..y, (x-1)*tileSize, (y-1)*tileSize) -- beware of -1
end


return pb
