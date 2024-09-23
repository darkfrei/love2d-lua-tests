-- pgimeno
-- https://love2d.org/forums/viewtopic.php?p=251974#p251974



love.window.setVSync(false)

local daynight = love.graphics.newShader[[
  // Pixel width/height in normalized units (i.e. inverse of screen w/h)
    extern float pw, ph;

  vec4 effect(vec4 colour, Image tex, vec2 texpos, vec2 scrpos)
  {
    float state=0.0;
    float
     sum = Texel(tex, texpos + vec2(-pw, -ph)).r;
    sum += Texel(tex, texpos + vec2(0.0, -ph)).r;
    sum += Texel(tex, texpos + vec2( pw, -ph)).r;
    sum += Texel(tex, texpos + vec2(-pw, 0.0)).r;
    sum += Texel(tex, texpos + vec2( pw, 0.0)).r;
    sum += Texel(tex, texpos + vec2(-pw,  ph)).r;
    sum += Texel(tex, texpos + vec2(0.0,  ph)).r;
    sum += Texel(tex, texpos + vec2( pw,  ph)).r;
    if (sum >= 2.5 && sum < 3.5 || sum >= 5.5) // 3, 6, 7, 8 becomes live
      state = 1.0;
    else if (sum >= 3.5 && sum < 4.5) // 4 unchanged, rest dies
      state = Texel(tex, texpos).r;
    return vec4(state, state, state, 1.0);
  }
]]

do
	local gettime = require('socket').gettime
	math.randomseed(gettime())
end

local current = love.graphics.newCanvas()
local new = love.graphics.newCanvas()

current:setWrap("repeat")
new:setWrap("repeat")

local rndimdata = love.image.newImageData(current:getDimensions())
rndimdata:mapPixel(function (x, y)
		local r = math.random(0, 1)
		return r, r, r, 1.0
	end)
local rndimg = love.graphics.newImage(rndimdata)
rndimdata:release()

love.graphics.setCanvas(current)
love.graphics.draw(rndimg)
love.graphics.setCanvas()
rndimg:release()
daynight:send('pw', 1/love.graphics.getWidth())
daynight:send('ph', 1/love.graphics.getHeight())


function love.resize(w, h)
	new:release()
	new = love.graphics.newCanvas()
	love.graphics.setCanvas(new)
	love.graphics.draw(current)
	love.graphics.setCanvas()
	current:release()
	current = new
	new = love.graphics.newCanvas()
	current:setWrap("repeat")
	new:setWrap("repeat")
	daynight:send('pw', 1/w)
	daynight:send('ph', 1/h)
end

function love.keypressed(k) 
	if k == "escape" then
		love.event.quit()
	end
end


function love.load()
	love.window.setTitle ('push SPACE to calculate')
	step = 0
	
end


function love.update(dt)
	if love.keyboard.isDown ('space') then
		step = step + 1
		love.graphics.setCanvas(new)
		love.graphics.setShader(daynight)
		love.graphics.draw(current)
		love.graphics.setShader()
		love.graphics.setCanvas()
		current, new = new, current

		love.window.setTitle (step)
	end

end


function love.draw()
	love.graphics.draw(current)
end