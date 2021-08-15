-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function get_intersection (ax, ay, bx, by, cx, cy, dx, dy) -- start end start end
	-- from line-following
	local d = (ax-bx)*(cy-dy)-(ay-by)*(cx-dx)
	if d == 0 then return end
	local a, b = ax*by-ay*bx, cx*dy-cy*dx
	local x = (a*(cx-dx) - b*(ax-bx))/d
	local y = (a*(cy-dy) - b*(ay-by))/d
	if x <= math.max(ax, bx) and x >= math.min(ax, bx) and
		x <= math.max(cx, dx) and x >= math.min(cx, dx) then
--			return {x=x, y=y}
			return x, y
	end
end

function normalization (x, y, offset)
	local d = (x*x+y*y)^0.5
	offset = offset or 1
	return offset*x/d, offset*y/d
end



function get_offset (vertices, offset)
	local offset_polygone = {}
	print ( #vertices)
	for i = 1, #vertices-1, 2 do
		local x1, y1 = vertices[i], vertices[i+1]
		local x2, y2 = vertices[i+2], vertices[i+3]
		if not x2 then
			x2, y2 = vertices[1], vertices[2]
		end
		local dx = x2-x1
		local dy = y2-y1
		local vnormx, vnormy = normalization (dx, dy, offset)
		local nx = vnormy
		local ny = -vnormx
		if counter_clockwise or other_side then
			nx = -vnormy
			ny =  vnormx
		end
		local px1, py1 = x1+nx, y1+ny
		local px2, py2 = x2+nx, y2+ny
		table.insert (offset_polygone, px1)
		table.insert (offset_polygone, py1)
		table.insert (offset_polygone, px2)
		table.insert (offset_polygone, py2)
	end
--	print ( #offset_polygone)
	return offset_polygone
end

function love.load()
	width, height = love.graphics.getDimensions( )

	-- polygon:
	vertices = {330,230, 370,190, 410,190, 390,230, 410,270, 450,290,
		490,270, 490,310, 450,350, 410,330, 370,350, 330,310, 350,270}
	local s = 3
	local dx = -270*s
	local dy = -170*s
	for i, v in pairs (vertices) do
		if i%2 == 0 then
			vertices[i] = v*s+dy
		else
			vertices[i] = v*s+dx
		end
	end
	
	r = 30
	offset_polygone = get_offset (vertices, r)
	for i = 1, #offset_polygone-3, 2 do
		print (offset_polygone[i], offset_polygone[i+1])
	end
	love.graphics.setLineWidth(3)
end

 
function love.update(dt)
	
end

function draw_concave (vertices)
	local triangles = love.math.triangulate(vertices)
	for i, triangle in ipairs(triangles) do
		love.graphics.polygon("fill", triangle)
	end
end

function draw_polygon (vertices, is_offset)
	if is_offset then
		love.graphics.setColor (0,1,0)
		love.graphics.polygon ('line', vertices)
	else
		love.graphics.setColor (0.5,0.5,0.5)
		draw_concave (vertices)
		love.graphics.setColor (1,1,1)
		love.graphics.polygon ('line', vertices)
	end
end

function love.draw()
	draw_polygon (vertices, false)

	love.graphics.setColor (1,1,1)
	draw_polygon (offset_polygone, true)
--	love.graphics.line (offset_polygone)
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end