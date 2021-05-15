function love.load()
	canvas = love.graphics.newCanvas(600, 600)
 
	-- Rectangle is drawn to the canvas with the regular alpha blend mode.
	love.graphics.setCanvas(canvas)
		love.graphics.clear()
		love.graphics.setBlendMode("alpha")
		love.graphics.setColor(0, 0.5, 0, 0.5)
--		love.graphics.rectangle('fill', 0, 0, 100, 100)
		love.graphics.circle('fill', 300, 300, 300)
	love.graphics.setCanvas()
	
	
end


 
function love.draw()
	-- very important!: reset color before drawing to canvas to have colors properly displayed
	-- see discussion here: https://love2d.org/forums/viewtopic.php?f=4&p=211418#p211418
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.points(300, 300)
	-- The rectangle from the Canvas was already alpha blended.
	-- Use the premultiplied alpha blend mode when drawing the Canvas itself to prevent improper blending.
--	love.graphics.setBlendMode("alpha", "premultiplied")
--	love.graphics.draw(canvas)
	-- Observe the difference if the Canvas is drawn with the regular alpha blend mode instead.
	love.graphics.setBlendMode("alpha")
	love.graphics.draw(canvas, 200, 0)
 
	-- Rectangle is drawn directly to the screen with the regular alpha blend mode.
--	love.graphics.setBlendMode("alpha")
--	love.graphics.setColor(1, 0, 0, 0.5)
--	love.graphics.rectangle('fill', 200, 0, 100, 100)
end