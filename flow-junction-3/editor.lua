-- editor.lua
-- scene manager: highway network graph editor

local Camera   = require("core.camera")
local Renderer = require("core.renderer")
local Map      = require("core.map")
local Exporter    = require("editor.exporter")
local FileManager = require("editor.filemanager")

local UIHub    = require("ui.ui")
local Tools    = require("editor.tools")

local Editor = {}

Editor.camera   = nil
Editor.map      = nil
Editor.ui       = nil
Editor.tools    = nil
Editor.app      = nil

Editor.selectedNode = nil
Editor.hoveredNode  = nil
Editor.selectedWay  = nil
Editor.hoveredWay   = nil
Editor.snapToGrid   = false

Editor.drag = {
	active  = false,
	nodeId  = nil,
	startWX = 0,
	startWY = 0,
}

Editor.notification = {
	text  = "",
	timer = 0,
}

--
-- load
--

function Editor.load(appContext)
	Editor.app    = appContext
	Editor.camera = Camera.new()
	Editor.map    = Map.new()
	Editor.tools  = Tools.new(Editor)
	Editor.ui     = UIHub.new(Editor, "editor")

	-- auto-load example.lua
	local ok, err = Map.loadFromFile(Editor.map, "example.lua")

	if ok then
		Editor.notify("loaded example.lua")
	else
		Map.loadDefault(Editor.map)
		Editor.notify("example.lua not found -> default loaded")
	end

	-- center camera
	Editor.camera:fitAll(Editor.map)

	Editor.notify("editor loaded | scroll - zoom | rmb/mmb - pan")
end

--
-- update
--

function Editor.update(dt)
	if Editor.notification.timer > 0 then
		Editor.notification.timer = Editor.notification.timer - dt
	end

	if Editor.ui then
		Editor.ui:update(dt)
	end

	local mx, my = love.mouse.getPosition()
	local wx, wy = Editor.camera:toWorld(mx, my)

	if mx > 220 then
		local radius = 15 / Editor.camera.scale
		local candidate = Map.nodeAt(Editor.map, wx, wy, radius)

		if candidate then
			-- control-point nodes are only hoverable if their bezier way is selected
			local ctrlSet = Map.getControlNodeSet(Editor.map)
			if ctrlSet[candidate] then
				-- only allow hover if selectedWay contains this control node
				local wayCtrl = Editor.selectedWay and
				Map.getControlNodeSetForWay(Editor.map, Editor.selectedWay)
				if wayCtrl and wayCtrl[candidate] then
					Editor.hoveredNode = candidate
				else
					Editor.hoveredNode = nil
				end
			else
				Editor.hoveredNode = candidate
			end
		else
			Editor.hoveredNode = nil
		end

		if not Editor.hoveredNode then
			Editor.hoveredWay = Map.wayAt(Editor.map, wx, wy, radius)
		else
			Editor.hoveredWay = nil
		end
	else
		Editor.hoveredNode = nil
		Editor.hoveredWay  = nil
	end
end

--
-- draw
--

function Editor.draw()
	Renderer.drawBackground()

	Editor.camera:apply()

	Renderer.drawBgImage(Editor.map)
	if Renderer.showGrid then Renderer.drawGrid(Editor.camera) end
	Renderer.drawWays(Editor.map, Editor)
	Renderer.drawNodes(Editor.map, Editor)
	Renderer.drawEditorOverlay(Editor)
	-- layer badges drawn last so they appear on top of road geometry
	Renderer.drawLayerBadges(Editor.map)

	Editor.camera:pop()

	if Editor.ui then
		Editor.ui:draw()
	end

	if Editor.notification.timer > 0 then
		love.graphics.setColor(1, 1, 1, math.min(1, Editor.notification.timer * 2))

		if UIHub.font and UIHub.font.normal then
			love.graphics.setFont(UIHub.font.normal)
		end

		love.graphics.print(Editor.notification.text, 240, love.graphics.getHeight() - 30)
	end
end

--
-- input
--

function Editor.mousepressed(x, y, button)
	if Editor.ui and Editor.ui:mousepressed(x, y, button) then return end
	if Editor.tools then
		Editor.tools:mousepressed(x, y, button)
	end
end

function Editor.mousereleased(x, y, button)
	if Editor.ui and Editor.ui:mousereleased(x, y, button) then return end
	if Editor.tools then
		Editor.tools:mousereleased(x, y, button)
	end
end

function Editor.mousemoved(x, y, dx, dy)
	if Editor.ui and Editor.ui:mousemoved(x, y, dx, dy) then return end
	if Editor.tools then
		Editor.tools:mousemoved(x, y, dx, dy)
	end
end

function Editor.wheelmoved(x, y)
	if Editor.ui and Editor.ui:wheelmoved(x, y) then return end
	if Editor.tools and Editor.tools:wheelmoved(y) then return end

	local mx, my = love.mouse.getPosition()
	if mx > 220 then
		Editor.camera:zoom(y, mx, my)
	end
end

--
-- keyboard
--

function Editor.keypressed(key)
	if Editor.ui and Editor.ui:keypressed(key) then return end
	if Editor.tools and Editor.tools:keypressed(key) then return end

	if key == "delete" or key == "backspace" then
		if Editor.selectedNode then
			Map.removeNode(Editor.map, Editor.selectedNode)
			Editor.selectedNode = nil
			Editor.notify("node removed")

		elseif Editor.selectedWay then
			local idx = Editor.selectedWay
			Map.removeWay(Editor.map, idx)
			Editor.selectedWay = nil
			Editor.notify("way removed")
		end

	elseif key == "escape" then
		Editor.selectedNode = nil
		Editor.selectedWay  = nil

		if Editor.tools then
			Editor.tools:cancel()
		end

		Editor.notify("operation cancelled")

	elseif key == "e" then
		Exporter.exportLua(Editor.map)
		Editor.notify("map saved to output.lua")

	elseif key == "r" then
		Map.loadDefault(Editor.map)
		Editor.selectedNode = nil
		Editor.selectedWay  = nil
		Editor.camera:fitAll(Editor.map)
		Editor.notify("map reset")

	elseif key == "f" then
		Editor.camera:fitAll(Editor.map)
		Editor.notify("camera focused")

	elseif key == "o" then
		print("Editor.keypressed", "openSaveFolder")
		Editor.openSaveFolder()
		Editor.notify("opened save folder")

	elseif key == "c" then
		Renderer.showCurvature = not Renderer.showCurvature
		Editor.notify("curvature comb: " .. (Renderer.showCurvature and "on" or "off"))
	end
end

--
-- text input
--

function Editor.textinput(t)
	if Editor.ui then
		Editor.ui:textinput(t)
	end
end

-- drag and drop a PNG file onto the window to set it as background image
function Editor.filedropped(file)
	local path = file:getFilename()
	local ext  = path:match("%.(%a+)$")
	if not ext or ext:lower() ~= "png" then
		Editor.notify("only PNG files can be dropped here")
		return
	end

	local fname = path:match("([^/\\]+)$") or "bg.png"

	local ok, err = FileManager.importImageData(file, fname)
	if not ok then
		Editor.notify("drop import failed: " .. tostring(err))
		return
	end

	local img, ierr = FileManager.loadImage(fname)
	if not img then
		Editor.notify("drop load failed: " .. tostring(ierr))
		return
	end

	local meta = Editor.map.meta
	meta.bgFile    = fname
	meta.bgImage   = img
	meta.bgScale   = meta.bgScale   or 1.0
	meta.bgOffsetX = meta.bgOffsetX or 0
	meta.bgOffsetY = meta.bgOffsetY or 0

	Editor.notify("background image set: " .. fname)
end

--
-- helpers
--

function Editor.notify(text)
	Editor.notification.text  = tostring(text)
	Editor.notification.timer = 3.5
end

function Editor.openSaveFolder()
	local path = love.filesystem.getSaveDirectory()
	love.system.openURL("file://" .. path)
end

return Editor