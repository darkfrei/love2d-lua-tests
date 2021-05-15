function get_area (data)
	local s = data.s or 0
	local sw = data.sw or s
	local sh = data.sh or s
	local area = {}
	area.active=true
	area.x=data.x and data.x+s or s
	area.y=data.y and data.y+s or s
	area.width =data.w and data.w-sw or love.graphics.getWidth()-sw-area.x
	area.height=data.h and data.h-sh or love.graphics.getHeight()-sh-area.y
	area.rx=data.rx or 5
	area.ry=data.ry or area.ry
	area.sy=data.sy
	return area
end

function draw_area (area, bool)
	if not area then return end
	local rx=area.rx or 5
	local ry=area.ry or rx
	if bool then
		love.graphics.setColor({.2,.2,.2})
	else
		love.graphics.setColor({.1,.1,.1})
	end
	love.graphics.rectangle("fill",area.x, area.y, area.width, area.height,rx, ry,area.segments)
	
	if is_position_inside_area({x=love.mouse.getX(),y=love.mouse.getY()}, area) then
		love.graphics.setColor({1,1,1})
	else
		love.graphics.setColor({.5,.5,.5})
	end
	love.graphics.rectangle("line",area.x, area.y, area.width, area.height,rx, ry,area.segments)
end

function love.load(bool)
	
	if bool then
		love.window.setMode( 640, 360, {resizable=true} )
	end
	gw,gh=love.graphics.getWidth(),love.graphics.getHeight()
	
	local font14 = love.graphics.newFont(14)
	
	local y0 = 0
	local s0 = 4
	local dy=font14:getHeight()+s0
	local ys = {
		y0+s0, -- first area
		y0+1*dy, -- tab button area
		y0+2*dy+2*s0, -- dark tab area A
		y0+4*dy, -- light tab area B
		y0+3*dy+2*s0, -- 
		y0+6*dy} -- scissor
	
	GUI = {}
	GUI.font14=font14
	GUI.description = "Global GUI Description"
	local dx_description = font14:getWidth(GUI.description)
	
	GUI.area = get_area{x=s0,y=ys[1],s=0,sw=s0, sh=s0} -- big GUI area
--	local dy_GUI = GUI.area.y+font14:getHeight()
	
	GUI.shift = {x=math.floor((gw-dx_description)/2), y=ys[1]}
	
	GUI.h_tabs = {}
	GUI.h_tab_active = 1
	GUI.scroll_area = get_area{x=155,y=ys[4], sw=s0*3, sh=s0*3, true} -- light tab area B
	GUI.scroll_y = 0
	GUI.scroll_dy = 4*s0+dy
	
	GUI.area_selected = {}
	GUI.scissor_area = get_area{x=GUI.scroll_area.x, y=ys[6], sw=3*s0,sh=4*s0}
	
	for i=1,6 do
		local i_dx = 100
		local h_tab = {}
		table.insert(GUI.h_tabs, h_tab)
		
		local hx = 2*s0+(i-1)*i_dx
		local hy = 2*dy
		
		h_tab.area = get_area{x=hx,y=ys[2], w=i_dx, h=hy, sw=s0}
		h_tab.name = "Tab A"..i
		h_tab.shift = {x=hx+1*s0, y=ys[2]+2*s0}
		
		-- description
		h_tab.tab_area = get_area{x=2*s0,y=ys[3], s=0,sw=2*s0, sh=2*s0}
		h_tab.description = "Tab A"..i..' Description'
		local xh_description = math.floor((gw-font14:getWidth(h_tab.description))/2)
		h_tab.shift2 = {x=xh_description, y=ys[3]+s0}
		
		h_tab.v_tabs = {}
		h_tab.v_tab_active = 1
		
		for j=1,7 do
			local j_dy = 4*s0+dy
			local v_tab = {}
			table.insert(h_tab.v_tabs, v_tab)
			
			local vx = 3*s0
			local vy = ys[4]+(j-1)*j_dy
			v_tab.area = get_area{x=vx,y=vy, w=150, h=j_dy, sh=2*s0}
			v_tab.name = "Tab B"..j..' (A'..i..')'
			v_tab.shift = {x=vx+s0, y=vy+s0*2}
			
			v_tab.description = "Tab B"..j..' (A'..i..')'.. ' Description'
			local xh_description = math.floor((gw-font14:getWidth(v_tab.description)+(v_tab.area.x+v_tab.area.width))/2)
			v_tab.shift2 = {x=xh_description, y=ys[4]+s0}
			
			v_tab.bottonlines = {}
			
--			local sax, say = GUI.scroll_area.x,GUI.scroll_area.y
			local sax, say = GUI.scissor_area.x,GUI.scissor_area.y
			
			

			for k = 1, 16 do
				local bottonline = {}
				table.insert (v_tab.bottonlines, bottonline)
				
				local bh=2*s0+dy
--				local by=ys[5]+(k-1)*GUI.scroll_dy
				local by=say-3*s0+(k-1)*GUI.scroll_dy
				
				
				bottonline.area = get_area{x=sax+s0,y=by, w=230, h=bh}
				bottonline.name = 'Name'
				bottonline.shift = {x=bottonline.area.x+2*s0, y=by+4*s0, sy=2*s0}
				
				bottonline.value = k
				bottonline.buttons=
				{
					{name='Add',    x=400+2*s0, area={x=400,y=0, width=50, height=bh, sh=2*s0}},
					{name='Remove', x=460+2*s0, area={x=460,y=0, width=80, height=bh, sh=2*s0}}
				}
			end
		end
	end
end
 
 
function love.update(dt)

end

function is_position_inside_area(position, area)
	local x,y = position.x,position.y
	local x1, x2 = area.x, area.x+area.width
	local y1, y2 = area.y, area.y+area.height
--	return (x1<x)and(x<x2)and(y1<y)and(y<y2) and true or false
	return (x1<x)and(x<x2)and(y1<y)and(y<y2)
end



function translate ()
	local mx = love.mouse.getX()
	local my = love.mouse.getY()
	if is_position_inside_area({x=mx, y=my}, GUI.scissor_area) then
		if love.mouse.isDown(1) then
			if not mouse_pressed then
				mouse_pressed = true
	--			dx = tx-mx
				dy = GUI.scroll_y-my
			else
	--			tx = mx+dx
				GUI.scroll_y = my+dy
			end
		elseif mouse_pressed then
			mouse_pressed = false
		end
	--	love.graphics.translate(tx, ty)
		GUI.scroll_y = math.min (GUI.scroll_y, 0)
--		GUI.scroll_y = math.max (GUI.scroll_y, -495)
	end
--	love.graphics.setFont(GUI.font8)
--	love.graphics.print('scroll_y:'..GUI.scroll_y.. ("Window size width: %d and height: %d."):format(gw, gh),
--		32,32)
end
 
function love.draw()
--	love.graphics.setFont(GUI.font14)
	translate ()
	
	
	
	draw_area (GUI.area)
	love.graphics.setColor({1,1,1})
	love.graphics.setFont(GUI.font14)
	love.graphics.print(GUI.description, GUI.shift.x, GUI.shift.y)
	
	
	
--	love.graphics.setFont(GUI.font24)
	
--	local active_h_tab = 0
	
	
	for i, h_tab in pairs (GUI.h_tabs) do
--		love.graphics.setFont(GUI.font24)
		
		
		if i == GUI.h_tab_active then -- active
			active_h_tab = i
			
			
		else
			draw_area (h_tab.area, false)
			love.graphics.setColor({0.5,0.5,0.5})
			love.graphics.print(h_tab.name, h_tab.shift.x, h_tab.shift.y)
		end
	end
	
	-- draw active
	local h_tab = GUI.h_tabs[active_h_tab]
	
	draw_area (h_tab.area, true)
	draw_area (h_tab.tab_area, false)
	love.graphics.setColor({1,1,1})
	love.graphics.print(h_tab.name, h_tab.shift.x, h_tab.shift.y)
	love.graphics.print(h_tab.description, h_tab.shift2.x, h_tab.shift2.y)
	local active_h_tab = 0
	for j, v_tab in pairs (h_tab.v_tabs) do
		
--		love.graphics.setFont(GUI.font24)
		if j == h_tab.v_tab_active then -- active
			active_h_tab = j

		else
			draw_area (v_tab.area, false)
			love.graphics.setColor({0.5,0.5,0.5})
			love.graphics.print(v_tab.name, v_tab.shift.x, v_tab.shift.y)
		end
	end
	
	
	local v_tab = h_tab.v_tabs[active_h_tab]
	draw_area (v_tab.area, true)
	
	draw_area (GUI.scroll_area, true)
	love.graphics.setColor({1,1,1})
	
	love.graphics.print(v_tab.name, v_tab.shift.x, v_tab.shift.y)
	love.graphics.print(v_tab.description, v_tab.shift2.x, v_tab.shift2.y)
	
	love.graphics.setFont(GUI.font14)
	
--	love.graphics.setScissor( GUI.scissor_area)
	love.graphics.setScissor( GUI.scissor_area.x,GUI.scissor_area.y,GUI.scissor_area.width,GUI.scissor_area.height)
	for k, bottonline in pairs (v_tab.bottonlines) do
		love.graphics.setColor({0,1,0})
		local sx = bottonline.shift.x
		local sy = bottonline.shift.y+GUI.scroll_y
		local sy2 = bottonline.shift.sy
		if sy >(GUI.scroll_area.y) and  sy <(GUI.scroll_area.y+GUI.scroll_area.height) then
			

			bottonline.area.y = bottonline.area.sy and sy+bottonline.area.sy or sy
			draw_area (bottonline.area, false)
			love.graphics.print(bottonline.name.. '	' .. bottonline.value, sx, sy+sy2)
			
			for n_botton, botton in pairs (bottonline.buttons) do
				botton.area.y=sy
--				print(botton.y)
				draw_area (botton.area, false)
				love.graphics.print(botton.name, botton.x, sy+sy2)
			end
		end
		
	end
	love.graphics.setScissor() -- Disables scissor
end


-- sorry, tabA is h_tab; tabB is v_tab:
function update_selected (position)
	for i, tabA in pairs (GUI.h_tabs) do
		
		if is_position_inside_area(position, tabA.area) then
			GUI.h_tab_active = i
			GUI.scroll_y = 0
			return
		elseif i == GUI.h_tab_active then
			for j, tabB in pairs (tabA.v_tabs) do
				if is_position_inside_area(position, tabB.area) then
					tabA.v_tab_active = j
					GUI.scroll_y = 0
					return
				elseif j == tabA.v_tab_active then
					if is_position_inside_area(position, GUI.scissor_area) then
						for k, bottonline in pairs (tabB.bottonlines) do
	--						bottonline.area
							for n_botton, botton in pairs (bottonline.buttons) do
								if is_position_inside_area(position, botton.area) then
									if botton.name == "Add" then 
										bottonline.value = bottonline.value+1
										return
									elseif botton.name == "Remove" then 
										bottonline.value = bottonline.value-1
										return
									end
								end
							end
						end
					end
				end
			end
		end
	end
	
end

function love.mousepressed(x, y, button, istouch)
	if button == 1 then
		update_selected ({x=x,y=y})
	end
end

function love.wheelmoved( dx, dy )
    GUI.scroll_y = math.min(GUI.scroll_y + dy*GUI.scroll_dy, 0)
end


function love.resize(w, h)
	print(("Window resized to width: %d and height: %d."):format(w, h))
	love.load(false)
end