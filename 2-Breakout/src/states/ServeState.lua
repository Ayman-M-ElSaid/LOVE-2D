ServeState = Class({ __includes = BaseState })

function ServeState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.ball = params.ball
    self.health = params.health
    self.score = params.score
    self.level = params.level
end

function ServeState:update(dt)
    self.paddle:update(dt)
    self.ball.x = self.paddle.centerX - self.ball.width / 2
    self.ball.y = self.paddle.y - 8

    if
        love.keyboard.wasPressed("return")
        or love.keyboard.wasPressed("space")
        or love.mouse.wasPressed(1)
    then
        GameState:change("play", {
            paddle = self.paddle,
            bricks = self.bricks,
            ball = self.ball,
            health = self.health,
            score = self.score,
            level = self.level,
        })
    elseif love.keyboard.wasPressed("escape") then
        GameState:change("start")
        Sounds["wall-hit"]:play()
    end
end

function ServeState:render()
    self.paddle:render()
    self.ball:render()
    for _, brick in ipairs(self.bricks) do
        brick:render()
    end

    RenderHealth(self.health)
    RenderScore(self.score)

    love.graphics.setFont(Fonts["large"])
    love.graphics.printf(
        string.format("Level %d", self.level),
        0,
        VIRTUAL_HEIGHT / 3 + 20,
        VIRTUAL_WIDTH,
        "center"
    )
    love.graphics.setFont(Fonts["medium"])
    love.graphics.printf(
        GetConfirmMessage() .. "to serve!",
        0,
        VIRTUAL_HEIGHT / 2 + 20,
        VIRTUAL_WIDTH,
        "center"
    )
end
