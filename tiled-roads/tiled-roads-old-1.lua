-- tiled roads
-- License CC0 (Creative Commons license) (c) darkfrei, 2022


love.window.setTitle( 'tiled roads' )


local TR = {}

function toColor (k)
--	k = k
	k = math.abs(k)^0.5 * (k>0 and 1 or -1)
	local r, g, b = -k, math.abs(k)*0.5-0.5, k
	return r, g, b
end

local function evaluate (curve, t)
	local ccpc = curve:getControlPointCount( )
	if ccpc > 1 then
		return curve:evaluate(t)
	elseif ccpc == 1 then
		return curve:getControlPoint(1)
	else
		return 0, 0
	end
end

function newTile (name, points)
	local colorPoints = {}
	
	local curve = love.math.newBezierCurve(points)
	local ccpc = curve:getControlPointCount ()
	if ccpc == 2 then
-- line
		for i = 0, 8 do
			local t = i/8
			local x, y = evaluate (curve, t)
			local r, g, b = toColor (0)
			table.insert (colorPoints, {x, y, r, g, b, 1})
		end
	elseif ccpc > 2 then
-- quadratic curve and higher
		local dcurve = curve:getDerivative ()
		local ddcurve = dcurve:getDerivative ()
		for i = 0, 8 do
			local t = i/8
			local x, y = evaluate (curve, t)
			local dx,dy = evaluate(dcurve, t)
			local ddx,ddy = evaluate(ddcurve, t)
			local k = (ddx*dy-ddy*dx)/((dx*dx+dy*dy)^(3/2))
			print (k)
			local r, g, b = toColor (k)
			table.insert (colorPoints, {x, y, r, g, b, 1})
		end
	end
	
	local tile ={
		name = name,
		bezierPoints = points,
		curve = curve,
		line = curve:render(),
		colorPoints = colorPoints,
	}
	return tile
end

function TR.load ()
	local tiles = {
		newTile ("road-str-1", {0.5, 1, 0.5, 0}),
		newTile ("road-cur-dia-1", {0.5, 1, 0.5, 0.5, 1, 0}),
		newTile ("road-cur-dia-2", {0.5, 1, 0.5, 0.5, 0.5, 0.5, 1, 0}),
		newTile ("road-cur-dia-3", {0.5,1, 0.5,1-0.75/2, 1-0.75/2,0.75/2, 1, 0}),
		newTile ("road-cur-1", {0.5, 1, 0.5, 0.5, 1, 0.5}),
		newTile ("road-cur-2", {0.5, 1, 0.5, 0.5, 0.5, 0.5, 1, 0.5}),
		newTile ("road-cur-3", {0.5, 1, 0.5, 1-0.55/2, 1-0.55/2, 0.5, 1, 0.5}),
		newTile ("road-dia-1", {0, 1, 1, 0}),
		newTile ("road-cur-4", {1, 1, 0.5, 0.5, 1, 0}),
		newTile ("road-cur-5", {1,1, 0.7,0.7, 0.7,0.3, 1,0}),
		newTile ("road-cur-6", {1,1, 0.6,0.6, 0.6,0.4, 1,0}),
		newTile ("road-cur-7", {0,1, 0.4,0.6, 0.4,0.4, 0,0}),
		newTile ("road-cur-8", {0,1, 0.5,0.5, 0.5,0.5, 0,0}),
		
	}
	TR.tiles = tiles
end

function TR.update(dt)
	
end



function drawTile (tile, x, y, s)
	love.graphics.push()
		love.graphics.translate ((x-1)*s, (y-1)*s)
		love.graphics.scale (s)
		love.graphics.setLineWidth(1/s)
		love.graphics.rectangle('line', 0, 0, 1, 1)
		love.graphics.setLineWidth(40/s)
		love.graphics.setColor (1,1,1)
		love.graphics.line (tile.line)
		love.graphics.setPointSize( 10 )
		love.graphics.setLineWidth(3/s)
		love.graphics.setColor (0.5, 0.5, 0.5)
		love.graphics.line (tile.bezierPoints)
		love.graphics.setColor (1,1,1)
		love.graphics.points (tile.colorPoints)
	love.graphics.pop()
end

function TR.draw()
--	love.graphics.print (TR.text,0,0)
	local s = 150
	drawTile (TR.tiles[1], 1, 1, s)
	drawTile (TR.tiles[2], 1, 2, s)
	drawTile (TR.tiles[3], 2, 2, s)
	drawTile (TR.tiles[4], 3, 2, s)
	drawTile (TR.tiles[5], 1, 3, s)
	drawTile (TR.tiles[6], 2, 3, s)
	drawTile (TR.tiles[7], 3, 3, s)
	drawTile (TR.tiles[8], 2, 1, s)
	drawTile (TR.tiles[9], 1, 4, s)
	drawTile (TR.tiles[10], 2, 4, s)
	drawTile (TR.tiles[11], 3, 4, s)
	drawTile (TR.tiles[12], 5, 4, s)
	drawTile (TR.tiles[13], 5, 3, s)
end

function TR.mousepressed( x, y, button, istouch, presses )
	
end

function TR.mousemoved( x, y, dx, dy, istouch )
	
end

function TR.mousereleased( x, y, button, istouch, presses )
	
end


return TR