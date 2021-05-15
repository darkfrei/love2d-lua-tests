-- darkfrei 2021-02-11

function get_value (map, position)
	local x = position[1] or position.x
	local y = position[2] or position.y
--	print ('get_value: x: '..x..' y: '..y)
	return map[x] and map[x][y] or 0
end

function get_udata (map, cx, cy)
	-- data: value in grid cells
	-- udata: value by grid verticles
	-- udata.e: value in the middle
	local chunk_size = 1
	local data = {}
	table.insert (data, get_value(map, {x=(cx-1)*chunk_size,y=(cy-1)*chunk_size}))
	table.insert (data, get_value(map, {x=(cx  )*chunk_size,y=(cy-1)*chunk_size}))
	table.insert (data, get_value(map, {x=(cx+1)*chunk_size,y=(cy-1)*chunk_size}))
	table.insert (data, get_value(map, {x=(cx-1)*chunk_size,y=(cy  )*chunk_size}))
	table.insert (data, get_value(map, {x=(cx  )*chunk_size,y=(cy  )*chunk_size}))
	table.insert (data, get_value(map, {x=(cx+1)*chunk_size,y=(cy  )*chunk_size}))
	table.insert (data, get_value(map, {x=(cx-1)*chunk_size,y=(cy+1)*chunk_size}))
	table.insert (data, get_value(map, {x=(cx  )*chunk_size,y=(cy+1)*chunk_size}))
	table.insert (data, get_value(map, {x=(cx+1)*chunk_size,y=(cy+1)*chunk_size}))
	local udata = {}
	udata.a = (data[1]+data[2]+data[4]+data[5])/4 -- top left
	udata.b = (data[2]+data[3]+data[5]+data[6])/4 -- top right
	udata.c = (data[5]+data[6]+data[8]+data[9])/4 -- bottom left
	udata.d = (data[4]+data[5]+data[7]+data[8])/4 -- bottom right
--	udata.e = (udata.a+udata.b+udata.c+udata.d)/4 -- middle
	udata.e = (udata.a+udata.b+udata.c+udata.d
		-math.min(udata.a,udata.b,udata.c,udata.d)
		-math.max(udata.a,udata.b,udata.c,udata.d)
			)/2 -- middle
	--print ('udata.a: '..udata.a..' udata.b: '..udata.b..' udata.c: '..udata.c..' udata.d: '..udata.d..' udata.e: '..udata.e)
	return udata
end

function get_point (p1,p2,u1,u2,u)
	if u1 == u2 then return end -- no gradient here
	if u > math.max(u1,u2) or u < math.min(u1,u2) then return end -- out of range
	local s = (u-u1)/(u2-u1)
	local dx = (p2.x-p1.x)
	local dy = (p2.y-p1.y)
	local x, y = p1.x+s*dx,p1.y+s*dy
--	print ('x: '..x..' y: '..y)
	return {x=x,y=y}
end


function get_mLines (map,levels)
	
	local triangles = {a={"a","b","e"},b={"b","c","e"},c={"c","d","e"},d={"d","a","e"}}
	local positions = {a={x=0,y=0},b={x=1,y=0},c={x=1,y=1},d={x=0,y=1},e={x=0.5,y=0.5}}
	local mLines = {} -- multiple short lines
	for cx, ys in pairs (map) do
		for cy, ys in pairs (ys) do
		
			local udata = get_udata (map, cx, cy)
			
			for i, u in pairs (levels) do
				mLines[u]= mLines[u] or {}
				local mu = mLines[u]
				for tr_letter, triangle in pairs (triangles) do
					
					local l1,l2,l3 = triangle[1],triangle[2],triangle[3] -- l - point letter
--					print ('l1: '..l1..' l2: '..l2..' l3: '..l3)
					local u1,u2,u3 = udata[l1],udata[l2],udata[l3] -- pollution value
--					print ('udata[l1]: '..udata[l1]..' udata[l2]: '..udata[l2]..' udata[l3]: '..udata[l3])
					local p1,p2,p3 = positions[l1],positions[l2],positions[l3] -- position
--					print(u1,u2,u)
					local point_a = get_point (p1,p2,u1,u2,u)
					local point_b = get_point (p2,p3,u2,u3,u)
					local point_c = get_point (p3,p1,u3,u1,u)
					local point_1 = point_a or point_b
					local point_2 = point_a and point_b or point_c
					
					if point_1 and point_2 then
						mu[#mu+1]={point_1, point_2, position={cx=cx,cy=cy}} -- short line
					else
						--print('no short line: u: '..u..' cx: '..cx..' cy: '..cy)
					end
				end
				--print ('mu '.. #mu)
			end
		end
	end
	return mLines
end

return get_mLines

