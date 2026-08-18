VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 360, 800

require("src.dependencies")

local function loadFonts(w, h)
    FONT_SCALE = math.min(w / VIRTUAL_WIDTH, h / VIRTUAL_HEIGHT)
    Fonts = {
        ["title"] = love.graphics.newFont("assets/fonts/Fredoka.ttf", 60 * FONT_SCALE),
        ["button"] = love.graphics.newFont("assets/fonts/Fredoka.ttf", 35 * FONT_SCALE),
        ["large"] = love.graphics.newFont("assets/fonts/BubblegumSans.ttf", 45 * FONT_SCALE),
        ["meduim"] = love.graphics.newFont("assets/fonts/Fredoka.ttf", 25 * FONT_SCALE),
        ["small"] = love.graphics.newFont("assets/fonts/Fredoka.ttf", 16 * FONT_SCALE),
    }
end

function love.load()
    love.filesystem.setIdentity("Slime Dash")
    love.window.setTitle("Slime Dash")
    love.graphics.setDefaultFilter("linear", "linear")
    love.window.setMode(1080, 2400, {
        fullscreen = true,
        resizable = false,
        vsync = true,
    })
    Push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })

    Textures = {}
    for _, file in ipairs(love.filesystem.getDirectoryItems("assets/images")) do
        local name, extension = file:match("(.+)%.(.+)")
        Textures[name] = love.graphics.newImage(
            string.format("assets/images/%s.%s", name, extension)
        )
    end
    Frames = {
        ["slime"] = GenerateQuads(Textures["slime"], 0, 0, 40, 40),
        ["logo"] = GenerateQuads(Textures["logo"], 0, 0, 156.75, 157),
    }
    Sounds = {}
    for _, file in ipairs(love.filesystem.getDirectoryItems("assets/sounds")) do
        local name, extension = file:match("(.+)%.(.+)")
        local type = extension == "wav" and "static" or "stream"
        Sounds[name] = love.audio.newSource(
            string.format("assets/sounds/%s.%s", name, extension),
            type
        )
    end
    GameState = StateMachine({
        ["start"] = function()
            return StartState()
        end,
        ["play"] = function()
            return PlayState()
        end,
        ["level-complete"] = function()
            return LevelCompleteState()
        end,
        ["level-select"] = function()
            return LevelSelectState()
        end,
    })
    love.graphics.setBackgroundColor(0.96, 0.96, 0.86, 1)
    loadFonts(love.graphics.getDimensions())
    Sounds["music"]:setLooping(true)
    Sounds["music"]:play()
    Progress = Save.load()
    GameState:change("start")

    love.keyboard.keysPressed = {}
    love.touch.pressed = {}
    love.touch.released = {}
end

function love.resize(w, h)
    Push.resize(w, h)
    loadFonts(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    return love.keyboard.keysPressed[key]
end

function love.touchpressed(id, x, y)
    x, y = Push.toGame(x, y)
    table.insert(love.touch.pressed, { id = id, x = x, y = y })
end

function love.touchreleased(id, x, y)
    x, y = Push.toGame(x, y)
    table.insert(love.touch.released, { id = id, x = x, y = y })
end

function love.update(dt)
    GameState:update(dt)
    love.keyboard.keysPressed = {}
    love.touch.pressed = {}
    love.touch.released = {}
end

function love.draw()
    Push.start()
    GameState:render()
    Push.finish()
end
