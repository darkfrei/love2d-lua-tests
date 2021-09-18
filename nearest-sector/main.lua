-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function get_nearest_line_color (x, y, line)
	local x1, y1, x2, y2 = nearest_sector_in_line (x, y, line)
	
	for i = 1, #line -3, 2 do
		if x1 == line[i] and y1 == line[i+1] and x2 == line[i+2] and y2 == line[i+3] then
			local t = (i-1)/(#line-3)
			local color = get_red_blue_gradient_color (t)
			return color
		end
	end
end


function love.load()
	line = {
	0,266,22,256,44,246,67,234,88,222,107,210,
	124,196,141,181,157,164,173,147,188,130,
	203,114,218,98,236,83,254,71,274,62,295,57,
	318,56,340,60,360,67,375,79,381,95,378,113,
	368,132,355,150,343,168,331,185,322,203,
	317,220,319,234,330,243,347,246,368,243,
	390,236,412,224,434,213,455,207,477,207,
	496,216,508,231,511,249,505,267,492,282,
	474,296,455,307,435,315,413,321,390,324,
	368,325,344,326,320,327,295,329,270,333,
	246,340,224,348,203,360,184,375,167,393,
	155,412,149,432,151,451,162,466,179,478,
	198,487,217,494,236,502,256,509,277,514,
	299,518,324,521,349,523,374,524,398,524,
	422,524,446,524,470,524,493,523,515,522,
	537,519,557,513,573,504,581,493,576,483,
	562,476,544,472,525,469,504,468,484,466,
	465,463,448,457,434,446,423,431,414,416,
	401,405,384,402,366,405,347,410,328,416,
	310,418,295,413,285,403,285,389,294,377,
	309,368,327,363,347,360,369,358,393,357,
	416,357,440,358,462,361,483,366,505,371,
	528,375,552,375,576,373,600,366,623,357,
	642,346,658,333,668,317,669,299,663,279,
	651,260,635,243,618,230,600,218,581,207,
	562,195,544,183,527,169,513,155,503,137,
	497,118,496,99,500,81,512,67,528,59,548,56,
	568,58,588,63,608,72,626,83,644,96,661,110,
	675,126,688,144,700,164,709,185,716,205,
	722,225,726,245,728,266,726,286,722,307,
	716,327,708,346,700,366,692,386,685,407,
	680,429,677,450,673,470,666,490,656,509,
	642,525,626,538,607,548,587,554,565,558,
	543,561,521,563,498,567,476,573,452,581,
	424,589,391,595}

	selected_line = {0,266,22,256}
	
	width, height = love.graphics.getDimensions( )

	
	canvas = love.graphics.newCanvas()
	love.graphics.setCanvas(canvas)
		for x = 1, width do
			for y = 1, height do
				local color = get_nearest_line_color (x, y, line)
				love.graphics.setColor(color)
				love.graphics.points(x, y)
			end
		end
	love.graphics.setCanvas()
end

 
function love.update(dt)
	
end


function get_red_blue_gradient_color (t)
	local r = 2-4*t
	local g = t < 1/2 and 4*t or 4-4*t
	local b = -2 + 4*t
	r = math.min(math.max(0, r), 1)
	g = math.min(math.max(0, g), 1)
	b = math.min(math.max(0, b), 1)
	return {r^0.5,g^0.5,b^0.5,1}
end


function love.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(canvas)
	love.graphics.setColor(0,0,0)
	love.graphics.setLineWidth(11)
	love.graphics.line(line)
	
	love.graphics.setLineWidth(1)
--	love.graphics.line(line)
	for i = 1, #line -3, 2 do
		local t = (i-1)/(#line-3)
		love.graphics.setColor(get_red_blue_gradient_color (t))
		love.graphics.line(line[i],line[i+1],line[i+2],line[i+3])
	end
	
	love.graphics.setColor(1,1,0)
	love.graphics.setLineWidth(3)
	love.graphics.line(selected_line)
end

function distPointToLine(px,py,x1,y1,x2,y2) -- point, start and end of the segment
	local dx,dy = x2-x1,y2-y1
	local length = math.sqrt(dx*dx+dy*dy)
	dx,dy = dx/length,dy/length
	local p = dx*(px-x1)+dy*(py-y1)
	if p < 0 then
		dx,dy = px-x1,py-y1
		return math.sqrt(dx*dx+dy*dy)
	elseif p > length then
		dx,dy = px-x2,py-y2
		return math.sqrt(dx*dx+dy*dy)
	end
	return math.abs(dy*(px-x1)-dx*(py-y1))
end

function nearest_sector_in_line (x, y, line)
	local x1, y1, x2, y2, min_dist
	local ax,ay = line[1], line[2]
	for j = 3, #line-1, 2 do
		local bx,by = line[j], line[j+1]
		local dist = distPointToLine(x,y,ax,ay,bx,by)
		if not min_dist or dist < min_dist then
			min_dist = dist
			x1, y1, x2, y2 = ax,ay,bx,by
		end
		ax, ay = bx, by
	end
--	love.graphics.line(x1, y1, x2, y2)
	return x1, y1, x2, y2
end

function love.mousemoved( x, y, dx, dy, istouch )
	local x1, y1, x2, y2 = nearest_sector_in_line (x, y, line)
	selected_line = {x1, y1, x2, y2}
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end
