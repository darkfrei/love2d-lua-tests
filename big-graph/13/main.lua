window = require ("zoom-and-move-window")
to_tsv = require ("tsv-to-lua")

local tables_list = to_tsv('graph.tsv')

function love.load()
	local width = love.graphics.getWidth()
	local height = love.graphics.getHeight()
	love.window.setMode( width, 600, {resizable=true})
	window:load(height)
	
	window.zoom = 0.00048828125
	window.zoom_x = 0.25
	window.translate.y = 300
	
	--	love.graphics.scale(0.5, 0.5)
	frame = {0, width}
	last_zoom = 1
	dpixel = 1
	
	line_thickness = 1.1
	love.graphics.setLineWidth( line_thickness +0.6 )
	
	sampling = 1
	
	lines = {}
	for n_tabl, tabl in pairs (tables_list) do
		local line = {}
		for i = 1, width, math.ceil(1/window.zoom) do
			
			line[#line+1]=i
			line[#line+1]=tables_list[i]
		end
		lines[#lines+1]=line
	end
end
 
 
function love.update(dt)
	window:update(dt)
	
	if not ((last_zoom == window.zoom)and(last_tx == window.translate.x)) then
		local width = love.graphics.getWidth()
		local x1 = math.floor(-window.translate.x/window.zoom_x)
		local x2 = math.ceil((width-window.translate.x)/window.zoom_x)
		frame = {x1, x2}
		for i, list in pairs (tables_list) do
			line = {}
			sampling = math.max(1, math.ceil(0.5/window.zoom_x))
			for i = x1, x2, sampling do
				if list[i] then
					local x = i
					local y = -list[i]
					x = x * window.zoom_x +window.translate.x
					y = y * window.zoom +window.translate.y
					line[#line+1]=x
					line[#line+1]=y
				end
			end
			lines[i]=line

		end
		last_zoom = window.zoom
		last_tx = window.translate.x
	end
end
 
 
function love.draw()
--	window:draw()
	
	for n_line, line in pairs (lines) do
		local color = tables_list[n_line].color or {1,1,1}
		love.graphics.setColor(color)
		if #line > 4 then
			if n_line == 1 then
				love.graphics.line(line)
			else
				for i = 1, #line-2, 2 do
					love.graphics.line(line[i], line[i+1], line[i+2], line[i+3])
				end
			end
		end
	end
	
	if true then -- debug enabled
	-- debug GUI
		local mx = love.mouse.getX()
		local my = love.mouse.getY()
		love.graphics.origin()
		love.graphics.setColor(0,1,0)
		love.graphics.print ('Debug GUI:', 1, 0)
		love.graphics.print('x: ' .. mx ..', y: '.. love.graphics.getHeight()-my, 1, 15) 
		love.graphics.print('tx: ' .. (mx-window.translate.x)/window.zoom_x ..
			', ty: '.. -(my-window.translate.y)/window.zoom, 1, 30) 
		
		love.graphics.print('zoom ' .. window.zoom .. ' zoom_x ' .. window.zoom_x, 1, 45) 
		love.graphics.print('tr ' .. window.translate.x ..', '.. window.translate.y, 1, 60) 
		love.graphics.print('dscale: ' .. window.dscale , 1, 75)
		love.graphics.print("Current FPS: "..tostring(love.timer.getFPS( )), 1, 90)
--		love.graphics.print("dpixel: "..tostring(dpixel), 1, 105)
		love.graphics.print("frame: "..tostring(frame[1])..' '..tostring(frame[2]), 1, 105)
		love.graphics.print("line_thickness: "..tostring(line_thickness), 1, 120)
		love.graphics.print("sampling: "..tostring(sampling), 1, 135)
	end
end


function love.mousepressed(x, y, k)
	window:mousepressed(x, y, k)
end

 
function love.wheelmoved(x, y)
	window:wheelmoved(x, y)
end

function love.keypressed( key, scancode, isrepeat )
	print (key)
	if (key == 'kp+') then
		line_thickness = line_thickness+0.1
		love.graphics.setLineWidth( line_thickness +0.6)

	elseif (key == 'kp-') then
		line_thickness= line_thickness-0.1
		love.graphics.setLineWidth( line_thickness +0.6 )

	end
end

