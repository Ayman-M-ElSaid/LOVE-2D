PlayState = Class({ __includes = BaseState })

function PlayState:init()
    self.balls = {}
    self.powerUps = {}
end

local function checkLockedBricks(bricks)
    for _, brick in ipairs(bricks) do
        if brick.isLocked then
            return true
        end
    end
    return false
end

function PlayState:enter(params)
    self.paddle = params.paddle
    self.bricks = params.bricks
    table.insert(self.balls, params.ball)
    self.health = params.health
    self.score = params.score
    self.level = params.level
    self.hasLockedBricks = checkLockedBricks(self.bricks)
end

local function handlePause(self)
    if self.paused then
        if love.keyboard.wasPressed("space") or love.keyboard.wasPressed("p") then
            self.paused = false
            Sounds["pause"]:play()
        elseif love.keyboard.wasPressed("escape") then
            GameState:change("start")
            Sounds["wall-hit"]:play()
        end
    elseif love.keyboard.wasPressed("escape") or love.keyboard.wasPressed("p") then
        self.paused = true
        Sounds["pause"]:play()
    end
end

local function updateComponents(dt, self)
    self.paddle:update(dt)
    for _, ball in ipairs(self.balls) do
        ball:update(dt)
    end
    for _, brick in ipairs(self.bricks) do
        brick:update(dt)
    end
    for _, powerUp in ipairs(self.powerUps) do
        powerUp:update(dt)
    end
end

local function resetComponents(self)
    PaddleSpeed = 250
    self.paddle.size = 2
    self.paddle.width = 64
    self.balls[1]:changeScale(1)
    self.balls[1].dx = math.random(-250, 250)
    self.balls[1].dy = math.random(-50, -60)
    self.hasLockedBricks = checkLockedBricks(self.bricks)
end

local function checkPaddleCollision(self)
    for _, ball in ipairs(self.balls) do
        if
            not ball:collides(self.paddle)
            or ball.y > self.paddle.y + self.paddle.height - 4
        then
            goto continue
        end

        local penetrationX, penetrationY, offsetX, offsetY =
            ball:penetration(self.paddle)

        if penetrationY <= penetrationX then
            ball.y = ball.y + (offsetY > 0 and -penetrationY or penetrationY)
        else
            ball.x = ball.x + (offsetX > 0 and -penetrationX or penetrationX)
        end
        ball.dy = -math.abs(ball.dy)

        local paddleMovingLeft = self.paddle.dx < 0
        local paddleMovingRight = self.paddle.dx > 0
        local ballOffset = math.abs(ball.x - self.paddle.centerX)
        local minimumBounce, bounceMultiplier = 50, 8

        if ball.x < self.paddle.centerX and paddleMovingLeft then
            ball.dx = -minimumBounce - bounceMultiplier * ballOffset
        elseif ball.x > self.paddle.centerX and paddleMovingRight then
            ball.dx = minimumBounce + bounceMultiplier * ballOffset
        end

        Sounds["paddle-hit"]:play()
        ::continue::
    end
end

local function checkBricksCollision(self)
    for _, brick in ipairs(self.bricks) do
        for _, ball in ipairs(self.balls) do
            if ball:collides(brick) and brick.inPlay then
                if not brick.isLocked then
                    self.score = self.score + brick.score
                    brick:hit()
                    local chance = self.hasLockedBricks and math.random(10)
                        or math.random(15)
                    if chance == 1 then
                        table.insert(
                            self.powerUps,
                            PowerUp(
                                brick.centerX,
                                brick.centerY,
                                self.hasLockedBricks and POWER_UPS.KEY or nil
                            )
                        )
                    end
                else
                    Sounds["wall-hit"]:play()
                end

                local penetrationX, penetrationY, offsetX, offsetY =
                    ball:penetration(brick)

                if penetrationX < penetrationY then
                    ball.dx = -ball.dx
                    ball.x = ball.x + (offsetX > 0 and -penetrationX or penetrationX)
                else
                    ball.dy = -ball.dy
                    ball.y = ball.y + (offsetY > 0 and -penetrationY or penetrationY)
                end

                if math.abs(ball.dy) < 130 then
                    ball.dy = ball.dy * 1.02
                end
                break
            end
        end
    end
end

local function checkPowerUpsCollision(self)
    for _, powerUp in ipairs(self.powerUps) do
        if powerUp.inPlay and powerUp:collides(self.paddle) then
            powerUp:collect(self)
            self.hasLockedBricks = checkLockedBricks(self.bricks)
        end
    end
end

local function checkLoss(self)
    for i, ball in ipairs(self.balls) do
        if ball.y > VIRTUAL_HEIGHT then
            Sounds["hurt"]:play()
            if #self.balls ~= 1 then
                table.remove(self.balls, i)
            else
                self.health = self.health - 1
                if self.health ~= 0 then
                    resetComponents(self)
                    GameState:change("serve", {
                        paddle = self.paddle,
                        bricks = self.bricks,
                        ball = self.balls[1],
                        health = self.health,
                        score = self.score,
                        level = self.level,
                    })
                else
                    GameState:change("game-over", { score = self.score })
                end
            end
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

    updateComponents(dt, self)
    checkPaddleCollision(self)
    checkBricksCollision(self)
    checkPowerUpsCollision(self)
    checkLoss(self)
    if checkVictory(self) then
        Sounds["victory"]:play()
        resetComponents(self)
        GameState:change("victory", {
            level = self.level,
            paddle = self.paddle,
            ball = self.balls[1],
            health = self.health,
            score = self.score,
        })
    end
end

local function renderPauseMessage()
    love.graphics.setFont(Fonts["large"])
    love.graphics.printf("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(Fonts["medium"])
    love.graphics.printf(
        GetConfirmMessage() .. "to resume",
        0,
        VIRTUAL_HEIGHT / 2 + 10,
        VIRTUAL_WIDTH,
        "center"
    )
end

function PlayState:render()
    self.paddle:render()
    for _, ball in ipairs(self.balls) do
        ball:render()
    end
    for _, brick in ipairs(self.bricks) do
        brick:render()
        brick:renderParticles()
    end
    for _, powerUp in ipairs(self.powerUps) do
        powerUp:render()
    end

    RenderHealth(self.health)
    RenderScore(self.score)

    if self.paused then
        renderPauseMessage()
    end
end
