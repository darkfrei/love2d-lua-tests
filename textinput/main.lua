-- minimal_textinput.lua

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

local font
local major, minor, revision, codename = love.getVersion()
--print (major, minor, revision, codename)
if major == 12 then
	love.graphics.newFont(30)
else
	-- see https://fonts.google.com/noto/specimen/Noto+Sans
	font = love.graphics.newFont("NotoSans-Regular.ttf", 30)
end
local lineHeight = font:getHeight()

-- all field state in one table
local field = {
	x = 100,
	y = 100,
	w = 400,
	h = 0, -- computed dynamically
	paddingX = 5,
	text = [[1. Really long strings are supported
2. And multiline
3. И юникод (and unicode)
4. Also all arrow keys, backspace, delete, Home, End with blinking cursor]],
	cursorPos = 0,
	desiredCursorX = nil
}

-- key repeat state
local keyRepeat = {
	key = nil,
	timer = 0,
	delay = 0.5,
	interval = 0.03
}



-- helper: build visual wrapped lines and absolute start indices
local function getWrappedLinesWithStarts(textStr, maxWidth)
	local pos = 0
	local lines, starts = {}, {}
	for rawLine in (textStr .. "\n"):gmatch("(.-)\n") do
		if rawLine == "" then
			table.insert(lines, "")
			table.insert(starts, pos)
		else
			local _, wrapped = font:getWrap(rawLine, maxWidth)
			for _, w in ipairs(wrapped) do
				table.insert(lines, w)
				table.insert(starts, pos)
				pos = pos + utf8.len(w)
			end
		end
		pos = pos + 1
	end
	if #textStr > 0 then pos = pos - 1 end
	return lines, starts
end


local function updateFieldHeight()
	local maxWidth = field.w - 2 * field.paddingX
	local totalLines = 0

	-- split text into raw lines by newline
	for rawLine in (field.text .. "\n"):gmatch("(.-)\n") do
		-- wrap each raw line into visual lines
		local _, wrapped = font:getWrap(rawLine, maxWidth)
		totalLines = totalLines + #wrapped
	end

	-- ensure at least 3 lines
	local lineCount = math.max(totalLines, 3)
	field.h = lineCount * lineHeight + 2 * field.paddingX
end





-- update desired x using wrapped lines and absolute starts
local function updateDesiredX()
	local maxWidth = field.w - 2 * field.paddingX
	local allLines, allStarts = getWrappedLinesWithStarts(field.text, maxWidth)

	-- find visual line index for current cursorPos
	local idx = 1
	for i = 1, #allLines do
		local startPos = allStarts[i]
		local len = utf8.len(allLines[i])
		if field.cursorPos >= startPos and field.cursorPos <= startPos + len then
			idx = i
			break
		end
		if i == #allLines and field.cursorPos > startPos + len then
			idx = i
		end
	end

	-- measure width from line start to cursor within that visual line
	local lineStartPos = allStarts[idx]
	local charsInLineToCursor = math.max(field.cursorPos - lineStartPos, 0)
	local lineText = allLines[idx] or ""
	local subToCursor = utf8.sub(lineText, 1, charsInLineToCursor)

	field.desiredCursorX = font:getWidth(subToCursor)
end


-- move cursor vertically, keeping closest x position across wrapped lines
local function moveCursorVertical(direction)
	local maxWidth = field.w - 2 * field.paddingX
	local allLines, allStarts = getWrappedLinesWithStarts(field.text, maxWidth)

	-- find current visual line index
	local currentIdx = 1
	for i = 1, #allLines do
		local startPos = allStarts[i]
		local len = utf8.len(allLines[i])
		if field.cursorPos >= startPos and field.cursorPos <= startPos + len then
			currentIdx = i
			break
		end
		if i == #allLines and field.cursorPos > startPos + len then
			currentIdx = i
		end
	end

	-- target line index
	local targetIdx = currentIdx + direction
	if targetIdx < 1 or targetIdx > #allLines then
		return
	end

	-- ensure desiredCursorX is set to the current visual x if nil
	if field.desiredCursorX == nil then
		local lineStartPos = allStarts[currentIdx]
		local charsInLineToCursor = math.max(field.cursorPos - lineStartPos, 0)
		local lineText = allLines[currentIdx] or ""
		local subToCursor = utf8.sub(lineText, 1, charsInLineToCursor)
		field.desiredCursorX = font:getWidth(subToCursor)
	end

	-- project desired x onto the target line by measuring character widths
	local targetText = allLines[targetIdx] or ""
	local targetStart = allStarts[targetIdx]
	local targetLen = utf8.len(targetText) or 0

	local newCursorPosInLine = 0
	local prevWidth = 0
	local found = false
	for i = 1, targetLen do
		local subtext = utf8.sub(targetText, 1, i)
		local w = font:getWidth(subtext)
		if w >= field.desiredCursorX then
			-- choose the closer of the two positions
			if math.abs(field.desiredCursorX - prevWidth) <= math.abs(w - field.desiredCursorX) then
				newCursorPosInLine = i - 1
			else
				newCursorPosInLine = i
			end
			found = true
			break
		end
		prevWidth = w
	end
	if not found then
		newCursorPosInLine = targetLen
	end

	field.cursorPos = targetStart + newCursorPosInLine
end


local function replaceText(startIdx, endIdx, replacement)
	local before = utf8.sub(field.text, 1, startIdx - 1)
	local after = utf8.sub(field.text, endIdx + 1)
	field.text = before .. (replacement or "") .. after
end


-- handle key input
local function handleKey(key)
	if key == "backspace" and field.cursorPos > 0 then
		replaceText(field.cursorPos, field.cursorPos, "")
		field.cursorPos = field.cursorPos - 1
		updateDesiredX()
	elseif key == "delete" and field.cursorPos < utf8.len(field.text) then
		replaceText(field.cursorPos + 1, field.cursorPos + 1, "")

	elseif key == "left" and field.cursorPos > 0 then
		field.cursorPos = field.cursorPos - 1
		updateDesiredX()

	elseif key == "right" and field.cursorPos < utf8.len(field.text) then
		field.cursorPos = field.cursorPos + 1
		updateDesiredX()

	elseif key == "up" then
		moveCursorVertical(-1)

	elseif key == "down" then
		moveCursorVertical(1)

	elseif key == "return" then
		replaceText(field.cursorPos + 1, field.cursorPos, "\n")
		field.cursorPos = field.cursorPos + 1
		updateDesiredX()
		updateFieldHeight()

	elseif key == "home" then
		field.cursorPos = 0

	elseif key == "end" then
		field.cursorPos = utf8.len(field.text)
	end
end



-- separate function for rendering the cursor
local function drawCursor(field, font, lineHeight, maxWidth)

	-- blink speed in blinks per second
	local blinkSpeed = 3
	if math.floor(love.timer.getTime() * blinkSpeed) % 2 == 0 then
		-- get all visual lines and their start positions
		local allLines, allStarts = getWrappedLinesWithStarts(field.text, maxWidth)

		-- find the line where the cursor is located
		local cursorLineIndex = 1
		for i = 1, #allLines do
			local startPos = allStarts[i]
			local lineLen = utf8.len(allLines[i])
			if field.cursorPos >= startPos and field.cursorPos <= startPos + lineLen then
				cursorLineIndex = i
				break
			end
			if i == #allLines and field.cursorPos > startPos + lineLen then
				cursorLineIndex = i
			end
		end

		-- calculate offset inside the line
		local lineStartPos = allStarts[cursorLineIndex]
		local charsInLineToCursor = math.max(field.cursorPos - lineStartPos, 0)
		local lineText = allLines[cursorLineIndex] or ""
		local subToCursor = utf8.sub(lineText, 1, charsInLineToCursor)

		local cursorX = field.x + field.paddingX + font:getWidth(subToCursor)
		local cursorY = field.y + field.paddingX + (cursorLineIndex - 1) * lineHeight

		-- blinking cursor

		love.graphics.line(cursorX, cursorY, cursorX, cursorY + lineHeight)
	end
end




---------------------------
-- love2d -----------------
---------------------------


function love.load()
	-- enable text input
	love.keyboard.setTextInput(true)

	-- recalc field height
	updateFieldHeight()

	-- put cursor at the end of the text
	field.cursorPos = utf8.len(field.text)
	updateDesiredX()
end


function love.textinput(t)
	local before = utf8.sub(field.text, 1, field.cursorPos)
	local after = utf8.sub(field.text, field.cursorPos + 1)
	field.text = before .. t .. after
	field.cursorPos = field.cursorPos + utf8.len(t)
	updateDesiredX()
	updateFieldHeight()

end



function love.keypressed(key)
	if key == "escape" then
		love.event.quit()
		return
	end
	handleKey(key)
	keyRepeat.key = key
	keyRepeat.timer = 0
end

function love.keyreleased(key)
	if keyRepeat.key == key then
		keyRepeat.key = nil
		keyRepeat.timer = 0
	end
end

function love.update(dt)
	if keyRepeat.key then
		keyRepeat.timer = keyRepeat.timer + dt
		if keyRepeat.timer >= keyRepeat.delay then
			local elapsed = keyRepeat.timer - keyRepeat.delay
			local repeats = math.floor(elapsed / keyRepeat.interval)
			if repeats > 0 then
				handleKey(keyRepeat.key)
				keyRepeat.timer = keyRepeat.delay + (repeats * keyRepeat.interval)
			end
		end
	end
end


function love.draw()
	-- compute max text width inside the field
	local maxWidth = field.w - 2 * field.paddingX

	-- field background and border
	love.graphics.setColor(0.2, 0.2, 0.25)
	love.graphics.rectangle("fill", field.x, field.y, field.w, field.h)
	love.graphics.setColor(0.3, 0.5, 0.7)
	love.graphics.rectangle("line", field.x, field.y, field.w, field.h)

	-- draw text
	love.graphics.setColor(1, 1, 1)
	love.graphics.setFont(font)
	love.graphics.printf(field.text, field.x + field.paddingX, field.y + field.paddingX, maxWidth, "left")

	-- draw cursor
	drawCursor(field, font, lineHeight, maxWidth)

	-- debug info
	love.graphics.print(
		"CursorPos: " .. field.cursorPos ..
		"; TextLen: " .. utf8.len(field.text) ..
		"; desiredCursorX: " .. tostring(field.desiredCursorX),
		10, 10
	)
end
