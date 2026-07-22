CountdownState = Class({ __includes = BaseState })

local COUNTDOWN_TIME = 0.75

function CountdownState:init()
    self.count = 3
    self.timer = 0
end

function CountdownState:update(dt)
    self.timer = self.timer + dt
    if self.timer >= COUNTDOWN_TIME then
        self.count = self.count - 1
        self.timer = 0
    end

    if self.count == 0 then
        GameState:change("play")
    end
end

function CountdownState:render()
    love.graphics.setFont(Fonts["huge"])
    love.graphics.printf(tostring(self.count), 0, 120, VIRTUAL_WIDTH, "center")
end
