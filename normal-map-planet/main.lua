local sprite
local normalMap
local shader

local x1, y1
local iw, ih
local a1 = 0

function love.load()
	sprite = love.graphics.newImage('planet.png')
	normalMap = love.graphics.newImage('planet_normal.png')

	iw, ih = sprite:getWidth(), sprite:getHeight()
	x1, y1 = love.graphics.getWidth() / 2, love.graphics.getHeight() / 2

	shader = love.graphics.newShader([[
        extern vec2 lightPos;
        extern Image normalMap;
        extern float rotation;

        vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords) {
            vec4 texColor = Texel(texture, texCoords);
            vec3 normal = Texel(normalMap, texCoords).rgb * 2.0 - 1.0;

            // compute light direction in screen space
            vec2 lightDir2D_screen = screenCoords - lightPos;

            // rotate light direction to texture space
            float cosR = cos(-rotation);
            float sinR = sin(-rotation);
            vec2 lightDir2D_texture = vec2(
                cosR * lightDir2D_screen.x - sinR * lightDir2D_screen.y,
                sinR * lightDir2D_screen.x + cosR * lightDir2D_screen.y
            );

            // assume fixed z-component for light
            vec3 lightDir = normalize(vec3(lightDir2D_texture, 100.0));

            // compute diffuse lighting
            float diffuse = max(dot(normal, lightDir), 0.0);
            float ambient = 0.15;

            return vec4(texColor.rgb * (ambient + (1.0 - ambient) * diffuse), texColor.a);
        }
    ]])

	shader:send('normalMap', normalMap)
end

function love.update(dt)
	a1 = a1 + 0.3 * dt  -- rotate texture

	-- light position on screen (fixed)
	local lightX = love.graphics.getWidth() / 2 + 300
	local lightY = love.graphics.getHeight() / 2

	shader:send('lightPos', {lightX, lightY})
	shader:send('rotation', a1)  -- pass a1, use -rotation in shader
end

function love.draw()
	love.graphics.setShader(shader)
	love.graphics.draw(sprite, x1, y1, a1, 1, 1, iw / 2, ih / 2)
	love.graphics.setShader()

	-- draw light source for reference
	love.graphics.setColor(1, 1, 0)
	love.graphics.circle('fill', love.graphics.getWidth() / 2 + 300, love.graphics.getHeight() / 2, 5)
	love.graphics.setColor(1, 1, 1)
end