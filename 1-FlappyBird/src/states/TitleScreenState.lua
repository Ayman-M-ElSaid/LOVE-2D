TitleScreenState = Class({ __includes = BaseState })

function TitleScreenState:init()
    self.message = IS_MOBILE and "Tap to Play!" or "Press Space to Play!"
end

function TitleScreenState:update(dt)
    if love.keyboard.wasPressed("space") or love.mouse.wasPressed(1) then
        GameState:change("countdown")
    elseif love.keyboard.wasPressed("escape") then
        love.event.quit()
    end
end

function TitleScreenState:render()
    love.graphics.setFont(Fonts["flappy"])
    love.graphics.printf("Flappy Bird", 0, 64, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(Fonts["medium"])
    love.graphics.printf(self.message, 0, 100, VIRTUAL_WIDTH, "center")
end
