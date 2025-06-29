local sprite = love.graphics.newImage('planet.png')
local normalMap = love.graphics.newImage('planet_normal.png')

local shader = love.graphics.newShader([[
extern vec2 lightPos;
extern vec2 screenSize;
extern Image normalMap;

vec4 effect(vec4 color, Image texture, vec2 texCoords, vec2 screenCoords) {
    vec4 texColor = Texel(texture, texCoords);
    vec3 normal = Texel(normalMap, texCoords).rgb * 2.0 - 1.0;

    vec2 fragPos = screenCoords / screenSize;
    vec2 lightPixel = lightPos / screenSize;
    vec2 lightDir2D = fragPos - lightPixel;
    vec3 lightDir = normalize(vec3(lightDir2D, 1.0));

    float diffuse = max(dot(normalize(normal), lightDir), 0.0);
    float ambient = 0.1;

    return vec4(texColor.rgb * (ambient + (1.0 - ambient) * diffuse), texColor.a);
}

]])

function love.load()
    -- send required values to shader
    shader:send('normalMap', normalMap)
    shader:send('screenSize', {love.graphics.getWidth(), love.graphics.getHeight()})
end

function love.update()
    -- update light position from mouse
    shader:send('lightPos', {love.mouse.getX(), love.mouse.getY()})
end

function love.draw()
    -- draw image in center of screen
    local sw, sh = love.graphics.getDimensions()
    local iw, ih = sprite:getDimensions()
    local x = (sw - iw) / 2
    local y = (sh - ih) / 2

    love.graphics.setShader(shader)
    love.graphics.draw(sprite, x, y)
    love.graphics.setShader()
end
