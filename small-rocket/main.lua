-- License CC0 (Creative Commons license) (c) darkfrei, 2022

function love.load()
	local image = love.graphics.newImage ('rocket.png')
	Rocket ={x=200,y=200,angle=0,image=image,ox=image:getWidth()/2,oy=image:getHeight()/2}
end
function love.update(dt)
	local mx, my = love.mouse.getPosition()
	local dx, dy = mx-Rocket.x, my-Rocket.y
	Rocket.angle = math.atan2 (dy, dx)
	Rocket.x = Rocket.x + dt*dx
	Rocket.y = Rocket.y + dt*dy
end
function love.draw()
	love.graphics.draw (Rocket.image, Rocket.x, Rocket.y, Rocket.angle, 1, 1, Rocket.ox, Rocket.oy)
end
