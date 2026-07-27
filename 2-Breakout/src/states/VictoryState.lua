VictoryState = Class({ __includes = BaseState })

function VictoryState:enter(params)
    self.level = params.level
    self.score = params.score
    self.paddle = params.paddle
    self.health = params.health
    self.ball = params.ball
end

function VictoryState:update(dt)
    self.paddle:update(dt)
    self.ball.x = self.paddle.x + (self.paddle.width / 2) - 4
    self.ball.y = self.paddle.y - 8

    if love.keyboard.wasPressed("return") or love.keyboard.wasPressed("space") then
        GameState:change("serve", {
            level = self.level + 1,
            bricks = LevelMaker.createMap(self.level + 1),
            ball = self.ball,
            paddle = self.paddle,
            health = self.health,
            score = self.score,
        })
    elseif love.keyboard.wasPressed("escape") then
        GameState:change("start")
    end
end

function VictoryState:render()
    self.paddle:render()
    self.ball:render()

    RenderHealth(self.health)
    RenderScore(self.score)

    love.graphics.setFont(Fonts["large"])
    love.graphics.printf(
        string.format("Level %d complete!", self.level),
        0,
        VIRTUAL_HEIGHT / 4,
        VIRTUAL_WIDTH,
        "center"
    )
    love.graphics.setFont(Fonts["medium"])
    love.graphics.printf(
        "Press Space to serve!",
        0,
        VIRTUAL_HEIGHT / 2,
        VIRTUAL_WIDTH,
        "center"
    )
end
