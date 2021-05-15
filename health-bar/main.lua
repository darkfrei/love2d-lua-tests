
function love.load()
	global = {}
	global.player = {}
	global.player.max_health = 100
	global.player.health = 100
end
 
 
function love.update(dt)
	local damage = 10*dt*(-math.random()*1)
	local new_health = math.min(global.player.health+damage, global.player.max_health)
--	new_health = math.max(0, new_health)
	new_health = (new_health > 0) and new_health or global.player.max_health -- restore health on death
	global.player.health = new_health
end
 
 

function love.draw()
	local sx,sy = 32,32
	
	local c = global.player.health/global.player.max_health
	local color = {2-2*c,2*c,0} -- red by 0 and green by 1
	love.graphics.setColor(color)
	love.graphics.print('Health: ' .. math.floor(global.player.health),sx,sy)
	love.graphics.rectangle('fill',sx,1.5*sy,global.player.health,sy/2)
	
	love.graphics.setColor(1,1,1)
	love.graphics.rectangle('line',sx,1.5*sy,global.player.max_health,sy/2)
end
