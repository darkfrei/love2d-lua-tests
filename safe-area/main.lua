-- License CC0 (Creative Commons license) (c) darkfrei, 2022

function love.load()
	--love.window.setMode(1920, 1080, {resizable=true, borderless=false})
	love.window.setMode(240, 320) -- QVGA, but vertical
	love.window.setMode(240, 320) -- double it!
--	love.timer.sleep(1)
	safeX, safeY, safeW, safeH = love.window.getSafeArea( )
end

function love.draw()
	love.graphics.translate(safeX, safeY) -- or minus, not tested
	love.graphics.rectangle("line", 0, 0, safeW, safeH)
	love.graphics.line(0, 0, safeW, safeH)
	love.graphics.line(0, safeH, safeW, 0)
	love.graphics.circle ('line', safeW/2, safeH/2, safeW/2)
	love.graphics.circle ('line', safeW/2, safeH/2, safeH/2)
end
