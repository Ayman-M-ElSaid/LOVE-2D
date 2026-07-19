Push = require("libs.push")
Class = require("libs.class")

require("src.states.BaseState")
require("src.StateMachine")
require("src.states.StartState")
require("src.states.ServeState")
require("src.states.PlayState")
require("src.states.VictoryState")

local Paddle = require("src.Paddle")
local Ball = require("src.Ball")
local Flash = require("src.Flash")

WINDOW_WIDTH = 1280
WINDOW_HEIGHT = 720
VIRTUAL_WIDTH = 432
VIRTUAL_HEIGHT = 243

PADDLE_SPEED = 200
WINNING_SCORE = 5
FLASH_DURATION = 0.15
FLASH_INTENSITY = 5

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    love.window.setTitle("Pong")
    love.window.setMode(WINDOW_WIDTH, WINDOW_HEIGHT, {
        fullscreen = false,
        resizable = true,
        vsync = true,
    })
    Push.setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, { upscale = "normal" })

    Fonts = {
        ["large"] = love.graphics.newFont("font.ttf", 32),
        ["medium"] = love.graphics.newFont("font.ttf", 16),
        ["small"] = love.graphics.newFont("font.ttf", 8),
    }
    Sounds = {
        ["paddle_hit"] = love.audio.newSource("sounds/paddle_hit.wav", "static"),
        ["score"] = love.audio.newSource("sounds/score.wav", "static"),
        ["wall_hit"] = love.audio.newSource("sounds/wall_hit.wav", "static"),
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
    })

    Player1 = Paddle(15, VIRTUAL_HEIGHT / 2 - 10, 5, 20)
    Player2 = Paddle(VIRTUAL_WIDTH - 20, VIRTUAL_HEIGHT / 2 - 10, 5, 20)
    GameBall = Ball(VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2, 4, 4)
    Scores = { 0, 0 }
    AI = false
    Winner = nil
    ScoreFlash = Flash()
    GameState:change("start")

    love.keyboard.keysPressed = {}
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

function love.update(dt)
    GameState:update(dt)
    ScoreFlash:update(dt)
    love.keyboard.keysPressed = {}
end

local function renderScore()
    love.graphics.setFont(Fonts["large"])
    love.graphics.printf(
        string.format("%d\t%d", Scores[1], Scores[2]),
        0,
        50,
        VIRTUAL_WIDTH,
        "center"
    )
end

local function displayFPS()
    love.graphics.setColor(0, 1, 0)
    love.graphics.setFont(Fonts["small"])
    love.graphics.print(string.format("FPS: %d", love.timer.getFPS()), 10, 10)
    love.graphics.setColor(1, 1, 1)
end

function love.draw()
    Push.start()

    love.graphics.setBackgroundColor(40 / 255, 45 / 255, 52 / 255)

    GameState:render()
    Player1:render()
    Player2:render()
    GameBall:render()
    if GameState.current.showScore then
        renderScore()
    end
    ScoreFlash:render()
    displayFPS()

    Push.finish()
end
