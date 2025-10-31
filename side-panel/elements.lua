-- elements.lua
-- base element classes for sidepanel

local utf8 = require("utf8")

-- helper function to get substring by character count (UTF-8 aware)
function utf8.sub(s, i, j)
	if not s then return "" end
	local len = utf8.len(s)
	if not len then return "" end

	i = i or 1
	j = j or len

	if i < 0 then i = len + i + 1 end
	if j < 0 then j = len + j + 1 end
	if i < 1 then i = 1 end
	if j > len then j = len end
	if i > j then return "" end

	local startByte = utf8.offset(s, i)
	if not startByte then return "" end

	local endByte = utf8.offset(s, j + 1)
	if endByte then
		return string.sub(s, startByte, endByte - 1)
	else
		return string.sub(s, startByte)
	end
end

-- wrap text into lines that fit within maxWidth using given font
local function wrapText(font, text, maxWidth)
	if not text or text == "" then return {""}, 0 end
	if not font or maxWidth == nil or maxWidth <= 0 then 
		return {text}, font and font:getWidth(text) or 0 
	end

	local lines = {}
	local maxLineWidth = 0

	local function splitLongWord(word)
		local parts = {}
		local cur = ""
		local pos = 1

		while pos do
			local nextPos = utf8.offset(word, 2, pos)
			local ch = word:sub(pos, (nextPos and nextPos - 1) or #word)

			if font:getWidth(cur .. ch) <= maxWidth then
				cur = cur .. ch
			else
				if cur == "" then
					table.insert(parts, ch)
				else
					table.insert(parts, cur)
					cur = ch
					if font:getWidth(cur) > maxWidth then
						table.insert(parts, cur)
						cur = ""
					end
				end
			end
			pos = nextPos
		end

		if cur ~= "" then table.insert(parts, cur) end
		return parts
	end

	local startPos = 1
	while true do
		local s, e = text:find("\n", startPos, true)
		local paragraph
		if s then
			paragraph = text:sub(startPos, s - 1)
			startPos = e + 1
		else
			paragraph = text:sub(startPos)
			startPos = nil
		end

		if paragraph == "" then
			table.insert(lines, "")
		else
			local current = ""
			for word in paragraph:gmatch("%S+") do
				local sep = (current == "") and "" or " "
				if font:getWidth(current .. sep .. word) <= maxWidth then
					current = current .. sep .. word
				else
					if current ~= "" then
						table.insert(lines, current)
						maxLineWidth = math.max(maxLineWidth, font:getWidth(current))
						current = ""
					end

					if font:getWidth(word) <= maxWidth then
						current = word
					else
						local parts = splitLongWord(word)
						for _, part in ipairs(parts) do
							if current == "" then
								current = part
							else
								if font:getWidth(current .. " " .. part) <= maxWidth then
									current = current .. " " .. part
								else
									table.insert(lines, current)
									maxLineWidth = math.max(maxLineWidth, font:getWidth(current))
									current = part
								end
							end
						end
					end
				end
			end

			if current ~= "" then
				table.insert(lines, current)
				maxLineWidth = math.max(maxLineWidth, font:getWidth(current))
			end
		end

		if not startPos then break end
	end

	return lines, maxLineWidth
end

-----------------------------------------------------------
-- BASE ELEMENT CLASS
-----------------------------------------------------------

local Element = {}
Element.__index = Element

function Element:new(instance)
--	local instance = setmetatable({}, self)
	setmetatable(instance, self)

	-- position and size
	instance.x = instance.x or 0
	instance.y = instance.y or 0
	instance.w = instance.w or 0
	instance.h = instance.h or 0

	-- default padding
	instance.paddingX = instance.paddingX or 4
	instance.paddingY = instance.paddingY or 4

	-- styling
	instance.bgColor = instance.bgColor or {0.2, 0.2, 0.25}
	instance.fgColor = instance.fgColor or {1, 1, 1}
	instance.borderColor = instance.borderColor or {0.3, 0.3, 0.35}

	-- font
	instance.font = instance.font or love.graphics.getFont()

	-- auto sizing flags
	instance.autoWidth = instance.autoWidth or false
	instance.autoHeight = instance.autoHeight or false

	return instance
end

function Element:calculateSize(availableWidth)
	-- override in child classes
	return self.w, self.h
end

function Element:draw()
	-- override in child classes
end

-----------------------------------------------------------
-- TEXT ELEMENT
-----------------------------------------------------------

local TextElement = setmetatable({}, {__index = Element})
TextElement.__index = TextElement

function TextElement:new(elConfig)
--	print ('elConfig.type', elConfig.type)
	local instance = Element.new(self, elConfig)
--	print ('instance.type', instance.type)

	-- store text and font
	instance.text = elConfig.text or ""
--    instance.text = elConfig.text or ""
	instance.lines = {}
	instance.lineHeight = instance.font:getHeight()

	-- if width is not given, calculate based on text and font
	if not elConfig.w or elConfig.w == 0 then
		local textWidth = instance.font:getWidth(instance.text)
		instance.w = textWidth + 2 * instance.paddingX
	end

	-- if height is not given, calculate from line height
	if not elConfig.h or elConfig.h == 0 then
		instance.h = instance.lineHeight + 2 * instance.paddingY
	end

	-- wrap text into lines if it exceeds width
	local contentWidth = instance.w - 2 * instance.paddingX
	instance.lines, _ = wrapText(instance.font, instance.text, contentWidth)

	-- recalc height based on lines
	instance.h = #instance.lines * instance.lineHeight + 2 * instance.paddingY

	return instance
end


function TextElement:calculateSize(availableWidth)

	self.lineHeight = self.font:getHeight()

	-- calculate content width
	local contentWidth = availableWidth - 2 * self.paddingX

	-- wrap text
	self.lines, _ = wrapText(self.font, self.text, contentWidth)

	-- calculate final size
	if self.autoWidth then
		local maxW = 0
		for _, line in ipairs(self.lines) do
			maxW = math.max(maxW, self.font:getWidth(line))
		end
		self.w = maxW + 2 * self.paddingX
	else
		self.w = availableWidth
	end

	self.h = #self.lines * self.lineHeight + 2 * self.paddingY

	return self.w, self.h
end

function TextElement:draw()
	love.graphics.setFont(self.font)
	love.graphics.setColor(self.fgColor)

	for i, line in ipairs(self.lines) do
		local lineY = self.y + (i - 1) * self.lineHeight + self.paddingY
		love.graphics.print(line, self.x + self.paddingX, lineY)
	end
end

-----------------------------------------------------------
-- HEADER ELEMENT
-----------------------------------------------------------

local HeaderElement = setmetatable({}, {__index = TextElement})
HeaderElement.__index = HeaderElement

function HeaderElement:new(config)
	local instance = TextElement.new(self, config)

	-- header specific defaults
	instance.paddingY = config.paddingY or 8
	instance.fgColor = config.fgColor or {0.8, 0.8, 0.9}
	instance.underlineColor = config.underlineColor or {0.4, 0.4, 0.5}
	instance.drawUnderline = config.drawUnderline ~= false

	return instance
end

function HeaderElement:draw()
	love.graphics.setFont(self.font)
	love.graphics.setColor(self.fgColor)
	love.graphics.print(self.text, self.x + self.paddingX, self.y + self.paddingY)

	if self.drawUnderline then
		love.graphics.setColor(self.underlineColor)
		local underlineY = self.y + self.h
		love.graphics.line(self.x, underlineY, self.x + self.w, underlineY)
	end
end

-----------------------------------------------------------
-- SEPARATOR ELEMENT
-----------------------------------------------------------

local SeparatorElement = setmetatable({}, {__index = Element})
SeparatorElement.__index = SeparatorElement

function SeparatorElement:new(config)
	local instance = Element.new(self, config)

	instance.isVertical = config.isVertical or false
	instance.thickness = config.thickness or 1
	instance.color = config.color or {0.4, 0.4, 0.5}

	-- for vertical: w is thickness, h is stretch
	-- for horizontal: w is stretch, h is thickness
	if instance.isVertical then
		instance.w = config.w or instance.thickness
		instance.h = config.h or 0
	else
		instance.w = config.w or 0
		instance.h = config.h or instance.thickness
	end

	return instance
end

function SeparatorElement:calculateSize(availableWidth)
	if not self.isVertical then
		self.w = availableWidth
	end
	return self.w, self.h
end

function SeparatorElement:draw()
	love.graphics.setColor(self.color)
	love.graphics.setLineWidth(self.thickness)

	if self.isVertical then
		-- vertical line
		local centerX = self.x + self.w / 2
		love.graphics.line(centerX, self.y, centerX, self.y + self.h)
	else
		-- horizontal line
		local centerY = self.y + self.h / 2
		love.graphics.line(self.x, centerY, self.x + self.w, centerY)
	end
end

-----------------------------------------------------------
-- FIELD ELEMENT (single line input)
-----------------------------------------------------------

local FieldElement = setmetatable({}, {__index = Element})
FieldElement.__index = FieldElement

--function FieldElement:new(config)
--	local instance = Element.new(self, config)

--	instance.label = config.label or ""
--	instance.value = config.value or ""
--	instance.isEditing = false
--	instance.isHovered = false
--	instance.cursorPos = 0

--	-- styling
--	instance.bgColor = config.bgColor or {0.2, 0.2, 0.25}
--	instance.bgColorHover = config.bgColorHover or {0.25, 0.25, 0.35}
--	instance.borderColor = config.borderColor or {0.3, 0.3, 0.35}
--	instance.borderColorActive = config.borderColorActive or {0.3, 0.5, 0.7}

--	-- default height
--	instance.h = config.h or 30

--	return instance
--end

function FieldElement:new(config)
	local instance = Element.new(self, config)

	instance.label = config.label or ""
	instance.value = config.value or ""
	instance.isEditing = false
	instance.isHovered = false
	instance.cursorPos = utf8.len(instance.value)

	-- data binding
	instance.tableRef = config.table
	instance.keyRef = config.key

	-- styling
	instance.bgColor = config.bgColor or {0.2, 0.2, 0.25}
	instance.bgColorHover = config.bgColorHover or {0.25, 0.25, 0.35}
	instance.borderColor = config.borderColor or {0.3, 0.3, 0.35}
	instance.borderColorActive = config.borderColorActive or {0.3, 0.5, 0.7}

	-- calculate base text height
	instance.lineHeight = instance.font:getHeight()

	-- set default height if not given
	if not config.h or config.h == 0 then
		instance.h = instance.lineHeight + 2 * instance.paddingY
	else
		instance.h = config.h
	end

	-- sync from table if exists
	if instance.tableRef and instance.keyRef then
		local v = instance.tableRef[instance.keyRef]
		if v ~= nil then instance.value = tostring(v) end
	end

	return instance
end



function FieldElement:calculateSize(availableWidth)
	self.w = availableWidth
	return self.w, self.h
end

function FieldElement:draw()
	-- draw background
	if self.isHovered then
		love.graphics.setColor(self.bgColorHover)
	else
		love.graphics.setColor(self.bgColor)
	end
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 3)

	-- draw border
	if self.isEditing then
		love.graphics.setColor(self.borderColorActive)
	else
		love.graphics.setColor(self.borderColor)
	end
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 3)

	-- draw text
	love.graphics.setColor(self.fgColor)
	love.graphics.setFont(self.font)
	love.graphics.print(self.value, self.x + self.paddingX, self.y + self.paddingY)

	-- draw cursor if editing
	if self.isEditing then
		local textBeforeCursor = utf8.sub(self.value, 1, self.cursorPos)
		local cursorX = self.x + self.paddingX + self.font:getWidth(textBeforeCursor)
		local cursorY = self.y + self.paddingY
		local blink = math.floor(love.timer.getTime() * 2) % 2 == 0
		if blink then
			love.graphics.setColor(1, 1, 1)
			love.graphics.line(cursorX, cursorY, cursorX, cursorY + self.font:getHeight())
		end
	end
end

function FieldElement:mousepressed(mx, my, button)
	if button == 1 then
		if mx >= self.x and mx <= self.x + self.w and 
		my >= self.y and my <= self.y + self.h then
			self.isEditing = true
			self.cursorPos = utf8.len(self.value)
			return true
		else
			self.isEditing = false
		end
	end
	return false
end

--function FieldElement:textinput(t)
--	if self.isEditing then
--		local before = utf8.sub(self.value, 1, self.cursorPos)
--		local after = utf8.sub(self.value, self.cursorPos + 1)
--		self.value = before .. t .. after
--		self.cursorPos = self.cursorPos + 1
--	end
--end

function FieldElement:textinput(t)
	if self.isEditing then
		local before = utf8.sub(self.value, 1, self.cursorPos)
		local after = utf8.sub(self.value, self.cursorPos + 1)
		self.value = before .. t .. after
		self.cursorPos = self.cursorPos + 1

		-- update bound table
		if self.tableRef and self.keyRef then
			self.tableRef[self.keyRef] = self.value
		end
	end
end

function FieldElement:keypressed(key)
	if not self.isEditing then return end

	if key == "backspace" and self.cursorPos > 0 then
		local before = utf8.sub(self.value, 1, self.cursorPos - 1)
		local after = utf8.sub(self.value, self.cursorPos + 1)
		self.value = before .. after
		self.cursorPos = self.cursorPos - 1
	elseif key == "delete" and self.cursorPos < utf8.len(self.value) then
		local before = utf8.sub(self.value, 1, self.cursorPos)
		local after = utf8.sub(self.value, self.cursorPos + 2)
		self.value = before .. after
	elseif key == "left" and self.cursorPos > 0 then
		self.cursorPos = self.cursorPos - 1
	elseif key == "right" and self.cursorPos < utf8.len(self.value) then
		self.cursorPos = self.cursorPos + 1
	elseif key == "home" then
		self.cursorPos = 0
	elseif key == "end" then
		self.cursorPos = utf8.len(self.value)
	elseif key == "return" or key == "escape" then
		self.isEditing = false
	end

	-- update bound table
	if self.tableRef and self.keyRef then
		self.tableRef[self.keyRef] = self.value
	end
end

-----------------------------------------------------------
-- MULTILINE FIELD ELEMENT
-----------------------------------------------------------

local MultilineFieldElement = setmetatable({}, {__index = FieldElement})
MultilineFieldElement.__index = MultilineFieldElement

function MultilineFieldElement:new(config)
	local instance = FieldElement.new(self, config)

	instance.lines = {}
	instance.minHeight = config.minHeight or 60

	return instance
end

function MultilineFieldElement:calculateSize(availableWidth)
	self.w = availableWidth

	local contentWidth = self.w - 2 * self.paddingX
	self.lines, _ = wrapText(self.font, self.value, contentWidth)

	local lineHeight = self.font:getHeight()
	self.h = math.max(self.minHeight, #self.lines * lineHeight + 2 * self.paddingY)

	return self.w, self.h
end

function MultilineFieldElement:textinput(t)
	if self.isEditing then
		local before = utf8.sub(self.value, 1, self.cursorPos)
		local after = utf8.sub(self.value, self.cursorPos + 1)
		self.value = before .. t .. after
		self.cursorPos = self.cursorPos + 1
		
		if self.tableRef and self.keyRef then
			self.tableRef[self.keyRef] = self.value
		end
		
		self:calculateSize(self.w)
	end
end

function MultilineFieldElement:keypressed(key)
	if not self.isEditing then return end
	
	local changed = false
	
	if key == "return" then
		local before = utf8.sub(self.value, 1, self.cursorPos)
		local after = utf8.sub(self.value, self.cursorPos + 1)
		self.value = before .. "\n" .. after
		self.cursorPos = self.cursorPos + 1
		changed = true
	elseif key == "backspace" and self.cursorPos > 0 then
		local before = utf8.sub(self.value, 1, self.cursorPos - 1)
		local after = utf8.sub(self.value, self.cursorPos + 1)
		self.value = before .. after
		self.cursorPos = self.cursorPos - 1
		changed = true
	elseif key == "delete" and self.cursorPos < utf8.len(self.value) then
		local before = utf8.sub(self.value, 1, self.cursorPos)
		local after = utf8.sub(self.value, self.cursorPos + 2)
		self.value = before .. after
		changed = true
	elseif key == "left" and self.cursorPos > 0 then
		self.cursorPos = self.cursorPos - 1
	elseif key == "right" and self.cursorPos < utf8.len(self.value) then
		self.cursorPos = self.cursorPos + 1
	elseif key == "home" then
		self.cursorPos = 0
	elseif key == "end" then
		self.cursorPos = utf8.len(self.value)
	elseif key == "escape" then
		self.isEditing = false
	end
	
	if changed then
		if self.tableRef and self.keyRef then
			self.tableRef[self.keyRef] = self.value
		end
		
		-- recalculate height and notify panel
		local oldH = self.h
		self:calculateSize(self.w)
		
		if oldH ~= self.h and self.panel then
			self.panel:recalculateElements()
		end
	end
end



function MultilineFieldElement:draw()
	if self.isHovered then
		love.graphics.setColor(self.bgColorHover)
	else
		love.graphics.setColor(self.bgColor)
	end
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h, 3)
	
	if self.isEditing then
		love.graphics.setColor(self.borderColorActive)
	else
		love.graphics.setColor(self.borderColor)
	end
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h, 3)
	
	love.graphics.setColor(self.fgColor)
	love.graphics.setFont(self.font)
	
	local lineHeight = self.font:getHeight()
	local contentWidth = self.w - 2 * self.paddingX
	
	-- split by newlines first
	local paragraphs = {}
	if self.value == "" then
		paragraphs = {""}
	else
		for line in (self.value .. "\n"):gmatch("([^\n]*)\n") do
			table.insert(paragraphs, line)
		end
	end
	
	-- draw and track cursor position
	local drawY = self.y + self.paddingY
	local cursorX, cursorY = 0, 0
	local charCount = 0
	local foundCursor = false
	
	for pIdx, paragraph in ipairs(paragraphs) do
		-- wrap this paragraph
		local wrappedLines = wrapText(self.font, paragraph, contentWidth)
		
		for wIdx, wline in ipairs(wrappedLines) do
			love.graphics.print(wline, self.x + self.paddingX, drawY)
			
			-- check if cursor is on this wrapped line
			if self.isEditing and not foundCursor then
				local lineLen = utf8.len(wline)
				if self.cursorPos >= charCount and self.cursorPos <= charCount + lineLen then
					local textBeforeCursor = utf8.sub(wline, 1, self.cursorPos - charCount)
					cursorX = self.font:getWidth(textBeforeCursor)
					cursorY = drawY
					foundCursor = true
				end
				charCount = charCount + lineLen
			else
				charCount = charCount + utf8.len(wline)
			end
			
			drawY = drawY + lineHeight
		end
		
		-- account for newline character between paragraphs
		if pIdx < #paragraphs then
			charCount = charCount + 1
			
			-- check if cursor is at the newline position
			if self.isEditing and not foundCursor and self.cursorPos == charCount - 1 then
				cursorX = self.font:getWidth(paragraphs[pIdx])
				cursorY = drawY - lineHeight
				foundCursor = true
			end
		end
	end
	
	-- draw cursor
	if self.isEditing then
		local blink = math.floor(love.timer.getTime() * 2) % 2 == 0
		if blink then
			love.graphics.setColor(1, 1, 1)
			love.graphics.line(
				self.x + self.paddingX + cursorX, cursorY,
				self.x + self.paddingX + cursorX, cursorY + lineHeight
			)
		end
	end
end

-----------------------------------------------------------
-- LINE ELEMENT (horizontal container)
-----------------------------------------------------------

local LineElement = setmetatable({}, {__index = Element})
LineElement.__index = LineElement

function LineElement:new(config)
	local instance = Element.new(self, config)

	instance.elements = config.elements or {}
	instance.spacing = config.spacing or 6

	return instance
end

function LineElement:calculateSize(availableWidth)
	self.w = availableWidth

	-- calculate total fixed width and find auto-width element
	local totalFixed = 0
	local autoElement = nil
	local elementCount = #self.elements

	for _, el in ipairs(self.elements) do
		if el.autoWidth then
			autoElement = el
		else
			local w, _ = el:calculateSize(0)
			totalFixed = totalFixed + w
		end
	end

	-- calculate spacing
	local totalSpacing = self.spacing * (elementCount - 1)

	-- distribute remaining width to auto element
	if autoElement then
		local remaining = availableWidth - totalFixed - totalSpacing
		autoElement.w = math.max(10, remaining)
	end

	-- recalculate all elements and find max height
	local maxHeight = 0
	local currentX = self.x

	for _, el in ipairs(self.elements) do
		el.x = currentX
		el.y = self.y

		local w, h = el:calculateSize(el.w or availableWidth)
		el.w = w
		el.h = h

		maxHeight = math.max(maxHeight, h)
		currentX = currentX + w + self.spacing
	end

	-- stretch vertical separators to line height
	for _, el in ipairs(self.elements) do
		if el.isVertical then
			el.h = maxHeight
		end
	end

	self.h = maxHeight

	return self.w, self.h
end

function LineElement:draw()
	for _, el in ipairs(self.elements) do
		el:draw()
	end
end

function LineElement:mousepressed(mx, my, button)
	for _, el in ipairs(self.elements) do
		if el.mousepressed and el:mousepressed(mx, my, button) then
			return true
		end
	end
	return false
end

function LineElement:textinput(t)
	for _, el in ipairs(self.elements) do
		if el.textinput then
			el:textinput(t)
		end
	end
end

function LineElement:keypressed(key)
	for _, el in ipairs(self.elements) do
		if el.keypressed then
			el:keypressed(key)
		end
	end
end

-----------------------------------------------------------
-- IMAGE ELEMENT
-----------------------------------------------------------

local ImageElement = setmetatable({}, {__index = Element})
ImageElement.__index = ImageElement

function ImageElement:new(config)
	local instance = Element.new(self, config)

	-- load image
	if config.img then
		instance.image = love.graphics.newImage(config.img)
	else
		error("[ImageElement] missing image file path")
	end

	-- image dimensions
	instance.imgW = instance.image:getWidth()
	instance.imgH = instance.image:getHeight()

	-- if width or height not given, use image size
	instance.w = config.w or instance.imgW
	instance.h = config.h or instance.imgH

	-- alignment options (optional)
	instance.align = config.align or "left"

	return instance
end

function ImageElement:calculateSize(availableWidth)
	-- stretch to full width, preserve aspect ratio
	local scale = availableWidth / self.imgW
	self.w = availableWidth
	self.h = self.imgH * scale
	return self.w, self.h
end


function ImageElement:draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.image, self.x, self.y)
end


-----------------------------------------------------------
-- EXPORT
-----------------------------------------------------------

return {
	Element = Element,
	TextElement = TextElement,
	HeaderElement = HeaderElement,
	SeparatorElement = SeparatorElement,
	FieldElement = FieldElement,
	MultilineFieldElement = MultilineFieldElement,
	LineElement = LineElement,
	ImageElement = ImageElement,
}