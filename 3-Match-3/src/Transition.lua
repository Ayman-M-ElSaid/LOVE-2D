Transition = Class({})

Transition.alpha = 0

function Transition.to(nextState, params, duration)
    duration = duration or 0.5
    Timer.tween(duration, { [Transition] = { alpha = 1 } }):finish(function()
        GameState:change(nextState, params)
        Timer.tween(duration, { [Transition] = { alpha = 0 } })
    end)
end

function Transition.render()
    if Transition.alpha > 0 then
        love.graphics.setColor(1, 1, 1, Transition.alpha)
        love.graphics.rectangle("fill", 0, 0, VIRTUAL_WIDTH, VIRTUAL_HEIGHT)
        love.graphics.setColor(1, 1, 1, 1)
    end
end
