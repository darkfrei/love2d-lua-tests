-- components/camera.lua
-- all comments in code are in english and lowercase

local Settings = require("settings")

local Camera = {}

function Camera.new(x, y)
	local self = {
		x = x or 0,
		y = y or 0,
		speed = Settings.cameraSpeed or 500,
		ox = 1280/2,
		oy = 800/2,
	}
	return self
end

return Camera
