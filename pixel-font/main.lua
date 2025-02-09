local filename =  'pixelfont-11p.png'
local glyphs = " abcdefghijklmnopqrstuvwxyz" ..
    "ABCDEFGHIJKLMNOPQRSTUVWXYZ0" ..
    "123456789.,!?-+/():;%&`'*#=[]\""

local fontImageData = love.image.newImageData(filename)
local font11p = love.graphics.newImageFont(fontImageData, glyphs)
font11p:setFilter( 'nearest', 'nearest' )

function love.draw ()
	love.graphics.setFont(font11p)
	love.graphics.print (glyphs, 0, 12)
	love.graphics.scale (2)
	love.graphics.print (glyphs, 0, 12)
	love.graphics.scale (2)
	love.graphics.print (glyphs, 0, 12)
	love.graphics.scale (2)
	love.graphics.print (glyphs, 0, 12)
end


--[[
https://love2d.org/wiki/File:pixelfont-11p.png

To include a file in a page, use a link in one of the following forms:

-- [[File:File.jpg]] to use the full version of the file
-- [[File:File.png|200px|thumb|left|alt text]] to use a 200 pixel wide rendition in a box in the left margin with "alt text" as description
-- [[Media:File.ogg]] for directly linking to the file without displaying the file

--]]