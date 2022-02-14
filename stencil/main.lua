local width, height = 274, 192
love.window.setMode(width, height)

local lg = love.graphics
local image = lg.newImage('texture.png')
local mask = lg.newImage('mask.png')

local canvas = { -- we don't need to store them seperately
  lg.newCanvas(width, height),
  depthstencil = lg.newCanvas(width, height, {format="stencil8"}),
}

-- shader to discard non-black pixels
local shader = lg.newShader([[
vec4 effect(vec4 color, Image tex, vec2 texture_coords, vec2 screen_coords)
{
    vec4 texturecolor = Texel(tex, texture_coords);
    if (texturecolor.a - texturecolor.r < 0.5) // I only check the red channel, but you can check more if you desire
      discard;
    return texturecolor;
}
]])

local function stencilFunction()
  lg.setShader(shader)
  lg.draw(mask)
  lg.setShader()
end

local drawStencil = function()
  lg.push("all")
  lg.setCanvas(canvas)
  lg.clear(true, true)
  lg.stencil(stencilFunction, "replace", 1)
  lg.pop()
end
drawStencil()

function love.draw()
  lg.push("all")
	  lg.setCanvas(canvas)
	  lg.clear(true, false)
	  lg.setStencilTest("greater", 0)
	  lg.draw(image)
  lg.pop()
  lg.draw(canvas[1])
end