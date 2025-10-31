-- main.lua for Love2D 11.4

local SidePanel = require("sidepanel")

SidePanel.headerFont = love.graphics.newFont(20) -- header font size
SidePanel.textFont = love.graphics.newFont(14)

local leftPanel, rightPanel

-- main.lua
function love.load()
	love.window.setMode (1920, 1080)

	-- create left side panel with custom settings
	leftPanel = SidePanel:newPanel({side = "left", width = 600})

	-- define header font and store on panel (can be overridden per-element)
--	leftPanel.headerFont = love.graphics.newFont(20) -- header font size
--	leftPanel.textFont = love.graphics.newFont(30) -- header font size
	leftPanel.hideKey = "n"

	-- example data object
	local exampleData = {
		id = 237,
		fixText = "fixText",
		fixmultiLineText = "1. fixmultiLineText\n2. fixmultiLineText2",
		lineText = {key = 'key', value = 'value'},


		playerName = "Hero",
		playerHealth = "100",
		description = "Multi-line text",
	}

	-- add fields to panel, pass font explicitly (optional)
	leftPanel:addElement({type = "header", text = "N-Panel"})
	leftPanel:addElement({type = "header", text = "ID "..exampleData.id})
	leftPanel:addElement({type = "text", text = "fixText: "..exampleData.fixText})

--	leftPanel:addElement({type = "separator"})
	leftPanel:addElement({type = "separator"})
	leftPanel:addLine({
			{type = "separator"}, -- must be vertical separator
			{type = "text", text = exampleData.lineText.key},
			{type = "separator"}, -- must be vertical separator
			{type = "text", text = exampleData.lineText.value},
			{type = "separator"}, -- must be vertical separator
			{type = "text", text = '0000000000000\n0000000000000\n0000000000000', autoWidth = true},
			{type = "separator"}, -- must be vertical separator
			{type = "text", text = exampleData.lineText.value},
			{type = "separator"}, -- must be vertical separator
		})
	leftPanel:addElement({type = "separator"})
	leftPanel:addElement({type = "text", text = "fixText: "..exampleData.fixText})
	leftPanel:addElement({type = "separator"})
	leftPanel:addElement({type = "field", table=exampleData, key = "playerName"})
	leftPanel:addElement({type = "separator"})
	leftPanel:addElement({
			type = "image",
			img = "image580x280.png"
		})
	leftPanel:addElement({type = "separator"})
	leftPanel:addElement({type = "multilineField", table=exampleData, key = "playerName"})
	leftPanel:addElement({type = "separator"})


	--------------------------------------

	rightPanel = SidePanel:newPanel({side = "right", width = 600})
	rightPanel:addElement({type = "header", text = "P-Panel"})
	rightPanel:addElement({
			type = "image",
			img = "image580x280.png"
		})

end


function love.update(dt)
	-- draw panel
	if leftPanel then
		leftPanel:update(dt)
	end

	if rightPanel then
		rightPanel:update(dt)
	end
end

function love.draw()
	-- draw panel
	if leftPanel then
		leftPanel:draw()
	end
	if rightPanel then
		rightPanel:draw()
	end
end

function love.mousepressed(x, y, button)
	if leftPanel then
		leftPanel:mousepressed(x, y, button)
	end
	if rightPanel then
		rightPanel:mousepressed(x, y, button)
	end
end

function love.mousemoved(mx, my, dx, dy)
	if leftPanel and leftPanel.mousemoved then
		leftPanel:mousemoved(mx, my, dx, dy)
	end
	if rightPanel and rightPanel.mousemoved then
		rightPanel:mousemoved(mx, my, dx, dy)
	end
end


function love.mousereleased(x, y, button)
	if leftPanel then
		leftPanel:mousereleased(x, y, button)
	end
	if rightPanel then
		rightPanel:mousereleased(x, y, button)
	end
end

function love.wheelmoved(x, y)
	if leftPanel and leftPanel.wheelmoved then
		leftPanel:wheelmoved(x, y)
	end
	if rightPanel and rightPanel.wheelmoved then
		rightPanel:wheelmoved(x, y)
	end
end

function love.textinput(t)
	if leftPanel and leftPanel.textinput then
		leftPanel:textinput(t)
	end
	if rightPanel and rightPanel.textinput then
		rightPanel:textinput(t)
	end
end

function love.keypressed(key)
	if leftPanel then
		leftPanel:keypressed(key)
	end
	if rightPanel then
		rightPanel:keypressed(key)
	end

	if key == "escape" then
		love.event.quit()
	end
end