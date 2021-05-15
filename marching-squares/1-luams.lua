-- from https://github.com/phobus/LuaMarchingSquares/tree/master/src

local LEFT, RIGHT, TOP, BOTTOM, NONE = "LEFT", "RIGHT", "TOP", "BOTTOM", "NONE"
local ts, hts = 1, 0.5

local verbose= false
local interpolate= true

local function log(...) if verbose then print(...) end end

local function clearTile(tile) if tile.tile_id ~= 5 and tile.tile_id ~= 10 and tile.tile_id ~= 15 then tile.tile_id = 15 end end

local function getXY(tile, side)
  if     side == TOP    then return    tile.top, 0.0
  elseif side == LEFT   then return         0.0, tile.left
  elseif side == RIGHT  then return         1.0, tile.right
  elseif side == BOTTOM then return tile.bottom, 1.0
  end
end

local function firstSide(tile, prev)
  local id = tile.tile_id
  if      id == 1 or id == 3  or id == 7              then return LEFT
  elseif  id == 2 or id == 6  or id == 14             then return BOTTOM
  elseif  id == 4 or id == 11 or id == 12 or id == 13 then return RIGHT
  elseif  id == 8 or id == 9                          then return TOP
  elseif  id == 5 then
    if prev == LEFT then return RIGHT elseif prev == RIGHT then return LEFT end
  elseif  id == 10 then
    if prev == BOTTOM then return TOP elseif prev == TOP then return BOTTOM end
  end
end

local function secondSide(tile, prev)
  local id = tile.tile_id
  if      id == 8 or id == 12 or id == 14 then return LEFT
  elseif  id == 1 or id == 9  or id == 13 then return BOTTOM
  elseif  id == 2 or id == 3  or id == 11 then return RIGHT
  elseif  id == 4 or id == 6  or id == 7  then return TOP
  elseif  id == 5 then
    if prev == LEFT then
      if tile.flipped then return BOTTOM else return TOP end
    elseif prev == RIGHT then 
      if tile.flipped then return TOP else return BOTTOM end
    end
  elseif id == 10 then
    if prev == BOTTOM then
      if tile.flipped then return RIGHT else return LEFT end
    elseif prev == TOP then 
      if tile.flipped then return LEFT else return RIGHT end
    end
  end
end

local function traceSection(bitMaskLayers, i, r, c)
  local layer = bitMaskLayers.layers[i]
  local currentCell = layer[r][c]
  local rows = bitMaskLayers.rows
  local path = {}
  local ndx = 1
  local x, y = c -1, r -1
  
  -- push initial segment
  local edge = firstSide(currentCell, NONE)
  path[ndx], path[ndx+1]= getXY(currentCell, edge)
  path[ndx], path[ndx+1]= path[ndx] + x, path[ndx+1] + y
  ndx = ndx + 2
  
  edge = secondSide(currentCell, edge)
  path[ndx], path[ndx+1]= getXY(currentCell, edge)
  path[ndx], path[ndx+1]= path[ndx] + x, path[ndx+1] + y
  ndx = ndx + 2  
  log("Start " .. firstSide(currentCell, NONE) .. " to " .. secondSide(currentCell, edge), " id: " .. currentCell._id .. " row: " ..  r .. " col: " .. c)
  
  clearTile(currentCell)
  
  local r2, c2 = r, c
  -- now walk arround the enclosed area in clockwise-direction                            
  if     edge == LEFT   then c2 = c2 - 1
  elseif edge == RIGHT  then c2 = c2 + 1
  elseif edge == BOTTOM then r2 = r2 + 1
  elseif edge == TOP    then r2 = r2 - 1 end
  x, y = c2 -1, r2 -1
  
  local closed = true
  while r2 >= 1 and c2 >= 1 --and r2 < rows 
  and (r ~= r2 or c ~= c2) do
    currentCell = layer[r2] and layer[r2][c2]
    if not currentCell then 
      print(r2 .. " " .. c2 .. " is undefined, stopping path!")
      break
    end
    if currentCell.tile_id == 15 or currentCell.tile_id == 0 then
      return { path= path, info= "mergeable" }
    end
    edge = secondSide(currentCell, edge)
    path[ndx], path[ndx+1]= getXY(currentCell, edge)
    path[ndx], path[ndx+1]= path[ndx] + x, path[ndx+1] + y
    ndx = ndx + 2            
    log("  path to " .. edge  , " id: " .. currentCell._id .. " row: " ..  r2 .. " col: " .. c2)
    
    clearTile(currentCell)            
    if     edge == LEFT   then c2 = c2 - 1
    elseif edge == RIGHT  then c2 = c2 + 1
    elseif edge == BOTTOM then r2 = r2 + 1
    elseif edge == TOP    then r2 = r2 - 1 end
    x, y = c2 -1, r2 -1
  end          
  return {path= path, info= "closed"}
end

local function clearDuplicatePoints(paths)  
  for l=1, #paths do    
    for p=1, #paths[l] do      
      for n=1, #paths[l][p], 2 do
        if not paths[l][p][n+2] then break end
        local x1, y1 = paths[l][p][n], paths[l][p][n+1]        
        local x2, y2 = paths[l][p][n+2], paths[l][p][n+3]        
        while x1 == x2 and y1 == y2 do
          table.remove(paths[l][p], n)
          table.remove(paths[l][p], n)
          x2, y2 = paths[l][p][n+2], paths[l][p][n+3]          
        end
      end
    end  
  end
end

local function tracePaths(bitMaskLayers)
  local rows= bitMaskLayers.rows
  local cols= bitMaskLayers.cols
  local length= bitMaskLayers.length
  local layers= bitMaskLayers.layers
  local paths = {}
  local epsilon = 1e-7
  local abs = math.abs
  
  for i=1, length do    
    local path_idx = 1
    paths[i] = {}
    
    for r=1, rows do      
      for c=1, cols do        
        local currentCell = layers[i][r] and layers[i][r][c]
        if  currentCell and
            currentCell.tile_id ~= 15 and currentCell.tile_id ~= 0 and  --not isTrivial
            currentCell.tile_id ~= 5 and currentCell.tile_id ~= 10 then --not isSaddle
          local section= traceSection(bitMaskLayers, i, r, c)
          local merged = false
          
          if section.info == "mergeable" then 
            log("mergeable")
            local x, y = section.path[#section.path-1], section.path[#section.path]
            for k= path_idx - 1, 1, -1 do              
              if abs(paths[i][k][1] - x) <= epsilon and abs(paths[i][k][2] - y) <= epsilon then                
                for m=#section.path -2, 1, -2 do                  
                  log("insert path " , k, m)	
                  table.insert(paths[i][k], 1, section.path[m])
                  table.insert(paths[i][k], 1, section.path[m-1])
                end                
                merged = true
                break
              end
            end
          end
          
          if not merged then
            paths[i][path_idx] = section.path
            path_idx = path_idx + 1
          end
          
        end         
      end      
    end    
  end  
  --clearDuplicatePoints(paths)
  clearDuplicatePoints(paths)
  return paths
end

local function createTile(data, threshold, r, c)
  local tl = data[r  ][c  ]
  local tr = data[r  ][c+1]
  local br = data[r+1][c+1]
  local bl = data[r+1][c  ]
  
  local tile_id = 0  
  if tl < threshold then tile_id = tile_id + 8 end
  if tr < threshold then tile_id = tile_id + 4 end      
  if br < threshold then tile_id = tile_id + 2 end
  if bl < threshold then tile_id = tile_id + 1 end
  
  if tile_id ~= 0 and tile_id ~= 15 then --store no Trivial  
    local flipped = nil 
    if tile_id == 5 or tile_id == 10 then
      local avg = (tl + tr + br + bl) / 4
      if avg > threshold then flipped = true end
    end
        
    local left, top, right, bottom = hts, hts, hts, hts    
    if interpolate then -- linear interpolation        
      if tile_id ==  1 then      
        left   = ((threshold - tl) / (bl - tl))
        bottom = ((threshold - bl) / (br - bl))
      elseif tile_id ==  2 then
        bottom = ((threshold - bl) / (br - bl))      
        right = ((threshold - tr) / (br - tr))
      elseif tile_id ==  3 then      
        left   = ((threshold - tl) / (bl - tl))      
        right = ((threshold - tr) / (br - tr))
      elseif tile_id ==  4 then
        top   = ((threshold - tl) / (tr - tl))      
        right = ((threshold - tr) / (br - tr))
      elseif tile_id ==  5 then      
        left   = ((threshold - tl) / (bl - tl))
        bottom = ((threshold - bl) / (br - bl))
        top    = ((threshold - tl) / (tr - tl))      
        right = ((threshold - tr) / (br - tr))
      elseif tile_id ==  6 then
        bottom = ((threshold - bl) / (br - bl))
        top    = ((threshold - tl) / (tr - tl))
      elseif tile_id ==  7 then      
        left   = ((threshold - tl) / (bl - tl))
        top    = ((threshold - tl) / (tr - tl))
      elseif tile_id ==  8 then      
        left   = ((threshold - tl) / (bl - tl))
        top    = ((threshold - tl) / (tr - tl))                
      elseif tile_id ==  9 then
        bottom = ((threshold - bl) / (br - bl))
        top    = ((threshold - tl) / (tr - tl))
      elseif tile_id == 10 then      
        left   = ((threshold - tl) / (bl - tl))
        bottom = ((threshold - bl) / (br - bl))
        top    = ((threshold - tl) / (tr - tl))      
        right = ((threshold - tr) / (br - tr))
      elseif tile_id == 11 then
        top    = ((threshold - tl) / (tr - tl))      
        right = ((threshold - tr) / (br - tr))
      elseif tile_id == 12 then      
        left   = ((threshold - tl) / (bl - tl))      
        right = ((threshold - tr) / (br - tr))
      elseif tile_id == 13 then
        bottom = ((threshold - bl) / (br - bl))      
        right = ((threshold - tr) / (br - tr))
      elseif tile_id == 14 then            
        left   = ((threshold - tl) / (bl - tl))
        bottom = ((threshold - bl) / (br - bl))
      end
    end
    return {tile_id= tile_id, _id= tile_id, flipped= flipped, left=left, top=top, right=right, bottom=bottom}
  end
end

local function buildBitMask(data, levels)
  local rows= #data - 1
  local cols= #data[1] - 1
  local length = #levels    
  local layers = {}
  
  for i=1, length do --   Create layer    
    layers[i] = {}
    local threshold = levels[i]
    for r=1, rows do --   Create layer > row      
      layers[i][r] = {}
      for c=1, cols do
        local tile = createTile(data, threshold, r, c)        
        layers[i][r][c] = tile
      end
    end
  end  
  return {levels= levels, length= length, layers= layers, rows= rows, cols= cols}
end

local MarchingSquares = {
  setVerbose = function(value) verbose = value end,  
  setInterpolate = function(value) interpolate = value end,    
  
  getContour= function(data, levels) return tracePaths(buildBitMask(data, levels)) end,
  
  buildBitMask= buildBitMask,
  tracePaths= tracePaths,
}

return MarchingSquares