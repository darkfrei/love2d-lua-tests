-- core/system.lua
-- all comments in code are in english and lowercase

local System = {}
System.__index = System

-- create a new system
function System.new()
    local self = setmetatable({}, System)
    return self
end

-- initialize the system (optional override)
function System:init(world)
    -- called once when the system is added to the world
    -- override in specific system if needed
end

-- update the system (optional override)
function System:update(world, dt)
    -- called every frame with dt
    -- override in specific system
end

-- draw the system (optional override)
function System:draw(world)
    -- called every frame
    -- override in specific system
end

return System
