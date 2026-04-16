-- main parameters for voronoi
local main_n = 42
local w, h = 1920, 1080

-- shader and render target
local craqShader, canvas

-- base color palette for cells
local palette = {
	{0.78, 0.64, 0.47}, {0.74, 0.59, 0.40}, {0.70, 0.55, 0.37},
	{0.82, 0.70, 0.54}, {0.66, 0.51, 0.34}, {0.76, 0.67, 0.55},
	{0.80, 0.72, 0.58}, {0.64, 0.52, 0.38}, {0.72, 0.62, 0.48},
	{0.68, 0.57, 0.43},
}

local frag = [[
extern vec2 mPts[MAIN_N];
extern vec3 mCols[MAIN_N];
extern vec2 res;

// hash for procedural point generation inside cell
vec2 h22(vec2 p) {
 float n = sin(dot(p, vec2(41.0, 289.0)));
 return fract(vec2(262144.0, 32768.0) * n);
}

// distance with aspect ratio and toroidal wrapping
vec2 wrapDistAspect(vec2 a, vec2 b, float aspect) {
 vec2 d = a - b;
 d.x *= aspect;
 // y axis is not scaled
 d = abs(d);
 return min(d, vec2(aspect, 1.0) - d);
}

// basic hash noise
float h21(vec2 p) {
 p = fract(p * vec2(127.1, 311.7));
 p += dot(p, p + 45.32);
 return fract(p.x * p.y);
}

// smooth value noise
float noise(vec2 p) {
 vec2 i = floor(p), f = fract(p), u = f*f*(3.0-2.0*f);
 return mix(mix(h21(i), h21(i+vec2(1,0)), u.x),
 mix(h21(i+vec2(0,1)), h21(i+vec2(1,1)), u.x), u.y);
}

// fractal noise for richer surface
float fbm(vec2 p) {
 return noise(p)*0.50 + noise(p*2.3)*0.25 + noise(p*5.1)*0.125;
}

// main shader entry
vec4 effect(vec4 col, Image tex, vec2 tc, vec2 sc) {

 // normalized screen coordinates
 vec2 uv = sc / res;

 // screen aspect ratio
 float aspect = res.x / res.y;

 // compute main voronoi cells
 float sd1 = 1e18, sd2 = 1e18;
 int idx = 0;

 for(int i = 0; i < MAIN_N; i++) {
 vec2 dv = wrapDistAspect(uv, mPts[i], aspect);
 float sd = dot(dv, dv);
 if(sd < sd1) { sd2 = sd1; sd1 = sd; idx = i; }
 else if(sd < sd2) sd2 = sd;
 }

 // distances to nearest and second nearest points
 float d1 = sqrt(sd1);
 float d2 = sqrt(sd2);

 // edge thickness measure
 float mEdge = d2 - d1;

 // get cell color and center
 vec3 c = mCols[0];
 vec2 cCenter = mPts[0];

 for(int i = 1; i < MAIN_N; i++) {
 if(i == idx) {
 c = mCols[i];
 cCenter = mPts[i];
 }
 }

 // compute micro voronoi inside each cell
 float sd3 = 1e18, sd4 = 1e18;

 // local coordinates relative to cell center
 vec2 localUV = uv - cCenter;

 // wrap to tileable range
 localUV = localUV - floor(localUV + 0.5);

 // apply aspect scaling for isotropy
 localUV.x *= aspect;

 // grid resolution for micro cracks
 int gridSize = 10;
 float step = 1.0 / float(gridSize);
 float offset = -0.5 + step * 0.5;

 for(int y = 0; y < gridSize; y++) {
 for(int x = 0; x < gridSize; x++) {

 vec2 cell = vec2(float(x), float(y));

 // per cell random offset
 vec2 rnd = h22(cell + float(idx));

 vec2 p;
 p.x = offset + float(x) * step + (rnd.x - 0.5) * step * 0.5;
 p.y = offset + float(y) * step + (rnd.y - 0.5) * step * 0.5;

 // match aspect scaling
 vec2 pAdj = p;
 pAdj.x *= aspect;

 vec2 dv = localUV - pAdj;
 float sd = dot(dv, dv);

 if(sd < sd3) { sd4 = sd3; sd3 = sd; }
 else if(sd < sd4) sd4 = sd;
 }
 }

 float sEdge = sqrt(sd4) - sqrt(sd3);

 // add subtle surface noise
 c += fbm(uv * 22.0) * 0.08 - 0.04;
 c += noise(uv * 90.0) * 0.030 - 0.015;

 // lighting based on distance to cell center
 vec2 toC = cCenter - uv;
 toC = toC - floor(toC + 0.5);
 toC.x *= aspect;

 float diff = dot(normalize(toC + vec2(1e-5)), normalize(vec2(-0.55, -0.85)));

 c += diff * d1 * 0.32;
 c *= 0.93 + d1 * 0.35;

 // crack width parameters
 float crW = 0.0100 + noise(uv * 8.5) * 0.0045;
 float subW = 0.0025 + noise(uv * 24.0) * 0.0010;

 // anti aliasing width
 float mAa = max(fwidth(mEdge) * 0.85, 0.00035);
 float sAa = max(fwidth(sEdge) * 0.85, 0.00025);

 // fade small cracks near main cracks
 float farFromMain = smoothstep(crW * 0.6, crW * 2.2, mEdge);

 float subMask = 1.0 - smoothstep(subW - sAa, subW + sAa, sEdge);
 subMask *= farFromMain;

 // apply small cracks
 if(subMask > 0.001) {
	c = mix(c, vec3(0.07, 0.05, 0.02), subMask * 1.2);
	c *= 1.0 - subMask * 0.10;
 }

 // apply main cracks
 float mainMask = 1.0 - smoothstep(crW - mAa, crW + mAa, mEdge);

 if(mainMask > 0.001) {
	c = mix(vec3(0.055, 0.040, 0.020), c, 1.0 - mainMask);
	c *= mix(0.70, 1.0, 1.0 - mainMask);

	float rim = smoothstep(crW*0.52, crW*0.80, mEdge)
	* (1.0 - smoothstep(crW*0.80, crW, mEdge));

	c += rim * 0.08;
 }

 // final color tweak
 c.r += 0.012;
 c.g += 0.005;

 return vec4(clamp(c, 0.0, 1.0), 1.0);
}
]]

frag = frag:gsub("MAIN_N", tostring(main_n))

-- relax points to avoid clustering
local function relaxPoints(pts, iterations, radius)
	for it = 1, iterations do
		for i = 1, #pts do
			local px, py = pts[i][1], pts[i][2]
			local fx, fy = 0, 0

			for j = 1, #pts do
				if i ~= j then
					local dx = px - pts[j][1]
					local dy = py - pts[j][2]

					-- toroidal wrapping
					dx = dx - math.floor(dx + 0.5)
					dy = dy - math.floor(dy + 0.5)

					local d2 = dx*dx + dy*dy
					if d2 < radius*radius and d2 > 1e-6 then
						local d = math.sqrt(d2)
						local force = (radius - d) / radius
						fx = fx + (dx / d) * force
						fy = fy + (dy / d) * force
					end
				end
			end

			-- apply relaxation force
			px = px + fx * 0.02
			py = py + fy * 0.02

			-- wrap back into 0 to 1
			pts[i][1] = px - math.floor(px)
			pts[i][2] = py - math.floor(py)
		end
	end
end

-- generate new texture
local function generate()
	local mpts, mcols = {}, {}

	-- random points and colors
	for i = 1, main_n do
		mpts[i] = { math.random(), math.random() }

		local p = palette[math.random(#palette)]
		local v = (math.random() - 0.5) * 0.13

		mcols[i] = {
			math.max(0, math.min(1, p[1] + v)),
			math.max(0, math.min(1, p[2] + v)),
			math.max(0, math.min(1, p[3] + v)),
		}
	end

	-- relax distribution
	relaxPoints(mpts, 5, 0.18)

	-- send data to shader
	craqShader:send("mPts", unpack(mpts))
	craqShader:send("mCols", unpack(mcols))
	craqShader:send("res", { w, h })

	-- render into canvas
	canvas = love.graphics.newCanvas(w, h)
	love.graphics.setCanvas(canvas)
	love.graphics.setShader(craqShader)
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.rectangle("fill", 0, 0, w, h)
	love.graphics.setShader()
	love.graphics.setCanvas()
end

function love.load()
	-- init window
	love.window.setMode(w, h, { resizable = false, vsync = 1 })
	love.window.setTitle("fake craquelure")

	-- init random seed
	math.randomseed(os.time())

	-- compile shader and generate texture
	craqShader = love.graphics.newShader(frag)
	generate()
end

function love.draw()
	-- draw generated texture
	love.graphics.setColor(1, 1, 1, 1)
	love.graphics.draw(canvas)
end

function love.keypressed(k)
	-- regenerate or exit
	if k == "space" then
		generate()
	elseif k == "escape" then
		love.event.quit()
	end
end