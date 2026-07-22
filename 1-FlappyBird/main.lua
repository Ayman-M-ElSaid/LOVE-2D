Push = require("libs.push")
Class = require("libs.class")

require("src.states.BaseState")
require("src.StateMachine")
require("src.states.TitleScreenState")
require("src.states.CountdownState")
require("src.states.PlayState")
require("src.states.ScoreState")

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 288

local BACKGROUND_SCROLL_SPEED = 30
local GROUND_SCROLL_SPEED = 60
local BACKGROUND_LOOPING_POINT = 413

local backgroundX = 0
local groundX = 0

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Flappy Bird")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
    })
    Push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })

    Background = love.graphics.newImage("assets/images/background.png")
    Ground = love.graphics.newImage("assets/images/ground.png")
    Fonts = {
        ["small"] = love.graphics.newFont("assets/fonts/font.ttf", 8),
        ["medium"] = love.graphics.newFont("assets/fonts/flappy.ttf", 14),
        ["huge"] = love.graphics.newFont("assets/fonts/flappy.ttf", 56),
        ["flappy"] = love.graphics.newFont("assets/fonts/flappy.ttf", 28),
    }
    Sounds = {
        ["music"] = love.audio.newSource("assets/sounds/marios_way.mp3", "stream"),
        ["jump"] = love.audio.newSource("assets/sounds/jump.wav", "static"),
        ["score"] = love.audio.newSource("assets/sounds/score.wav", "static"),
        ["hurt"] = love.audio.newSource("assets/sounds/hurt.wav", "static"),
        ["explosion"] = love.audio.newSource("assets/sounds/explosion.wav", "static"),
    }
    GameState = StateMachine({
        ["title"] = function()
            return TitleScreenState()
        end,
        ["countdown"] = function()
            return CountdownState()
        end,
        ["play"] = function()
            return PlayState()
        end,
        ["score"] = function()
            return ScoreState()
        end,
    })
    GameState:change("title")
    Sounds["music"]:setLooping(true)
    Sounds["music"]:play()

    Scrolling = true
    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
end

function love.resize(w, h)
    Push.resize(w, h)
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

function love.mousepressed(x, y, button)
    love.mouse.buttonsPressed[button] = true
end

function love.mouse.wasPressed(button)
    return love.mouse.buttonsPressed[button]
end

local function updateBackground(dt)
    if Scrolling then
        backgroundX = (backgroundX + BACKGROUND_SCROLL_SPEED * dt)
            % BACKGROUND_LOOPING_POINT
        groundX = (groundX + GROUND_SCROLL_SPEED * dt) % VIRTUAL_WIDTH
    end
end

function love.update(dt)
    updateBackground(dt)
    GameState:update(dt)
    love.keyboard.keysPressed = {}
    love.mouse.buttonsPressed = {}
end

function love.draw()
    Push.start()

    love.graphics.draw(Background, -backgroundX, 0)
    GameState:render()
    love.graphics.draw(Ground, -groundX, VIRTUAL_HEIGHT - Ground:getHeight())

    Push.finish()
end
