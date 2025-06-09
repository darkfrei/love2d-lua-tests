function generateColor(index)
	local hue = (index * 137.5) % 360 -- golden angle for varied hues
	local h = hue / 360
	local s, v = 0.7, 0.9 -- moderate saturation and high value
	local c = v * s
	local x = c * (1 - math.abs((h * 6) % 2 - 1))
	local m = v - c
	local r, g, b
	if h < 1/6 then
		r, g, b = c, x, 0
	elseif h < 2/6 then
		r, g, b = x, c, 0
	elseif h < 3/6 then
		r, g, b = 0, c, x
	elseif h < 4/6 then
		r, g, b = 0, x, c
	elseif h < 5/6 then
		r, g, b = x, 0, c
	else
		r, g, b = c, 0, x
	end
	return r + m, g + m, b + m
end