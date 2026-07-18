StartState = Class({ __includes = BaseState })

function StartState:init()
    math.randomseed(os.time())
    ServingPlayer = math.random(2)
end

function StartState:update(dt)
    if love.keyboard.wasPressed("space") then
        GameState:change("serve")
    end
end

function StartState:render()
    love.graphics.setFont(Fonts["small"])
    love.graphics.printf("Welcome to Pong!", 0, 15, VIRTUAL_WIDTH, "center")
    love.graphics.printf("Press Space to begin!", 0, 25, VIRTUAL_WIDTH, "center")
end
