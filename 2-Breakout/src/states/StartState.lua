StartState = Class({ __includes = BaseState })

function StartState:init()
    self.highlighted = 1
end

function StartState:update(dt)
    if
        love.keyboard.wasPressed("up")
        or love.keyboard.wasPressed("down")
        or love.keyboard.wasPressed("w")
        or love.keyboard.wasPressed("s")
    then
        self.highlighted = 3 - self.highlighted -- inversion interpolation: y = 3 - x (1 ↔ 2)
        Sounds["paddle-hit"]:play()
    end

    if love.keyboard.wasPressed("return") or love.keyboard.wasPressed("space") then
        Sounds["confirm"]:play()
        if self.highlighted == 1 then
            GameState:change("paddle-select")
        else
            GameState:change("high-scores")
        end
    end

    if love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end

function StartState:render()
    love.graphics.setFont(Fonts["large"])
    love.graphics.printf("BREAKOUT", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(Fonts["medium"])
    love.graphics.setColor(self.highlighted == 1 and { 103 / 255, 1, 1 } or { 1, 1, 1 })
    love.graphics.printf("START", 0, VIRTUAL_HEIGHT / 2 + 70, VIRTUAL_WIDTH, "center")
    love.graphics.setColor(self.highlighted == 2 and { 103 / 255, 1, 1 } or { 1, 1, 1 })
    love.graphics.printf(
        "HIGH SCORES",
        0,
        VIRTUAL_HEIGHT / 2 + 90,
        VIRTUAL_WIDTH,
        "center"
    )
    love.graphics.setColor(1, 1, 1) -- reset
end
