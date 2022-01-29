-- License CC0 (Creative Commons license) (c) darkfrei, 2022
-- push-blocks

local pb = {}

pb.grigSize = 40 -- pixels or units
pb.grigWidth = 48-1 -- tiles
pb.grigHeight = 24  -- tiles


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
		sizeX = 3,
		sizeY = 3,
		movable = true,
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
		sizeX = 3,
		sizeY = 3,
		movable = true,
	},
	{	
		tx = 6,  -- position horizontal position in tiles
		ty = 16,
		name = 'plus-block-3x3',
		form = {
			{1,1,1}, -- y=1
			{0,1,0}, -- y=2
			{1,1,1}, -- y=3
		},
		sizeX = 3,
		sizeY = 3,
		movable = true,
	},
}



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
	sizeX = 3,
	sizeY = 1,
}

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

local function isCollision (x1, y1, x2, y2)
--	thanks to https://love2d.org/wiki/BoundingBox.lua
	return x1<x2+1 and x2<x1+1 and y1<y2+1 and y2<y1+1
end

function pb:canMove (agent, dx, dy)
--	if dx>0 then dx = 0.25
--	elseif dx<0 then dx = -0.25
--	end
--	if dy>0 then dy = 0.25
--	elseif dy<0 then dy = -0.25
--	end
	for aty, atxs in ipairs (agent.form) do
		for atx, value in ipairs (atxs) do
			if value == 1 then
				for i, block in ipairs (self.blocks) do
					for bty, btxs in ipairs (block.form) do
						for btx, bvalue in ipairs (btxs) do
							if bvalue == 1 then
								if isCollision (agent.tx+atx+dx, agent.ty+aty+dy, block.tx+btx, block.ty+bty) then
									return false, block
								end
							end
						end
					end
				end
			end
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
		elseif block.movable then
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
		elseif block.movable then
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
		elseif block.movable then
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
		elseif block.movable then
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

function pb:drawBlocks ()
	love.graphics.setLineWidth(2)
	love.graphics.setColor(1,1,1)
	local tileSize = self.grigSize
	for i, block in ipairs (self.blocks) do
		local btx = block.tx
		local bty = block.ty 
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
