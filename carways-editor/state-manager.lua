-- [manages game states and transitions]

local StateManager = {}
StateManager.currentState = nil
StateManager.currentStateName = nil


function StateManager.switchState(newState, stateName)
	-- [switches to a new state and initializes it]
	if StateManager.currentState and StateManager.currentState.exit then
		StateManager.currentState.exit()
	end
	
	StateManager.currentState = newState
	StateManager.currentStateName = stateName
	
	if StateManager.currentState and StateManager.currentState.enter then
		StateManager.currentState.enter()
	end
	
--	for i, v in pairs (StateManager) do
--		print ('StateManager', i, stateName)
--	end
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

function StateManager.handleEvent(eventName, ...)
	-- [handles events in the current state]
	if StateManager.currentState and StateManager.currentState[eventName] then
		StateManager.currentState[eventName](...)
	end
end

return StateManager
