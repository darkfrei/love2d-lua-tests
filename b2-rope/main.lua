-- main.lua
-- [b2-rope](https://github.com/darkfrei/love2d-lua-tests/tree/main/b2-rope)

local b2Rope = require ('b2Rope')

-- [b2RopeDef Struct Reference](https://box2d.org/documentation/structb2_rope_def.html)
local position = {x=400, y=100}
local masses = {0} -- fixed
local vertices = {0, 0}
local angle = 0
for i = 2, 10 do
	local length = math.random (30, 50)
	local x = vertices[#vertices-1]
	local y = vertices[#vertices]
	x = x + length*math.cos (angle)
	y = y + length*math.sin (angle)
	table.insert (vertices, x)
	table.insert (vertices, y)
	angle = angle + (math.random()-0.5)
	local mass = math.random (4, 8)
	table.insert (masses, mass)
end

local gravity = {x=0, y=9.81*10}

local tuning = {
	stretchingModel = "pbd",
	
	damping = 0.2,
	
	stretchStiffness = 0.85,
	stretchDamping = 0.5,
	stretchHertz = 1,
	
	
--	bendingModel = "springAngle",
--	bendingModel = "pbdAngle",
	bendingModel = "xpbdAngle",
	bendStiffness = 0.1,
	bendHertz = 1,
	bendDamping = 0.2,
	
	isometric = false, 
	fixedEffectiveMass = true,
--	warmStart = true,
}



function love.load ()
	local def = {
		position = position,
		vertices = vertices,
		masses = masses,
		gravity = gravity,
		tuning = tuning,
		-- no count here, use (#vertices/2)
	}
	
	Rope = b2Rope:new (def)
end

function love.update (dt)
	Rope:update (dt)
end

function love.draw ()
--	love.graphics.setColor (1,1,1)
--	love.graphics.push()
--	love.graphics.translate (position.x, position.y)
--	love.graphics.line (vertices)
--	for i = 1, #vertices-1, 2 do
--		local iMass = (i-1)/2+1
--		local mass = masses[iMass]
--		if mass > 0 then
--			love.graphics.circle ('line', vertices[i], vertices[i+1], mass)
--		else
--			love.graphics.circle ('fill', vertices[i], vertices[i+1], 4)
--		end
--	end
	
--	love.graphics.pop()

	Rope:draw(4)
	
	love.graphics.setColor (1,1,1)
--	love.graphics.print (string.format("FPS %.6f", love.timer.getFPS( )), 0, 0)
	love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 10, 0)
	love.graphics.print (Rope.vertices[1] .. ' ' .. Rope.vertices[2], 0, 14)
	love.graphics.print (string.format("%.2f %.2f", Rope.vertices[3], Rope.vertices[4]), 0, 28)
	
end

function love.mousepressed (x, y)
	Rope:update (0.01, x, y)
end