serialize = require("lib/ser")


function get_area (data)
	local s = data.s or 0
	local sw = data.sw and s + data.sw or 2*s
	local sh = data.sh and s + data.sh or 2*s
	local area = {}
	area.active=true
	area.x=data.x and data.x+s or s
	area.y=data.y and data.y+s or s
	area.width =data.w and data.w-sw or love.graphics.getWidth()-sw-area.x
	area.height=data.h and data.h-sh or love.graphics.getHeight()-sh-area.y
	area.rx=data.rx and data.rx-s or 10-s
	area.ry=data.ry or area.rx
	area.sy=data.sy
	return area
end

function draw_area (area, bool, progress)
	if not area then return end
	local rx=area.rx or 5
	local ry=area.ry or rx
	if bool or (progress and progress>0) then
		love.graphics.setColor({.2,.2,.2})
	else
		progress = 1
		love.graphics.setColor({.1,.1,.1})
	end
--	progress = progress or 1
	local w = area.width*progress > 4 and area.width*progress or 4
	love.graphics.rectangle("fill",area.x, area.y, w, area.height,rx, ry,area.segments)
	
	if is_position_inside_area({x=love.mouse.getX(),y=love.mouse.getY()}, area) then
		love.graphics.setColor({1,1,1})
	else
		love.graphics.setColor({.5,.5,.5})
	end
	love.graphics.rectangle("line",area.x, area.y, area.width, area.height,rx, ry,area.segments)
end




function get_gui_line (time, y)
	return { -- line
			area = get_area{x=10, y=y, h=40, sw=10},
			button =
				{
					area=get_area{x=10, y=y, h=40, w=200, s=2},
					text="timer "..time.." s",
					default_text="timer "..time.." s",
					progress = 0
				},
			result = 
				{
					area=get_area{x=210, y=y, h=40, sw=10, s=2},
					text=0,
				},
			start = 0,
			enabled = false,
			timer = time -- seconds
		}
end


function love.load(bool)
	
	gw,gh=love.graphics.getWidth(),love.graphics.getHeight()
--	if bool then
--		love.window.setMode( 360, 640, {resizable=true} )
		love.window.setMode( gh, gw, {resizable=false} )
--	end
--	gw,gh=love.graphics.getWidth(),love.graphics.getHeight()
	
	GUI={}
	GUI.font14=love.graphics.newFont(14)
	
	timers = {}
	
	
	GUI.lines = 
	{
		get_gui_line (10, 50),
		get_gui_line (30, 100),
		get_gui_line (60, 150),
		get_gui_line (90, 200),
		get_gui_line (120, 250),
		get_gui_line (150, 300),
		get_gui_line (60*60, 350),
		get_gui_line (24*60*60, 400),
		
	}
	
	
end
 
 
function love.update(dt)

end


function draw_text(font, area, text)
	local w = font:getWidth(text)
	local h = font:getHeight()
	
	local x1 = (2*area.x+area.width)/2
	local y1 = (2*area.y+area.height)/2
--	love.graphics.line(x1,area.y, x1, area.y+area.height)
--	love.graphics.line(area.x,y1, area.x+area.width, y1)
	love.graphics.print(text, x1-w/2, y1-h/2)
end

function love.draw()

	
	love.graphics.setColor({1,1,1})
	love.graphics.setFont(GUI.font14)
	
	
	for i, line in pairs (GUI.lines) do
		draw_area(line.area)
		if line.enabled then
			local time = line.timer - love.timer.getTime( ) + line.start
			
			if time > 0 then
--				line.button.text = math.floor (time) .. ' s'
--				line.button.text = math.ceil (time) .. ' s'
				local seconds = math.ceil (time)
				local minutes = math.floor (seconds/60)
				
				local hours = math.floor (minutes/60)
				minutes=minutes-60*hours
				seconds=seconds%60
				
				line.button.text = hours>0 and hours..' h '..minutes..' m '..seconds..' s'
				or minutes>0 and minutes..' m '..seconds..' s'
				or seconds..' s'
				line.button.progress = 1-time/line.timer
			else
				line.button.progress = 0
				line.result.text = line.result.text + 1
				line.enabled = false
				line.button.text = line.button.default_text
			end
		end
		
		draw_area(line.button.area, false, line.button.progress)
		if line.enabled then
			love.graphics.setColor({1,1,1})
		end
		draw_text(GUI.font14, line.button.area, line.button.text)
		draw_area(line.result.area)
		if line.enabled then
			love.graphics.setColor({1,1,1})
		end
		draw_text(GUI.font14, line.result.area, line.result.text)
	end
end




function is_position_inside_area(position, area)
	local x,y = position.x,position.y
	local x1, x2 = area.x, area.x+area.width
	local y1, y2 = area.y, area.y+area.height
--	return (x1<x)and(x<x2)and(y1<y)and(y<y2) and true or false
	return (x1<x)and(x<x2)and(y1<y)and(y<y2)
end

function savetable(GUI, name)
	love.filesystem.write(name..".lua", serialize(GUI))
	
end


function update_selected (position)
	for i, line in pairs (GUI.lines) do
		
		if is_position_inside_area(position, line.button.area) then
			savetable(GUI, "GUItable")
			if not line.enabled then
				line.start = love.timer.getTime( )
				line.enabled = true
			else
				
				line.enabled = false
				line.button.text = line.button.default_text
				line.button.progress = 0
			end
			
			return
		end
	end
	
end

function love.mousepressed(x, y, button, istouch)
	if button == 1 then
		update_selected ({x=x,y=y})
	end
end

--function love.wheelmoved( dx, dy )
--    GUI.scroll_y = math.min(GUI.scroll_y + dy*GUI.scroll_dy, 0)
--end


function love.resize(w, h)
	print(("Window resized to width: %d and height: %d."):format(w, h))
	love.load(false)
end