GameOverState = Class({ __includes = BaseState })

local textColors = { { 0.08, 0.20, 0.16, 0.65 }, { 1.0, 0.82, 0.39, 1.0 } }

function GameOverState:init()
    self.button = Layout.gameOverState.button
end

function GameOverState:enter(params)
    self.accumulativeScore = params.accumulativeScore
    if self.accumulativeScore > (Progress[0] or 0) then
        self.isHighScore = true
        Progress[0] = self.accumulativeScore
        Save.write(Progress)
    end
    self.msg = self.isHighScore and "New High Score!"
        or string.format("High Score: %d", Progress[0])
end

function GameOverState:update(dt)
    if self.button:isClicked() then
        Transition.to("start")
    end
end

function GameOverState:render()
    for i, color in ipairs(textColors) do
        love.graphics.setColor(color)
        love.graphics.setFont(Fonts["title"])
        PrintfScaled(
            "GAME OVER",
            -2 * (i - 1),
            Layout.gameOverState.titleY - 2 * (i - 1),
            VIRTUAL_WIDTH,
            "center"
        )
        love.graphics.setFont(Fonts["large"])
        PrintfScaled(
            string.format("<Your Score: %d>", self.accumulativeScore),
            -2 * (i - 1),
            Layout.gameOverState.score - 2 * (i - 1),
            VIRTUAL_WIDTH,
            "center"
        )
        love.graphics.setFont(Fonts["meduim"])
        PrintfScaled(
            self.msg,
            -2 * (i - 1),
            Layout.gameOverState.highScore - 2 * (i - 1),
            VIRTUAL_WIDTH,
            "center"
        )
    end

    self.button:render()
end
