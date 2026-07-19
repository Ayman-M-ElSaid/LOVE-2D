StartState = Class({ __includes = BaseState })

local selectionIndex = 1
local timer = 0

function StartState:init()
    self.showScore = false
    math.randomseed(os.time())
    ServingPlayer = math.random(2)
    Player1.y = VIRTUAL_HEIGHT / 2 - Player1.height / 2
    Player2.y = VIRTUAL_HEIGHT / 2 - Player2.height / 2
end

function StartState:update(dt)
    if love.keyboard.wasPressed("space") then
        GameState:change("serve")
    elseif love.keyboard.wasPressed("right") or love.keyboard.wasPressed("d") then
        selectionIndex = 2
        AI = true
    elseif love.keyboard.wasPressed("left") or love.keyboard.wasPressed("a") then
        selectionIndex = 1
        AI = false
    end
    timer = timer + dt
    if timer >= 0.5 then
        timer = 0
    end
end

function StartState:render()
    love.graphics.setFont(Fonts["small"])
    love.graphics.printf("Welcome to Pong!", 0, 15, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Press Space to begin!", 0, 25, VIRTUAL_WIDTH, "center")

    local color1, color2
    if selectionIndex == 1 then
        color1 = { 1, 1, 1, 1 - 1.5 * timer }
        color2 = { 1, 1, 1, 1 }
    else
        color1 = { 1, 1, 1, 1 }
        color2 = { 1, 1, 1, 1 - 1.5 * timer }
    end
    love.graphics.setFont(Fonts["medium"])
    love.graphics.setColor(color1)
    love.graphics.printf("vs. Player", 20, 70, VIRTUAL_WIDTH / 2, "center")
    love.graphics.setColor(color2)
    love.graphics.printf(
        "vs. AI",
        VIRTUAL_WIDTH / 2 - 20,
        70,
        VIRTUAL_WIDTH / 2,
        "center"
    )
    love.graphics.setColor(1, 1, 1, 1)
end
