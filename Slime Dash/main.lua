require("src.dependencies")

VIRTUAL_WIDTH, VIRTUAL_HEIGHT = 360, 800

local function loadFonts(w, h)
    FONT_SCALE = math.min(w / VIRTUAL_WIDTH, h / VIRTUAL_HEIGHT)
    Fonts = {
        ["large"] = love.graphics.newFont("assets/fonts/Copyduck.otf", 40 * FONT_SCALE),
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
        ["play"] = function()
            return PlayState()
        end,
    })
    love.graphics.setBackgroundColor(0.96, 0.96, 0.86, 1)
    loadFonts(love.graphics.getDimensions())
    Sounds["music"]:setLooping(true)
    Sounds["music"]:play()
    GameState:change("play", { level = 1 })

    love.keyboard.keysPressed = {}
end

function love.resize(w, h)
    Push.resize(w, h)
    loadFonts(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
    if key == "escape" then
        love.event.quit()
    end
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
    GameState:render()
    Push.finish()
end
