-- main.lua for Love2D 11.4

local SidePanel = require("sidepanel")

SidePanel.headerFont = love.graphics.newFont(20) -- header font size
SidePanel.textFont = love.graphics.newFont(14)

local leftPanel, rightPanel

local font30 = love.graphics.newFont("NotoSans-Regular.ttf", 30)
local font20 = love.graphics.newFont("NotoSans-Regular.ttf", 20)

SidePanel.headerFont = font30
SidePanel.textFont = font20

-- main.lua
function love.load()
	love.window.setMode (1920, 1080)

	-- create left side panel with custom settings
--	leftPanel = SidePanel:newPanel({side = "left", width = 600})
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
		description = "Multi-line text\nAnd",
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
	leftPanel:addElement({type = "field", table=exampleData, key = "playerName", w = 100})
	leftPanel:addElement({type = "field", table=exampleData, key = "playerName", w = 100})
	leftPanel:addElement({type = "separator"})
	leftPanel:addElement({type = "image",	filename = "image580x280.png"})
	leftPanel:addElement({type = "separator"})
	leftPanel:addElement({type = "field", multiline = true, table=exampleData, key = "description", w = 200})
	leftPanel:addElement({type = "separator"})


	--------------------------------------

	rightPanel = SidePanel:newPanel({side = "right", width = 600})
	rightPanel:addElement({type = "header", text = "P-Panel"})
	rightPanel.hideKey = "p"
	rightPanel:addElement({
			type = "image",
			filename = "image280x280.png"
		})
	rightPanel:addElement({type = "separator"})
	rightPanel:addLine({
			{type = "separator"}, -- must be vertical separator
			{type = "text", text = 'Edit:'},
--			{type = "separator"}, -- must be vertical separator
			{type = "field", table=exampleData, key = "playerName", autoWidth = true},
			{type = "separator"}, -- must be vertical separator
		})
	rightPanel:addElement({type = "separator"})
	rightPanel:addLine({
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
	rightPanel:addElement({type = "separator"})
	rightPanel:addElement({
			type = "image",
			filename = "image1580x280.png"
		})

	-- multiline
	rightPanel:addElement({type = "field", multiline = true, table=exampleData, key = "description"})
	
	rightPanel:addElement({type = "separator"})

end


function love.update(dt)
	SidePanel.updateAll(dt)
end

function love.draw()
	SidePanel.drawAll()
end

function love.mousepressed(x, y, button)
	SidePanel.mousepressedAll(x, y, button)
end

function love.mousereleased(x, y, button)
	SidePanel.mousereleasedAll(x, y, button)
end

function love.mousemoved(mx, my, dx, dy)
	SidePanel.mousemovedAll(mx, my, dx, dy)
end

function love.wheelmoved(x, y)
	SidePanel.wheelmovedAll(x, y)
end

function love.textinput(t)
	SidePanel.textinputAll(t)
end

function love.keypressed(key)
	SidePanel.keypressedAll(key)
	if key == "escape" then love.event.quit() end
end
