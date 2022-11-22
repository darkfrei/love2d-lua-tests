-- just require it

--local keys = {
--	{0,0,0,0,1,0,0,0,0},
--}

local bit = require("bit")


local function drawPoints (a,b,c,d, x,y, subtileSize)
-- edges
		love.graphics.setColor (1,1,1)
		local points = {}
		if a then
			table.insert (points, x)
			table.insert (points, y)
		end
		if b then
			table.insert (points, x+subtileSize-1)
			table.insert (points, y)
		end
		if c then
			table.insert (points, x+subtileSize-1)
			table.insert (points, y+subtileSize-1)
		end
		if d then
			table.insert (points, x)
			table.insert (points, y+subtileSize-1)
		end
		love.graphics.points(points)
end


local function getCanvas()
	local subtileSize = 8
	local dpiscale = 5

	local canvas = love.graphics.newCanvas (8*(subtileSize+1)+1, 47*(subtileSize+1)+1, {dpiscale = dpiscale})
	--local canvas = love.graphics.newCanvas ()
	canvas:setFilter("linear", "nearest")

	love.graphics.setLineStyle("rough")
	love.graphics.setLineWidth(1)
	love.graphics.setCanvas(canvas)
	love.graphics.setPointSize (1)

	for i = 0, 15 do
		
		local a = not(i%2 == 0)
		local b = not(math.floor(i/2)%2 == 0)
		local c = not(math.floor(i/4)%2 == 0)
		local d = not(math.floor(i/8)%2 == 0)
	
		
		local x = 1.5
		local y = i*(subtileSize+1)+1.5
		
		-- outline
		love.graphics.setColor (1,0,1)
		love.graphics.rectangle ('line', x-1, y-1, subtileSize+1,subtileSize+1)
		
		-- background
		love.graphics.setColor (0.5,0.5,0.5)
		love.graphics.rectangle ('fill', x-0.5, y-0.5, subtileSize,subtileSize)
		
		
		drawPoints (a,b,c,d, x,y, subtileSize)
		
	end
	
	-- sides and edges
	local n = 16
	for i = 16, 255 do
		local a = not(i%2 == 0)
		local b = not(math.floor(i/2)%2 == 0)
		local c = not(math.floor(i/4)%2 == 0)
		local d = not(math.floor(i/8)%2 == 0)
		
		local ab = not((math.floor(i/16)%2 == 0))  and a and b
		local bc = not((math.floor(i/32)%2 == 0)) and b and c
		local cd = not((math.floor(i/64)%2 == 0)) and c and d
		local da = not((math.floor(i/128)%2 == 0)) and d and a
		
		local x = 1.5 + math.floor ((n)/16)*(subtileSize+1)
--		print ('x',x, n)
		local y = (n-16)%16*(subtileSize+1)+1.5
		
		-- outline
		love.graphics.setColor (1,0,1)
		love.graphics.rectangle ('line', x-1, y-1, subtileSize+1,subtileSize+1)
		
		love.graphics.setColor (1,1,1)
		if ab and bc and cd and da then
			-- ab
			love.graphics.line (x, y, x+subtileSize-1, y)
			-- bc
			love.graphics.line (x+subtileSize-1, y, x+subtileSize-1, y+subtileSize-1)
			-- cd
			love.graphics.line (x+subtileSize-1, y+subtileSize-1, x, y+subtileSize-1)
			-- da
			love.graphics.line (x, y+subtileSize-1, x, y)
			
			drawPoints (a,b,c,d, x,y, subtileSize)
			print (i, 'abcda')
			n = n+1
			
		elseif ab and bc and cd then
			-- ab
			love.graphics.line (x, y, x+subtileSize-1, y)
			-- bc
			love.graphics.line (x+subtileSize-1, y, x+subtileSize-1, y+subtileSize-1)
			-- cd
			love.graphics.line (x+subtileSize-1, y+subtileSize-1, x, y+subtileSize-1)
			-- da
--			love.graphics.line (x, y+subtileSize-1, x, y)
			
			drawPoints (a,b,c,d, x,y, subtileSize)
			print (i, 'abcd')
			n = n+1
			
		elseif da and ab and bc then
			-- ab
			love.graphics.line (x, y, x+subtileSize-1, y)
			-- bc
			love.graphics.line (x+subtileSize-1, y, x+subtileSize-1, y+subtileSize-1)
			-- cd
--			love.graphics.line (x+subtileSize-1, y+subtileSize-1, x, y+subtileSize-1)
			-- da
			love.graphics.line (x, y+subtileSize-1, x, y)
			
			drawPoints (a,b,c,d, x,y, subtileSize)
			print (i, 'dabc')
			n = n+1
		elseif ab then
			love.graphics.line (x, y, x+subtileSize-1, y)
			drawPoints (a,b,c,d, x,y, subtileSize)
			print (i, 'ab')
			n = n+1
		elseif bc then
			love.graphics.line (x+subtileSize-1, y, x+subtileSize-1, y+subtileSize-1)
			drawPoints (a,b,c,d, x,y, subtileSize)
			print (i, 'bc')
			n = n+1
		elseif cd then
			love.graphics.line (x+subtileSize-1, y+subtileSize-1, x, y+subtileSize-1)
			drawPoints (a,b,c,d, x,y, subtileSize)
			print (i, 'cd')
			n = n+1
		elseif da then
			love.graphics.line (x, y+subtileSize-1, x, y)
			drawPoints (a,b,c,d, x,y, subtileSize)
			print (i, 'da')
			n = n+1
		end
		
	end
	
	

	love.graphics.setCanvas()
	canvas:newImageData():encode("png","filename.png")
	return canvas
end


return getCanvas