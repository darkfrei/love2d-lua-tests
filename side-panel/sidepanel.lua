-- sidepanel.lua
-- refactored to use elements.lua OOP structure

local Elements = require("elements")

local SidePanel = {}

-- create new side panel panel
function SidePanel:newPanel(settings)
	local panel = {}
	setmetatable(panel, { __index = self })

	panel.side = settings.side or "left"

	-- default settings
	panel.width = settings and settings.width or 600
	panel.paddingX = settings and settings.paddingX or 10
	panel.paddingY = settings and settings.paddingY or 10
	panel.spacing = settings and settings.spacing or 10
	panel.lineSpacing = settings and settings.lineSpacing or 6

	-- resize handle
	panel.resizeHandleWidth = 6
	panel.resizing = false
	panel.resizeHover = false
	panel.resizeStartX = 0
	panel.originalWidth = panel.width
	panel.minWidth = 150

	-- scroll
	panel.scrollY = 0
	panel.maxScroll = 0
	panel.currentY = panel.paddingY

	-- visibility animation
	panel.visible = 1
	panel.targetVisible = 1
	panel.animating = false
	panel.animTime = 0
	panel.animDuration = 0.5
	panel.animStart = panel.visible
--	panel.hideKey = settings and settings.hideKey or "n"
	panel.hideKey = (panel.side == "right") and "p" or "n"

	-- fonts
	panel.headerFont = settings and settings.headerFont or self.headerFont or love.graphics.getFont()
	panel.textFont = settings and settings.textFont or self.textFont or love.graphics.getFont()

	-- elements storage
	panel.elements = {}

	return panel
end

-- add header element
function SidePanel:addHeader(config)
--	local text = config.text
--	config.text = text
	config.font = config.font or self.headerFont
	config.x = self.paddingX
	config.y = self.currentY

	local header = Elements.HeaderElement:new(config)
	header:calculateSize(self.width - 2 * self.paddingX)

	table.insert(self.elements, header)
	self.currentY = self.currentY + header.h + self.spacing
	self:updateMaxScroll()

	return header
end

-- add text element
function SidePanel:addText(config)
--	config = config or {}
--	config.text = text
	config.font = config.font or self.textFont
	config.x = self.paddingX
	config.y = self.currentY

	local textEl = Elements.TextElement:new(config)
	textEl:calculateSize(self.width - 2 * self.paddingX)

	table.insert(self.elements, textEl)
	self.currentY = self.currentY + textEl.h + self.spacing
	self:updateMaxScroll()

	return textEl
end

-- add horizontal separator
function SidePanel:addSeparator(config)
	config = config or {}
	config.isVertical = false
	config.x = self.paddingX
	config.y = self.currentY

	local sep = Elements.SeparatorElement:new(config)
	sep:calculateSize(self.width - 2 * self.paddingX)

	table.insert(self.elements, sep)
	self.currentY = self.currentY + sep.h + self.spacing
	self:updateMaxScroll()

	return sep
end

-- add field element

function SidePanel:addField(config)
--	config = config or {}
--	config.label = label
--	config.value = value or ""
	config.font = config.font or self.textFont
	config.x = self.paddingX
	config.y = self.currentY

	local field = Elements.FieldElement:new(config)
	field:calculateSize(self.width - 2 * self.paddingX)

	print ('inserting field')
	table.insert(self.elements, field)
	self.currentY = self.currentY + field.h + self.spacing
	self:updateMaxScroll()

	return field
end

function SidePanel:recalculateElementsAfter(element)
	-- find element index
	local startIndex = nil
	for i, el in ipairs(self.elements) do
		if el == element then
			startIndex = i
			break
		end
	end
	
	if not startIndex then return end
	
	-- recalculate positions for all elements after this one
	local currentY = element.y + element.h + self.spacing
	
	for i = startIndex + 1, #self.elements do
		local el = self.elements[i]
		el.y = currentY
		currentY = currentY + el.h + self.spacing
	end
	
	self.currentY = currentY
	self:updateMaxScroll()
end

-- add multiline text field
function SidePanel:addMultilineField(config)
	config.font = config.font or self.textFont
	config.x = self.paddingX
	config.y = self.currentY
	
	-- set initial height to 2 lines if not specified
	if not config.minHeight then
		local lineHeight = config.font:getHeight()
		config.minHeight = 2 * lineHeight + 2 * (config.paddingY or 4)
	end
	
	local field = Elements.MultilineFieldElement:new(config)
	field:calculateSize(self.width - 2 * self.paddingX)
	
	table.insert(self.elements, field)
	self.currentY = self.currentY + field.h + self.spacing
	self:updateMaxScroll()
	
	return field
end


-- add image element
function SidePanel:addImage(config)
	-- create image element
	local img = Elements.ImageElement:new({
			img = config.img,
			x = self.paddingX,
			y = self.currentY,
			w = config.w,
			h = config.h,
			align = config.align or "center"
		})

	-- calculate size relative to panel width
	local availableWidth = self.width - 2 * self.paddingX
	local w, h = img:calculateSize(availableWidth)

	img.w = w
	img.h = h

	-- add to elements list
	table.insert(self.elements, img)

	-- update layout
	local addingY = img.h + self.spacing
	print ('addingY', addingY)
	self.currentY = self.currentY + addingY
	self:updateMaxScroll()

	return img
end





-- add line element (horizontal container)
function SidePanel:addLine(config)
	local lineElements = {}

	-- create child elements from config
	for _, elConfig in ipairs(config) do
		local el = nil

		if elConfig.type == "text" then
			elConfig.font = elConfig.font or self.textFont
			el = Elements.TextElement:new(elConfig)
--			print ('addLine', 'el.type', el.type)
		elseif elConfig.type == "separator" then
			elConfig.isVertical = true
			el = Elements.SeparatorElement:new(elConfig)
		elseif elConfig.type == "field" then
			elConfig.font = elConfig.font or self.textFont
			el = Elements.FieldElement:new(elConfig)
--        elseif elConfig.type == "multiline" or elConfig.type == "multilineField" then
--            elConfig.font = elConfig.font or self.textFont
--            el = Elements.MultilineFieldElement:new(elConfig)
		else
			-- unknown types are ignored but logged
			print("[SidePanel] addLine: unknown element type:", elConfig.type)
		end

		if el then
			table.insert(lineElements, el)
		end
	end

	local spacing = self.lineSpacing or 6
	local availableWidth = self.width - 2 * self.paddingX
	local totalFixed = 0
	local autoEl = nil
	local elementCount = #lineElements

	-- first pass: measure fixed elements (call calculateSize to get intrinsic sizes)
	for _, el in ipairs(lineElements) do
		if el.autoWidth then
			autoEl = el
		else
			totalFixed = totalFixed + (el.w or 0)
		end
	end

	-- calculate total spacing
	local totalSpacing = math.max(0, (elementCount - 1)) * spacing

	-- distribute remaining width to auto element if present
	if autoEl then
		local remaining = availableWidth - totalFixed - totalSpacing
		autoEl.w = math.max(10, remaining)
	end

	-- second pass: set positions and finalize sizes, compute max height
	local currentX = self.paddingX
	local maxHeight = 0
	for _, el in ipairs(lineElements) do
		el.x = currentX
		el.y = self.currentY

		-- ask element to calculate size using its assigned width (or availableWidth fallback)
		local useWidth = el.w or availableWidth
--        local w, h = el:calculateSize(useWidth)
--        el.w = w
--        el.h = h

		if el.h then
			maxHeight = math.max(maxHeight, el.h or 0)
		end
		if el.w then
			currentX = currentX + el.w + spacing
		end
	end

	-- stretch vertical separators to the line height
	for _, el in ipairs(lineElements) do
		if el.isVertical then
			el.h = maxHeight
		end
	end

	-- create and register line container (store layout results on it)
	local line = Elements.LineElement:new({
			x = self.paddingX,
			y = self.currentY,
			elements = lineElements,
			spacing = spacing,
			type = "line"
		})

	-- set line dims to reflect calculated layout
	line.w = availableWidth
	line.h = maxHeight

	table.insert(self.elements, line)
	self.currentY = self.currentY + line.h + self.spacing
	self:updateMaxScroll()

	return line
end




-- update max scroll value
function SidePanel:updateMaxScroll()
	self.maxScroll = math.max(0, self.currentY - love.graphics.getHeight() + self.paddingY)
end

-- recalculate all element sizes (after resize)
function SidePanel:recalculateElements()
	self.currentY = self.paddingY

	for _, el in ipairs(self.elements) do
		el.x = self.paddingX
		el.y = self.currentY
		el:calculateSize(self.width - 2 * self.paddingX)
		self.currentY = self.currentY + el.h + self.spacing
	end

	self:updateMaxScroll()
end

-- check if mouse is over resize handle
function SidePanel:isOverResizeHandle(mx, my)
	if self.side == "left" then
		return mx >= self.width - self.resizeHandleWidth and mx <= self.width
	end
	return false
end

-- mouse events
function SidePanel:mousepressed(mx, my, button)
	-- check resize handle
	if button == 1 and self:isOverResizeHandle(mx, my) then
		self.resizing = true
		self.resizeStartX = mx
		self.originalWidth = self.width
		return
	end

	-- check elements
	local adjY = my + self.scrollY
	for _, el in ipairs(self.elements) do
		if el.mousepressed then
			if el:mousepressed(mx, adjY, button) then
				return
			end
		end
	end
end

-- helper to check if point is inside element rect (with scroll correction)
local function isOn(el, mx, my, scrollY)
	if not el or not el.w or not el.h then return false end
	return mx >= el.x and mx <= el.x + el.w and
	(my + scrollY) >= el.y and (my + scrollY) <= el.y + el.h
end

-- recursively clear hover and find the deepest hovered element
local function updateHoverState(el, mx, my, scrollY)
	el.isHovered = false

	-- check if point inside element rect
	local inside = mx >= el.x and mx <= el.x + el.w and
	(my + scrollY) >= el.y and (my + scrollY) <= el.y + el.h
	if not inside then
		return false
	end

	-- if this element has children (line container)
	if el.type == "line" and el.elements then
		for _, child in ipairs(el.elements) do
			if updateHoverState(child, mx, my, scrollY) then
				return true
			end
		end
	end

	-- mark this element as hovered if no child consumed the hover
	el.isHovered = true
	return true
end




function SidePanel:mousemoved(mx, my, dx, dy)
	-- handle resizing
	if self.resizing then
		local newW = math.max(self.minWidth, self.originalWidth + (mx - self.resizeStartX))
		newW = math.min(newW, love.graphics.getWidth() - 50)
		self.width = newW
		self:recalculateElements()
		return
	end

	-- check resize handle hover
	self.resizeHover = self:isOverResizeHandle(mx, my)

	-- clear all hover states
	for _, el in ipairs(self.elements) do
		el.isHovered = false
		if el.type == "line" and el.elements then
			for _, child in ipairs(el.elements) do
				child.isHovered = false
			end
		end
	end

	-- find the first hovered element recursively
	for _, el in ipairs(self.elements) do
		if updateHoverState(el, mx, my, self.scrollY) then
			return -- stop after first match
		end
	end
end




function SidePanel:mousereleased(mx, my, button)
	if button == 1 and self.resizing then
		self.resizing = false
	end
end

-- scroll event
function SidePanel:wheelmoved(x, y)
	self.scrollY = math.max(0, math.min(self.maxScroll, self.scrollY - y * 20))
end

-- keyboard events
function SidePanel:textinput(t)
	for _, el in ipairs(self.elements) do
		if el.textinput then
			local oldH = el.h
			el:textinput(t)
			
			-- if element height changed, recalculate positions after it
			if el.h and oldH ~= el.h then
				self:recalculateElementsAfter(el)
			end
		end
	end
end

function SidePanel:keypressed(key)
	-- check if any field is being edited
	local isEditing = false
	for _, el in ipairs(self.elements) do
		if el.isEditing then
			isEditing = true
			break
		end
		-- check nested elements in lines
		if el.type == "line" and el.elements then
			for _, child in ipairs(el.elements) do
				if child.isEditing then
					isEditing = true
					break
				end
			end
		end
	end
	
	-- toggle visibility only if not editing
	if key == self.hideKey and not isEditing then
		self:toggleVisibility()
		return
	end
	
	-- pass to elements and track height changes
	for _, el in ipairs(self.elements) do
		if el.keypressed then
			local oldH = el.h
			el:keypressed(key)
			
			-- if element height changed, recalculate positions after it
			if el.h and oldH ~= el.h then
				self:recalculateElementsAfter(el)
			end
		end
	end
end

function SidePanel:toggleVisibility()
	self.animating = true
	self.animTime = 0
	self.animStart = self.visible
	self.targetVisible = (self.targetVisible == 1) and 0 or 1
end

function SidePanel:addElement(config)
	local t = config.type
	if t == "header" then
		return self:addHeader(config)
	elseif t == "text" then
		return self:addText(config)
	elseif t == "separator" then
		return self:addSeparator(config)
	elseif t == "field" then
		print ('adding field')
		return self:addField(config)
	elseif t == "multiline" or t == "multilineField" then
		return self:addMultilineField(config)
	elseif t == "line" then
		return self:addLine(config.elements)

	elseif t == "image" then
		return self:addImage(config)
	else
		print("[SidePanel] unknown element type:", t)
	end
end



function SidePanel:update(dt)
	if self.animating then
		self.animTime = self.animTime + dt
		local t = math.min(1, self.animTime / self.animDuration)
		self.visible = self.animStart + (self.targetVisible - self.animStart) * t
		if t >= 1 then
			self.animating = false
		end
	end
end



-- recursively draw highlight for hovered elements
local function drawHoverRecursive(el)
	-- draw background if hovered
	if el.isHovered then
		love.graphics.setColor(0.35, 0.55, 0.85, 0.25)
		love.graphics.rectangle("fill", el.x - 2, el.y - 2, el.w + 4, el.h + 4, 4)
	end

	-- recurse into children if element is a line container
	if el.type == "line" and el.elements then
		for _, child in ipairs(el.elements) do
			drawHoverRecursive(child)
		end
	end
end


function SidePanel:drawScrolled(scrollY)
	love.graphics.push()
	love.graphics.translate(0, scrollY)

	-- first draw highlight backgrounds (under content)
	for _, el in ipairs(self.elements) do
		drawHoverRecursive(el)
	end

	-- then draw actual elements
	for _, el in ipairs(self.elements) do
		el:draw()
	end

	love.graphics.pop()
end


function SidePanel:draw()
	love.graphics.push()

	local offsetX = 0
	if self.side == "left" then
		offsetX = -self.width * (1 - self.visible)
	elseif self.side == "right" then
		offsetX = love.graphics.getWidth() - self.width * self.visible
	end

	love.graphics.translate(offsetX, 0)

	-- draw background
	love.graphics.setColor(0.15, 0.15, 0.2, 0.95)
	love.graphics.rectangle("fill", 0, 0, self.width, love.graphics.getHeight())

	self:drawScrolled(-self.scrollY)

	love.graphics.pop()
end


function SidePanel:reset()
	self.elements = {}
	self.currentY = self.paddingY
	self.scrollY = 0
	self.maxScroll = 0
end



return SidePanel