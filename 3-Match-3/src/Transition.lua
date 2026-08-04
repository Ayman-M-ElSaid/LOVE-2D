Transition = Class({})

Transition.alpha = 0

--- Transitions between two states with a white fade.
---@param nextState string The name of the state to transition to.
---@param params table? The parameters to pass to the next state.
---@param duration number? The transition duration in seconds. Defaults to 0.5.
function Transition.to(nextState, params, duration)
    duration = duration or 0.5
    Timer.tween(duration, { [Transition] = { alpha = 1 } }):finish(function()
        GameState:change(nextState, params)
        Timer.tween(duration, { [Transition] = { alpha = 0 } })
    end)
end

--- Renders the white fade overlay used during state transitions.
function Transition.render()
    if Transition.alpha > 0 then
        love.graphics.setColor(1, 1, 1, Transition.alpha)
        love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
        love.graphics.setColor(1, 1, 1, 1)
    end
end
