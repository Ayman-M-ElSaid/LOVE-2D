ServeState = Class({ __includes = BaseState })

function ServeState:init()
    self.showScore = true
    if not AI then
        self.message = string.format("Player %d's serve!", ServingPlayer)
    else
        self.message = ServingPlayer == 1 and "Player's serve!" or "AI's serve!"
    end
end

function ServeState:update(dt)
    GameBall.dx = ServingPlayer == 1 and math.random(140, 200) or -math.random(140, 200)
    GameBall.dy = math.random(-50, 50)

    Player1:handleInput(dt, "w", "s")
    if not AI then
        Player2:handleInput(dt, "up", "down")
    end

    if love.keyboard.wasPressed("space") then
        GameState:change("play")
    end
end

function ServeState:render()
    love.graphics.setFont(Fonts["small"])
    love.graphics.printf(self.message, 0, 15, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Press Space to serve!", 0, 25, VIRTUAL_WIDTH, "center")
end
