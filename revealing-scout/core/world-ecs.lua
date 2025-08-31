-- core/ecs.lua
-- all comments in code are in english and lowercase

local ECS = {}
ECS.__index = ECS

-- create new ecs world
function ECS.newWorld()
	local world = setmetatable({}, ECS)
	world.entities = {}       -- stores all entities
	world.systems = {}        -- stores all systems
	world.nextEntityId = 1    -- unique id for each entity
	
	world.moving = false
	world.turnTimer = 0
	world.turnDuration = 1
	world.day = 1
	
	return world
end

-- add a system to the world
function ECS:addSystem(system, message)
	if message then
		print (message)
	end
	table.insert(self.systems, system)
	if system.init then
		system:init(self)
	end
end

-- create a new entity
function ECS:newEntity()
	local entity = {
		id = self.nextEntityId,
		components = {}
	}
	self.nextEntityId = self.nextEntityId + 1
	table.insert(self.entities, entity)
	return entity
end

-- add component to entity
function ECS:addComponent(entity, componentName, componentData)
--	print ('ECS:addComponent', componentName)
	entity.components[componentName] = componentData
end

-- get entities with specific components
function ECS:getEntitiesWithComponents(componentList)
	local result = {}
	for _, entity in ipairs(self.entities) do
		local hasAll = true
		for _, comp in ipairs(componentList) do
			if not entity.components[comp] then
				hasAll = false
				break
			end
		end
		if hasAll then
			table.insert(result, entity)
		end
	end
	return result
end

-- update all systems
function ECS:update(dt)
	for _, system in ipairs(self.systems) do
		if system.update then
			system:update(self, dt)
		end
	end
end

-- draw all systems
function ECS:draw()
	for _, system in ipairs(self.systems) do
		if system.draw then
			system:draw(self)
		end
	end
end

return ECS
