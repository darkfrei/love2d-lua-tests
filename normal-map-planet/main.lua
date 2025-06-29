local sprite
local normalMap
local shader

local imageWidth, imageHeight
local objects

function love.load()
	-- load sprite and normal map images
	sprite = love.graphics.newImage("planet.png")
	normalMap = love.graphics.newImage("planet_normal.png")

	-- get image dimensions
	imageWidth, imageHeight = sprite:getWidth(), sprite:getHeight()

	-- create shader for lighting
	shader = love.graphics.newShader([[
        extern vec2 lightPos;
        extern Image normalMap;
        extern float rotation;

        vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords) {
            vec4 texColor = Texel(texture, texCoords);
            
            // rotate texture coordinates to match sprite rotation
            vec2 centered = texCoords - 0.5;
            float cosR = cos(rotation);
            float sinR = sin(rotation);
            vec2 rotated = vec2(
                cosR * centered.x - sinR * centered.y,
                sinR * centered.x + cosR * centered.y
            ) + 0.5;
            
            // sample normal map using rotated coordinates
            vec3 normal = Texel(normalMap, rotated).rgb * 2.0 - 1.0;

            // compute light direction
            vec2 lightDir = screenCoords - lightPos;
            vec3 lightVec = normalize(vec3(lightDir, 100.0));

            // compute diffuse lighting
            float diffuse = max(dot(normal, lightVec), 0.0);
            float ambient = 0.15;

            return vec4(texColor.rgb * (ambient + (1.0 - ambient) * diffuse), texColor.a);
        }
    ]])

	-- send normal map to shader
	shader:send("normalMap", normalMap)

	-- define objects with position and angular velocity
	objects = {
		{ x = 200, y = 100, angularVelocity = 1.0, angle = 0, sprite = sprite, scale = 0.3},
		{ x = 200, y = 500, angularVelocity = 2.5, angle = 0, sprite = sprite, scale = 0.4},
		{ x = 600, y = 100, angularVelocity = -1.5, angle = 0, sprite = sprite, scale = 0.5},
		{ x = 600, y = 500, angularVelocity = -2.5, angle = 0, sprite = sprite, scale = 0.6},
	}
end

function love.update(dt)
	-- update rotation for each object
	for _, object in ipairs(objects) do
		object.angle = object.angle + object.angularVelocity * dt
	end

	-- send light position from mouse
	shader:send("lightPos", {love.mouse.getPosition()})
end

function love.draw()
	-- draw each object
	love.graphics.setColor(1, 1, 1)
	for _, object in ipairs(objects) do
		-- send rotation for current object
		shader:send("rotation", object.angle)

		-- apply shader and draw sprite
		love.graphics.setShader(shader)
		love.graphics.draw(object.sprite, object.x, object.y, object.angle, object.scale, object.scale, imageWidth / 2, imageHeight / 2)
		love.graphics.setShader()
	end

	-- draw light source for reference
	local mouseX, mouseY = love.mouse.getPosition()
	love.graphics.setColor(1, 1, 0)
	love.graphics.circle("fill", mouseX, mouseY, 50)

end