StateMachine = Class({})

function StateMachine:init(states)
    self.states = states or {}
    self.current = BaseState
end

function StateMachine:change(stateName, enterParams)
    assert(self.states[stateName])
    self.current = self.states[stateName]()
    self.current:enter(enterParams)
end

function StateMachine:update(dt)
    self.current:update(dt)
end

function StateMachine:render()
    self.current:render()
end
