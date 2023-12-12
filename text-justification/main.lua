blackString = [[I'm trying to implement the effect you see in many games where text is printed a character at a time. (See the original Dragon Quest for an example.) On its own this is easy: all one needs to do is keep a counter then use string.sub and utf8.offset to print a substring that gets longer and longer. The trouble comes from another limitation I have: I'd like to use printf's "justify" alignment. The naive implementation of this looks weird, as though text is swooping in from the right. The reason for this is clear: the justification changes the position of text that's already printed. I'm not really sure how to solve this problem though, and I wasn't able to find anyone else posting about it.

The only workaround I can think of is to print all the text in one go, properly justified, but have it start out covered by black rectangles over each line, then shrink the rectangles a character at a time until all the text is revealed. This should work, but it seems a bit convoluted and might cause problems later down the line if, say, I want a semi-transparent textbox.]]

love.graphics.setDefaultFilter( "nearest", "nearest")


local font = love.graphics.getFont ()
local width = 380
local words = {}
for w in blackString:gmatch("%S+") do table.insert (words, w) end

local stringLines = {}
local strings = {}

local tempSTR = ""
for i, w in ipairs (words) do
	local temp
	if tempSTR == "" then temp = w else temp = tempSTR..' '..w end
	if (i == #words) then
		table.insert (stringLines, {
				str = temp, 
				sx = 1
				}
			)
		table.insert (strings, temp)
	elseif width < font:getWidth(temp) then
		table.insert (stringLines, {
				str = tempSTR, 
				sx = width/font:getWidth(tempSTR)
				}
			)
		table.insert (strings, tempSTR)
		tempSTR = w
	else
		tempSTR = temp
	end
end

loveText = love.graphics.newText( font, "" )
for i, str in ipairs (strings) do
	print (str)
	local words = {}
	for w in str:gmatch("%S+") do table.insert (words, w) end
	local spacesAmount = #words - 1
	local stringWidth = font:getWidth (str)
	local spaceWidth = font:getWidth (' ')
	local noSpacesStringWidth = stringWidth - spacesAmount * spaceWidth
	local newSpaceWidth = (width - noSpacesStringWidth)/spacesAmount
	local sxSpace = newSpaceWidth/spaceWidth
	
	if i == #strings then
		-- last line has no justification
		newSpaceWidth = spaceWidth
	end
	
	print (spacesAmount, stringWidth, noSpacesStringWidth, spaceWidth, newSpaceWidth, sxSpace)
	
	local x = 0
	local y = (i-1)*font:getHeight()
	for j, w in ipairs (words) do
		loveText:add( w, x, y)
		x = x + font:getWidth (w)
		if (j == #words) then
			-- do nothing
		else
			x = x + newSpaceWidth
		end
	end
end

function love.draw()
	love.graphics.rectangle ('line', 10,10, width, 260)
	for i, s in ipairs (stringLines) do
		love.graphics.printf({{1,1,1}, s.str}, 10, 10+(i-1)*font:getHeight(), width, "left", 0, s.sx, 1)
	end
	love.graphics.rectangle ('line', 410,10, width, 260)
	love.graphics.draw (loveText, 410, 10)
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "escape" then
		love.event.quit()
	end
end
