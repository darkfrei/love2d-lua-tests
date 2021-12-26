-- License CC0 (Creative Commons license) (c) darkfrei, 2021




local svg2lua = require ('svg2lua')

local ds = {
	"M40,360H-40", -- line
	"M -40,480 H 40", -- line
	"M 840,1000 V 920",
	"M 720,920 V 1000",
	"M 1280,-40 1200,40",
	"M 1320,40 1400,-40",
	"M 40,480 H 360",
	"M 760,360 400,360",
	"M 1120,240 1320,40",
	"M 400,360 40,360",
	
	"M 840,920 C 840,680 1040,320 1120,240",
	"M 1200,40 C 1160,80 1120,120 1080,160",
	"M 1080,160 C 920,320 520,360 400,360",
	"M 360,480 C 520,480 720,760 720,920",
	"M 760,360 C 640,360 560,520 640,600",
	"M 640,600 C 720,680 840,640 880,560",
	"M 880,560 C 920,480 880,360 760,360",
	"M 1080,160 C 1040,200 920,360 760,360",
	"M 360,480 C 480,480 560,520 640,600",
	"M 640,600 C 720,680 720,840 720,920",
	"M 840,920 C 840,800 840,640 880,560",
	"M 880,560 C 920,480 1120,240 1120,240",
	
	"M 0,600 H 360 L 600,840 V 960 H 0 F 0",
	"M 1440,0 H 1920 V 960 H 960 V 720 F 0",
	"M 0,0 H 1080 L 840,240 H 0 F 0"
}

local luapaths = {}

for i, d in ipairs (ds) do
	local luapath = svg2lua(d)
	table.insert (luapaths, luapath)
end


function love.load()
	love.window.setMode(1920, 1080, {resizable=true, borderless=false})
end

 
function love.update(dt)
	
end


function love.draw()
	for i, vertices in ipairs (luapaths) do
		love.graphics.setLineWidth (40)
		if #vertices > 2 then
			if vertices.bezier then
				if not vertices.curve then
					local curve = love.math.newBezierCurve(vertices)
					vertices.curve = curve:render()
				end
				love.graphics.line (vertices.curve)
			elseif vertices.fill then
				love.graphics.setLineWidth (1)
				love.graphics.polygon('fill', vertices)
			else
				love.graphics.line (vertices)
			end
		end
	end
	
	local mx, my = love.mouse.getPosition()
	love.graphics.print (mx..' '..my)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end

function love.mousepressed( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end

function love.mousemoved( x, y, dx, dy, istouch )
end

function love.mousereleased( x, y, button, istouch, presses )
	if button == 1 then -- left mouse button
	elseif button == 2 then -- right mouse button
	end
end