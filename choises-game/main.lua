-- main.lua
-- text quest with inventory

local questNodes = {
	start = {
		text = "You wake up in a dark room. There are two doors.",
		options = {
			{ text = "Open the right door", next = "rightRoom" },
			{ text = "Open the left door", next = "leftRoom" },
		}
	},
	leftRoom = {
		text = "A wild creature jumps at you! It looks dangerous.",
		options = {
			{ text = "Fight with your sword", next = "fightCreature", require = "sword", remove = "sword"},
			{ text = "Run away", next = "start" },
		}
	},
	rightRoom = {
		text = "The right room has a locked gate.",
		options = {
			{ text = "Open with the key", next = "treasureEnd", require = "key" },
			{ text = "Go back", next = "start" },
		}
	},
	fightCreature = {
		text = "You defeat the creature, but your sword breaks. You find a shiny key on the ground.",
		options = {
--			{ text = "Take the key and go back", next = "start", give = "key", remove = "sword" }
			{ text = "Take the key and go back", next = "start", give = "key"}
		}
	},
	treasureEnd = {
		text = "You open the gate with the key and find a chest of gold. \nYou win!\n\nThanks for playing.",
		options = {
			{ text = "Restart", next = "start", restart = true },
			{ text = "Exit", next = "exitGame" }
		}
	},
}

local inventory, currentNode = {}, nil
local optionHeight, startHeight, margin = 50, 390, 50

local function addItem(item) inventory[item] = true end
local function removeItem(item) inventory[item] = nil end
local function hasItem(item) return inventory[item] ~= nil end
local function resetInventory() inventory = {} end

function love.load()
	love.graphics.setFont(love.graphics.newFont(26))
	resetInventory()
	addItem("sword")
--	addItem("key")
	currentNode = questNodes.start
end

function love.draw()
	-- main text
	love.graphics.rectangle("line", margin/2, margin/2, 500 - margin, startHeight - margin*1.5, 8, 8)
	love.graphics.printf(currentNode.text, margin/2+10, margin/2, 435, "left")

	-- inventory
	local invText = "Inventory:\n"
	for item in pairs(inventory) do invText = invText .. "- " .. item .. "\n" end
	love.graphics.printf(invText, 500+margin/2, margin/2, love.graphics.getWidth()-500-margin, "left")
	love.graphics.rectangle("line", 500, margin/2, love.graphics.getWidth()-500-margin*0.5, startHeight-margin*1.5, 8, 8)

	-- options
	love.graphics.rectangle("line", margin/2, startHeight-margin/2, love.graphics.getWidth()-margin, love.graphics.getHeight()-startHeight+margin/4, 8, 8)
	for i, opt in ipairs(currentNode.options) do
		if not opt.require or hasItem(opt.require) then
			local x, y, w, h = margin, startHeight + (i-1)*(optionHeight+10), love.graphics.getWidth()-2*margin, optionHeight
			love.graphics.rectangle("line", x, y, w, h, 8, 8)
			love.graphics.printf(opt.text, x, y+10, w, "center")
		end
	end
end

function love.mousepressed(mx, my, button)
	if button ~= 1 then return end
	for i, opt in ipairs(currentNode.options) do
		if not opt.require or hasItem(opt.require) then
			local x, y, w, h = margin, startHeight + (i-1)*(optionHeight+10), love.graphics.getWidth()-2*margin, optionHeight
			if mx>=x and mx<=x+w and my>=y and my<=y+h then
				if opt.next=="exitGame" then love.event.quit() end
				if opt.give then addItem(opt.give) end
				if opt.remove then removeItem(opt.remove) end
				if opt.restart then 
					resetInventory() 
					addItem("sword")
					end
				currentNode = questNodes[opt.next]
				break
			end
		end
	end
end
