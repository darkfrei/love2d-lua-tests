-- License CC0 (Creative Commons license) (c) darkfrei, 2021

tau = 2 * math.pi

com = {}
com.new = function  (re, im)
	return {re=re or 0, im=im or 0}
end

com.summ = function  (a, b, negative)
	return negative and {re=a.re-b.re, im=a.im-b.im} or {re=a.re+b.re, im=a.im+b.im}
end

com.mul = function  (a, b)
	return {re=a.re*b.re-a.im*b.im, im=a.re*b.im+a.im*b.re}
end

function dft (x) -- array of signals
--	Discrete Fourier Transform
	local X = {} -- Fourier
	local N = #x
	for k = 1, N do
		local re, im = 0, 0
		for n = 1, N do
			local phi = (2*math.pi*k*(n-1))/N
			re = re + x[n] * math.cos(phi)
			im = im - x[n] * math.sin(phi)
		end
		re = re / N
		im = im / N
		local freq = k-1
		local amp = math.sqrt(re*re+im*im)
		local phase = math.atan2(im, re)
		X[k] = {re=re, im=im, freq=freq, amp=amp, phase=phase}
	end
	

	return X
end

function love.load()
	local ddwidth, ddheight = love.window.getDesktopDimensions( display )
	if ddheight > 1080 then
		print('ddheight: ' .. ddheight)
		love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	else
		love.window.setMode(ddwidth, ddheight-200, {resizable=true, borderless=false})
	end
	width, height = love.graphics.getDimensions()
	
	
--	y = {} -- y is a signal
--	y = {100,100,100,-100,-100,-100,100,100,100,-100,-100,-100,100,100,100,-100,-100,-100,100,100,100,-100,-100,-100,100,100,100,-100,-100,-100,100,100,100,-100,-100,-100,}
	y={}
	for i = 1, 20 do
		y[#y+1]=math.random(-100,100)
	end
	
	fourierY = dft(y) -- Discrete Fourier Transform of y
	time = 0
	wave = {}
	
--	for i, com in pairs (fourierY) do
--		local str = ''
--		for j, value in pairs (com) do
--			str = str .. '\n'..j..': '..value
--		end
--		print (i..': '..str)
--	end

	way_canvas = love.graphics.newCanvas(width, height)
end


 
function love.update(dt)
	time=time+dt/10
end

function draw_wave(x, y)
	table.insert(wave, 1, y)
	if #wave > 1200 then
		table.remove(wave, #wave)
	end
	
--	table.insert(wave, 1, x)
	local x2 = 200
	love.graphics.line(x, y, x2, y)
	
	if #wave > 2 then
		for i = 1, #wave-1  do
			love.graphics.line(i+x2, wave[i], i+x2+1, wave[i+1])
		end
	end
end


function love.draw()
	love.graphics.translate(400,400)
	love.graphics.setColor(1,1,1)
	local x, y = 0, 0
--	for i = 1, #fourierY do
	for i, comp in pairs (fourierY) do
		local prevx = x
		local prevy = y
		
		local freq = comp.freq
		local radius = comp.amp
		local phase = comp.phase
		
		
		x = x + radius * math.cos(freq*time + phase)
		y = y + radius * math.sin(freq*time + phase)
		
		
		love.graphics.circle('line', prevx, prevy, radius)
		
		love.graphics.line(prevx, prevy, x, y)
	end
	draw_wave(x, y)
	
	
	love.graphics.setCanvas( way_canvas )
		love.graphics.points (x, y)
	love.graphics.setCanvas()
	love.graphics.translate(-400,-400)
	love.graphics.setColor(1,1,0)
	love.graphics.draw(way_canvas)
	
	
end

function love.keypressed(key, scancode, isrepeat)
	if key == "escape" then
		love.event.quit()
	end
end