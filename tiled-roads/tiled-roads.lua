-- tiled roads
-- License CC0 (Creative Commons license) (c) darkfrei, 2022


love.window.setTitle( 'tiled roads' )


local TR = {}



function newTile (x1, y1, x3, y3)
	local p2 = {0.5, 0.5}
	local points = {x1, y1, p2[1], p2[2], x3, y3}
	
	local curve = love.math.newBezierCurve(points)
	
	
	
	local tile ={
		bezierPoints = points,
		curve = curve,
		line = curve:render(),
	}
	return tile
end

function TR.load (tileSize)
	local tiles = {
		newTile (0.5, 1, 0.5, 0),
		newTile (0.5, 1, 1,   0),
		newTile (0.5, 1, 1,   0.5),
		newTile (0,   1, 1,   0),
		newTile (1,   1, 1,   0),
		newTile (0,   1, 0,   0),
	}
	TR.tiles = tiles
	TR.tileSize = tileSize
end

function TR.update(dt)
	
end



function drawTile (tile, x, y, s)
	love.graphics.push()
		love.graphics.translate ((x-1)*s, (y-1)*s)
		love.graphics.scale (s)
		love.graphics.setLineWidth(2/s)
		love.graphics.setColor (1,1,1)
		love.graphics.rectangle('line', 0, 0, 1, 1)
--		love.graphics.setColor (1,1,1)
--		love.graphics.line (tile.line)
	love.graphics.pop()
end

function TR.draw()
--	love.graphics.print (TR.text,0,0)
	local tileSize = TR.tileSize
	drawTile (TR.tiles[1], 1, 1, tileSize)
	drawTile (TR.tiles[2], 1, 2, tileSize)
	drawTile (TR.tiles[3], 2, 2, tileSize)
	drawTile (TR.tiles[4], 3, 2, tileSize)
	drawTile (TR.tiles[5], 1, 3, tileSize)
	drawTile (TR.tiles[6], 2, 3, tileSize)

end

function TR.mousepressed( x, y, button, istouch, presses )
	
end

function TR.mousemoved( x, y, dx, dy, istouch )
	
end

function TR.mousereleased( x, y, button, istouch, presses )
	
end


return TR