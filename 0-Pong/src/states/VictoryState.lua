VictoryState = Class({ __includes = BaseState })

function VictoryState:update(dt)
    if love.keyboard.wasPressed("space") then
        Scores = { 0, 0 }
        ServingPlayer = Winner == 1 and 2 or 1
        GameState:change("serve")
    end
end

function VictoryState:render()
    love.graphics.setFont(Fonts["medium"])
    love.graphics.printf(
        string.format("Player %d wins!", Winner),
        0,
        15,
        VIRTUAL_WIDTH,
        "center"
    )
    love.graphics.setFont(Fonts["small"])
    love.graphics.printf("Press Space to restart!", 0, 35, VIRTUAL_WIDTH, "center")
end
