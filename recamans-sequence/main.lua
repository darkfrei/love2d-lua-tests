-- License CC0 (Creative Commons license) (c) darkfrei, 2021

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions( )

	position = 0
	counter = 0
	max_position = width/100
	local x = counter/2+position
	
	sequence = {}
	table.insert(sequence, {x=x,d=counter, top=true})
	
	list = {}

	buffer = 1
	
	gtop = true
	
	temp = {x=position-counter/2,d=counter, top=gtop,t=0, tx=0}
end

 
function love.update(dt)
	if not buffer or buffer < 0 then
		buffer = buffer + 1
		temp = nil
	elseif pause then
		return
	else
--		local back = position-counter > 0 and not (list[position-counter])
		local back = position-(counter+1) > 0 and not (list[position-(counter+1)])
		temp={}
		temp.t = (1-buffer)/1
		temp.top = gtop
		if back then
--			if not (list[position-(counter+1)])
			temp.x = position-(counter+1)/2
			temp.back = true
			temp.tx = position-(counter+1)
		else
			temp.x = position+(counter+1)/2
			temp.back = false
			temp.tx = position+(counter+1)
			
			max_position = math.max (max_position, temp.x+(counter+1)*math.cos(math.pi*(1-temp.t)))
		end
		temp.d = counter+1
		
		buffer = buffer - dt
		return
	end
	
	counter=counter+1
	
	local x
	if position-counter > 0 and not (list[position-counter]) then
		-- step back
		x = position-counter/2
		position = position-counter
		
	elseif not (list[position+counter]) then
		
		position = position+counter
		if max_position < position then max_position = position end
		x = position-counter/2
	end
	list[position]=true
	print (position) -- 0 1 3 6 2
	
	if x then
		table.insert(sequence, {x=x,top=gtop,d=counter})
		gtop = not gtop
	end
end


function love.draw()
	love.graphics.print (position,0,0)
	
	love.graphics.print (#sequence,0,20)
	
--	love.graphics.translate(0,max_diameter)
	love.graphics.translate(0,height/2)
	
	
--	local scale = math.min(100, 1000*counter/height)
--	local scale = math.max(10, 0.001*height/counter)
	local scale = math.min(1000, 1*height/counter, 1*width/max_position)
	love.graphics.scale(scale)
	love.graphics.setLineWidth(1/10)

	
	love.graphics.setColor(1,1,1)
	for i = 1, max_position do
		love.graphics.circle('line', i, 0, 0.01)
	end
	
	
	for i, v in ipairs (sequence) do
		if v.top then
			love.graphics.arc('line', 'open',v.x,0, v.d/2, 0, -math.pi)
		else
			love.graphics.arc('line', 'open',v.x,0, v.d/2, math.pi, 0)
		end
	end
	if temp then
		if temp.back then
			love.graphics.setColor(1,0,0)
			local a = math.pi*(1-temp.t)
			if temp.top then
				love.graphics.arc('line', 'open',temp.x,0, temp.d/2, 0, a-math.pi)
			else
				love.graphics.arc('line', 'open',temp.x,0, temp.d/2, 0, math.pi-a)
			end
		else
			love.graphics.setColor(0,1,0)
			local a = math.pi*(temp.t-1)
			if temp.top then
				love.graphics.arc('line', 'open',temp.x,0, temp.d/2, a, -math.pi)
			else
				love.graphics.arc('line', 'open',temp.x,0, temp.d/2, math.pi, -a)
			end
		end
		
		love.graphics.circle('line', temp.tx, 0, 0.01)
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "space" then
		pause = not pause
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