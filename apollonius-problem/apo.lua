

problems = {
	'ppp',
	'lpp',
	'llp',
	'cpp',
	'lll',
	'clp',
	'ccp',
	'cll',
	'ccl',
	'ccc',
}

problem = problems[1]

function distance(x1, y1, x2, y2)
	return math.sqrt((x2 - x1)^2 + (y2 - y1)^2)
end

function distanceDelta (dx, dy)
	return math.sqrt(dx*dx + dy*dy)
end


local function ppp (x1, y1, x2, y2, x3, y3)
	local d = 2 * (x1*(y2-y3)+x2*(y3-y1)+x3*(y1-y2))
	local t1, t2, t3 = x1*x1+y1*y1, x2*x2+y2*y2, x3*x3+y3*y3
	local x = (t1 * (y2 - y3) + t2 * (y3 - y1) + t3 * (y1 - y2)) / d
	local y = (t1 * (x3 - x2) + t2 * (x1 - x3) + t3 * (x2 - x1)) / d
	local radius = math.sqrt((x1-x)^2 + (y1-y)^2)
	return x, y, radius
end

print (ppp(0, 0, 0, 100, 300, 300)) -- 250, 50, ~255
print (ppp(0, 100, 250, 50, 300, 300)) -- 150, 200, ~180