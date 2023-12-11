blackString = [[I'm trying to implement the effect you see in many games where text is printed a character at a time. (See the original Dragon Quest for an example.) On its own this is easy: all one needs to do is keep a counter then use string.sub and utf8.offset to print a substring that gets longer and longer. The trouble comes from another limitation I have: I'd like to use printf's "justify" alignment. The naive implementation of this looks weird, as though text is swooping in from the right. The reason for this is clear: the justification changes the position of text that's already printed. I'm not really sure how to solve this problem though, and I wasn't able to find anyone else posting about it.

The only workaround I can think of is to print all the text in one go, properly justified, but have it start out covered by black rectangles over each line, then shrink the rectangles a character at a time until all the text is revealed. This should work, but it seems a bit convoluted and might cause problems later down the line if, say, I want a semi-transparent textbox.]]

--for i = 101, string.len(blackString), 100 do
--	local spaceIndex = string.find(blackString, " ", i)
--	blackString = blackString:sub(1, spaceIndex).. '\n' .. blackString:sub(spaceIndex+1)
--end

whiteString = ""

function love.draw()
	if math.random() > 0.8 then
		local letter = string.sub(blackString, 1, 1)
		blackString = string.sub(blackString, 2, -1)
		if letter and not (letter == "") then
			whiteString = whiteString .. letter
		end
	end
--	love.graphics.print(whiteString, 10, 10)
	love.graphics.printf({{1,1,1}, whiteString, {0,0,0}, blackString}, 10, 10, 200, "justify")
end
