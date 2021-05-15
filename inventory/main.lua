function update_gui()
	
	local font = love.graphics.getFont( )
	local th = font:getHeight( ) -- 14
	local dh = 2*th
	print (th)

	gui={}
	for i, inventory in pairs ({inventory_a, inventory_b}) do
		local x1 = (i==2) and love.graphics.getWidth( )/2 or 0

		for j, item in pairs (inventory) do
			local button = {}
			button.i=i
			button.j=j
			button.name=item.name
			button.text=item.name..', '..item.amount
			local width = font:getWidth( button.text )

			local area = {x=th+x1, y=dh*j, w=width+2*th, h=dh-4}
			button.area= area
			local x1 = (2*area.x+area.w)/2
			local y1 = (2*area.y+area.h)/2
			button.tx = x1-width/2
			button.ty = y1-th/2
			table.insert (gui, button)
		end
	end
end

function love.load()
	inventory_a={}
	inventory_b={}
	local items={'apple', 'orange', 'mango', 'banana'}
	
	for i = 1, 10 do
		table.insert (inventory_a, {name=items[math.random(#items)], amount = math.random(1, 4)})
		table.insert (inventory_b, {name=items[math.random(#items)], amount = math.random(1, 4)})
	end
	
	
	update_gui()
end

function draw_button (button)
	local area = button.area
	local text = button.text
	local tw = button.tw
	local th = button.th
	

	love.graphics.print(text, button.tx, button.ty)
	love.graphics.rectangle("line",area.x, area.y, area.w, area.h)
end


function love.draw()
	for i, button in pairs (gui) do
		draw_button (button)
	end
end

function is_position_inside_area(x,y, area)
	local x1, x2 = area.x, area.x+area.w
	local y1, y2 = area.y, area.y+area.h
	return (x1<x)and(x<x2)and(y1<y)and(y<y2)
end

function remove_item (name, inventory, j)
	local item = inventory[j]
	item.amount = item.amount - 1
	if item.amount <= 0 then
		table.remove(inventory, j)
	end
	
--	for i, item in pairs (inventory) do
--		if item.name == name then 
--			item.amount = item.amount - 1
--			if item.amount <= 0 then
--				table.remove(inventory, i)
--			end
--			return
--		end
--	end
end

function add_item (name, inventory)
	for i, item in pairs (inventory) do
		if item.name == name then 
			item.amount = item.amount + 1
			return
		end
	end
	table.insert (inventory, {name=name, amount = 1})
end


function item_from_to (button, inventory_from, inventory_to)
	local name = button.name
	local j = button.j
	remove_item (name, inventory_from, j)
	add_item (name, inventory_to)
	update_gui(inventory_a, inventory_b)
end

function love.mousereleased(x, y, button)
	if button == 1 then
		for i, button in pairs (gui) do
			if is_position_inside_area(x,y, button.area) then
--				print (button.name..' '..button.i)
				if button.i == 1 then
					item_from_to (button, inventory_a, inventory_b)
				else
					item_from_to (button, inventory_b, inventory_a)
				end
				return
			end
		end
	end
end