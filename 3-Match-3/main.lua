require("src.dependencies")

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

function love.load()
    love.graphics.setDefaultFilter("linear", "linear")
    love.window.setTitle("Tropical Match")

    love.window.setMode(0, 0, {
        fullscreen = true,
        resizable = false,
        vsync = true,
    })
    WINDOW_WIDTH, WINDOW_HEIGHT = love.graphics.getDimensions()
    Push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })

    FONT_SCALE = math.min(WINDOW_WIDTH / VIRTUAL_WIDTH, WINDOW_HEIGHT / VIRTUAL_HEIGHT)
    Fonts = {
        ["title"] = love.graphics.newFont("assets/fonts/Baloo.ttf", 35 * FONT_SCALE),
        ["button"] = love.graphics.newFont("assets/fonts/Fredoka.ttf", 22 * FONT_SCALE),
        ["meduim"] = love.graphics.newFont(
            "assets/fonts/Butterpop.otf",
            16 * FONT_SCALE
        ),
        ["large"] = love.graphics.newFont(
            "assets/fonts/Butterpop.otf",
            24 * FONT_SCALE
        ),
    }

    Music, SFX = true, true
    Sounds = {}
    for _, file in ipairs(love.filesystem.getDirectoryItems("assets/sounds")) do
        local name, extension = file:match("(.+)%.(.+)")
        local type = extension == "wav" and "static" or "stream"
        Sounds[name] = love.audio.newSource(
            string.format("assets/sounds/%s.%s", name, extension),
            type
        )
    end

    Textures = {}
    for _, file in ipairs(love.filesystem.getDirectoryItems("assets/images")) do
        local name, extension = file:match("(.+)%.(.+)")
        Textures[name] = love.graphics.newImage(
            string.format("assets/images/%s.%s", name, extension)
        )
    end
    BackgroundScale = VIRTUAL_WIDTH / Textures["background"]:getWidth()
    Frames = { ["fruits"] = GenerateQuads(Textures["fruits"], 0, 0, 128, 128) }

    GameState = StateMachine({
        ["start"] = function()
            return StartState()
        end,
        ["begin-level"] = function()
            return BeginLevelState()
        end,
        ["play"] = function()
            return PlayState()
        end,
        ["game-over"] = function()
            return GameOverState()
        end,
    })
    GameState:change("start")
    Sounds["music"]:setLooping(true)
    Sounds["music"]:play()

    love.mouse.buttonsPressed = {}
    love.mouse.buttonsReleased = {}
end

function love.mousepressed(x, y, button)
    love.mouse.buttonsPressed[button] = true
end

function love.mouse.wasPressed(button)
    return love.mouse.buttonsPressed[button]
end

function love.mousereleased(x, y, button)
    love.mouse.buttonsReleased[button] = true
end

function love.mouse.wasReleased(button)
    return love.mouse.buttonsReleased[button]
end

function love.update(dt)
    GameState:update(dt)
    Timer.update(dt)
    love.mouse.buttonsPressed = {}
    love.mouse.buttonsReleased = {}
end

function love.draw()
    Push.start()

    love.graphics.draw(
        Textures["background"],
        0,
        0,
        0,
        BackgroundScale,
        BackgroundScale
    )
    GameState:render()
    Transition.render()

    Push.finish()
end
