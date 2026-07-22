TitleScreenState = Class({ __includes = BaseState })

function TitleScreenState:update(dt)
    if love.keyboard.wasPressed("space") or love.mouse.wasPressed(1) then
        GameState:change("countdown")
    end
end

function TitleScreenState:render()
    love.graphics.setFont(Fonts["flappy"])
    love.graphics.printf("Flappy Bird", 0, 64, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(Fonts["medium"])
    love.graphics.printf("Press Space", 0, 100, VIRTUAL_WIDTH, "center")
end
