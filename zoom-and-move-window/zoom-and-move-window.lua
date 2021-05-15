local zam_window = {}


function zam_window:load()
	self.translate={x=0, y=0}
	self.delta={x=0, y=0}
	self.zoom=1
	self.dscale = 2^(1/6)
	self.mouse_pressed = false
end


function zam_window:update(dt)
	zam_window:update_translation ()
end


function zam_window:draw()
--	zam_window:update_translation ()

--	first translate than scale:
	love.graphics.translate(math.floor(self.translate.x+0.5), math.floor(self.translate.y))
	love.graphics.scale(self.zoom)
end


function zam_window:mousepressed(x, y, k)
	if k == 3 then
--		resets screen
		self.zoom = 1
		self.translate.x = 0
		self.translate.y = 0
	end
end

function zam_window:update_translation ()
	local mx = love.mouse.getX()
	local my = love.mouse.getY()
	if love.mouse.isDown(1) then
		if not window.mouse_pressed then -- click
			window.mouse_pressed = true
			window.delta.x = (window.translate.x-mx)/window.zoom
			window.delta.y = (window.translate.y-my)/window.zoom
		else
			window.translate.x = mx + window.delta.x*window.zoom
			window.translate.y = my + window.delta.y*window.zoom
		end
	else	-- left mouse not pressed
		if window.mouse_pressed then 
			window.mouse_pressed = false
		end
	end
end


function zam_window:wheelmoved(x, y)
	local mx = love.mouse.getX()
	local my = love.mouse.getY()
    if not (y == 0) then -- mouse wheel moved up or down
--		zoom in to point or zoom out of point
		local mouse_x = mx - self.translate.x
		local mouse_y = my - self.translate.y
		local k = self.dscale^y
		self.zoom = self.zoom*k
		self.translate.x = math.floor(self.translate.x + mouse_x*(1-k)+0.5)
		self.translate.y = math.floor(self.translate.y + mouse_y*(1-k)+0.5)
	else
		print ('wheel x: ' .. x .. ' y: ' .. y)
    end
end

return zam_window