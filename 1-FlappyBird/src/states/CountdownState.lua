CountdownState = Class({ __includes = BaseState })

local COUNTDOWN_TIME = 0.75

function CountdownState:init()
    self.count = 3
    self.timer = 0
    Sounds["countdown"]:play()
end

function Countdown(dt, count, timer)
    timer = timer + dt
    if timer >= COUNTDOWN_TIME then
        count = count - 1
        timer = 0
    end
    return count, timer
end

function CountdownState:update(dt)
    self.count, self.timer = Countdown(dt, self.count, self.timer)

    if self.count == 0 then
        GameState:change("play")
    end
end

function RenderCountdown(count)
    love.graphics.setFont(Fonts["huge"])
    love.graphics.printf(tostring(count), 0, 120, VIRTUAL_WIDTH, "center")
end

function CountdownState:render()
    RenderCountdown(self.count)
end
