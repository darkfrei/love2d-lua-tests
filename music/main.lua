-- 2021-04-27 License CC0 (Creative Commons license) (c) darkfrei

function love.load()
	source = love.audio.newSource("Ye-Olde-Pub_Looping.mp3", "stream")
--	source:play()
	a = 0
end

 
function love.update(dt)
	if not source:isPlaying( ) then
		a = a+1
		love.audio.play( source )
	end

end


function love.draw()
	love.graphics.print('Music by Eric Matyas\nYe-Olde-Pub_Looping: ' .. a)
end

function love.keypressed(key, scancode, isrepeat)
   if key == "escape" then
      love.event.quit()
   end
end