-- text-input-field.lua
-- standalone text input field module
-- https://github.com/darkfrei/love2d-lua-tests/tree/main/text-input-field
-- https://github.com/darkfrei/text-input-field/tree/main

local utf8 = require("utf8")

-- utf8-aware substring
function utf8.sub(s, i, j)
	if not s then return "" end
	local len = utf8.len(s) or 0
	i = i or 1
	j = j or len
	if i < 0 then i = len + i + 1 end
	if j < 0 then j = len + j + 1 end
	if i < 1 then i = 1 end
	if j > len then j = len end
	if i > j then return "" end
	local startByte = utf8.offset(s, i)
	local endByte = utf8.offset(s, j + 1)
	return string.sub(s, startByte, endByte and endByte - 1 or -1)
end

local TextInputField = {}
TextInputField.__index = TextInputField

-- builds visual wrapped lines with absolute character positions
local function getWrappedLinesWithStarts(font, textStr, maxWidth, maxIndent)
	if not textStr or textStr == "" then
		return {""}, {0}, {true}
	end

	local effectiveWidth = maxWidth - maxIndent
	local pos, lines, starts, isNewLine = 0, {}, {}, {}

	for rawLine in (textStr .. "\n"):gmatch("(.-)\n") do
		if rawLine == "" then
			table.insert(lines, "")
			table.insert(starts, pos)
			table.insert(isNewLine, true)
		else
			local _, wrapped = font:getWrap(rawLine, effectiveWidth)
			for wrapIdx, w in ipairs(wrapped) do
				table.insert(lines, w)
				table.insert(starts, pos)
				table.insert(isNewLine, wrapIdx == 1)
				pos = pos + utf8.len(w)
			end
		end
		pos = pos + 1
	end
	if #textStr > 0 then pos = pos - 1 end
	return #lines > 0 and lines or {""}, 
		#starts > 0 and starts or {0},
		#isNewLine > 0 and isNewLine or {true}
end

-- creates new text input field instance
function TextInputField:new(config)
	local instance = setmetatable({}, self)

	instance.x = config.x or 0
	instance.y = config.y or 0
	instance.w = config.w or 200
	instance.h = 0
	instance.paddingX = config.paddingX or 5
	instance.paddingY = config.paddingY or 5

	instance.boundTable = config.boundTable
	instance.boundKey = config.boundKey

	if instance.boundTable and instance.boundKey then
		instance.text = tostring(instance.boundTable[instance.boundKey] or "")
	else
		instance.text = config.text or ""
	end
	
	instance.cursorPos = config.cursorPos or 0
	instance.desiredCursorX = nil
	instance.isActive = false

	instance.font = config.font or love.graphics.getFont()
	instance.lineHeight = instance.font:getHeight()
	instance.minLines = config.minLines or 1
	instance.maxLines = config.maxLines or nil
	instance.bgColor = config.bgColor or {0.2, 0.2, 0.25}
	instance.borderColor = config.borderColor or {0.3, 0.5, 0.7}
	instance.textColor = config.textColor or {1, 1, 1}
	instance.cursorColor = config.cursorColor or {1, 1, 1}
	instance.blinkSpeed = config.blinkSpeed or 3

	instance.selAnchor = nil
	instance.selStart = nil
	instance.selEnd = nil
	instance.isDragging = false

	instance.onFocus = config.onFocus
	instance.onBlur = config.onBlur

	instance.newLineIndent = config.newLineIndent or ""
	instance.wrapIndent = config.wrapIndent or " "

	instance.singleLine = config.singleLine or false
	instance.numeric = config.numeric or (config.numericOnly and true) or nil
	instance.min = config.min
	instance.max = config.max

	instance.newLineIndentWidth = instance.font:getWidth(instance.newLineIndent)
	instance.wrapIndentWidth = instance.font:getWidth(instance.wrapIndent)

	instance.scrollLineOffset = 0

	instance.cachedLines = nil
	instance.cachedStarts = nil
	instance.cachedIsNewLine = nil
	instance.cacheValid = false

	if not instance.numeric then
		instance:updateCache()
	end
	instance:updateHeight()

	return instance
end

-- finalizes numeric text when field loses focus
function TextInputField:finalizeNumericText()
	if not self.numeric then
		return
	end
	
	self.text = tostring(self.text)
	local normalizedText = self.text:gsub(",", ".")
	local num = tonumber(normalizedText)

	if not num then
		self.text = ""
		return
	end

	if not self:isWithinRange(num) then
		if self.min then num = math.max(self.min, num) end
		if self.max then num = math.min(self.max, num) end
	end

	if self.numeric == "integer" or self.numeric == "int" then
		num = math.floor(num + 0.5)
	end

	self.text = tostring(num)
	self.cacheValid = false
end

-- sets field active/inactive state with callbacks
function TextInputField:setActive(active)
	if self.isActive == active then
		return
	end

	self.isActive = active

	if not active then
		self:finalizeNumericText()
	end

	if active then
		if self.onFocus then
			self:onFocus()
		end
	else
		self:clearSelection()
		self.selAnchor = nil
		if self.onBlur then
			self:onBlur()
		end
	end
end

-- recalculates field height based on wrapped text
function TextInputField:updateHeight()
	local allLines = self:getWrappedLines()
	local totalLines = #allLines

	local visibleLines
	if self.maxLines then
		visibleLines = math.min(totalLines, self.maxLines)
	else
		visibleLines = totalLines
	end

	local lineCount = math.max(visibleLines, self.minLines)
	self.h = lineCount * self.lineHeight + 2 * self.paddingY
end

-- adjusts scroll offset to keep cursor visible
function TextInputField:ensureCursorVisible()
	if not self.maxLines then return end

	local allLines, allStarts = self:getWrappedLines()

	local cursorLineIndex = 1
	for i = 1, #allLines do
		local startPos = allStarts[i]
		local len = utf8.len(allLines[i])
		if self.cursorPos >= startPos and self.cursorPos <= startPos + len then
			cursorLineIndex = i
			break
		end
	end

	local firstVisibleLine = self.scrollLineOffset + 1
	local lastVisibleLine = self.scrollLineOffset + self.maxLines

	if cursorLineIndex < firstVisibleLine then
		self.scrollLineOffset = cursorLineIndex - 1
	elseif cursorLineIndex > lastVisibleLine then
		self.scrollLineOffset = cursorLineIndex - self.maxLines
	end

	local maxScroll = math.max(0, #allLines - self.maxLines)
	self.scrollLineOffset = math.max(0, math.min(self.scrollLineOffset, maxScroll))
end

-- moves cursor up or down one visual line
function TextInputField:moveCursorVertical(direction)
	local allLines, allStarts, allIsNewLine = self:getWrappedLines()

	local currentIdx = 1
	for i = 1, #allLines do
		local startPos = allStarts[i]
		local len = utf8.len(allLines[i])
		if self.cursorPos >= startPos and self.cursorPos <= startPos + len then
			currentIdx = i
			break
		end
	end

	local targetIdx = currentIdx + direction
	if targetIdx < 1 or targetIdx > #allLines then
		return
	end

	local currentIndent = allIsNewLine[currentIdx] and self.newLineIndentWidth or self.wrapIndentWidth
	local targetIndent = allIsNewLine[targetIdx] and self.newLineIndentWidth or self.wrapIndentWidth

	if not self.desiredCursorX then
		local lineStartPos = allStarts[currentIdx]
		local charsInLineToCursor = math.max(self.cursorPos - lineStartPos, 0)
		local lineText = allLines[currentIdx] or ""
		local subToCursor = utf8.sub(lineText, 1, charsInLineToCursor)
		local textWidth = self.font:getWidth(subToCursor)
		self.desiredCursorX = currentIndent + textWidth
	end

	local targetText = allLines[targetIdx] or ""
	local targetStart = allStarts[targetIdx]
	local targetLen = utf8.len(targetText) or 0
	local targetRelativeX = math.max(0, self.desiredCursorX - targetIndent)

	local newCursorPosInLine = 0
	local prevWidth = 0

	for i = 1, targetLen do
		local subtext = utf8.sub(targetText, 1, i)
		local w = self.font:getWidth(subtext)

		if w >= targetRelativeX then
			local distPrev = math.abs(targetRelativeX - prevWidth)
			local distCurr = math.abs(w - targetRelativeX)

			if distPrev <= distCurr then
				newCursorPosInLine = i - 1
			else
				newCursorPosInLine = i
			end
			break
		end
		prevWidth = w
		newCursorPosInLine = i
	end

	self.cursorPos = targetStart + newCursorPosInLine
	self:ensureCursorVisible()
end

-- handles mouse click to activate field and position cursor
function TextInputField:mousepressed(mx, my, button)
	if button ~= 1 then return false end

	if mx < self.x or mx > self.x + self.w or my < self.y or my > self.y + self.h then
		self:setActive(false)
		self:clearSelection()
		return false
	end

	self:setActive(true)
	self:clearSelection()

	local allLines, allStarts, allIsNewLine = self:getWrappedLines()

	local localY = my - (self.y + self.paddingY)
	local visibleLineIndex = math.floor(localY / self.lineHeight) + 1

	local lineIndex = visibleLineIndex + self.scrollLineOffset
	lineIndex = math.max(1, math.min(lineIndex, #allLines))

	local lineText = allLines[lineIndex] or ""
	local lineStartPos = allStarts[lineIndex] or 0

	local indent = allIsNewLine[lineIndex] and self.newLineIndentWidth or self.wrapIndentWidth
	local localX = math.max(0, mx - (self.x + self.paddingX + indent))

	local len = utf8.len(lineText)
	local prevWidth = 0
	local cursorInLine = 0
	for i = 1, len do
		local sub = utf8.sub(lineText, 1, i)
		local w = self.font:getWidth(sub)
		if localX <= w then
			if (localX - prevWidth) <= (w - localX) then
				cursorInLine = i - 1
			else
				cursorInLine = i
			end
			break
		end
		prevWidth = w
		cursorInLine = i
	end

	self.cursorPos = lineStartPos + cursorInLine

	local textWidth = self.font:getWidth(utf8.sub(lineText, 1, cursorInLine))
	self.desiredCursorX = indent + textWidth

	self.selAnchor = self.cursorPos
	self.selStart = self.cursorPos
	self.selEnd = self.cursorPos
	self.isDragging = true

	return true
end

-- handles mouse drag to update selection
function TextInputField:mousemoved(mx, my, dx, dy)
	if not self.isDragging then return end

	local allLines, allStarts, allIsNewLine = self:getWrappedLines()
	local localY = my - (self.y + self.paddingY)
	local visibleLineIndex = math.floor(localY / self.lineHeight) + 1

	local lineIndex = visibleLineIndex + self.scrollLineOffset
	lineIndex = math.max(1, math.min(lineIndex, #allLines))

	local lineText = allLines[lineIndex] or ""
	local lineStartPos = allStarts[lineIndex] or 0

	local indent = allIsNewLine[lineIndex] and self.newLineIndentWidth or self.wrapIndentWidth
	local localX = math.max(0, mx - (self.x + self.paddingX + indent))

	local len = utf8.len(lineText)
	local prevWidth = 0
	local cursorInLine = 0
	for i = 1, len do
		local sub = utf8.sub(lineText, 1, i)
		local w = self.font:getWidth(sub)
		if localX <= w then
			if (localX - prevWidth) <= (w - localX) then
				cursorInLine = i - 1
			else
				cursorInLine = i
			end
			break
		end
		prevWidth = w
		cursorInLine = i
	end

	self.cursorPos = lineStartPos + cursorInLine
	self.selStart = self.selAnchor
	self.selEnd = self.cursorPos
end

-- handles mouse release to end drag selection
function TextInputField:mousereleased(mx, my, button)
	if button ~= 1 then return false end
	if self.isDragging then
		self.isDragging = false
		return true
	end
	return false
end

-- checks if character is allowed based on field settings
function TextInputField:isCharAllowed(char)
	if self.singleLine and char == "\n" then
		return false
	end

	if self.numeric then
		if type(self.text) ~= "string" then
			self.text = tostring(self.text)
		end

		if char:match("[%d%.,%-]") then
			if char == "-" then
				if self.cursorPos ~= 0 then
					return false
				end
				if self.text:find("%-") then
					return false
				end
			elseif char == "." or char == "," then
				if self.text:find("[%.,]") then
					return false
				end
			end
			return true
		else
			return false
		end
	end

	return true
end

-- updates bound table value from current text
function TextInputField:updateBoundValue()
	if not self.boundTable or not self.boundKey then return end

	if not self.numeric then
		self.boundTable[self.boundKey] = self.text
		return
	end

	if self.text == "" or self.text == "-" or self.text == "-." then
		self.boundTable[self.boundKey] = nil
		return
	end

	local normalizedText = self.text:gsub(",", ".")
	local num = tonumber(normalizedText)

	if num and self:isWithinRange(num) then
		if self.numeric == "integer" or self.numeric == "int" then
			self.boundTable[self.boundKey] = math.floor(num)
		else
			self.boundTable[self.boundKey] = num
		end
	end
end

-- syncs text from bound table value
function TextInputField:syncFromBoundValue()
	if self.boundTable and self.boundKey then
		local value = self.boundTable[self.boundKey]
		local newText = tostring(value or "")
		if newText ~= self.text then
			self.text = newText
			self:invalidateCache()
			self:updateHeight()
			local maxPos = utf8.len(self.text)
			if self.cursorPos > maxPos then
				self.cursorPos = maxPos
				self:updateDesiredX()
			end
		end
	end
end

-- updates cached wrapped lines data
function TextInputField:updateCache()
	local maxWidth = self.w - 2 * self.paddingX
	local maxIndent = math.max(self.newLineIndentWidth, self.wrapIndentWidth)

	local text = self.text
	if type(text) ~= "string" then
		text = tostring(text)
	end

	self.cachedLines, self.cachedStarts, self.cachedIsNewLine = 
		getWrappedLinesWithStarts(self.font, text, maxWidth, maxIndent)
	self.cacheValid = true
end

-- invalidates cache
function TextInputField:invalidateCache()
	self.cacheValid = false
end

-- gets wrapped lines data using cache
function TextInputField:getWrappedLines()
	if not self.cacheValid then
		self:updateCache()
	end
	return self.cachedLines, self.cachedStarts, self.cachedIsNewLine
end

-- replaces text between utf8 indices
function TextInputField:replaceText(startIdx, endIdx, replacement)
	local before = utf8.sub(self.text, 1, startIdx - 1)
	local after = utf8.sub(self.text, endIdx + 1)
	self.text = before .. (replacement or "") .. after
	self:invalidateCache()
	self:updateBoundValue()
end

-- moves cursor to start of line or text
function TextInputField:moveCursorHome()
	local allLines, allStarts = self:getWrappedLines()

	local currentIdx = 1
	for i = 1, #allLines do
		local startPos = allStarts[i]
		local len = utf8.len(allLines[i])
		if self.cursorPos >= startPos and self.cursorPos <= startPos + len then
			currentIdx = i
			break
		end
	end

	local lineStart = allStarts[currentIdx] or 0
	if self.cursorPos == lineStart then
		self.cursorPos = 0
	else
		self.cursorPos = lineStart
	end
	self:updateDesiredX()
end

-- moves cursor to end of line or text
function TextInputField:moveCursorEnd()
	local allLines, allStarts = self:getWrappedLines()

	local currentIdx = 1
	for i = 1, #allLines do
		local startPos = allStarts[i]
		local len = utf8.len(allLines[i])
		if self.cursorPos >= startPos and self.cursorPos <= startPos + len then
			currentIdx = i
			break
		end
	end

	local lineStart = allStarts[currentIdx] or 0
	local lineLen = utf8.len(allLines[currentIdx] or "")
	local lineEnd = lineStart + lineLen
	if self.cursorPos == lineEnd then
		self.cursorPos = utf8.len(self.text)
	else
		self.cursorPos = lineEnd
	end
	self:updateDesiredX()
end

-- starts continuous key repeat
function TextInputField:startKeyRepeat(key, delay, interval)
	self.repeatKey = key
	self.repeatTimer = 0
	self.repeatStarted = false
	self.repeatDelay = delay or 0.4
	self.repeatInterval = interval or 0.05
end

-- stops key repeat
function TextInputField:stopKeyRepeat(key)
	if key == self.repeatKey then
		self.repeatKey = nil
		self.repeatTimer = 0
		self.repeatStarted = false
	end
end

-- clears current selection
function TextInputField:clearSelection()
	self.selAnchor = nil
	self.selStart = nil
	self.selEnd = nil
	self.isDragging = false
end

-- replaces selected text with replacement string
function TextInputField:replaceSelection(replacement)
	local s, e = self:getSelectionRange()
	if not s or not e then return false end

	local before = utf8.sub(self.text, 1, s - 1)
	local after = utf8.sub(self.text, e + 1)
	self.text = before .. (replacement or "") .. after

	self.cursorPos = (s - 1) + (replacement and utf8.len(replacement) or 0)
	self:clearSelection()
	self:invalidateCache()
	self:updateBoundValue()
	return true
end

-- handles key release to stop repeat
function TextInputField:keyreleased(key, scancode)
	if not self.isActive then return false end
	self:stopKeyRepeat(key)
	return true
end

-- draws blinking cursor
local function drawBlinkingCursor(self, allLines, allStarts, allIsNewLine)
	if self.isActive then
		local blink = math.floor(love.timer.getTime() * self.blinkSpeed) % 2 == 0
		if blink then
			local cursorLineIndex = 1
			for i = 1, #allLines do
				local startPos = allStarts[i]
				local len = utf8.len(allLines[i])
				if self.cursorPos >= startPos and self.cursorPos <= startPos + len then
					cursorLineIndex = i
					break
				end
			end

			local visibleLineIndex = cursorLineIndex - self.scrollLineOffset
			if visibleLineIndex < 1 or (self.maxLines and visibleLineIndex > self.maxLines) then
				return
			end

			local lineStartPos = allStarts[cursorLineIndex]
			local charsInLineToCursor = math.max(self.cursorPos - lineStartPos, 0)
			local lineText = allLines[cursorLineIndex] or ""
			local subToCursor = utf8.sub(lineText, 1, charsInLineToCursor)

			local indentX = allIsNewLine[cursorLineIndex] and self.newLineIndentWidth or self.wrapIndentWidth
			local cursorX = self.x + self.paddingX + indentX + self.font:getWidth(subToCursor)
			local cursorY = self.y + self.paddingY + (visibleLineIndex - 1) * self.lineHeight

			love.graphics.setColor(self.cursorColor)
			love.graphics.line(cursorX, cursorY, cursorX, cursorY + self.lineHeight)
		end
	end
end

-- draws selection highlight
local function drawSelection(self, allLines, allStarts, allIsNewLine)
	if self.selStart and self.selEnd and self.selStart ~= self.selEnd then
		local s1, s2 = math.min(self.selStart, self.selEnd), math.max(self.selStart, self.selEnd)

		local startLine = self.scrollLineOffset + 1
		local endLine = self.maxLines and (self.scrollLineOffset + self.maxLines) or #allLines

		for i = startLine, math.min(endLine, #allLines) do
			local startPos = allStarts[i]
			local len = utf8.len(allLines[i])
			local lineEnd = startPos + len
			if s2 >= startPos and s1 <= lineEnd then
				local selStartInLine = math.max(s1 - startPos, 0)
				local selEndInLine = math.min(s2 - startPos, len)

				local preSel = utf8.sub(allLines[i], 1, selStartInLine)
				local selText = utf8.sub(allLines[i], selStartInLine + 1, selEndInLine)

				local indentX = allIsNewLine[i] and self.newLineIndentWidth or self.wrapIndentWidth
				local x1 = self.x + self.paddingX + indentX + self.font:getWidth(preSel)
				local wSel = self.font:getWidth(selText)

				local visibleLineIndex = i - self.scrollLineOffset
				local y1 = self.y + self.paddingY + (visibleLineIndex - 1) * self.lineHeight

				love.graphics.setColor(0.25, 0.4, 0.8, 0.4)
				love.graphics.rectangle("fill", x1, y1, wSel, self.lineHeight)
			end
		end
	end
end

-- draws indent symbols and text lines
local function drawIndentSymbols(self, allLines, allStarts, allIsNewLine)
	love.graphics.setFont(self.font)

	local startLine = self.scrollLineOffset + 1
	local endLine = self.maxLines and (self.scrollLineOffset + self.maxLines) or #allLines

	local drawY = self.y + self.paddingY
	for i = startLine, math.min(endLine, #allLines) do
		local indent = allIsNewLine[i] and self.newLineIndent or self.wrapIndent
		local indentX = allIsNewLine[i] and self.newLineIndentWidth or self.wrapIndentWidth

		if indent ~= "" then
			love.graphics.setColor(self.textColor[1] * 0.4, self.textColor[2] * 0.4, self.textColor[3] * 0.4)
			love.graphics.print(indent, self.x + self.paddingX, drawY)
		end

		love.graphics.setColor(self.textColor)
		love.graphics.print(allLines[i], self.x + self.paddingX + indentX, drawY)

		drawY = drawY + self.lineHeight
	end
end

-- renders the text input field
function TextInputField:draw()
	local allLines, allStarts, allIsNewLine = self:getWrappedLines()

	love.graphics.setColor(self.bgColor)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

	love.graphics.setColor(self.borderColor)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

	drawSelection(self, allLines, allStarts, allIsNewLine)
	drawIndentSymbols(self, allLines, allStarts, allIsNewLine)
	drawBlinkingCursor(self, allLines, allStarts, allIsNewLine)
end

-- performs single key action
function TextInputField:performKeyAction(key)
	if key == "backspace" then
		local s, e = self:getSelectionRange()
		if s and e then
			self:replaceSelection(nil)
		else
			if self.cursorPos > 0 then
				local before = utf8.sub(self.text, 1, self.cursorPos - 1)
				local after = utf8.sub(self.text, self.cursorPos + 1)
				self.text = before .. after
				self.cursorPos = self.cursorPos - 1
				self:invalidateCache()
				self:updateBoundValue()
			end
		end
		self:updateDesiredX()
		self:updateHeight()
		self:ensureCursorVisible()

	elseif key == "delete" then
		local s, e = self:getSelectionRange()
		if s and e then
			self:replaceSelection(nil)
		else
			if self.cursorPos < utf8.len(self.text) then
				self:replaceText(self.cursorPos + 1, self.cursorPos + 1, "")
			end
		end
		self:updateDesiredX()
		self:updateHeight()
		self:ensureCursorVisible()

	elseif key == "left" then
		if self.cursorPos > 0 then
			self.cursorPos = self.cursorPos - 1
			self:updateDesiredX()
			self:ensureCursorVisible()
		end

	elseif key == "right" then
		if self.cursorPos < utf8.len(self.text) then
			self.cursorPos = self.cursorPos + 1
			self:updateDesiredX()
			self:ensureCursorVisible()
		end

	elseif key == "up" then
		self:moveCursorVertical(-1)

	elseif key == "down" then
		self:moveCursorVertical(1)
	end
end

-- handles key press with shortcuts and repeat
function TextInputField:keypressed(key, scancode)
	if not self.isActive then return false end

	local hasSelection = self.selStart and self.selEnd and self.selStart ~= self.selEnd
	local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")
	local shift = love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift")

	local handled = false

	if ctrl and shift then
		-- ctrl+shift combinations (reserved)
	elseif ctrl and not shift then
		if key == "a" then
			self.selAnchor = 0
			self.selStart = 0
			self.selEnd = utf8.len(self.text)
			return true
		elseif key == "c" then
			if hasSelection then
				local s, e = self:getSelectionRange()
				local selectedText = utf8.sub(self.text, s, e)
				love.system.setClipboardText(selectedText)
			end
			return true
		elseif key == "v" then
			local clipText = love.system.getClipboardText()
			if clipText and clipText ~= "" then
				local validText = ""
				for _, char in utf8.codes(clipText) do
					local charStr = utf8.char(char)
					if self:isCharAllowed(charStr) then
						validText = validText .. charStr
					end
				end

				if validText ~= "" then
					local testText
					if hasSelection then
						local s, e = self:getSelectionRange()
						local before = utf8.sub(self.text, 1, s - 1)
						local after = utf8.sub(self.text, e + 1)
						testText = before .. validText .. after
					else
						local before = utf8.sub(self.text, 1, self.cursorPos)
						local after = utf8.sub(self.text, self.cursorPos + 1)
						testText = before .. validText .. after
					end

					if self:isValidNumber(testText) then
						if hasSelection then
							self:replaceSelection(validText)
						else
							local before = utf8.sub(self.text, 1, self.cursorPos)
							local after = utf8.sub(self.text, self.cursorPos + 1)
							self.text = before .. validText .. after
							self.cursorPos = self.cursorPos + utf8.len(validText)
							self:invalidateCache()
						end
						self:updateDesiredX()
						self:updateHeight()
						self:updateBoundValue()
					end
				end
			end
			return true
		elseif key == "x" then
			if hasSelection then
				local s, e = self:getSelectionRange()
				
	local selectedText = utf8.sub(self.text, s, e)
				love.system.setClipboardText(selectedText)
				self:replaceSelection(nil)
				self:updateDesiredX()
				self:updateHeight()
			end
			return true
		end

	elseif shift and not ctrl then
		if key == "left" then
			if not self.selAnchor then
				self.selAnchor = self.cursorPos
			end
			if self.cursorPos > 0 then
				self.cursorPos = self.cursorPos - 1
			end
			self.selStart = self.selAnchor
			self.selEnd = self.cursorPos
			self:updateDesiredX()
			self:ensureCursorVisible()
			self:startKeyRepeat("left")
			handled = true

		elseif key == "right" then
			if not self.selAnchor then
				self.selAnchor = self.cursorPos
			end
			if self.cursorPos < utf8.len(self.text) then
				self.cursorPos = self.cursorPos + 1
			end
			self.selStart = self.selAnchor
			self.selEnd = self.cursorPos
			self:updateDesiredX()
			self:ensureCursorVisible()
			self:startKeyRepeat("right")
			handled = true

		elseif key == "up" then
			if not self.selAnchor then
				self.selAnchor = self.cursorPos
			end
			self:moveCursorVertical(-1)
			self.selStart = self.selAnchor
			self.selEnd = self.cursorPos
			self:startKeyRepeat("up")
			handled = true

		elseif key == "down" then
			if not self.selAnchor then
				self.selAnchor = self.cursorPos
			end
			self:moveCursorVertical(1)
			self.selStart = self.selAnchor
			self.selEnd = self.cursorPos
			self:startKeyRepeat("down")
			handled = true
		end

	else
		if self.selAnchor then
			self.cursorPos = math.max(self.selAnchor, self.cursorPos)
			self.selAnchor = nil
		end

		if key == "backspace" then
			self:performKeyAction("backspace")
			self:startKeyRepeat("backspace")
			handled = true

		elseif key == "delete" then
			self:performKeyAction("delete")
			self:startKeyRepeat("delete")
			handled = true

		elseif key == "left" then
			if hasSelection then
				local s = math.min(self.selStart, self.selEnd)
				self.cursorPos = s
				self:clearSelection()
				self:updateDesiredX()
			else
				self:performKeyAction("left")
				self:startKeyRepeat("left")
			end
			handled = true

		elseif key == "right" then
			if hasSelection then
				local e = math.max(self.selStart, self.selEnd)
				self.cursorPos = e
				self:clearSelection()
				self:updateDesiredX()
			else
				self:performKeyAction("right")
				self:startKeyRepeat("right")
			end
			handled = true

		elseif key == "up" then
			self:performKeyAction("up")
			self:clearSelection()
			self:startKeyRepeat("up")
			handled = true

		elseif key == "down" then
			self:performKeyAction("down")
			self:clearSelection()
			self:startKeyRepeat("down")
			handled = true

		elseif key == "return" then
			if not self.singleLine then
				if hasSelection then
					self:replaceSelection("\n")
				else
					local before = utf8.sub(self.text, 1, self.cursorPos)
					local after = utf8.sub(self.text, self.cursorPos + 1)
					self.text = before .. "\n" .. after
					self.cursorPos = self.cursorPos + 1
					self:invalidateCache()
					self:updateBoundValue()
				end
				self:updateDesiredX()
				self:updateHeight()
				self:clearSelection()
				self:ensureCursorVisible()
				handled = true
			end

		elseif key == "tab" then
			if hasSelection then
				self:replaceSelection("\t")
			else
				local before = utf8.sub(self.text, 1, self.cursorPos)
				local after = utf8.sub(self.text, self.cursorPos + 1)
				self.text = before .. "\t" .. after
				self.cursorPos = self.cursorPos + 1
				self:invalidateCache()
				self:updateBoundValue()
			end
			self:updateDesiredX()
			self:updateHeight()
			self:ensureCursorVisible()
			handled = true

		elseif key == "home" then
			self:moveCursorHome()
			self:clearSelection()
			handled = true

		elseif key == "end" then
			self:moveCursorEnd()
			self:clearSelection()
			handled = true
		end
	end

	return handled
end

-- handles key repeat in update loop
function TextInputField:update(dt)
	if not self.isActive or not self.repeatKey then return end

	self.repeatTimer = self.repeatTimer + dt
	if not self.repeatStarted then
		if self.repeatTimer >= self.repeatDelay then
			self.repeatStarted = true
			self.repeatTimer = 0
			self:performKeyAction(self.repeatKey)
		end
	else
		if self.repeatTimer >= self.repeatInterval then
			self.repeatTimer = 0
			self:performKeyAction(self.repeatKey)
		end
	end
end

-- handles text input event
function TextInputField:textinput(t)
	if not self.isActive then return false end

	if t == "kp-" then t = "-" end

	if self.numeric then
		t = t:gsub(",", ".")
	end

	for _, code in utf8.codes(t) do
		local char = utf8.char(code)
		if not self:isCharAllowed(char) then
			return false
		end
	end

	local s, e = self:getSelectionRange()
	local newText

	if s and e then
		local before = utf8.sub(self.text, 1, s - 1)
		local after = utf8.sub(self.text, e + 1)
		newText = before .. t .. after
	else
		local before = utf8.sub(self.text, 1, self.cursorPos)
		local after = utf8.sub(self.text, self.cursorPos + 1)
		newText = before .. t .. after
	end

	if self.numeric and not self:isValidNumber(newText) then
		return false
	end

	if s and e then
		local before = utf8.sub(self.text, 1, s - 1)
		local after = utf8.sub(self.text, e + 1)
		self.text = before .. t .. after
		self.cursorPos = (s - 1) + utf8.len(t)
		self:clearSelection()
	else
		local before = utf8.sub(self.text, 1, self.cursorPos)
		local after = utf8.sub(self.text, self.cursorPos + 1)
		self.text = before .. t .. after
		self.cursorPos = self.cursorPos + utf8.len(t)
	end

	self:invalidateCache()
	self:updateDesiredX()
	self:updateHeight()
	self:updateBoundValue()
	self:ensureCursorVisible()
	return true
end

-- returns normalized selection range or nil
function TextInputField:getSelectionRange()
	if not self.selStart or not self.selEnd then
		return nil
	end

	local a, b = self.selStart, self.selEnd

	if a == b then
		return nil
	end

	local s, e
	if a < b then
		s = a + 1
		e = b
	else
		s = b + 1
		e = a
	end

	return s, e
end

-- updates desired cursor x position
function TextInputField:updateDesiredX()
	local allLines, allStarts, allIsNewLine = self:getWrappedLines()

	local idx = 1
	for i = 1, #allLines do
		local startPos = allStarts[i]
		local len = utf8.len(allLines[i])
		if self.cursorPos >= startPos and self.cursorPos <= startPos + len then
			idx = i
			break
		end
	end

	local lineStartPos = allStarts[idx]
	local charsInLineToCursor = math.max(self.cursorPos - lineStartPos, 0)
	local lineText = allLines[idx] or ""
	local subToCursor = utf8.sub(lineText, 1, charsInLineToCursor)

	local indent = allIsNewLine[idx] and self.newLineIndentWidth or self.wrapIndentWidth
	local textWidth = self.font:getWidth(subToCursor)
	self.desiredCursorX = indent + textWidth
end

-- checks if number is within allowed range
function TextInputField:isWithinRange(value)
	if not self.numeric then return true end
	if type(value) ~= "number" then return false end

	if self.min and value < self.min then return false end
	if self.max and value > self.max then return false end
	return true
end

-- validates if text matches numeric field constraints
function TextInputField:isValidNumber(text)
	if not self.numeric then return true end

	if text == "" or text == "-" or text == "." or text == "-." then
		return true
	end

	local normalized = text:gsub(",", ".")

	if self.numeric == "integer" or self.numeric == "int" then
		if normalized:match("^%-?%d*$") then
			local hasDigits = normalized:match("%d")
			if hasDigits then
				local num = tonumber(normalized)
				if not num then return false end
				if self.min and num < self.min then return false end
				if self.max and num > self.max then return false end
			end
			return true
		end
		return false
	end

	if normalized:match("^%-?%d*%.?%d*$") then
		local hasDigits = normalized:match("%d")
		if hasDigits then
			local num = tonumber(normalized)
			if num then
				if self.min and num < self.min then return false end
				if self.max and num > self.max then return false end
			end
		end
		return true
	end

	return false
end

--return TextInputField			

------------------------------------------------------------------------
------------------------------------------------------------------------
------------------------------------------------------------------------
--[[

================ quick reference ================

utf8.sub(s, i, j) > substring (utf8-aware)
getWrappedLinesWithStarts(font, text, w) > lines, starts, isNewLine

TextInputField:new(config) > new TextInputField instance
TextInputField:setActive(active) > nil
TextInputField:updateHeight() > nil
TextInputField:ensureCursorVisible() > nil
TextInputField:moveCursorVertical(dir) > nil

TextInputField:mousepressed(mx, my, btn) > bool
TextInputField:mousemoved(mx, my) > nil
TextInputField:mousereleased(mx, my, btn) > bool

TextInputField:isCharAllowed(char) > bool
TextInputField:updateBoundValue() > nil
TextInputField:syncFromBoundValue() > nil

TextInputField:updateCache() > nil
TextInputField:invalidateCache() > nil
TextInputField:getWrappedLines() > lines, starts, isNewLine

TextInputField:replaceText(s, e, repl) > nil
TextInputField:replaceSelection(repl) > bool
TextInputField:clearSelection() > nil
TextInputField:getSelectionRange(debug) > (startIdx, endIdx) or nil

TextInputField:moveCursorHome() > nil
TextInputField:moveCursorEnd() > nil

TextInputField:startKeyRepeat(key) > nil
TextInputField:stopKeyRepeat(key) > nil

TextInputField:performKeyAction(key,dbg) > nil
TextInputField:keypressed(key, scan) > bool
TextInputField:keyreleased(key, scan) > bool
TextInputField:update(dt) > nil
TextInputField:textinput(t) > bool

TextInputField:updateDesiredX() > nil

TextInputField:isWithinRange(value) > bool
TextInputField:isValidNumber(text) > bool

TextInputField:draw() > nil
]]--


return TextInputField
