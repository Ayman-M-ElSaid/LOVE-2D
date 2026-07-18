StateMachine = Class({})

function StateMachine:init(states)
    self.states = states or {}
    self.current = BaseState
end

function StateMachine:change(stateName)
    assert(self.states[stateName])
    self.current = self.states[stateName]()
end

function StateMachine:update(dt)
    self.current:update(dt)
end

function StateMachine:render()
    self.current:render()
end
