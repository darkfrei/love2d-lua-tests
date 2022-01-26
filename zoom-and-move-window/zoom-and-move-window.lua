-- scale and move the window
-- License CC0 (Creative Commons license) (c) darkfrei, 2022


local Screen = {}


function Screen:load()
	self.x, self.y, self.w, self.h = love.window.getSafeArea()
	self.translate={x=0, y=0}
	self.scale=1
	self.dscale = 2^(1/6)
	self.mouse_pressed = false
	-- for touchscreen
	self.touches = {}
end

function Screen:draw()
	love.graphics.setColor(0,1,0)
	love.graphics.setLineWidth(2)
	love.graphics.rectangle('line', self.x, self.y, self.w, self.h)
	love.graphics.translate(math.floor(self.translate.x+0.5), math.floor(self.translate.y))
	love.graphics.scale(self.scale)
end


function Screen:mousepressed (x, y, button, istouch, presses)
	if not istouch then
		if button == 1 then
			self.mouse_pressed = true
		elseif button == 3 then
			-- middle mouse button: reset translate and scale
			self.translate.x = 0
			self.translate.y = 0
			self.scale = 1
		end
	end
end

function Screen:mousemoved (x, y, dx, dy, istouch)
	if self.mouse_pressed then
		self.translate.x = self.translate.x + dx
		self.translate.y = self.translate.y + dy
	end
end

function Screen:mousereleased (x, y, button)
	if button == 1 then
		self.mouse_pressed = false
	end
end

function Screen:wheelmoved(x, y)
	local mx = love.mouse.getX()
	local my = love.mouse.getY()
    if not (y == 0) then -- mouse wheel moved up or down
--		scale in to point or scale out of point
		local mouse_x = mx - self.translate.x
		local mouse_y = my - self.translate.y
		local dscale = self.dscale^y
		self.scale = self.scale*dscale
		self.translate.x = math.floor(self.translate.x + mouse_x*(1-dscale)+0.5)
		self.translate.y = math.floor(self.translate.y + mouse_y*(1-dscale)+0.5)
    end
end

-- multitouch touch screen
-- touch screen

-- https://love2d.org/wiki/love.touchpressed
function Screen:touchpressed (id, x, y, dx, dy, pressure)
	local newTouch = {id=id, x=x, y=y, dx=0, dy=0}
	table.insert (self.touches, newTouch)
end

-- https://love2d.org/wiki/love.touchmoved
function Screen:touchmoved (id, x, y, dx, dy, pressure)
	local dpiScale = love.window.getDPIScale( ) -- 1.875
	if #self.touches == 1 then
		-- translate
		self.translate.x = self.translate.x + dx
		self.translate.y = self.translate.y + dy
		self.touches[1].x = x
		self.touches[1].y = y
	elseif #self.touches == 2 then
		self.translate.x = self.translate.x + dx/2
		self.translate.y = self.translate.y + dy/2
		if self.touches[1].id == id then
			self.touches[1].x = x
			self.touches[1].y = y
		else
			self.touches[2].x = x
			self.touches[2].y = y
		end
		local x1, y1 = self.touches[1].x, self.touches[1].y
		local x2, y2 = self.touches[2].x, self.touches[2].y
		x, y=(x1+x2)/2, (y1+y2)/2
		local dx, dy = x2-x1, y2-y1
		
		local dscale = (dx2*dx2+dy2*dy2)^0.5/(dx1*dx1+dy1*dy1)^0.5
		self.scale = self.scale*dscale
		self.translate.x = math.floor(self.translate.x + x*(1-dscale)+0.5)
		self.translate.y = math.floor(self.translate.y + y*(1-dscale)+0.5)
	end
end

-- https://love2d.org/wiki/love.touchreleased
function Screen:touchreleased (id, x, y, dx, dy, pressure)
	for i, touch in ipairs (self.touches) do
		if touch.id == id then
			table.remove (self.touches, i)
		end
	end
end

return Screen