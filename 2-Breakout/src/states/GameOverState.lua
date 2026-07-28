GameOverState = Class({ __includes = BaseState })

function GameOverState:enter(params)
    self.score = params.score
end

function GameOverState:update(dt)
    if
        love.keyboard.wasPressed("return")
        or love.keyboard.wasPressed("space")
        or love.mouse.wasPressed(1)
    then
        local highScore = false
        local highScoreIndex
        for i = 10, 1, -1 do
            local score = HighScores[i].score or 0
            if self.score > score then
                highScoreIndex = i
                highScore = true
            end
        end

        if highScore then
            Sounds["high-score"]:play()
            GameState:change("enter-high-score", {
                score = self.score,
                scoreIndex = highScoreIndex,
            })
        else
            GameState:change("start")
            Sounds["wall-hit"]:play()
        end
    end

    if love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end

function GameOverState:render()
    love.graphics.setFont(Fonts["large"])
    love.graphics.printf("GAME OVER", 0, VIRTUAL_HEIGHT / 3, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(Fonts["medium"])
    love.graphics.printf(
        "Final Score: " .. tostring(self.score),
        0,
        VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH,
        "center"
    )
    love.graphics.printf(
        GetConfirmMessage() .. "to Play Again!",
        0,
        VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 4,
        VIRTUAL_WIDTH,
        "center"
    )
end
