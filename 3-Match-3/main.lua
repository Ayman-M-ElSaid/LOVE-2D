require("src.dependencies")

IS_MOBILE = love.system.getOS() == "Android" or love.system.getOS() == "iOS"
VIRTUAL_WIDTH, VIRTUAL_HEIGHT = Layout.getDimensions()

function love.load()
    love.filesystem.setIdentity("Tropical Match")
    love.window.setTitle("Tropical Match")
    love.graphics.setDefaultFilter("linear", "linear")
    love.window.setMode(1080, 2400, {
        fullscreen = true,
        resizable = false,
        vsync = true,
    })
    Push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })
    Progress = Save.load()

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
    Frames = {
        ["fruits"] = GenerateQuads(Textures["fruits"], 0, 0, 128, 128),
        ["super-fruits"] = GenerateQuads(Textures["super-fruits"], 0, 0, 128, 128),
        ["particles"] = GenerateQuads(Textures["particles"], 0, 0, 64, 64),
    }
    Cursors = {}
    for _, file in ipairs(love.filesystem.getDirectoryItems("assets/cursors")) do
        local name, extension = file:match("(.+)%.(.+)")
        Cursors[name] = love.mouse.newCursor(
            love.image.newImageData(
                string.format("assets/cursors/%s.%s", name, extension)
            ),
            5,
            5
        )
    end
    Layout.loadFonts(love.graphics.getDimensions())
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
    love.mouse.setCursor(Cursors["basic"])
    Layout.build()
    Background = Layout.getBackground()
    BackgroundScale = VIRTUAL_WIDTH / Background:getWidth()
    GameState:change("start")
    Sounds["music"]:setLooping(true)
    Sounds["music"]:play()

    love.mouse.buttonsPressed = {}
    love.mouse.buttonsReleased = {}
end

function love.resize(w, h)
    Push.resize(w, h)
    Layout.loadFonts(love.graphics.getDimensions())
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

    love.graphics.draw(Background, 0, 0, 0, BackgroundScale, BackgroundScale)
    GameState:render()
    Transition.render()

    Push.finish()
end
