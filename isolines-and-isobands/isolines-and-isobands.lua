-- isolines and isobands

local iso = {}


--[[
The iso.createNoise function takes several optional parameters: 
noiseFunction (defaulting to love.math.noise), 
shiftX, shiftY, scaleX, scaleY, and angle. 
These parameters control the transformation 
and scaling applied to the input coordinates 
before passing them to the noiseFunction.

The resulting noise function is assigned to iso.noise 
and can be called with x and y coordinates 
to retrieve the noise value.

You can use this iso.noise function to generate 
noise values based on the provided parameters.
]]

function iso.createNoise(noiseFunction, shiftX, shiftY, scaleX, scaleY, angle)
  noiseFunction = noiseFunction or love.math.noise
  shiftX = shiftX or 0
  shiftY = shiftY or 0
  scaleX = scaleX or 1
  scaleY = scaleY or 1
  angle = angle or 0
  
  iso.noise = function(x, y)
		y = -y -- maybe delete
    x, y = x*math.cos(angle)-y*math.sin(angle), x*math.sin(angle)+y*math.cos(angle)
    x = (x + shiftX) * scaleX
    y = (y + shiftY) * scaleY
    return noiseFunction(x, y)
  end
end


--[[
The function iterates over each row and column 
of the grid and calls iso.noise 
to generate a noise value for each position. 
The resulting values are stored in the grid table.
]]

function iso.createNoiseGrid (width, height)
	local xMin, xMax = 1, width
	local yMin, yMax = 1, height
  local noiseGrid = {}
  for y = yMin, yMax do
		noiseGrid[y] = {}
    for x = xMin, xMax do
      local value = iso.noise (x, y)
      noiseGrid[y][x] = value
    end
  end
	iso.xMin, iso.xMax = xMin, xMax
	iso.yMin, iso.yMax = yMin, yMax
	iso.noiseGrid = noiseGrid
  return noiseGrid
end


--[[
The function calculates the interpolation parameter t 
and then checks if it is less than 0 or greater than 1. 
If t is less than 0, it returns the coordinates 
of the first point along with false to indicate 
that no interpolation was performed. If t is greater than 1, 
it returns the coordinates of the second point along with false. 
Otherwise, if t is within the range [0, 1], it performs 
linear interpolation to determine the x and y coordinates 
of the interpolated point and returns them along with true 
to indicate successful interpolation.
]]
local function interpolatePoint(x1, y1, v1, x2, y2, v2, isovalue)
  -- Calculate the interpolation parameter t
  local t = (isovalue - v1) / (v2 - v1)

  -- Check if t is less than 0
  if t < 0 then
    -- Return the coordinates of the first point and false to indicate no interpolation
    return x1, y1, false
  end

  -- Check if t is greater than 1
  if t > 1 then
    -- Return the coordinates of the second point and false to indicate no interpolation
    return x2, y2, false
  end

  -- Perform linear interpolation to determine the x and y coordinates of the interpolated point
  local x = x1 + t * (x2 - x1)
  local y = y1 + t * (y2 - y1)

  -- Return the interpolated x and y coordinates along with true to indicate successful interpolation
  return x, y, true
end

local function interpolateAndInsertPoint(x1, y1, v1, x2, y2, v2, isovalue, line)
  local px, py, success = interpolatePoint(x1, y1, v1, x2, y2, v2, isovalue)
  if success then
    table.insert(line, px)
    table.insert(line, py)
  end
end

local function findIsoLine(x, y, isovalue)
  local noiseGrid = iso.noiseGrid
  local xs = {x, x+1, x+1, x}
  local ys = {y, y, y+1, y+1}
  local vs = {noiseGrid[y][x], noiseGrid[y][x+1], noiseGrid[y+1][x+1], noiseGrid[y+1][x]}
  local line = {}
  for i = 1, 4 do
    local j = i % 4 + 1
    local x1, y1, v1 = xs[i], ys[i], vs[i]
    local x2, y2, v2 = xs[j], ys[j], vs[j]
    if math.min(v1, v2) < isovalue and math.max(v1, v2) >= isovalue then
      interpolateAndInsertPoint(x1, y1, v1, x2, y2, v2, isovalue, line)
    end
  end

  if #line == 8 then
    if math.abs(vs[1] + vs[3] - 2 * isovalue) > math.abs(vs[2] + vs[4] - 2 * isovalue) then
      return {line[1], line[2], line[3], line[4]}, {line[5], line[6], line[7], line[8]}
    else
      return {line[1], line[2], line[7], line[8]}, {line[5], line[6], line[3], line[4]}
    end
  elseif #line == 4 then
    return line
  end
end

local function createIsolines (isovalue)
	local isolines = {} -- list of lines for isovalues
	for y = iso.yMin, iso.yMax-1 do
		for x = iso.xMin, iso.xMax-1 do
			local line1, line2 = findIsoLine(x, y, isovalue)
			table.insert (isolines, line1)
			table.insert (isolines, line2)
		end
	end
	if not iso.isolines then iso.isolines = {} end
	iso.isolines[isovalue] = isolines
	return isolines
end



local function createNoisePoints (isovalueMin, isovalueMax, r, g, b)
	local noiseMap = iso.noiseGrid
	local noisePoints = {}
	for y = iso.yMin, iso.yMax do
		for x = iso.xMin, iso.xMax do
			local t = noiseMap[y][x]
			if isovalueMin < t and t <= isovalueMax then
				table.insert(noisePoints, {x, y, r, g, b ,1})
			end
		end
	end
	
	if not iso.noisePoints then iso.noisePoints = {} end
	iso.noisePoints[isovalueMin..'-'..isovalueMax] = noisePoints
	return noisePoints
end


return iso