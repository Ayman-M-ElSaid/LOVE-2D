PlayState = Class({ __includes = BaseState })

local AISpeedFactor = (math.random() * 0.5 + 0.5)
local AIErrorMargin = math.random(-12.5, 12.5)

local function checkCollision()
    -- Paddles Collision
    local player1Collision = GameBall:collides(Player1)
    local player2Collision = GameBall:collides(Player2)

    if player1Collision or player2Collision then
        GameBall.dx = -GameBall.dx * 1.05
        GameBall.dy = GameBall.dy > 0 and math.random(20, 150) or -math.random(20, 150)
        Sounds["paddle_hit"]:play()
    end

    if player1Collision then
        GameBall.x = Player1.x + Player1.width
        AIErrorMargin = math.random(-12.5, 12.5)
    elseif player2Collision then
        GameBall.x = Player2.x - GameBall.width
        AISpeedFactor = (math.random() * 0.5 + 0.5)
    end

    --Ceiling Collisions
    if GameBall.y < 0 then
        GameBall.y = 0
        GameBall.dy = -GameBall.dy
        Sounds["wall_hit"]:play()
    elseif GameBall.y > VIRTUAL_HEIGHT - GameBall.height then
        GameBall.y = VIRTUAL_HEIGHT - GameBall.height
        GameBall.dy = -GameBall.dy
        Sounds["wall_hit"]:play()
    end
end

local function updateScores()
    local scorer

    if GameBall.x < -GameBall.width then
        scorer = 2
        ScoreFlash:trigger(0, 1)
    elseif GameBall.x > VIRTUAL_WIDTH then
        scorer = 1
        ScoreFlash:trigger(VIRTUAL_WIDTH, -1)
    end

    if scorer then
        Sounds["score"]:play()
        Scores[scorer] = Scores[scorer] + 1
        GameBall:reset()
        ServingPlayer = 3 - scorer -- the equation of the straight line joining the two points (scorer:ServingPlayer) = {(1,2),(2,1)} so that the other player serves next.
        if Scores[scorer] == WINNING_SCORE then
            Winner = scorer
            GameState:change("victory")
        else
            GameState:change("serve")
        end
    end
end

local function updateAI(dt)
    local targetY = GameBall.y + GameBall.height / 2 + AIErrorMargin
    local paddleCenterY = Player2.y + Player2.height / 2
    local distance = targetY - paddleCenterY
    if GameBall.dx > 0 then
        if math.abs(distance) > 5 then
            Player2.dy = (distance > 0 and 1 or -1) * PADDLE_SPEED * AISpeedFactor
        else
            Player2.dy = 0
        end
        Player2:update(dt)
    end
end

function PlayState:update(dt)
    Player1:handleInput(dt, "w", "s")
    if AI then
        updateAI(dt)
    else
        Player2:handleInput(dt, "up", "down")
    end
    GameBall:update(dt)
    checkCollision()
    updateScores()
end

function PlayState:render() end
