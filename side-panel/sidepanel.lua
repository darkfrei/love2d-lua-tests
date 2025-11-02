-- sidepanel.lua

local Elements = require ( "elements" ) 

local SidePanel = {}

-- sidepanel manager
SidePanel.panels = {}

-- global defaults
SidePanel.paddingX = 10
SidePanel.paddingY = 10

SidePanel.spacing = 10


SidePanel.resizeHandleWidth = 6

SidePanel.visible = 1
SidePanel.scrollY = 0
SidePanel.animDuration = 0.5
SidePanel.targetVisible = 1

-- create new side panel panel
--function SidePanel:newPanel ( settings ) 
--	local panel = {}
--	setmetatable ( panel, { __index = self } ) 

--	panel.side = settings.side or "left"

--	-- default settings
--	panel.width = settings and settings.width or 600
--	panel.paddingX = settings and settings.paddingX or 10
--	panel.paddingY = settings and settings.paddingY or 10
--	panel.spacing = settings and settings.spacing or 10
--	panel.lineSpacing = settings and settings.lineSpacing or 6

--	-- resize handle
--	panel.resizeHandleWidth = 6
--	panel.resizing = false
--	panel.resizeHover = false
--	panel.resizeStartX = 0
--	panel.originalWidth = panel.width
--	panel.minWidth = 150

--	-- scroll
--	panel.scrollY = 0
--	panel.maxScroll = 0
--	panel.currentY = panel.paddingY

--	-- visibility animation
--	panel.visible = 1
--	panel.targetVisible = 1
--	panel.animating = false
--	panel.animTime = 0
--	panel.animDuration = 0.5
--	panel.animStart = panel.visible
----	panel.hideKey = settings and settings.hideKey or "n"
--	panel.hideKey =  ( panel.side == "right" )  and "p" or "n"

--	-- fonts
--	panel.headerFont = settings and settings.headerFont or self.headerFont or love.graphics.getFont (  ) 
--	panel.textFont = settings and settings.textFont or self.textFont or love.graphics.getFont (  ) 

--	-- elements storage
--	panel.elements = {}

--	return panel
--end

function SidePanel:newPanel(opts)
	local panel = setmetatable(opts or {}, {__index = SidePanel})
	panel.elements = {}
--	panel.x, panel.y = 0, 0
	if panel.side == "left" then 
		panel.x = 0
	elseif panel.side == "right" then 
		panel.x = love.graphics.getWidth() - panel.width 
	end
	panel.y = 0
	panel.currentY = self.paddingY
	
	table.insert(SidePanel.panels, panel)
	return panel
end

-- add header element
function SidePanel:addHeader ( config ) 
--	local text = config.text
--	config.text = text
	config.font = config.font or self.headerFont
	config.x = self.paddingX
	config.y = self.currentY

	local header = Elements.HeaderElement:new ( config ) 
	header:calculateSize ( self.width - 2 * self.paddingX ) 

	table.insert ( self.elements, header ) 
	self.currentY = self.currentY + header.h + self.spacing
	self:updateMaxScroll (  ) 

	return header
end

-- add text element
function SidePanel:addText ( config ) 
--	config = config or {}
--	config.text = text
	config.font = config.font or self.textFont
	config.x = self.paddingX
	config.y = self.currentY

	local textEl = Elements.TextElement:new ( config ) 
	textEl:calculateSize ( self.width - 2 * self.paddingX ) 

	table.insert ( self.elements, textEl ) 
	self.currentY = self.currentY + textEl.h + self.spacing
	self:updateMaxScroll (  ) 

	return textEl
end

-- add horizontal separator
function SidePanel:addSeparator ( config ) 
	config = config or {}
	config.isVertical = false
	config.x = self.paddingX
	config.y = self.currentY

	local sep = Elements.SeparatorElement:new ( config ) 
	sep:calculateSize ( self.width - 2 * self.paddingX ) 

	table.insert ( self.elements, sep ) 
	self.currentY = self.currentY + sep.h + self.spacing
	self:updateMaxScroll (  ) 

	return sep
end

-- add field element

function SidePanel:addField ( config ) 

	config.font = config.font or self.fieldFont or self.textFont
	config.x = self.paddingX
	config.y = self.currentY
	if config.w then
		config.fixedW = config.w
	end

	local field = Elements.FieldElement:new ( config )

	field:calculateSize ( self.width - 2 * self.paddingX ) 

--	--print  ( 'inserting field' ) 
	table.insert ( self.elements, field ) 
	self.currentY = self.currentY + field.h + self.spacing
	self:updateMaxScroll (  ) 

	return field
end

function SidePanel:recalculateElementsAfter ( element ) 
	-- find element index
	local startIndex = nil
	for i, el in ipairs ( self.elements )  do
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
	self:updateMaxScroll (  ) 
end


-- add image element
function SidePanel:addImage ( config ) 
	-- create image element
	config.x = config.x or self.paddingX
	config.y = config.y or self.currentY

	local image = Elements.ImageElement:new (config ) 

	-- calculate size relative to panel width
	local availableWidth = self.width - 2 * self.paddingX
	local w, h = image:calculateSize ( availableWidth ) 
	--print ('filename', config.filename, w, h ) 

	image.w = w
	image.h = h

	-- add to elements list
	table.insert ( self.elements, image ) 

	-- update layout
	local addingY = image.h + self.spacing
--	--print  ( 'addingY', addingY ) 
	self.currentY = self.currentY + addingY
	self:updateMaxScroll (  ) 

	return image
end


function SidePanel:addElement ( config ) 
	local t = config.type
	if t == "header" then
		return self:addHeader ( config ) 
	elseif t == "text" then
		return self:addText ( config ) 
	elseif t == "separator" then
		return self:addSeparator ( config ) 
	elseif t == "field" then
--		--print  ( 'adding field' ) 
		return self:addField ( config ) 
--	elseif t == "multiline" or t == "multilineField" then
--		return self:addMultilineField ( config ) 
	elseif t == "line" then
		return self:addLine ( config.elements ) 
	elseif t == "image" then
		return self:addImage ( config ) 
	else
		--print ( "[SidePanel] unknown element type:", t ) 
	end
end

-- calculate max height of elements in a line and set vertical positions
function SidePanel.calculateLineHeight(lineElements, startY, spacing)
	local currentX = 0
	local maxHeight = 0
	for _, el in ipairs(lineElements) do
		-- set element position
		el.x = currentX
		el.y = startY

		-- calculate size if element supports it
		if el.calculateSize then
			local w, h = el:calculateSize(el.w or 0)
			el.w = w
			el.h = h
		end

		-- update maxHeight
		if el.h then
			maxHeight = math.max(maxHeight, el.h)
		end

		-- advance x for next element
		if el.w then
			currentX = currentX + el.w + spacing
		end
	end

	-- stretch vertical separators
	for _, el in ipairs(lineElements) do
		if el.isVertical then
			el.h = maxHeight
		end
	end

	return maxHeight
end


function SidePanel:addLine(config)
	local lineElements = {}

	for _, elConfig in ipairs(config) do
		local el = nil
		if elConfig.type == "text" then
			elConfig.font = elConfig.font or self.textFont
			el = Elements.TextElement:new(elConfig)
		elseif elConfig.type == "separator" then
			elConfig.isVertical = true
			el = Elements.SeparatorElement:new(elConfig)
		elseif elConfig.type == "field" then
			elConfig.font = elConfig.font or self.textFont
			el = Elements.FieldElement:new(elConfig)
		elseif elConfig.type == "image" then
			el = Elements.ImageElement:new(elConfig)
		end

		if el then
			table.insert(lineElements, el)
		end
	end

	-- handle autoWidth
	local spacing = self.lineSpacing or 6
	local availableWidth = self.width - 2 * self.paddingX
	local totalFixed, autoEl = 0, nil
	for _, el in ipairs(lineElements) do
		if el.autoWidth then autoEl = el else totalFixed = totalFixed + (el.w or 0) end
	end
	local totalSpacing = math.max(0, #lineElements - 1) * spacing
	if autoEl then
		autoEl.w = math.max(10, availableWidth - totalFixed - totalSpacing)
	end

	-- calculate line height and set element positions
	local maxHeight = SidePanel.calculateLineHeight(lineElements, self.currentY, spacing)

	-- create line container
	local line = Elements.LineElement:new({
		x = self.paddingX,
		y = self.currentY,
		elements = lineElements,
		spacing = spacing,
		type = "line"
	})
	line.w = availableWidth
	line.h = maxHeight

	table.insert(self.elements, line)
	self.currentY = self.currentY + line.h + self.spacing
	self:updateMaxScroll()

	return line
end






-- update max scroll value
function SidePanel:updateMaxScroll (  ) 
	self.maxScroll = math.max ( 0, self.currentY - love.graphics.getHeight (  )  + self.paddingY ) 
end

-- recalculate all element sizes  ( after resize ) 
function SidePanel:recalculateElements (  ) 
	self.currentY = self.paddingY

	for _, el in ipairs ( self.elements )  do
		el.x = self.paddingX
		el.y = self.currentY
		el:calculateSize ( self.width - 2 * self.paddingX ) 
		self.currentY = self.currentY + el.h + self.spacing
	end

	self:updateMaxScroll (  ) 
end

-- check if mouse is over resize handle
function SidePanel:isOverResizeHandle ( mx, my ) 
	if self.side == "left" then
		return mx >= self.width - self.resizeHandleWidth and mx <= self.width
	end
	return false
end

-- helper: clear isEditing recursively (handles lines and nested elements)
function SidePanel:clearEditingRecursive(el)
	if el.isEditing then
		el.isEditing = false
	end

	if el.type == "line" and el.elements then
		for _, child in ipairs(el.elements) do
			self:clearEditingRecursive(child)
		end
	end
end

-- mouse events
function SidePanel:mousepressed(mx, my, button)
	-- calculate panel offset
	local panelX = 0
	if self.side == "left" then
		panelX = -self.width * (1 - self.visible)
	elseif self.side == "right" then
		panelX = love.graphics.getWidth() - self.width * self.visible
	end

	-- adjust mouse coordinates relative to panel
	local adjustedMx = mx - panelX
	local adjY = my + self.scrollY

	-- check resize handle
	if button == 1 and self:isOverResizeHandle(mx, my) then
		self.resizing = true
		self.resizeStartX = mx
		self.originalWidth = self.width
		return
	end

	-- helper to recursively clear editing state
	local function clearEditingRecursive(el)
		if el.isEditing then el.isEditing = false end
		if el.type == "line" and el.elements then
			for _, child in ipairs(el.elements) do
				clearEditingRecursive(child)
			end
		end
	end

	-- clear editing for all elements first
	for _, el in ipairs(self.elements) do
		clearEditingRecursive(el)
	end

	-- then check mouse press for elements
	for _, el in ipairs(self.elements) do
		if el.mousepressed then
			if el:mousepressed(adjustedMx, adjY, button) then
				return
			end
		end

		-- handle nested line elements
		if el.type == "line" and el.elements then
			for _, child in ipairs(el.elements) do
				if child.mousepressed and child:mousepressed(adjustedMx, adjY, button) then
					return
				end
			end
		end
	end
end


-- helper to check if point is inside element rect  ( with scroll correction ) 
local function isOn ( el, mx, my, scrollY ) 
	if not el or not el.w or not el.h then return false end
	return mx >= el.x and mx <= el.x + el.w and
	( my + scrollY )  >= el.y and  ( my + scrollY )  <= el.y + el.h
end

-- recursively clear hover and find the deepest hovered element
local function updateHoverState ( el, mx, my, scrollY ) 
	el.isHovered = false

	-- check if point inside element rect
	local inside = mx >= el.x and mx <= el.x + el.w and
	( my + scrollY )  >= el.y and  ( my + scrollY )  <= el.y + el.h
	if not inside then
		return false
	end

	-- if this element has children  ( line container ) 
	if el.type == "line" and el.elements then
		for _, child in ipairs ( el.elements )  do
			if updateHoverState ( child, mx, my, scrollY )  then
				return true
			end
		end
	end

	-- mark this element as hovered if no child consumed the hover
	el.isHovered = true
	return true
end




function SidePanel:mousemoved(mx, my, dx, dy ) 
	-- handle resizing
	if self.resizing then
		local newW
		if self.side == "left" then
			newW = math.max(self.minWidth, self.originalWidth + (mx - self.resizeStartX )  ) 
		elseif self.side == "right" then
			newW = math.max(self.minWidth, self.originalWidth - (mx - self.resizeStartX )  ) 
		end
		newW = math.min(newW, love.graphics.getWidth( )  - 50 ) 
		self.width = newW
		self:recalculateElements( ) 
		return
	end

	-- check resize handle hover
	self.resizeHover = self:isOverResizeHandle(mx, my ) 

	-- calculate panel offset
	local panelX = 0
	if self.side == "left" then
		panelX = -self.width * (1 - self.visible ) 
	elseif self.side == "right" then
		panelX = love.graphics.getWidth( )  - self.width * self.visible
	end

	-- adjust mouse coordinates relative to panel
	local adjustedMx = mx - panelX

	-- clear all hover states
	for _, el in ipairs(self.elements )  do
		el.isHovered = false
		if el.type == "line" and el.elements then
			for _, child in ipairs(el.elements )  do
				child.isHovered = false
			end
		end
	end

	-- find the first hovered element recursively
	for _, el in ipairs(self.elements )  do
		if updateHoverState(el, adjustedMx, my, self.scrollY )  then
			return
		end
	end
end




function SidePanel:mousereleased ( mx, my, button ) 
	if button == 1 and self.resizing then
		self.resizing = false
	end
end

-- scroll event
function SidePanel:wheelmoved(x, y ) 
	-- only scroll if mouse is over this panel
	local mx, my = love.mouse.getPosition( ) 
	local panelX = 0

	if self.side == "left" then
		panelX = -self.width * (1 - self.visible ) 
	elseif self.side == "right" then
		panelX = love.graphics.getWidth( )  - self.width * self.visible
	end

	-- check if mouse is within panel bounds
	if mx >= panelX and mx <= panelX + self.width then
		self.scrollY = math.max(0, math.min(self.maxScroll, self.scrollY - y * 20 )  ) 
	end
end

------------------------------------------

-- update all matching fields across all panels
function SidePanel.updateFieldsContent(changedField)
	local tbl, key = changedField.tableRef, changedField.keyRef
	if not tbl or not key then return end

	local function updateElements(elements)
		for _, el in ipairs(elements) do
			if el.type == "field" and el.tableRef == tbl and el.keyRef == key and el ~= changedField then
				local oldH = el.h
				el:updateWrappedLines()
				el:calculateSize(el.w)
				el:updateCursorMetrics()

				-- debug
--				--print(string.format(
--					"[updateFieldsContent] updated field keyRef=%s, oldH=%.1f newH=%.1f",
--					tostring(el.keyRef), oldH, el.h
--				))
			elseif el.type == "line" and el.elements then
				updateElements(el.elements)
			end
		end
	end

	for _, panel in ipairs(SidePanel.panels) do
		updateElements(panel.elements)
	end
end

-- shift elements and recalc line heights if any element changed height
function SidePanel.updateElementsHeight(panel)
	if not panel then return end

	local currentY = panel.paddingY or 0
	local spacing = panel.spacing or 6

	for _, el in ipairs(panel.elements) do
		el.y = currentY

		if el.type == "line" and el.elements then
			-- recalc line height and update positions of children
			local maxH = SidePanel.calculateLineHeight(el.elements, currentY, el.spacing or (panel.lineSpacing or 6))
			el.h = maxH
		end

		-- advance currentY for next element
		currentY = currentY + (el.h or 0) + spacing
	end

	panel:updateMaxScroll()
end






function SidePanel:textinput(t)
	-- debug: indicate panel receiving input
	--print('SidePanel:textinput called, side:', self.side, 'input:', t)

	local handled = false

	-- helper to process a field
	local function processField(field)
		if field:textinput(t) then
			--print(string.format(
--				"    field updated, keyRef=%s, new value='%s'",
--				tostring(field.keyRef),
--				tostring(field.tableRef[field.keyRef])
--			))
			-- update all matching fields in all panels
			SidePanel.updateFieldsContent(field)
			-- recalc positions for all panels
			for _, p in ipairs(SidePanel.panels) do
				SidePanel.updateElementsHeight(p)
			end
			return true
		else
			--print("    field:textinput returned false")
			return false
		end
	end

	-- iterate top-level elements
	for _, el in ipairs(self.elements) do
		if el.type == "field" and el.isEditing then
			--print("  attempting to textinput into field, keyRef="..tostring(el.keyRef))
			handled = processField(el)
			break -- only one field can be edited at a time per panel
		elseif el.type == "line" and el.elements then
			for _, child in ipairs(el.elements) do
				if child.type == "field" and child.isEditing then
					--print("    attempting to textinput into child field, keyRef="..tostring(child.keyRef))
					handled = processField(child)
					break
				end
			end
		end
		if handled then break end
	end

	if not handled then
		--print("  no editable field handled input in this panel")
	end
end





-- handle key presses for the panel
function SidePanel:keypressed(key)
	-- check if any field is being edited
	local isEditing = false
	for _, el in ipairs(self.elements) do
		if el.isEditing then
			isEditing = true
			break
		end
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

	-- pass keypress to elements and track content/height changes
	for _, el in ipairs(self.elements) do
		if el.keypressed then
			local oldH = el.h
			-- call keypressed, returns true if content changed
			local contentChanged = el:keypressed(key)

			-- if content changed, update all related fields across panels
			if contentChanged then
				SidePanel.updateFieldsContent(el)
				SidePanel.updateElementsHeight(self)
			end

			-- if height changed, recalc subsequent elements in this panel
			if el.h and oldH ~= el.h then
				self:recalculateElementsAfter(el)
			end
		end
	end
end





function SidePanel:toggleVisibility (  ) 
	self.animating = true
	self.animTime = 0
	self.animStart = self.visible
	self.targetVisible =  ( self.targetVisible == 1 )  and 0 or 1
end





function SidePanel:update ( dt ) 
	if self.animating then
		self.animTime = self.animTime + dt
		local t = math.min ( 1, self.animTime / self.animDuration ) 
		self.visible = self.animStart +  ( self.targetVisible - self.animStart )  * t
		if t >= 1 then
			self.animating = false
		end
	end
end



-- recursively draw highlight for hovered elements
local function drawHoverRecursive ( el ) 
	-- draw background if hovered
	if el.isHovered then
		love.graphics.setColor ( 0.35, 0.55, 0.85, 0.25 ) 
		love.graphics.rectangle ( "fill", el.x - 2, el.y - 2, el.w + 4, el.h + 4, 4 ) 
	end

	-- recurse into children if element is a line container
	if el.type == "line" and el.elements then
		for _, child in ipairs ( el.elements )  do
			drawHoverRecursive ( child ) 
		end
	end
end


function SidePanel:drawScrolled ( scrollY ) 
	love.graphics.push (  ) 
	love.graphics.translate ( 0, scrollY ) 

	-- first draw highlight backgrounds  ( under content ) 
	for _, el in ipairs ( self.elements )  do
		drawHoverRecursive ( el ) 
	end

	-- then draw actual elements
	for _, el in ipairs ( self.elements )  do
		el:draw (  ) 
	end

	love.graphics.pop (  ) 
end


function SidePanel:draw (  ) 
	love.graphics.push (  ) 

	local offsetX = 0
	if self.side == "left" then
		offsetX = -self.width *  ( 1 - self.visible ) 
	elseif self.side == "right" then
		offsetX = love.graphics.getWidth (  )  - self.width * self.visible
	end

	love.graphics.translate ( offsetX, 0 ) 

	-- draw background
	love.graphics.setColor ( 0.15, 0.15, 0.2, 0.95 ) 
	love.graphics.rectangle ( "fill", 0, 0, self.width, love.graphics.getHeight (  )  ) 

	self:drawScrolled ( -self.scrollY ) 

	love.graphics.pop (  ) 
end


function SidePanel:reset (  ) 
	self.elements = {}
	self.currentY = self.paddingY
	self.scrollY = 0
	self.maxScroll = 0
end

---------------------------------------------------------

-- update all panels
function SidePanel.updateAll(dt)
	for _, panel in ipairs(SidePanel.panels) do
		if panel.update then panel:update(dt) end
	end
end

-- draw all panels
function SidePanel.drawAll()
	for _, panel in ipairs(SidePanel.panels) do
		if panel.draw then panel:draw() end
	end
end

-- handle mousepressed for all panels
function SidePanel.mousepressedAll(x, y, button)
	for _, panel in ipairs(SidePanel.panels) do
		if panel.mousepressed then panel:mousepressed(x, y, button) end
	end
end

-- handle mousereleased for all panels
function SidePanel.mousereleasedAll(x, y, button)
	for _, panel in ipairs(SidePanel.panels) do
		if panel.mousereleased then panel:mousereleased(x, y, button) end
	end
end

-- handle mousemoved for all panels
function SidePanel.mousemovedAll(mx, my, dx, dy)
	for _, panel in ipairs(SidePanel.panels) do
		if panel.mousemoved then panel:mousemoved(mx, my, dx, dy) end
	end
end

-- handle wheelmoved for all panels
function SidePanel.wheelmovedAll(x, y)
	for _, panel in ipairs(SidePanel.panels) do
		if panel.wheelmoved then panel:wheelmoved(x, y) end
	end
end

-- handle textinput for all panels
function SidePanel.textinputAll(t)
	for _, panel in ipairs(SidePanel.panels) do
		if panel.textinput then panel:textinput(t) end
	end
end

-- handle keypressed for all panels
function SidePanel.keypressedAll(key)
	for _, panel in ipairs(SidePanel.panels) do
		if panel.keypressed then panel:keypressed(key) end
	end
end

return SidePanel