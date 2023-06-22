local function removeDuplicateElements (list)
	local hash = {}
	local res = {}

	for _,v in ipairs(list) do
		if (not hash[v]) then
			res[#res+1] = v -- you could print here instead of saving to result table if you wanted
			hash[v] = true
		end

	end
	return res
end

local function createTpSet4Procedural()
	-- Define the surrounding vertices
	local size = 4
	local vertices = {}
	for i = 1, size do
		local t1 = i - 1
		vertices[i] = {t1, 0}
		vertices[i + size] = {size, t1}
		local t2 = size - i + 1
		vertices[i + size * 2] = {t2, size}
		vertices[i + size * 3] = {0, t2}
	end
	local sides = {{},{},{},{}}
	for i = 1, size+1 do
		table.insert (sides[1], i)
		table.insert (sides[2], i+size)
		table.insert (sides[3], i+2*size)
		table.insert (sides[4], i+3*size)
	end
	for iSide, side in ipairs (sides) do
		print ('side', iSide, table.concat(side, ', '))
	end

	local corners = {{},{},{},{}}
	for i = 1, 2*size+1 do
		table.insert (corners[1], i)
		table.insert (corners[2], i+size)
		table.insert (corners[3], i+2*size)
		table.insert (corners[4], i+3*size)
	end
	for iCorner, corner in ipairs (corners) do
		print ('corner', iCorner, table.concat(corner, ', '))
	end


	local edges = {1, size+1, 2*size+1, 3*size+1}
--	local fullPolygon = edges

	local polygons = {}
	local polygonHash  = {}

-- edges
	local amount = #vertices

	for iCorner = 1, 4 do
--	local iCorner = 1
		local v0 = edges[(iCorner+2)%4+1]
		print ('corner', iCorner, 'edge', v0)


		for i, v in ipairs (corners[iCorner])  do
			print ('vertex i', i, 'vertex v', v)

			local v0 = v0
			if iCorner == 1 then
				v0 = 1
			end

			local v1 = v0 + size
			local v2 = v0 + 2*size
			local v3 = v0 + 3*size
			print ('v1-v3', v1, v2, v3)

			local polygon = {}
			table.insert (polygon, v0)
			table.insert (polygon, (v-1)% amount + 1)


			if v > v1 then
				table.insert (polygon, (v1-1)% amount + 1)
				if v > v2 then
					table.insert (polygon, (v2-1)% amount + 1)
					if v > v3 then
						table.insert (polygon, (v3-1)% amount + 1)
					end
				end
			end

			table.sort (polygon)
			polygon = removeDuplicateElements (polygon)
			if #polygon > 2 then
				table.insert (polygons, polygon)
			end
		end
	end


	local tpSet4 = {
		side = size,
		vertices = vertices,
		polygons = polygons,
	}
	return tpSet4
end

-- Usage:
local tpSet4 = createTpSet4Procedural()

return tpSet4