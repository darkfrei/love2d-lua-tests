-- init.lua
local validator = require('questlib.validator')
local runtime   = require('questlib.runtime')
local serializer = require('questlib.serializer')

local questlib = {}

function questlib.load(data)
	if type(data) ~= 'table' then
		error("[questlib] load() requires a table")
	end
	print("[questlib] load() called")
	local err = validator.validate_quest(data)
	if err then
		print("[questlib] validation failed:", tostring(err))
		error(err)
	end

	print("[questlib] validation passed. initializing runtime...")
	runtime.load_quest(data)

	print("[questlib] entering start node:", data.start_node)
	local result = runtime.enter_node(data.start_node)

	print("[questlib] start node loaded. choices available:", result and #result.choices or 0)
	return result
end

function questlib.step()
	local id = runtime.get_current_id()
	if not id then return nil end
	return runtime.enter_node(id)
end

function questlib.choose(index)
	if type(index) ~= 'number' or index < 1 then
		print("[questlib] choose() invalid index:", tostring(index))
		return nil
	end
	local result = runtime.choose(index)
	if result then
		print("[questlib] choice executed. new node:", result.id)
	else
		print("[questlib] choice failed: disabled, consumed, or target hidden.")
	end
	return result
end

function questlib.get_state()
	return runtime.get_state()
end

function questlib.set_state(t)
	if type(t) == 'table' then
		runtime.set_state(t)
	end
end

function questlib.save_state(path)
	if type(path) ~= 'string' then return false, "path must be string" end
	print("[questlib] saving state to:", path)
	return serializer.save_table(path, runtime.get_state())
end

function questlib.load_state(path)
	if type(path) ~= 'string' then return false, "path must be string" end
	print("[questlib] loading state from:", path)
	local state, err = serializer.load_table(path)
	if not state then
		print("[questlib] load failed:", tostring(err))
		return false, err
	end
	runtime.set_state(state)
	print("[questlib] state loaded successfully.")
	return true
end

function questlib.reset()
	print("[questlib] full reset.")
	runtime.reset()
end

return questlib