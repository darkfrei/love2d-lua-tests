local pi = math.pi
local mp = 400 -- middle point

function love.load()
	love.window.setMode( 2*mp, 2*mp)
	canvas = love.graphics.newCanvas(2*mp, 2*mp)
	love.graphics.setCanvas(canvas)
		love.graphics.clear()
		love.graphics.setBlendMode("alpha")
--		love.graphics.setBlendMode("add")
	love.graphics.setCanvas()
	
	m = {x=mp, y=mp}
	a = {r=mp/4,	a= 0,	omega= 23, x=0, y=0, x1=0, x2=0}
	b = {r=mp/3,	a= 0,	omega= 13, x=nil, y=0, x1=0, x2=0}
	c = {r=mp/7,	a= 0,	omega= 1.001, x=nil, y=0, x1=0, x2=0}
	d = {r=3,	a= 0,	omega= 1200, x=nil, y=0, x1=0, x2=0}
	
end
 
 
function love.update(dt)
	dt = 1/10000
	love.graphics.setCanvas(canvas)
	love.graphics.setColor(1, 1, 1, 0.1)
	for i = 1, 10000 do
		a.x1 = a.x
		a.y1 = a.y
		b.x1 = b.x
		b.y1 = b.y
		c.x1 = c.x
		c.y1 = c.y
		d.x1 = d.x
		d.y1 = d.y
		a.a = a.a + dt*a.omega
		b.a = b.a + dt*b.omega
		c.a = c.a + dt*c.omega
		d.a = d.a + dt*d.omega
		a.x = m.x + a.r*math.cos(a.a)
		a.y = m.y + a.r*math.sin(a.a)
		b.x = a.x + b.r*math.cos(b.a)
		b.y = a.y + b.r*math.sin(b.a)
		c.x = b.x + c.r*math.cos(c.a)
		c.y = b.y + c.r*math.sin(c.a)
		d.x = c.x + d.r*math.cos(d.a)
		d.y = c.y + d.r*math.sin(d.a)
		
		

		if c.x1 then 
			if false then -- draw points
	--		love.graphics.setColor(0, 1, 0, 0.8)
	--		love.graphics.points(a.x, a.y)
				love.graphics.setColor(1, 1, 1, 0.1)
				love.graphics.points(d.x, d.y)
			else -- draw lines
				love.graphics.setColor(
					math.abs(math.cos(a.a)+math.abs(math.cos(b.a))), 
					math.abs(math.sin(b.a)), 
					math.cos(c.a)+math.sin(a.a), 0.1)
				love.graphics.line(d.x1, d.y1, d.x, d.y)
--				love.graphics.line(c.x1, c.y1, c.x, c.y)
--				love.graphics.line(b.x1, b.y1, c.x, c.y)
			end
		end
	end
	
	love.graphics.setCanvas()
end
 
 
function love.draw()
	love.graphics.setColor(0, 1, 0, 1)
	love.graphics.line(m.x, m.y, a.x, a.y)
	love.graphics.setColor(1, 1, 0, 1)
	love.graphics.line(a.x, a.y, b.x, b.y)
	love.graphics.setColor(0, 1, 1, 1)
	love.graphics.line(b.x, b.y, c.x, c.y)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.line(c.x, c.y, d.x, d.y)
	
	love.graphics.draw(canvas, 0, 0)
end

