-- myButtons lib
-- v. 2023-11-09 1
-- (MIT license)

-- myButtons.lua
local myButtons = {}

myButtons.buttons = {} -- default button set
myButtons.buttonSets = {myButtons.buttons}

function myButtons:newButtonsSet ()
	local buttonSet = {}
	myButtons.buttons = buttonSet
	table.insert (myButtons.buttonSets, buttonSet)
	return buttonSet
end

function myButtons:setButtonsSet (buttonSet)
	myButtons.buttons = buttonSet
	return buttonSet
end

function myButtons:new (data)
	local button = {}
	for i, v in pairs (data) do
		button[i] = v
	end
	if not (button.enabled == false) then
		button.enabled = true
	end
	if button.onButtonNotHovered then
		button:onButtonNotHovered ()
	end
	table.insert(myButtons.buttons, button)
	return button
end

function myButtons.update(dt)
	for i, button in ipairs(myButtons.buttons) do
		if button.enabled and button.updateButton then
			button:updateButton(dt)
		end
	end
end

local function isOn (mx, my, x, y, w, h)
	if (mx > x) and (mx < (x + w)) and (my > y) and (my < (y + h)) then
		return true
	end
end

function myButtons.mousepressed(mx, my, mbutton)
	for i, button in ipairs(myButtons.buttons) do
		local x, y, w, h = button.x, button.y, button.w, button.h
		if button.enabled and isOn (mx, my, x, y, w, h) then
			if button.onToggle then
				button:onToggle(mx, my, mbutton, button.value)
			elseif button.onButtonPressed then
				button:onButtonPressed(mx, my, mbutton)
			end
		end
	end
end

function myButtons.mousereleased(mx, my, mbutton)
	for i, button in ipairs(myButtons.buttons) do
		local x, y, w, h = button.x, button.y, button.w, button.h
		if button.enabled and isOn (mx, my, x, y, w, h) then
			if button.onButtonrReleased then
				button:onButtonrReleased(mx, my, mbutton)
			end
		elseif button.enabled and button.onOtherButtonReleased then
			button:onOtherButtonReleased (mx, my, mbutton)
		end
	end
end

function myButtons.mousemoved (mx, my, dx, dy)
	for i, button in ipairs(myButtons.buttons) do
		local x, y, w, h = button.x, button.y, button.w, button.h
		if button.enabled and isOn (mx, my, x, y, w, h) then
			if button.onButtonHovered then
				button:onButtonHovered(mx, my, dx, dy)
			end
		elseif button.enabled and button.onButtonNotHovered then
			button:onButtonNotHovered(mx, my, dx, dy)
		end
	end
end

function myButtons.draw ()
	for i, button in ipairs(myButtons.buttons) do
		if button.enabled and button.drawButton then
			button:drawButton ()
		elseif button.drawDisabledButton then
			button:drawDisabledButton ()
		end
	end
end

return myButtons

