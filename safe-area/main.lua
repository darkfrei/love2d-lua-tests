-- License CC0 (Creative Commons license) (c) darkfrei, 2023

-- outside of love.load
love.window.setMode(240, 320) -- QVGA, but vertical
love.window.setMode(240, 320) -- double it!
safeX, safeY, safeW, safeH = love.window.getSafeArea( )
function love.load()
	
end

function love.draw()
	love.graphics.translate(safeX, safeY) -- or minus, not tested
	love.graphics.rectangle("line", 0, 0, safeW, safeH)
	love.graphics.line(0, 0, safeW, safeH)
	love.graphics.line(0, safeH, safeW, 0)
	love.graphics.circle ('line', safeW/2, safeH/2, safeW/2)
	love.graphics.circle ('line', safeW/2, safeH/2, safeH/2)
end
