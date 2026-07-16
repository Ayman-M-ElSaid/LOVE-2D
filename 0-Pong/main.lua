Push = require("push")
Class = require("class")
require("Paddle")
require("Ball")

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200

function love.load()
    math.randomseed(os.time())

    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
    })
    love.window.setTitle("Pong")
    Push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })

    Fonts = {
        ["large"] = love.graphics.newFont("font.ttf", 32),
        ["medium"] = love.graphics.newFont("font.ttf", 24),
        ["small"] = love.graphics.newFont("font.ttf", 8),
    }

    Sounds = {
        ["paddle_hit"] = love.audio.newSource("sounds/paddle_hit.wav", "static"),
        ["score"] = love.audio.newSource("sounds/score.wav", "static"),
        ["wall_hit"] = love.audio.newSource("sounds/wall_hit.wav", "static"),
    }

    GameState = "start"
    ServingPlayer = math.random(2)
    Winner = nil

    Player1 = Paddle(15, VIRTUAL_HEIGHT / 2 - 10, 5, 20)
    Player2 = Paddle(VIRTUAL_WIDTH - 20, VIRTUAL_HEIGHT / 2 - 10, 5, 20)
    Player1Score = 0
    Player2Score = 0
    GameBall = Ball(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 4, 4)
end

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
    local player1Collision = GameBall:collides(Player1)
    local player2Collision = GameBall:collides(Player2)

    if player1Collision or player2Collision then
        GameBall.dx = -GameBall.dx * 1.05
        GameBall.dy = GameBall.dy > 0 and math.random(20, 150) or -math.random(20, 150)
        Sounds["paddle_hit"]:play()
    end

    if player1Collision then
        GameBall.x = Player1.x + Player1.width
    end
    if player2Collision then
        GameBall.x = Player2.x - GameBall.width
    end

    if GameBall.y < 0 then
        GameBall.y = 0
        GameBall.dy = -GameBall.dy
        Sounds["wall_hit"]:play()
    end
    if GameBall.y > VIRTUAL_HEIGHT - GameBall.height then
        GameBall.y = VIRTUAL_HEIGHT - GameBall.height
        GameBall.dy = -GameBall.dy
        Sounds["wall_hit"]:play()
    end
end

local function updateScores()   
    if GameBall.x < -GameBall.width then
        GameBall:reset()
        ServingPlayer = 1
        Player1Score = Player1Score + 1
        Sounds["score"]:play()
        if Player1Score == 5 then
            GameState = "victory"
            Winner = 1
        else
            GameState = "serve"
        end
    end
    if GameBall.x > VIRTUAL_WIDTH then
        GameBall:reset()
        ServingPlayer = 2
        Player2Score = Player2Score + 1
        Sounds["score"]:play()
        if Player2Score == 5 then
            GameState = "victory"
            Winner = 2
        else
            GameState = "serve"
        end
    end
end

local function displayFPS()
    love.graphics.setFont(Fonts["small"])
    love.graphics.setColor(0, 1, 0)
    love.graphics.print(string.format("FPS: %d", love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1)
end

local function renderMessages()
    love.graphics.setFont(Fonts["small"])
    if GameState == "start" then
        love.graphics.printf("Welcome to Pong!", 0, 15, VIRTUAL_WIDTH, "center")
        love.graphics.printf("Press Enter to begin!", 0, 25, VIRTUAL_WIDTH, "center")
    elseif GameState == "serve" then
        love.graphics.printf(
            string.format("Player %d's serve!", ServingPlayer),
            0,
            15,
            VIRTUAL_WIDTH,
            "center"
        )
        love.graphics.printf("Press Enter to serve!", 0, 25, VIRTUAL_WIDTH, "center")
    elseif GameState == "victory" then
        love.graphics.setFont(Fonts["medium"])
        love.graphics.printf(
            string.format("Player %d wins!", Winner),
            0,
            10,
            VIRTUAL_WIDTH,
            "center"
        )
        love.graphics.setFont(Fonts["small"])
        love.graphics.printf("Press Enter to restart!", 0, 35, VIRTUAL_WIDTH, "center")
    end
end

local function renderScore()
    love.graphics.setFont(Fonts["large"])
    love.graphics.printf(
        string.format("%d\t%d", Player1Score, Player2Score),
        0,
        50,
        VIRTUAL_WIDTH,
        "center"
    )
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    elseif key == "enter" or key == "return" then
        if GameState == "start" then
            GameState = "serve"
        elseif GameState == "serve" then
            GameState = "play"
        elseif GameState == "victory" then
            Player1Score = 0
            Player2Score = 0
            ServingPlayer = Winner == 1 and 2 or 1
            GameState = "serve"
        end
    end
end

function love.update(dt)
    if GameState == "serve" then
        GameBall.dx = ServingPlayer == 1 and math.random(140, 200) or -math.random(140, 200)
        GameBall.dy = math.random(-50, 50)
    elseif GameState == "play" then
        updatePlayersMovement(dt)
        GameBall:update(dt)
        checkCollision()
    end
    updateScores()
end

function love.draw()
    Push.start()

    love.graphics.setBackgroundColor(40 / 255, 45 / 255, 52 / 255)

    Player1:render()
    Player2:render()
    GameBall:render()

    renderMessages()
    renderScore()
    displayFPS()

    Push.finish()
end

function love.resize(w, h)
    Push.resize(w, h)
end

