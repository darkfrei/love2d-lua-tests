someText = "Some random piece of text\nHellow, world!"
glowColor = {0, 1, 0}
textColor = {0, 0, 1}

function glowText(glowColor, textColor, text, x, y, r, sx, sy, ox, oy, kx, ky)
    love.graphics.setColor(glowColor)
    love.graphics.print(text, x-1, y-1, r, sx, sy, ox, oy, kx, ky)
--    love.graphics.print(text, x, y-1, r, sx, sy, ox, oy, kx, ky)
--    love.graphics.print(text, x+1, y-1, r, sx, sy, ox, oy, kx, ky)
--    love.graphics.print(text, x-1, y, r, sx, sy, ox, oy, kx, ky)
--    love.graphics.print(text, x+1, y, r, sx, sy, ox, oy, kx, ky)
--    love.graphics.print(text, x-1, y+1, r, sx, sy, ox, oy, kx, ky)
--    love.graphics.print(text, x, y+1, r, sx, sy, ox, oy, kx, ky)
    love.graphics.print(text, x+1, y+1, r, sx, sy, ox, oy, kx, ky)
--    love.graphics.setColor(textColor)
--    love.graphics.print(text, x, y, r, sx, sy, ox, oy, kx, ky)
end

function love.draw()
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle("fill", 30, 10, 50, 50)
    love.graphics.setColor(1, 0, 1)
    love.graphics.circle("fill", 80, 40, 20)
    glowText(glowColor, textColor, someText, 10, 20)
end