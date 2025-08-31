-- core/entity.lua
-- all comments in code are in english and lowercase

local Entity = {}
Entity.__index = Entity

-- create a new entity in the given world
function Entity.new(world, comment)
	if comment then
	print ('Entity.new', comment)
	end
	local entity = setmetatable({}, Entity)
	entity.world = world                  -- reference to ecs world
	entity.id = world:newEntity().id     -- create entity in world
	print ('new entity id:', entity.id)
	entity.components = {}                -- local cache of components
	
	table.insert(world.entities, entity)
	return entity
end

-- add a component to the entity
function Entity:addComponent(name, data)
	self.components[name] = data
	self.world:addComponent({id = self.id, components = self.components}, name, data)
	return self
end

-- get a component from the entity
function Entity:getComponent(name)
	return self.components[name]
end

-- helper: create entity with multiple components at once
function Entity:create(world, components)
	local e = Entity.new(world)
	for name, data in pairs(components) do
		e:addComponent(name, data)
	end
	return e
end

return Entity
