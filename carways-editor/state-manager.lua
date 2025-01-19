-- [manages game states and transitions]

local StateManager = {}
StateManager.currentState = nil

function StateManager.switchState(newState)
	-- [switches to a new state and initializes it]
	if StateManager.currentState and StateManager.currentState.exit then
		StateManager.currentState.exit()
	end
	StateManager.currentState = newState
	if StateManager.currentState and StateManager.currentState.enter then
		StateManager.currentState.enter()
	end
	for i, v in pairs (StateManager) do
		print ('StateManager', i, v)
	end
end

function StateManager.update(dt)
	-- [updates the current state]
	if StateManager.currentState and StateManager.currentState.update then
		StateManager.currentState.update(dt)
	end
end

function StateManager.draw()
	-- [draws the current state]
	if StateManager.currentState and StateManager.currentState.draw then
		StateManager.currentState.draw()
	end
end

function StateManager.handleEvent(event, ...)
	-- [handles events in the current state]
	if StateManager.currentState and StateManager.currentState[event] then
		StateManager.currentState[event](...)
	end
end

return StateManager
