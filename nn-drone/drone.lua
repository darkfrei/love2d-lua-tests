drone = {}

function drone.new (wb, gen)
	gen = gen or 1
	local c = {x=love.graphics.getWidth()/2, y=love.graphics.getHeight()/2}
	local color = {0.3+0.7*math.random(),0.3+0.7*math.random(),0.3+0.7*math.random()}
	return {x=c.x, y=c.y, vx=0, vy=0, points = 0, score = 100, wb=wb, color=color, alive =true,
		ax=0, ay=0, sv=0, sa=0, gen=gen, a=0}
end

function compare(a,b)
  return a.score > b.score
end

function drone.sort (dr)
	table.sort(dr, compare)
end

function drone.remove (drones, index)
	drones[index] = drones[#drones]
	drones[#drones] = nil
end



function drone.is_in_range (dr)
	local max_x, max_y = love.graphics.getWidth(), love.graphics.getHeight()
	local b = 0
	if (dr.x < b) or dr.x > (max_x - b) then
		return false
	end
	if (dr.y < b) or dr.y > (max_y - b) then
		return false
	end
	return true
end








return drone