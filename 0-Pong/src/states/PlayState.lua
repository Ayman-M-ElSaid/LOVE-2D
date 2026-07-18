PlayState = Class({ __includes = BaseState })

local function updatePlayersMovement(dt)
    -- Player 1 Movement
    if love.keyboard.isDown("w") then
        Player1.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("s") then
        Player1.dy = PADDLE_SPEED
    else
        Player1.dy = 0
    end
    Player1:update(dt)

    -- Player 2 Movement
    if love.keyboard.isDown("up") then
        Player2.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown("down") then
        Player2.dy = PADDLE_SPEED
    else
        Player2.dy = 0
    end
    Player2:update(dt)
end

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
    elseif player2Collision then
        GameBall.x = Player2.x - GameBall.width
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
        scorer = 1
        ScoreFlash:trigger(0, 1)
    elseif GameBall.x > VIRTUAL_WIDTH then
        scorer = 2
        ScoreFlash:trigger(VIRTUAL_WIDTH, -1)
    end

    if scorer then
        Sounds["score"]:play()
        Scores[scorer] = Scores[scorer] + 1
        GameBall:reset()
        ServingPlayer = scorer
        if Scores[scorer] == WINNING_SCORE then
            Winner = scorer
            GameState:change("victory")
        else
            GameState:change("serve")
        end
    end
end

function PlayState:update(dt)
    updatePlayersMovement(dt)
    GameBall:update(dt)
    checkCollision()
    updateScores()
end

function PlayState:render() end
