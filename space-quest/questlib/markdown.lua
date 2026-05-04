local markdown = {}

function markdown.parse(str)
	local result = {}
	local buf = ""
	local flags = {b=false, i=false, m=false, s=false, th=false} -- th = tag_highlight
	local at_line_start = true
	local pending_indent = 0

	local function flush()
		if #buf == 0 then return end
		table.insert(result, {
				text = buf,
				bold = flags.b or nil,
				italic = flags.i or nil,
				mono = flags.m or nil,
				strike = flags.s or nil,
				tag_highlight = flags.th or nil,
				indent = pending_indent > 0 and pending_indent or nil
			})
		buf = ""
		pending_indent = 0
	end

	local pos = 1
	local len = #str
	while pos <= len do
		local ch = str:sub(pos, pos)
		local ch2 = str:sub(pos, pos+1)

		if ch == '\n' then
			flush()
			table.insert(result, {text = "\n", newline = true})
			at_line_start = true
			pending_indent = 0
			pos = pos + 1
		elseif at_line_start and ch == ' ' then
			local count = 0
			while pos + count <= len and str:sub(pos + count, pos + count) == ' ' do
				count = count + 1
			end
			if count >= 3 then
				pending_indent = math.floor(count / 4)
				pos = pos + count
				at_line_start = false
			else
				buf = buf .. string.rep(' ', count)
				pos = pos + count
				at_line_start = false
			end
		elseif ch2 == '**' then
			flush(); flags.b = not flags.b; pos = pos + 2
		elseif ch2 == '~~' then
			flush(); flags.s = not flags.s; pos = pos + 2
		elseif ch2 == '==' then
			flush(); flags.th = not flags.th; pos = pos + 2
		elseif ch == '*' and str:sub(pos+1, pos+1) ~= '*' then
			flush(); flags.i = not flags.i; pos = pos + 1
		elseif ch == '`' then
			flush(); flags.m = not flags.m; pos = pos + 1
		else
			if at_line_start then at_line_start = false end
			buf = buf .. ch
			pos = pos + 1
		end
	end
	flush()
	return result
end

return markdown