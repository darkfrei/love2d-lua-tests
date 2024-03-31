-- math functions for voronoi beachlines


function getFocusParabolaRoots (fx, fy, y, dirY) -- focus, horizontal line
-- dirY is global
	local h = fx -- x shift
	local p = -(dirY-fy)/2 -- always negative for voronoi
	local k = fy - p -y
	local leftX = h - math.sqrt (-k*4*p)
	local rightX = h + math.sqrt (-k*4*p)
	return leftX, rightX
end



function getBezierControlPoint (fx, fy, ax, bx, dirY)
-- based on [code](https://stackoverflow.com/a/78216720/12968803)

--	https://www.desmos.com/calculator/ugcvzce4ox
	local f = function (x) return (x*x-2*fx*x+fx*fx+fy*fy-dirY*dirY) / (2*(fy-dirY)) end
	local function df(x) return (x-fx) / (fy-dirY) end
	if (fy == dirY) then return end -- not parabola
	local ay, by = f(ax), f(bx)
	local ad, dx = df(ax), (bx-ax)/2
	return ax+dx, ay+ad*dx
end

function evaluateParabola (fx, fy, x, dirY)
	local k = (fy+dirY)/2
	local p = -(dirY-fy)/2
	local y = (x-fx)^2 / (4*p) + k
	return y
end

function sortEventQueue(events)
	table.sort(events, function(a, b)
			return a.y < b.y or (a.y == b.y and a.x < b.x)
		end)
end

----------------------------------------------------------------

function printEventQueue (events, str)
	print ('event queue', str)
	for i, event in ipairs (events) do
		print (i, 'event', event.type, event.y, event.x)
	end
end

----------------------------------------------------------------

function getEventFromQueue (queue)
	local n = #queue
	if n >= 1 then
		sortEventQueue (eventQueue)
		return table.remove (queue, 1)
	end
end

