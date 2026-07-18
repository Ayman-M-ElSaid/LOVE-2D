ServeState = Class({ __includes = BaseState })

function ServeState:update(dt)
    GameBall.dx = ServingPlayer == 1 and math.random(140, 200) or -math.random(140, 200)
    GameBall.dy = math.random(-50, 50)

    if love.keyboard.wasPressed("space") then
        GameState:change("play")
    end
end

function ServeState:render()
    love.graphics.setFont(Fonts["small"])
    love.graphics.printf(
        string.format("Player %d's serve!", ServingPlayer),
        0,
        15,
        VIRTUAL_WIDTH,
        "center"
    )
    love.graphics.printf("Press Space to serve!", 0, 25, VIRTUAL_WIDTH, "center")
end
