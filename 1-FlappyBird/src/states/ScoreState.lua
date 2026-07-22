ScoreState = Class({ __includes = BaseState })

function ScoreState:init()
    Scrolling = false
end

function ScoreState:enter(params)
    self.score = params.score
    love.timer.sleep(0.35)
end

function ScoreState:update(dt)
    if love.keyboard.wasPressed("space") or love.mouse.wasPressed(1) then
        GameState:change("countdown")
    end
end

function ScoreState:render()
    love.graphics.setFont(Fonts["flappy"])
    love.graphics.printf("Oof! You lost!", 0, 64, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(Fonts["medium"])
    love.graphics.printf(
        string.format("Score: %d", self.score),
        0,
        100,
        VIRTUAL_WIDTH,
        "center"
    )
    love.graphics.printf("Press Space to Play Again!", 0, 160, VIRTUAL_WIDTH, "center")
end
