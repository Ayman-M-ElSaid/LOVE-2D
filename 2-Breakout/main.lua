require("src.dependencies")

local function loadHighScores()
    love.filesystem.setIdentity("Breakout")

    if not love.filesystem.getInfo("breakout.dat") then
        local scores = ""
        for i = 10, 1, -1 do
            scores = scores .. "Ayman," .. tostring(i * 0) .. "\n"
        end

        love.filesystem.write("breakout.dat", scores)
    end

    local scores = {}
    for i = 1, 10 do
        scores[i] = {
            name = nil,
            score = nil,
        }
    end

    local counter = 1
    for line in love.filesystem.lines("breakout.dat") do
        local name, score = line:match("^(%a+),(%d+)$")
        if name and score then
            scores[counter].name = name
            scores[counter].score = tonumber(score)
            counter = counter + 1
        end
    end

    return scores
end

function love.load()
    math.randomseed(os.time())
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Flappy Bird")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
    })
    Push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })

    Fonts = {
        ["small"] = love.graphics.newFont("assets/font.ttf", 8),
        ["medium"] = love.graphics.newFont("assets/font.ttf", 16),
        ["large"] = love.graphics.newFont("assets/font.ttf", 32),
    }

    Sounds = {}
    for _, file in ipairs(love.filesystem.getDirectoryItems("assets/sounds")) do
        local name = file:gsub("%.wav$", "")
        Sounds[name] =
            love.audio.newSource("assets/sounds/" .. name .. ".wav", "static")
    end

    Textures = {}
    for _, file in ipairs(love.filesystem.getDirectoryItems("assets/images")) do
        local name = file:gsub("%.png$", "")
        Textures[name] = love.graphics.newImage("assets/images/" .. name .. ".png")
    end
    Frames = {
        ["paddles"] = GeneratePaddleQuads(),
        ["balls"] = GenerateBallQuads(),
        ["bricks"] = GenerateBrickQuads(),
    }

    GameState = StateMachine({
        ["start"] = function()
            return StartState()
        end,
        ["serve"] = function()
            return ServeState()
        end,
        ["play"] = function()
            return PlayState()
        end,
        ["victory"] = function()
            return VictoryState()
        end,
        ["game-over"] = function()
            return GameOverState()
        end,
        ["high-scores"] = function()
            return HighScoreState()
        end,
        ["enter-high-score"] = function()
            return EnterHighScoreState()
        end,
        ["paddle-select"] = function()
            return PaddleSelectState()
        end,
    })
    GameState:change("start")
    HighScores = loadHighScores()

    Sounds["music"]:setLooping(true)
    Sounds["music"]:play()
    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    Push.resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.update(dt)
    GameState:update(dt)
    love.keyboard.keysPressed = {}
end

function love.draw()
    Push.start()

    local backgroundWidth = Textures["background"]:getWidth()
    local backgroundHeight = Textures["background"]:getHeight()
    love.graphics.draw(
        Textures["background"],
        0,
        0,
        0,
        VIRTUAL_WIDTH / (backgroundWidth - 1),
        VIRTUAL_HEIGHT / (backgroundHeight - 1)
    )

    GameState:render()
    Push.finish()
end

function RenderHealth(health)
    local healthX = VIRTUAL_WIDTH - 100

    for _ = 1, health do
        love.graphics.draw(Textures["heart"], healthX, 4)
        healthX = healthX + 11
    end

    for _ = 1, 3 - health do
        love.graphics.draw(Textures["no-heart"], healthX, 4)
        healthX = healthX + 11
    end
end

function RenderScore(score)
    love.graphics.setFont(Fonts["small"])
    love.graphics.print("Score:", VIRTUAL_WIDTH - 60, 5)
    love.graphics.printf(tostring(score), VIRTUAL_WIDTH - 50, 5, 40, "right")
end
