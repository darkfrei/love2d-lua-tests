-- License CC0 (Creative Commons license) (c) darkfrei, 2023

love.window.setMode(1280, 800) -- Steam Deck resolution


function hue2rgb(p, q, t)
	t=t%1
	if t < 1/6 then 
		return p + (q - p) * 6 * t
	elseif t < 1/2 then 
		return q
	elseif t < 2/3 then 
		return p + (q - p) * (2/3 - t) * 6 
	end
	return p
end

function hslToRgb(h, s, l)
  local r, g, b
  if s == 0 then
    r, g, b = l, l, l -- achromatic
  else
    local q = l < 0.5 and l * (1 + s) or l + s - l * s
    local p = 2 * l - q
    r = hue2rgb(p, q, h + 1/3)
    g = hue2rgb(p, q, h)
    b = hue2rgb(p, q, h - 1/3)
  end
  return {math.floor(r * 255), math.floor(g * 255), math.floor(b * 255)}
end



function colorBrightness(color)
  return (0.299 * color[1] + 0.587 * color[2] + 0.114 * color[3])
end


function generatePalette(hue)
--  local hue = love.math.random() -- случайный оттенок
  local saturation = love.math.random() * 0.25 + 0.25
	local dlight = (2*love.math.random ()-1)/8

	local dhue1 = ((2*love.math.random ()-1))^3/8
  local color1 = hslToRgb(hue+dhue1, saturation, 0.75+dlight)
  local color2 = hslToRgb(hue, saturation, 0.50+dlight)
  local color3 = hslToRgb(hue-dhue1, saturation, 0.25+dlight)

	local dsat = love.math.random ()/4
	local dhue = (2*love.math.random ()-1)/128
--	local contrastColor = hslToRgb(hue+0.5+dhue, 0.9*saturation-dsat, 0.5)
	local contrastColor = hslToRgb(hue+0.5+dhue, 0.2*saturation + dsat, 0.5)
	
	local palette = { color1, color2, color3, contrastColor }
	
	for i = 1, #palette do
		local color = palette[i]
		palette[i] = {love.math.colorFromBytes(color)}
	end
	
	print (
		colorBrightness(palette[1]), 
		colorBrightness(palette[2]), 
		colorBrightness(palette[3]), 
		colorBrightness(palette[4])
	)
	
  return palette
end


globalHue = 0.25-0.06/2
--Palette = generatePalette(globalHue)
Palette = {
	{love.math.colorFromBytes(hslToRgb(0.25, 0.5, 0.75))},
	{love.math.colorFromBytes(hslToRgb(0.25, 0.5, 0.50))},
	{love.math.colorFromBytes(hslToRgb(0.25, 0.5, 0.25))},
	{love.math.colorFromBytes(hslToRgb(0.75, 0.25, 0.50))},
	}


Palettes = {Palette}

for i = 1, 11 do
	globalHue = (globalHue + (1+math.sqrt(5))/2/256)%1
	local palette = generatePalette(globalHue)
	love.window.setTitle ('hue:'..globalHue)
	table.insert (Palettes, palette)
end

function love.draw()
	local w, h = love.graphics.getDimensions ()
	h=h/4
	w=w/#Palettes
	for i, palette in ipairs (Palettes) do
		for j = 1, 4 do
			local color = palette[j]
			love.graphics.setColor (color)
			love.graphics.rectangle ('fill', (i-1)*w, (j-1)*h, w, h)
			local r, g, b = love.math.colorToBytes(color)
			love.graphics.setColor (palette[(j+2)%4+1])
			love.graphics.print (r..' '..g..' '..b, (i-1)*w, (j-1)*h)
		end
	end
end

function love.keypressed(key, scancode, isrepeat)
	if false then
	elseif key == "space" then
		globalHue = (globalHue + (1+math.sqrt(5))/2/64)%1
		
		local palette = generatePalette(globalHue)
		love.window.setTitle ('hue:'..globalHue)
		table.insert (Palettes, palette)
		if #Palettes > 12 then
			table.remove (Palettes, 1)
		end
	elseif key == "escape" then
		love.event.quit()
	end
end
