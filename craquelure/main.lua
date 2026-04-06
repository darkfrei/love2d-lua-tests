local W, H = 1920, 1080

local canvas_thickness    = nil
local canvas_displacement = nil
local shader_init         = nil

local canvas_stress = nil
local shader_stress = nil

local EPSILON = 1.5  -- stretch coefficient



function love.load()
	love.window.setMode(W, H)
	love.window.setTitle ('Craquelure, 2026-04-06, darkfrei')
	

	canvas_thickness    = love.graphics.newCanvas(W, H)
	canvas_displacement = love.graphics.newCanvas(W, H)

	-- load heightmap
	local img = love.graphics.newImage("heightmap.png")
	love.graphics.setCanvas(canvas_thickness)
	love.graphics.setBlendMode("replace")
	love.graphics.draw(img, 0, 0, 0, W / img:getWidth(), H / img:getHeight())
	love.graphics.setBlendMode("alpha")
	love.graphics.setCanvas()

	-- displacement: pure radial from canvas center, no thickness involved
	shader_init = love.graphics.newShader([[
        uniform float epsilon;

        vec4 effect(vec4 color, Image image, vec2 uv, vec2 screen) {
            vec2 center = vec2(0.5, 0.5);
            vec2 disp   = epsilon * (uv - center);
            float mag   = length(disp);
            // encode: center at 0.5
            return vec4(disp.x * 0.5 + 0.5, disp.y * 0.5 + 0.5, mag, 1.0);
        }
    ]])

	love.graphics.setCanvas(canvas_displacement)
	love.graphics.setShader(shader_init)
	shader_init:send("epsilon", EPSILON)
	love.graphics.draw(canvas_thickness, 0, 0)  -- use thickness as uv carrier
	love.graphics.setShader()
	love.graphics.setCanvas()

	canvas_stress = love.graphics.newCanvas(W, H)

	-- stress: simple sigma = displacement magnitude / thickness
	shader_stress = love.graphics.newShader([[
    uniform Image thickness;
    uniform Image displacement;

    vec4 effect(vec4 color, Image image, vec2 uv, vec2 screen) {
        float t      = max(Texel(thickness, uv).r, 0.01);
        vec4  d      = Texel(displacement, uv);
        float mag    = d.b; // magnitude stored in b channel of displacement
//        float sigma1 = clamp(mag / t, 0.0, 1.0);
				float sigma1 = clamp((1.0 - mag) / t, 0.0, 1.0);


        // heat map: blue -> yellow -> red
        vec3 heat = mix(
            mix(vec3(0.0, 0.2, 0.8), vec3(0.9, 0.8, 0.0), sigma1),
            vec3(1.0, 0.1, 0.0),
            smoothstep(0.5, 1.0, sigma1)
        );
        return vec4(heat, 1.0);
    }
]])

	-- compute stress once
	love.graphics.setCanvas(canvas_stress)
	love.graphics.setShader(shader_stress)
	shader_stress:send("thickness",    canvas_thickness)
	shader_stress:send("displacement", canvas_displacement)
	love.graphics.draw(canvas_thickness, 0, 0)
	love.graphics.setShader()
	love.graphics.setCanvas()
end

function love.draw()
	local hw = W / 2

	-- top-left: thickness
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(canvas_thickness,    0,  0, 0, 0.5, 0.5)

	-- top-right: displacement (r=x, g=y, b=magnitude)
	love.graphics.draw(canvas_displacement, hw, 0, 0, 0.5, 0.5)

	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.print("thickness",    8,      8)
	love.graphics.print("displacement", hw + 8, 8)

	-- bottom-left: stress heat
	love.graphics.draw(canvas_stress, 0, H/2, 0, 0.5, 0.5)

	love.graphics.print("stress", 8, H/2 + 8)
end

function love.keypressed(key)
	if key == "escape" then love.event.quit() end
end