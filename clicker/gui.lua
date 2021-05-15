local font = love.graphics.getFont()
local h_text = font:getHeight( )

local gui = 
{
	x = 32,
	y=32+h_text,
	dy=2*h_text,
	buttons = {},
	input = "Toyota",
	input_process = "xxx"
}

function gui.create_plus()
	local plus_button = 
	{
		x = gui.x,
		y = gui.y,
		r = h_text/2,
		name = "plus-button",
		text = "add",
		amount = 0
	}
	gui.buttons["plus-button"] = plus_button
	gui.y = gui.y+gui.dy
end

function gui.add_button (name, text)
	name = name or 'button-'..#gui.buttons+1
	text = text or name
	if not (text == "") then
		
		local y = gui.y
		local new_button = 
		{
			x = gui.x,
			y = gui.y,
			r = h_text/2,
			name = name,
			text = text,
			amount = 0
		}
		gui.buttons[#gui.buttons+1] = new_button
		gui.y = gui.y+gui.dy -- for the next one
	end
end


function gui.button_pressed ( x, y, button, istouch, presses )
	local clicked
	for i, button in pairs (gui.buttons) do
		local square_distance = (button.x-x)^2+(button.y-y+t.y)^2
		if square_distance <= button.r^2 then
			clicked = button.name
			button.amount = button.amount + 1
		end
	end
	if clicked and clicked == "plus-button" then
		local text = gui.input
		gui.input = ''
		gui.add_button (name, text)
	end
end

function gui.draw_buttons()
	for i, button in pairs (gui.buttons) do
		local x=button.x
		local y=button.y
		local r=button.r
		local text = button.text
		if y+t.y > 32 then
			love.graphics.circle('line', x,y,r)
			love.graphics.print(button.amount..' '..text,x+r+5, y-r)
		end
	end
end


function gui.draw()
	gui.draw_buttons()
end

return gui