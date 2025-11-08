-- text-input-field.lua
-- standalone text input field module

local utf8 = require("utf8")

-- utf8-aware substring
-- returns substring of s from i to j (inclusive) using utf8 codepoints instead of bytes
-- handles negative indices and out-of-range values safely
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

-- helper: build visual wrapped lines and absolute start indices
-- receives: font (love.graphics font), textStr (string), maxWidth (number), maxIndent (max indent width)
-- returns: 
-- lines - table of wrapped visible lines as strings
-- starts - table of absolute starting character positions for each visual line
-- isNewLine - table of booleans indicating if line starts after \n
local function getWrappedLinesWithStarts(font, textStr, maxWidth, maxIndent)
	if not textStr or textStr == "" then
		return {""}, {0}, {true}
	end
	
	-- reduce available width by maximum indent to ensure text doesn't overflow
	local effectiveWidth = maxWidth - maxIndent
	
	local pos, lines, starts, isNewLine = 0, {}, {}, {}
	local paragraphIndex = 0
	
	for rawLine in (textStr .. "\n"):gmatch("(.-)\n") do
		paragraphIndex = paragraphIndex + 1
		if rawLine == "" then
			table.insert(lines, "")
			table.insert(starts, pos)
			table.insert(isNewLine, true)
		else
			local _, wrapped = font:getWrap(rawLine, effectiveWidth)
			for wrapIdx, w in ipairs(wrapped) do
				table.insert(lines, w)
				table.insert(starts, pos)
				table.insert(isNewLine, wrapIdx == 1) -- first wrap is new line, rest are wraps
				pos = pos + utf8.len(w)
			end
		end
		pos = pos + 1 -- count newline
	end
	if #textStr > 0 then pos = pos - 1 end
	return #lines > 0 and lines or {""}, 
	       #starts > 0 and starts or {0},
	       #isNewLine > 0 and isNewLine or {true}
end


-----------------------------------------------------------------------
-----------------------------------------------------------------------
-----------------------------------------------------------------------

-- creates new text input field instance
-- receives: config table with position, size, colors, font, etc.
-- returns: new TextInputField object
function TextInputField:new(config)
	local instance = setmetatable({}, self)

	-- position and size setup
	instance.x = config.x or 0
	instance.y = config.y or 0
	instance.w = config.w or 200
	instance.h = 0
	instance.paddingX = config.paddingX or 5
	instance.paddingY = config.paddingY or 5

	-- text state
	instance.text = config.text or ""
	instance.cursorPos = config.cursorPos or 0 -- utf8 position (not byte index)
	instance.desiredCursorX = nil -- keeps horizontal x position when moving vertically

	-- visual parameters
	instance.font = config.font or love.graphics.getFont()
	instance.lineHeight = instance.font:getHeight()
	instance.minLines = config.minLines or 3
	instance.bgColor = config.bgColor or {0.2, 0.2, 0.25}
	instance.borderColor = config.borderColor or {0.3, 0.5, 0.7}
	instance.textColor = config.textColor or {1, 1, 1}
	instance.cursorColor = config.cursorColor or {1, 1, 1}
	instance.blinkSpeed = config.blinkSpeed or 3

	-- selection state
	instance.selAnchor = nil -- utf8 index where selection started (or nil)
	instance.selStart = nil -- utf8 index selection start (inclusive)
	instance.selEnd = nil -- utf8 index selection end (inclusive)
	instance.isDragging = false

-- indentation settings
-- indent after \n (e.g. "")
	instance.newLineIndent = config.newLineIndent or ""
	-- indent for wrapped lines (e.g. "")
	instance.wrapIndent = config.wrapIndent or " "

	-- precompute widths
	instance.newLineIndentWidth = instance.font:getWidth(instance.newLineIndent)
	instance.wrapIndentWidth = instance.font:getWidth(instance.wrapIndent)

	-- input focus state
	instance.isActive = false

	-- cached wrapped lines data (updated when text changes)
	instance.cachedLines = nil
	instance.cachedStarts = nil
	instance.cachedIsNewLine = nil
	instance.cacheValid = false

	instance:updateCache()
	instance:updateHeight()

	return instance
end

-- updates cached wrapped lines data
-- call this whenever text or width changes
function TextInputField:updateCache()
	local maxWidth = self.w - 2 * self.paddingX
	-- use maximum indent width to ensure nothing overflows
	local maxIndent = math.max(self.newLineIndentWidth, self.wrapIndentWidth)
	
	self.cachedLines, self.cachedStarts, self.cachedIsNewLine = 
		getWrappedLinesWithStarts(self.font, self.text, maxWidth, maxIndent)
	self.cacheValid = true
end

-- invalidates cache (call when text changes)
function TextInputField:invalidateCache()
	self.cacheValid = false
end

-- gets wrapped lines data (uses cache)
function TextInputField:getWrappedLines()
	if not self.cacheValid then
		self:updateCache()
	end
	return self.cachedLines, self.cachedStarts, self.cachedIsNewLine
end

-- recalculates total field height based on wrapped text
-- receives: none
-- returns: nothing, updates self.h
--function TextInputField:updateHeight()
--	local maxWidth = self.w - 2 * self.paddingX
--	local totalLines = 0

--	-- wrap each paragraph line and count total number of visual lines
--	for rawLine in (self.text .. "\n"):gmatch("(.-)\n") do
--		local _, wrapped = self.font:getWrap(rawLine, maxWidth)
--		totalLines = totalLines + #wrapped
--	end

--	local lineCount = math.max(totalLines, self.minLines)
--	self.h = lineCount * self.lineHeight + 2 * self.paddingY
--end

-- recalculates total field height based on wrapped text
-- receives: none
-- returns: nothing, updates self.h
function TextInputField:updateHeight()
	local allLines = self:getWrappedLines()
	local lineCount = math.max(#allLines, self.minLines)
	self.h = lineCount * self.lineHeight + 2 * self.paddingY
end


-- replaces text between startIdx and endIdx (utf8 indices) with replacement string
-- receives: startIdx (int), endIdx (int), replacement (string or nil)
-- returns: nothing, updates self.text
function TextInputField:replaceText(startIdx, endIdx, replacement)
	local before = utf8.sub(self.text, 1, startIdx - 1)
	local after = utf8.sub(self.text, endIdx + 1)
	self.text = before .. (replacement or "") .. after
	self:invalidateCache()
end


-- move cursor to start of line or start of text if already at start
function TextInputField:moveCursorHome()
	local allLines, allStarts, allIsNewLine = self:getWrappedLines()

	-- find current visual line
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
		-- already at start of line → go to start of entire text
		self.cursorPos = 0
	else
		self.cursorPos = lineStart
	end
	self:updateDesiredX()
end


function TextInputField:moveCursorEnd()
	local allLines, allStarts, allIsNewLine = self:getWrappedLines()

	-- find current visual line
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
		-- already at end of line → go to end of entire text
		self.cursorPos = utf8.len(self.text)
	else
		self.cursorPos = lineEnd
	end
	self:updateDesiredX()
end



-- start continuous key repeat
function TextInputField:startKeyRepeat(key, delay, interval)
	self.repeatKey = key
	self.repeatTimer = 0
	self.repeatStarted = false
	self.repeatDelay = delay or 0.4
	self.repeatInterval = interval or 0.05
end

-- stop key repeat
function TextInputField:stopKeyRepeat(key)
	if key == self.repeatKey then
		self.repeatKey = nil
		self.repeatTimer = 0
		self.repeatStarted = false
	end
end



-- clear current selection
function TextInputField:clearSelection()
	self.selAnchor = nil
	self.selStart = nil
	self.selEnd = nil
end

-- if selection exists, replace it; otherwise behave like normal replace
function TextInputField:replaceSelection(replacement)
	local s, e = self:getSelectionRange()
	if not s or not e then return false end

	-- s and e are already 1-based inclusive indices from getSelectionRange
	local before = utf8.sub(self.text, 1, s - 1)
	local after = utf8.sub(self.text, e + 1)
	self.text = before .. (replacement or "") .. after

	-- move cursor to insertion point (s-1 because s is 1-based, cursor is 0-based)
	self.cursorPos = (s - 1) + (replacement and utf8.len(replacement) or 0)
	self:clearSelection()
	self:invalidateCache()
	return true
end




function TextInputField:keyreleased(key)
	if not self.isActive then return false end
	self:stopKeyRepeat(key)
	return true
end





function TextInputField:mousereleased(mx, my, button)
	if button ~= 1 then return false end
	if self.isDragging then
		self.isDragging = false
		-- selection remains (selStart/selEnd) until cleared by other actions
		return true
	end
	return false
end



-- perform single backspace deletion (used by both keypress and repeat)
function TextInputField:performBackspace()
	if self.cursorPos > 0 then
		self:replaceText(self.cursorPos, self.cursorPos, "")
		self.cursorPos = self.cursorPos - 1
		self:updateDesiredX()
		self:updateHeight()
	end
end



local function drawBlincingCursor (self, allLines, allStarts, allIsNewLine)
	-- draw blinking cursor
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

			local lineStartPos = allStarts[cursorLineIndex]
			local charsInLineToCursor = math.max(self.cursorPos - lineStartPos, 0)
			local lineText = allLines[cursorLineIndex] or ""
			local subToCursor = utf8.sub(lineText, 1, charsInLineToCursor)

			local indentX = allIsNewLine[cursorLineIndex] and self.newLineIndentWidth or self.wrapIndentWidth
			local cursorX = self.x + self.paddingX + indentX + self.font:getWidth(subToCursor)
			local cursorY = self.y + self.paddingY + (cursorLineIndex - 1) * self.lineHeight

			love.graphics.setColor(self.cursorColor)
			love.graphics.line(cursorX, cursorY, cursorX, cursorY + self.lineHeight)
		end
	end
end


local function drawSelection(self, allLines, allStarts, allIsNewLine)
	-- draw selection
	if self.selStart and self.selEnd and self.selStart ~= self.selEnd then
		local s1, s2 = math.min(self.selStart, self.selEnd), math.max(self.selStart, self.selEnd)
		for i = 1, #allLines do
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
				local y1 = self.y + self.paddingY + (i - 1) * self.lineHeight

				love.graphics.setColor(0.25, 0.4, 0.8, 0.4)
				love.graphics.rectangle("fill", x1, y1, wSel, self.lineHeight)
			end
		end
	end
end

local function drawIndentSymbols (self, allLines, allStarts, allIsNewLine)
	-- draw indent symbols and text lines
	love.graphics.setFont(self.font)
	local drawY = self.y + self.paddingY

	for i = 1, #allLines do
		local indent = allIsNewLine[i] and self.newLineIndent or self.wrapIndent
		local indentX = allIsNewLine[i] and self.newLineIndentWidth or self.wrapIndentWidth

		-- draw indent symbol with dimmed color
		if indent ~= "" then
			love.graphics.setColor(self.textColor[1] * 0.4, self.textColor[2] * 0.4, self.textColor[3] * 0.4)
			love.graphics.print(indent, self.x + self.paddingX, drawY)
		end

		-- draw text line with normal color
		love.graphics.setColor(self.textColor)
		love.graphics.print(allLines[i], self.x + self.paddingX + indentX, drawY)

		drawY = drawY + self.lineHeight
	end
end

function TextInputField:draw()
	local allLines, allStarts, allIsNewLine =  self:getWrappedLines()

	-- draw background
	love.graphics.setColor(self.bgColor)
	love.graphics.rectangle("fill", self.x, self.y, self.w, self.h)

	-- draw border
	love.graphics.setColor(self.borderColor)
	love.graphics.rectangle("line", self.x, self.y, self.w, self.h)

	-- draw selection
	drawSelection(self, allLines, allStarts, allIsNewLine)

	-- draw indent symbols and text lines
	drawIndentSymbols (self, allLines, allStarts, allIsNewLine)

-- draw blinking cursor
	drawBlincingCursor (self, allLines, allStarts, allIsNewLine)
end


-- perform single action based on key (used by both keypress and repeat)
function TextInputField:performKeyAction(key)
	if key == "backspace" then
		local s, e = self:getSelectionRange()
		if s and e and s ~= e then
			self:replaceSelection(nil)
		else
			if self.cursorPos > 0 then
				local before = utf8.sub(self.text, 1, self.cursorPos - 1)
				local after = utf8.sub(self.text, self.cursorPos + 1)
				self.text = before .. after
				self.cursorPos = self.cursorPos - 1
				self:invalidateCache()
			end
		end
		self:updateDesiredX()
		self:updateHeight()
	elseif key == "delete" then
		local s, e = self:getSelectionRange()
		if s and e and s ~= e then
			self:replaceSelection(nil)
		elseif self.cursorPos < utf8.len(self.text) then
			self:replaceText(self.cursorPos + 1, self.cursorPos + 1, "")
		end
		self:updateDesiredX()
		self:updateHeight()
	elseif key == "left" then
		if self.cursorPos > 0 then
			self.cursorPos = self.cursorPos - 1
			self:updateDesiredX()
		end
	elseif key == "right" then
		if self.cursorPos < utf8.len(self.text) then
			self.cursorPos = self.cursorPos + 1
			self:updateDesiredX()
		end
	elseif key == "up" then
		self:moveCursorVertical(-1)
	elseif key == "down" then
		self:moveCursorVertical(1)
	end
end

-- handle keypress (supports continuous repeat and shortcuts)
function TextInputField:keypressed(key)
	if not self.isActive then return false end
	local hasSelection = self.selStart and self.selEnd and self.selStart ~= self.selEnd
	local ctrl = love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")

	local handled = false

	-- ctrl shortcuts
	if ctrl then
		if key == "a" then
			-- select all
			self.selAnchor = 0
			self.selStart = 0
			self.selEnd = utf8.len(self.text)
			return true
		elseif key == "c" then
			-- copy
			if hasSelection then
				local s, e = self:getSelectionRange()
				local selectedText = utf8.sub(self.text, s, e)
				love.system.setClipboardText(selectedText)
			end
			return true
		elseif key == "v" then
			-- paste
			local clipText = love.system.getClipboardText()
			if clipText and clipText ~= "" then
				if hasSelection then
					self:replaceSelection(clipText)
				else
					local before = utf8.sub(self.text, 1, self.cursorPos)
					local after = utf8.sub(self.text, self.cursorPos + 1)
					self.text = before .. clipText .. after
					self.cursorPos = self.cursorPos + utf8.len(clipText)
					self:invalidateCache()
				end
				self:updateDesiredX()
				self:updateHeight()
			end
			return true
		elseif key == "x" then
			-- cut
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
		if hasSelection then
			self:replaceSelection("\n")
		else
			local before = utf8.sub(self.text, 1, self.cursorPos)
			local after = utf8.sub(self.text, self.cursorPos + 1)
			self.text = before .. "\n" .. after
			self.cursorPos = self.cursorPos + 1
			self:invalidateCache()
		end
		self:updateDesiredX()
		self:updateHeight()
		self:clearSelection()
		handled = true

	elseif key == "tab" then
		if hasSelection then
			self:replaceSelection("\t")
		else
			local before = utf8.sub(self.text, 1, self.cursorPos)
			local after = utf8.sub(self.text, self.cursorPos + 1)
			self.text = before .. "\t" .. after
			self.cursorPos = self.cursorPos + 1
			self:invalidateCache()
		end
		self:updateDesiredX()
		self:updateHeight()
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

	return handled
end

-- handle key repeat in update loop
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

---------------------------------------------

-- handles text input event from love.textinput
function TextInputField:textinput(t)
	if not self.isActive then return false end
	if self:replaceSelection(t) then
		-- selection replaced
	else
		local before = utf8.sub(self.text, 1, self.cursorPos)
		local after = utf8.sub(self.text, self.cursorPos + 1)
		self.text = before .. t .. after
		self.cursorPos = self.cursorPos + utf8.len(t)
	end
	self:invalidateCache()
	self:updateDesiredX()
	self:updateHeight()
	return true
end


-- returns selection range normalized (start <= end) or nil when no selection
function TextInputField:getSelectionRange()
	-- returns startIndex (inclusive, 1-based), endIndex (inclusive, 1-based)
	if not self.selStart or not self.selEnd then return nil end
	local a, b = self.selStart, self.selEnd
	-- if start == end, there's no selection
	if a == b then return nil end

	-- convert from 0-based cursor positions to 1-based string indices
	local s, e
	if a <= b then
		s, e = a + 1, b
	else
		s, e = b + 1, a
	end

--	print(string.format("getSelectionRange: cursorPos %d..%d -> stringIdx %d..%d", 
--		math.min(a,b), math.max(a,b), s, e))

	return s, e
end

function TextInputField:mousemoved(mx, my, dx, dy)
	-- update selection when dragging
	if not self.isDragging then return end

	local allLines, allStarts, allIsNewLine = self:getWrappedLines()
	local localY = my - (self.y + self.paddingY)
	local lineIndex = math.max(1, math.min(math.floor(localY / self.lineHeight) + 1, #allLines))
	local lineText = allLines[lineIndex] or ""
	local lineStartPos = allStarts[lineIndex] or 0

	-- apply correct indent based on line type
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


-- moves cursor up or down one visual line
function TextInputField:moveCursorVertical(direction)
	local allLines, allStarts, allIsNewLine = self:getWrappedLines()

	-- find current visual line index
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
		return -- out of bounds, ignore
	end

	-- get indents for current and target lines
	local currentIndent = allIsNewLine[currentIdx] and self.newLineIndentWidth or self.wrapIndentWidth
	local targetIndent = allIsNewLine[targetIdx] and self.newLineIndentWidth or self.wrapIndentWidth

	-- initialize desiredCursorX if not set (first vertical move)
	if not self.desiredCursorX then
		local lineStartPos = allStarts[currentIdx]
		local charsInLineToCursor = math.max(self.cursorPos - lineStartPos, 0)
		local lineText = allLines[currentIdx] or ""
		local subToCursor = utf8.sub(lineText, 1, charsInLineToCursor)
		local textWidth = self.font:getWidth(subToCursor)

		-- store absolute position with current indent
		self.desiredCursorX = currentIndent + textWidth
	end

	-- find closest character position in target line matching desiredCursorX
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
end

-- handles mouse click, activates field and sets cursor position
function TextInputField:mousepressed(mx, my, button)
	if button ~= 1 then return false end

	if mx < self.x or mx > self.x + self.w or my < self.y or my > self.y + self.h then
		self.isActive = false
		self:clearSelection()
		return false
	end

	self.isActive = true
	self:clearSelection() -- clear selection on click

	local allLines, allStarts, allIsNewLine = self:getWrappedLines()

	local localY = my - (self.y + self.paddingY)
	local lineIndex = math.max(1, math.min(math.floor(localY / self.lineHeight) + 1, #allLines))
	local lineText = allLines[lineIndex] or ""
	local lineStartPos = allStarts[lineIndex] or 0

	-- apply correct indent based on line type
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

	-- store absolute screen position (indent + text width)
	local textWidth = self.font:getWidth(utf8.sub(lineText, 1, cursorInLine))
	self.desiredCursorX = indent + textWidth

	self.selAnchor = self.cursorPos
	self.selStart = self.cursorPos
	self.selEnd = self.cursorPos
	self.isDragging = true

	return true
end

-- updates desiredCursorX based on current cursorPos
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

	-- store absolute screen position (indent + text width)
	local indent = allIsNewLine[idx] and self.newLineIndentWidth or self.wrapIndentWidth
	local textWidth = self.font:getWidth(subToCursor)
	self.desiredCursorX = indent + textWidth
end

return TextInputField
