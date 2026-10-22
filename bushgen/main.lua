-- main.lua
-- viewer for bushgen with smooth mutation animation
--
-- modes
--   styles:  every row is one random style, columns are different plants
--   focus:   the whole grid shows plants of the selected style
--   presets: every preset from data_plants.lua is one row (no animation)
--
-- keys
--   space          play / pause
--   left / right   rewind / forward while held (shift: faster)
--   r              reverse playback direction
--   home           back to time 0
--   + / -          animation speed
--   up / down      select style row (in focus mode: previous / next style)
--   m              focus on the selected style / back to all styles
--   tab            presets mode on / off
--   n              new world (new seeds for everything)
--   s              save grid as png, e: save grid 5x larger
--   wheel          zoom at mouse, drag with left mouse to move
--   h              help on / off, esc: quit

local bushgen = require("bushgen")
local plants = require("data_plants")
local variety = require("variety")

local TILE = 32
local COLS = 8
local ROWS = 9
local BUDGET = 0.012 -- seconds of tile generation per frame

local mode = "styles"
local world = 1
local selected = 1
local t = 0
local speed = 0.01 -- time units per frame at 60 fps
local dir = 1
local playing = true
local showHelp = true

local view = {x = 0, y = 0, scale = 2}
local dragging = false
local atlasData, atlasImage
local tiles = {}
local cursor = 1
local dirtyUpload = false
local exportSrc = nil
local EXPORT_SCALE = 5

---------------------------------------------------------------- grid

local function gridRows()
	if mode == "presets" then return #plants end
	return ROWS
end

local function styleSeed(row)
	return world * 1009 + row * 7919 + 17
end

-- description of one tile: which style and plant seeds it uses
local function tileRecipe(row, col)
	if mode == "presets" then
		return {preset = plants[row], seed = world * 100003 + row * 1301 + col * 97 + 5}
	end
	if mode == "focus" then
		local index = (row - 1) * COLS + col
		return {style = styleSeed(selected), seed = world * 100003 + selected * 1301 + index * 97 + 5}
	end
	return {style = styleSeed(row), seed = world * 100003 + row * 1301 + col * 97 + 5}
end

local function buildGrid()
	local rows = gridRows()
	atlasData = love.image.newImageData(COLS * TILE, rows * TILE)
	atlasImage = love.graphics.newImage(atlasData)
	atlasImage:setFilter("nearest", "nearest")
	tiles = {}
	for row = 1, rows do
		for col = 1, COLS do
			local tl = tileRecipe(row, col)
			tl.row, tl.col = row, col
			tl.doneT = nil
			tiles[#tiles + 1] = tl
		end
	end
	cursor = 1
end

local function renderTile(tl)
	local preset
	if tl.preset then
		preset = tl.preset
	else
		local st = variety.makeStyle(tl.style, t)
		preset = variety.makePlant(st, tl.seed, t)
	end
	local img = bushgen.generate(preset, tl.seed, TILE, TILE)
	local px = img.pixels
	local ox, oy = (tl.col - 1) * TILE, (tl.row - 1) * TILE
	for y = 0, TILE - 1 do
		for x = 0, TILE - 1 do
			local o = (y * TILE + x) * 4
			atlasData:setPixel(ox + x, oy + y, px[o + 1], px[o + 2], px[o + 3], px[o + 4])
		end
	end
	tl.doneT = t
	dirtyUpload = true
end

-- renders tiles that are behind the current time, round robin, until
-- the frame budget is used; presets do not depend on time
local function updateTiles()
	local start = love.timer.getTime()
	local n = #tiles
	for _ = 1, n do
		local tl = tiles[cursor]
		cursor = cursor % n + 1
		local stale = tl.doneT == nil or (not tl.preset and tl.doneT ~= t)
		if stale then
			renderTile(tl)
			if love.timer.getTime() - start > BUDGET then break end
		end
	end
	if dirtyUpload then
		atlasImage:replacePixels(atlasData)
		dirtyUpload = false
	end
end

---------------------------------------------------------------- view

local function fitView()
	local w, h = love.graphics.getDimensions()
	local gw, gh = COLS * TILE, gridRows() * TILE
	view.scale = math.max(1, math.floor(math.min((w - 140) / gw, (h - 60) / gh)))
	view.x = math.floor((w - gw * view.scale) / 2 + 40)
	view.y = math.floor((h - gh * view.scale) / 2)
end

---------------------------------------------------------------- export

local function upscalePixel(x, y)
	return exportSrc:getPixel(math.floor(x / EXPORT_SCALE), math.floor(y / EXPORT_SCALE))
end

local function saveGrid(factor)
	local name = string.format("bushgen_%s_w%d_t%.2f", mode, world, t)
	local data = atlasData
	if factor > 1 then
		exportSrc = atlasData
		data = love.image.newImageData(atlasData:getWidth() * factor, atlasData:getHeight() * factor)
		data:mapPixel(upscalePixel)
		name = name .. "_x" .. factor
	end
	name = name .. ".png"
	data:encode("png", name)
	print("saved " .. love.filesystem.getSaveDirectory() .. "/" .. name)
end

---------------------------------------------------------------- love

function love.load()
	love.graphics.setDefaultFilter("nearest", "nearest")
	local dw, dh = love.window.getDesktopDimensions()
	love.window.setMode(math.floor(dw * 0.85), math.floor(dh * 0.85), {resizable = true})
	love.window.setTitle("bushgen")
	buildGrid()
	fitView()
end

function love.update(dt)
	local step = speed * dt * 60
	local fast = love.keyboard.isDown("lshift", "rshift") and 5 or 1
	if love.keyboard.isDown("left") then
		t = t - step * 4 * fast
	elseif love.keyboard.isDown("right") then
		t = t + step * 4 * fast
	elseif playing and mode ~= "presets" then
		t = t + step * dir
	end
	updateTiles()
end

function love.keypressed(key)
	if key == "space" then
		playing = not playing
	elseif key == "r" then
		dir = -dir
	elseif key == "home" then
		t = 0
	elseif key == "=" or key == "+" or key == "kp+" then
		speed = math.min(0.2, speed * 1.5)
	elseif key == "-" or key == "kp-" then
		speed = math.max(0.0005, speed / 1.5)
	elseif key == "up" or key == "down" then
		local d = key == "up" and -1 or 1
		if mode == "focus" then
			selected = math.max(1, selected + d)
			buildGrid()
		elseif mode == "styles" then
			selected = math.max(1, math.min(ROWS, selected + d))
		end
	elseif key == "m" then
		if mode == "styles" then
			mode = "focus"
		elseif mode == "focus" then
			mode = "styles"
			selected = math.min(selected, ROWS)
		end
		buildGrid()
	elseif key == "tab" then
		mode = mode == "presets" and "styles" or "presets"
		selected = math.min(selected, ROWS)
		buildGrid()
		fitView()
	elseif key == "n" then
		world = world + 1
		buildGrid()
	elseif key == "s" then
		saveGrid(1)
	elseif key == "e" then
		saveGrid(EXPORT_SCALE)
	elseif key == "h" then
		showHelp = not showHelp
	elseif key == "escape" then
		love.event.quit()
	end
end

-- zoom in integer steps, keeping the point under the mouse in place
function love.wheelmoved(_, dy)
	local mx, my = love.mouse.getPosition()
	local old = view.scale
	local new = math.max(1, math.min(32, old + (dy > 0 and 1 or -1)))
	if new == old then return end
	local wx, wy = (mx - view.x) / old, (my - view.y) / old
	view.x = math.floor(mx - wx * new + 0.5)
	view.y = math.floor(my - wy * new + 0.5)
	view.scale = new
end

function love.mousepressed(_, _, button)
	if button == 1 then dragging = true end
end

function love.mousereleased(_, _, button)
	if button == 1 then dragging = false end
end

function love.mousemoved(_, _, dx, dy)
	if dragging then
		view.x = view.x + dx
		view.y = view.y + dy
	end
end

function love.draw()
	love.graphics.clear(0.5, 0.5, 0.5)
	local s = view.scale
	love.graphics.setColor(1, 1, 1)
	love.graphics.draw(atlasImage, view.x, view.y, 0, s, s)
	-- row labels and selection frame
	local rows = gridRows()
	for row = 1, rows do
		local y = view.y + (row - 1) * TILE * s
		local label
		if mode == "presets" then
			label = plants[row].name
		elseif mode == "focus" then
			label = row == 1 and ("style " .. selected) or ""
		else
			label = "style " .. row
		end
		if mode == "styles" and row == selected then
			love.graphics.setColor(1, 1, 0.6)
			love.graphics.rectangle("line", view.x - 1, y - 1, COLS * TILE * s + 2, TILE * s + 2)
		else
			love.graphics.setColor(0.1, 0.1, 0.1)
		end
		love.graphics.print(label, view.x - 70, y + TILE * s / 2 - 6)
	end
	-- status line
	love.graphics.setColor(0.08, 0.08, 0.08)
	local h = love.graphics.getHeight()
	local state = playing and (dir > 0 and "play" or "play back") or "pause"
	love.graphics.print(string.format("%s   t %.2f   speed %.4f   %s   world %d   zoom %dx",
		mode, t, speed, state, world, s), 10, h - 22)
	if showHelp then
		love.graphics.print("space play/pause   left/right rewind/forward (shift faster)   r reverse   home t=0   +/- speed\n"
			.. "up/down style   m focus style   tab presets   n new world   s save png   e save x5   wheel zoom, drag move   h help",
			10, 8)
	end
end
