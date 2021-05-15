-- I need isobands
-- darkfrei 2021-02-11


get_mLines = require ('luams')

love.window.setTitle( 'isolines-and-isobands-04' )


local tileSize = 70

local function drawGrid()
	love.graphics.setColor(0, 0.5,0)
	local w = math.ceil( love.graphics.getWidth() / tileSize )
	local h = math.ceil( love.graphics.getHeight() / tileSize )
	local width, height = love.graphics.getDimensions()	
	for r=0, w do love.graphics.line(r * tileSize, 0, r * tileSize, height) end	
	for c=0, h do love.graphics.line(0, c * tileSize, width, c * tileSize) end
end

function transpose (udata)
	local tdata = {}
	for y, xs in pairs (udata) do
		for x, value in pairs (xs) do
			tdata[x]=tdata[x]or{}
			tdata[x][y]=value
		end
	end
	return tdata
end


function get_data ()
	local data = { -- values in grid cells
		{  0,   0,   0,   0,   0,   0,   0,   0},
		{  0, 0.5,   0, 0.2, 0.3, 0.2,  1.5,   0},
		{  0, 0.7,   1, 0.3, 0.7, 0.9, 0.7,   0},
		{  0,   1,   1,   2, 0.6, 0.25,0.2,   0},
		{  0, 0.8,   1,   1, 0.1, 0.2, 0.1,   0},
		{  0, 0.3, 0.1,   1, 0.1, 0.1,0.05,   0},
		{  0,   0,   0,   0,   0,   0,   0,   0},
	}
	data = transpose (data)
	return data
end

function get_levels (data)
	local levels = {}
	for i=0.1,0.9,0.1 do
		levels[#levels+1]=i
	end
--	print (unpack(levels))
	return levels
end


function draw_mLines(mLines)
	local s = tileSize
	for u, sLines in pairs (mLines) do
		local color = {u*2,2-u*2,0}
		love.graphics.setColor(color)
		for i, sLine in pairs (sLines) do
--			sLine
--			print ('sLine[1]: '..sLine[1].x..' '..sLine[1].y)
--			print ('sLine[2]: '..sLine[2].x..' '..sLine[2].y)
--			print (u..'sLine position: '..sLine.position.cx..' '..sLine.position.cy)
			local cx, cy = sLine.position.cx, sLine.position.cy
			love.graphics.line(s*(cx-1+sLine[1].x),s*(cy-1+sLine[1].y),s*(cx-1+sLine[2].x),s*(cy-1+sLine[2].y))
		end
	end
end

function serializeTable(val, name, skipnewlines, depth)
    skipnewlines = skipnewlines or false
    depth = depth or 0

    local tmp = string.rep(" ", depth)

    if name then tmp = tmp .. name .. " = " end

    if type(val) == "table" then
        tmp = tmp .. "{" .. (not skipnewlines and "\n" or "")

        for k, v in pairs(val) do
            tmp =  tmp .. serializeTable(v, k, skipnewlines, depth + 1) .. "," .. (not skipnewlines and "\n" or "")
        end

        tmp = tmp .. string.rep(" ", depth) .. "}"
    elseif type(val) == "number" then
        tmp = tmp .. tostring(val)
    elseif type(val) == "string" then
        tmp = tmp .. string.format("%q", val)
    elseif type(val) == "boolean" then
        tmp = tmp .. (val and "true" or "false")
    else
        tmp = tmp .. "\"[inserializeable datatype:" .. type(val) .. "]\""
    end

    return tmp
end

function love.load()
	love.window.setMode( 600, 600)
	local data = get_data ()
--	print(serializeTable(data))
	local levels = get_levels (data)
	
	
	local mLines = get_mLines (data, levels)
	
--	print('mLines: '..serializeTable(mLines))
	
	canvas = love.graphics.newCanvas()
	love.graphics.setCanvas(canvas)
		drawGrid()
		draw_mLines(mLines)
		
--		draw_uData(uData)
--		draw_mTextes(textes)
--		draw_mPoints(mPoints)
		
--		drawBands(bands)
	
	love.graphics.setCanvas()
	
--	local data = canvas:newImageData( )
--	data:encode('png')
	
	love.graphics.captureScreenshot( 'file.png' )

end

function love.draw()
	love.graphics.setColor(1,1,1)
	love.graphics.draw(canvas)
end






















