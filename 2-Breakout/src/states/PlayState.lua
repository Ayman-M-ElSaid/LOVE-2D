PlayState = Class({ __includes = BaseState })

function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    self.ball = params.ball
    self.health = params.health
    self.score = params.score
    self.level = params.level

    self.ball.dx = math.random(-250, 250)
    self.ball.dy = math.random(-50, -60)
end

local function handlePause(self)
    if self.paused then
        if love.keyboard.wasPressed("space") or love.keyboard.wasPressed("p") then
            self.paused = false
            Sounds["pause"]:play()
        elseif love.keyboard.wasPressed("escape") then
            GameState:change("start")
        end
    elseif love.keyboard.wasPressed("escape") or love.keyboard.wasPressed("p") then
        self.paused = true
        Sounds["pause"]:play()
    end
end

local function checkPaddleCollision(dt, self)
    if self.ball:collides(self.paddle) then
        self.ball.y = self.paddle.y - 8
        self.ball.dy = -self.ball.dy

        local paddleMovingLeft = self.paddle.dx < 0
        local paddleMovingRight = self.paddle.dx > 0
        local ballOffset = math.abs(self.ball.x - self.paddle.centerX)
        local minimumBounce = 50
        local bounceMyltiplier = 8

        if self.ball.x < self.paddle.centerX and paddleMovingLeft then
            self.ball.dx = -minimumBounce - bounceMyltiplier * ballOffset
        elseif self.ball.x > self.paddle.centerX and paddleMovingRight then
            self.ball.dx = minimumBounce + bounceMyltiplier * ballOffset
        end

        Sounds["paddle-hit"]:play()
    end
end

local function checkBricksCollision(dt, self)
    for _, brick in ipairs(self.bricks) do
        if self.ball:collides(brick) and brick.inPlay then
            self.score = self.score + brick.score
            brick:hit()

            local BALL_RADIUS = 4
            local ballCenterX = self.ball.x + BALL_RADIUS
            local ballCenterY = self.ball.y + BALL_RADIUS
            local offsetX = brick.centerX - ballCenterX
            local offsetY = brick.centerY - ballCenterY
            local penetrationX = brick.width / 2 + BALL_RADIUS - math.abs(offsetX)
            local penetrationY = brick.height / 2 + BALL_RADIUS - math.abs(offsetY)

            if penetrationX < penetrationY then
                self.ball.dx = -self.ball.dx
                self.ball.x = self.ball.x
                    + (offsetX > 0 and -penetrationX or penetrationX)
            else
                self.ball.dy = -self.ball.dy
                self.ball.y = self.ball.y
                    + (offsetY > 0 and -penetrationY or penetrationY)
            end

            if math.abs(self.ball.dy) < 130 then
                self.ball.dy = self.ball.dy * 1.02
            end
            break
        end
    end
end

local function checkVictory(self)
    for _, brick in ipairs(self.bricks) do
        if brick.inPlay then
            return false
        end
    end
    return true
end

function PlayState:update(dt)
    handlePause(self)
    if self.paused then
        return
    end

    checkPaddleCollision(dt, self)
    checkBricksCollision(dt, self)

    self.paddle:update(dt)
    self.ball:update(dt)
    for _, brick in ipairs(self.bricks) do
        brick:update(dt)
    end

    if checkVictory(self) then
        Sounds["victory"]:play()
        GameState:change("victory", {
            level = self.level,
            paddle = self.paddle,
            ball = self.ball,
            health = self.health,
            score = self.score,
        })
    end

    if self.ball.y > VIRTUAL_HEIGHT then
        self.health = self.health - 1
        Sounds["hurt"]:play()

        if self.health ~= 0 then
            GameState:change("serve", {
                paddle = self.paddle,
                bricks = self.bricks,
                ball = self.ball,
                health = self.health,
                score = self.score,
                level = self.level,
            })
        else
            GameState:change("game-over", { score = self.score })
        end
    end
end

local function renderPauseMessage()
    love.graphics.setFont(Fonts["large"])
    love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(Fonts["medium"])
    love.graphics.printf(
        "press space to resume",
        0,
        VIRTUAL_HEIGHT / 2 + 10,
        VIRTUAL_WIDTH,
        "center"
    )
end

function PlayState:render()
    self.paddle:render()
    self.ball:render()
    for _, brick in ipairs(self.bricks) do
        brick:render()
        brick:renderParticles()
    end

    RenderHealth(self.health)
    RenderScore(self.score)

    if self.paused then
        renderPauseMessage()
    end
end
