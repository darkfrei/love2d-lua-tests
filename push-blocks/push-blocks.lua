-- License CC0 (Creative Commons license) (c) darkfrei, 2022
-- push-blocks

local pb = {}

local function setBlockOutline (block)
	local m = {} -- map of outlines
	local tiles = block.tiles -- list of tiles as {x1,y1, x2,y2, x3,y3 ...}
	for i = 1, #tiles, 2 do
		local x, y = tiles[i], tiles[i+1]
		if not m[y] then m[y] = {} end
		if not m[y][x] then 
			m[y][x] = {v=true, h=true} 
		else
			m[y][x].v = not m[y][x].v
			m[y][x].h = not m[y][x].h
		end
		
		if not m[y][x+1] then 
			m[y][x+1] = {v=true, h=false} 
		else
			m[y][x+1].v = not m[y][x+1].v
		end
		
		if not m[y+1] then m[y+1] = {} end
		if not m[y+1][x] then 
			m[y+1][x] = {v=false, h=true} 
		else
			m[y+1][x].h = not m[y+1][x].h
		end
	end
	local lines = {}
	for y, xs in pairs (m) do
		for x, tabl in pairs (xs) do
			if m[y][x].v then
				table.insert (lines, {x,y, x,y+1})
			end
			if m[y][x].h then
				table.insert (lines, {x,y, x+1,y})
			end
		end
	end
	block.lines = lines
end

function pb:load (level)
--	print (level.name)
	local width, height = love.graphics.getDimensions()
	self.map = level.map
	self.gridWidth = level.w
	self.gridHeight = level.h
	self.gridSize = math.min(width/(level.w), height/(level.h))
	print ('self.gridWidth', self.gridWidth)
	
	self.blocks = level.blocks
	for i, block in ipairs (self.blocks) do
		setBlockOutline (block)
	end
	self.agents = level.agents
	for i, agent in ipairs (self.agents) do
		setBlockOutline (agent)
	end
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
		if agent == self.agent then
			-- no collision detection with active agent
		elseif self:isBlockToBlockCollision (blockA, agent, dx, dy) then
			return false -- cannot move any agent
		end
	end
	
	for i, block in ipairs (self.blocks) do
		if block == blockA then
			-- self collision: do nothing
		elseif isValueInList (block, blocks) then
			-- block is already in list: do nothing
		elseif self:isBlockToBlockCollision (blockA, block, dx, dy) then
			-- checks if the agent is strong
			if block.heavy and not self.agent.heavy then
				return false
			end
			table.insert (blocks, block)
			
			-- make it deeper!
			if not self:getCollisionBlocks (block, blocks, dx, dy) then
				return false
			end
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
	if scancode == 'right' or scancode == 'left' or scancode == 'up' or scancode == 'down' then
		local dx = scancode == 'right' and 1 or scancode == 'left' and -1 or 0
		local dy = scancode == 'down' and 1 or scancode == 'up' and -1 or 0
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

function pb:drawOutline  (block)
	local lines = block.lines
	local tileSize = self.gridSize
	local x, y = block.x-1, block.y-1
	for i, line in ipairs (lines) do
		love.graphics.line ((x+line[1])*tileSize, (y+line[2])*tileSize, (x+line[3])*tileSize, (y+line[4])*tileSize)
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
	love.graphics.setColor(1,1,0.5)
	for i, block in ipairs (self.blocks) do
		-- draw filled block
		love.graphics.setLineWidth(1)
		love.graphics.setColor(1,1,0.5)
		self:drawBlock (block)
		
		-- outline
		love.graphics.setLineWidth(3)
		if block.heavy then
			love.graphics.setColor(0,1,1)
		else
			love.graphics.setColor(0,1,0)
		end
		self:drawOutline  (block)
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
		
		-- outline
		love.graphics.setLineWidth(3)
		if agent.heavy then
			love.graphics.setColor(0,1,1)
		else
			love.graphics.setColor(0,1,0)
		end
		self:drawOutline  (agent)
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
