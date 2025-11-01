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
	if not text or text == "" then 
		--print("[wrapText] empty text, returning single empty line")
		return {""}, 0 
	end
	if not font or maxWidth == nil or maxWidth <= 0 then 
		--print("[wrapText] invalid font or maxWidth, returning full text as single line")
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
				end
			end
			pos = nextPos
		end
		if cur ~= "" then table.insert(parts, cur) end
		--print("[wrapText] splitLongWord:", word, "->", table.concat(parts, "|"))
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

		--print("[wrapText] paragraph:", paragraph)

		if paragraph == "" then
			table.insert(lines, "")
			--print("[wrapText] empty paragraph -> added empty line")
		else
			local current = ""
			for word, sep in paragraph:gmatch("(%S+)(%s*)") do
				local token = word .. sep -- include trailing spaces
				--print("  [wrapText] token:", token)
				if font:getWidth(current .. token) <= maxWidth then
					current = current .. token
					--print("    appended to current line ->", current)
				else
					if current ~= "" then
						table.insert(lines, current)
						maxLineWidth = math.max(maxLineWidth, font:getWidth(current))
						--print("    line full, added:", current)
						current = ""
					end
					if font:getWidth(token) <= maxWidth then
						current = token
						--print("    token fits on new line ->", current)
					else
						local parts = splitLongWord(token)
						for _, part in ipairs(parts) do
							if current == "" then
								current = part
							else
								if font:getWidth(current .. part) <= maxWidth then
									current = current .. part
								else
									table.insert(lines, current)
									maxLineWidth = math.max(maxLineWidth, font:getWidth(current))
									--print("    split word, added line:", current)
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
				--print("  added final line of paragraph:", current)
			end
		end

		if not startPos then break end
	end

	--print("[wrapText] finished, total lines:", #lines, "maxLineWidth:", maxLineWidth)
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
	instance.x = instance.x or nil
	instance.y = instance.y or nil
	instance.w = instance.w or nil
	instance.h = instance.h or nil

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
--	--print ('elConfig.type', elConfig.type)
	local instance = Element.new(self, elConfig)
--	--print ('instance.type', instance.type)

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
-- FIELD ELEMENT (single and multiline input)
-----------------------------------------------------------

local FieldElement = setmetatable({}, {__index = Element})
FieldElement.__index = FieldElement


function FieldElement:new(config)
	local instance = Element.new(self, config)

	instance.isEditing = false
	instance.isHovered = false
	instance.multiline = config.multiline or false

	-- data binding (required)
	instance.tableRef = config.table
	instance.keyRef = config.key

	-- default paddings
	instance.paddingX = config.paddingX or 6
	instance.paddingY = config.paddingY or 4

	-- styling
	instance.bgColor = config.bgColor or {0.2, 0.2, 0.25}
	instance.bgColorHover = config.bgColorHover or {0.25, 0.25, 0.35}
	instance.borderColor = config.borderColor or {0.3, 0.3, 0.35}
	instance.borderColorActive = config.borderColorActive or {0.3, 0.5, 0.7}

	instance.lineHeight = instance.font:getHeight()
	--print ('instance.lineHeight', instance.lineHeight)

-- test, removed:
--	local h = config.h or (2 * instance.lineHeight + 2 * instance.paddingY)
--	instance.h = h



	if instance.multiline then
		instance.minHeight = (3 * instance.lineHeight + 2 * instance.paddingY)
		--print ('field instance.minHeight', instance.minHeight)
--		instance.h = instance.minHeight
--	else
--		-- single-line fields get full text height + paddings
--		instance.h = (config.h and config.h > 0) and config.h or (instance.lineHeight + 2 * instance.paddingY)
	end

	return instance
end



-- recalc field height for any text, single or multiline
function FieldElement:calculateSize(availableWidth)
	if self.fixedW then
		self.w = self.fixedW
	else
		self.w = availableWidth
	end

	local value = tostring(self.tableRef and self.tableRef[self.keyRef] or "")
	local contentWidth = self.w - 2 * self.paddingX

	-- always wrap text
	local lines, _ = wrapText(self.font, value, contentWidth)
	local lineCount = math.max(1, #lines)

	-- recalc height based on wrapped lines
	self.h = lineCount * self.lineHeight + 2 * self.paddingY

	-- enforce minimum height if set
	if self.minHeight then
		self.h = math.max(self.h, self.minHeight)
	end

	return self.w, self.h
end




function FieldElement:drawSingleLine(value)
	local contentWidth = self.w - 2 * self.paddingX
	local lines, _ = wrapText(self.font, value, contentWidth)

	local drawY = self.y + self.paddingY
	for _, line in ipairs(lines) do
		love.graphics.print(line, self.x + self.paddingX, drawY)
		drawY = drawY + self.lineHeight
	end

	-- draw cursor
	if self.isEditing then
		local blink = math.floor(love.timer.getTime() * 2) % 2 == 0
		if blink then
			love.graphics.setColor(1, 1, 1)
			love.graphics.line(
				self.x + self.paddingX + self.cursorX,
				self.cursorY,
				self.x + self.paddingX + self.cursorX,
				self.cursorY + self.lineHeight
			)
		end
	end
end

function FieldElement:drawMultiline(value)
	local contentWidth = self.w - 2 * self.paddingX

	-- split value into paragraphs by newline
	local paragraphs = {}
	if value == "" then
		paragraphs = {""}
	else
		for line in (value .. "\n"):gmatch("([^\n]*)\n") do
			table.insert(paragraphs, line)
		end
	end

	local drawY = self.y + self.paddingY

	for _, paragraph in ipairs(paragraphs) do
		local wrappedLines = wrapText(self.font, paragraph, contentWidth)

		for _, wline in ipairs(wrappedLines) do
			love.graphics.print(wline, self.x + self.paddingX, drawY)
			drawY = drawY + self.lineHeight
		end
	end

	-- draw cursor at precalculated position
	if self.isEditing then
		local blink = math.floor(love.timer.getTime() * 2) % 2 == 0
		if blink then
			love.graphics.setColor(1, 1, 1)
			love.graphics.line(
				self.x + self.paddingX + (self.cursorX or 0),
				self.cursorY or (self.y + self.paddingY),
				self.x + self.paddingX + (self.cursorX or 0),
				(self.cursorY or (self.y + self.paddingY)) + self.lineHeight
			)
		end
	end
end


-- recalc wrapped lines for current text and store them
function FieldElement:updateWrappedLines()
	local value = tostring(self.tableRef and self.tableRef[self.keyRef] or "")
	local contentWidth = self.w - 2 * self.paddingX
	self.wrappedLines, self.maxLineWidth = wrapText(self.font, value, contentWidth)
end


-- unified draw for wrapped text (used for single-line and multiline fields)
function FieldElement:drawWrapped()
	if not self.wrappedLines then
		self:updateWrappedLines()
	end

	local drawY = self.y + self.paddingY
	for _, line in ipairs(self.wrappedLines) do
		love.graphics.print(line, self.x + self.paddingX, drawY)
		drawY = drawY + self.lineHeight
	end

	-- draw cursor
	if self.isEditing then
		local blink = math.floor(love.timer.getTime() * 2) % 2 == 0
		if blink then
			love.graphics.setColor(1, 1, 1)
			love.graphics.line(
				self.x + self.paddingX + (self.cursorX or 0),
				self.cursorY or (self.y + self.paddingY),
				self.x + self.paddingX + (self.cursorX or 0),
				(self.cursorY or (self.y + self.paddingY)) + self.lineHeight
			)
		end
	end
end



function FieldElement:draw()
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

	local value = tostring(self.tableRef and self.tableRef[self.keyRef] or "")
	self:drawWrapped(value)
end

-- recalc cursor metrics after text or cursor movement using pre-wrapped lines
function FieldElement:updateCursorMetrics()
	local value = tostring(self.tableRef and self.tableRef[self.keyRef] or "")
	local contentWidth = self.w - 2 * self.paddingX

	-- update wrapped lines
	self:updateWrappedLines()
	local lines = self.wrappedLines

	local charCount = 0
	local cursorX, cursorY = 0, self.y + self.paddingY
	local found = false

	--print("=== updateCursorMetrics ===")
	--print("full value:", string.format("%q", value))
	--print("cursorPos:\t", self.cursorPos)
	--print("paragraphs count:", #lines)

	for lineIdx, lineText in ipairs(lines) do
		local lineLen = utf8.len(lineText)
		--print(string.format("line %d: '%s' (chars %d)", lineIdx, lineText, lineLen))

		for i = 0, lineLen do
			-- position before character i
			if charCount == self.cursorPos then
				local textBefore = (i == 0) and "" or utf8.sub(lineText, 1, i)
				cursorX = self.font:getWidth(textBefore)
				cursorY = self.y + self.paddingY + (lineIdx - 1) * self.lineHeight
				found = true
				--print(string.format("  cursor in line: localPos=%d, cursorX=%.1f, cursorY=%.1f", i, cursorX, cursorY))
				break
			end
			charCount = charCount + 1
		end

		if found then break end
	end

	if not found then
		cursorX = 0
		cursorY = self.y + self.paddingY
		--print("cursor not found, fallback to start")
	end

	self.cursorX = cursorX
	self.cursorY = cursorY
	--print(string.format("final cursorX=%.1f cursorY=%.1f", self.cursorX, self.cursorY))
	--print("===========================\n")
end



--function FieldElement:textinput(t)
--	if self.isEditing and self.tableRef and self.keyRef then
--		local value = tostring(self.tableRef[self.keyRef])
--		local before = utf8.sub(value, 1, self.cursorPos)
--		local after = utf8.sub(value, self.cursorPos + 1)
--		self.tableRef[self.keyRef] = before .. t .. after
--		self.cursorPos = self.cursorPos + 1

--		-- update field size and cursor metrics
----		if self.multiline then
--		self:calculateSize(self.w)
----		end
--		--print ('\n'..'FieldElement:textinput')
--		self:updateCursorMetrics()

--		-- debug log
--		--print(string.format(
----				"[FieldElement:textinput] len=%d cursor=%d cursorX=%.1f cursorY=%.1f",
----				utf8.len(self.tableRef[self.keyRef]), self.cursorPos, self.cursorX, self.cursorY
----			))
--	end
--end

-- field text input
function FieldElement:textinput(t)
	if not self.isEditing or not self.tableRef or not self.keyRef then
		return false
	end

	local value = tostring(self.tableRef[self.keyRef])
	local before = utf8.sub(value, 1, self.cursorPos)
	local after = utf8.sub(value, self.cursorPos + 1)
	self.tableRef[self.keyRef] = before .. t .. after
	self.cursorPos = self.cursorPos + #t

	self:calculateSize(self.w)
	self:updateWrappedLines()
	self:updateCursorMetrics()

	return true  -- indicate that value changed
end





-- field element key handling
function FieldElement:keypressed(key)
	if not self.isEditing or not self.tableRef or not self.keyRef then return end

	local value = tostring(self.tableRef[self.keyRef])
	local changed = false

	if key == "return" then
		if self.multiline then
			local before = utf8.sub(value, 1, self.cursorPos)
			local after = utf8.sub(value, self.cursorPos + 1)
			self.tableRef[self.keyRef] = before .. "\n" .. after
			self.cursorPos = self.cursorPos + 1
			changed = true
		else
			self.isEditing = false
		end
	elseif key == "backspace" and self.cursorPos > 0 then
		local before = utf8.sub(value, 1, self.cursorPos - 1)
		local after = utf8.sub(value, self.cursorPos + 1)
		self.tableRef[self.keyRef] = before .. after
		self.cursorPos = self.cursorPos - 1
		changed = true
	elseif key == "delete" and self.cursorPos < utf8.len(value) then
		local before = utf8.sub(value, 1, self.cursorPos)
		local after = utf8.sub(value, self.cursorPos + 2)
		self.tableRef[self.keyRef] = before .. after
		changed = true
	elseif key == "left" and self.cursorPos > 0 then
		self.cursorPos = self.cursorPos - 1
	elseif key == "right" and self.cursorPos < utf8.len(value) then
		self.cursorPos = self.cursorPos + 1
	elseif key == "home" then
		local before = utf8.sub(value, 1, self.cursorPos)
		local lastNewline = before:match(".*()\n")
		self.cursorPos = lastNewline or 0
	elseif key == "end" then
		local after = utf8.sub(value, self.cursorPos + 1)
		local nextNewline = after:find("\n")
		if nextNewline then
			self.cursorPos = self.cursorPos + nextNewline - 1
		else
			self.cursorPos = utf8.len(value)
		end
	elseif key == "up" or key == "down" then
		-- handle vertical movement (unchanged, omitted here for brevity)
	end

	-- recalc height if multiline and content changed
	if changed and self.multiline then
		self:calculateSize(self.w)
	end

	-- recalc cursor metrics
	self:updateCursorMetrics()

	-- return true if content changed, so SidePanel can propagate
	return changed
end



function FieldElement:mousepressed(mx, my, button)
	if button == 1 then
		if mx >= self.x and mx <= self.x + self.w and 
		my >= self.y and my <= self.y + self.h then
			self.isEditing = true
			local value = tostring(self.tableRef and self.tableRef[self.keyRef] or "")
			-- move cursor to the end of text
			self.cursorPos = utf8.len(value)
			-- recalc cursor metrics
			--print ('\n'..'FieldElement:mousepressed')
			self:updateCursorMetrics()
			return true
		else
			self.isEditing = false
		end
	end
	return false
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
	if config.filename then
		instance.image = love.graphics.newImage(config.filename)
	else
		error("[ImageElement] missing image file path")
	end

	return instance
end

function ImageElement:calculateSize(availableWidth)
	local imgW = self.image:getWidth()
	local imgH = self.image:getHeight()
	local scale = availableWidth / imgW
	--print ('scale', scale)
	if scale < 1 then
		self.w = availableWidth
		self.h = imgH * scale
		self.scale = scale
		return self.w, self.h
	else
		self.w = imgW
		self.h = imgH
		self.scale = nil
		return self.w, self.h
	end
end


function ImageElement:draw()
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(self.image, self.x, self.y, 0, self.scale)
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
--	MultilineFieldElement = MultilineFieldElement,
	LineElement = LineElement,
	ImageElement = ImageElement,
}