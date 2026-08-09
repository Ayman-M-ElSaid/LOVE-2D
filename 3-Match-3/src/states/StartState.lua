StartState = Class({ __includes = BaseState })

function StartState:init()
    self.startButton = Layout.startState.startButton
    self.quitButton = Layout.startState.quitButton
    self.musicButton = Layout.startState.musicButton
    self.sfxButton = Layout.startState.sfxButton
end

function StartState:update(dt)
    if self.startButton:isClicked() then
        Transition.to("begin-level", { level = 1 })
    elseif self.musicButton:isClicked() then
        Music = not Music
        if Music then
            Sounds["music"]:play()
        else
            Sounds["music"]:stop()
        end
    elseif self.sfxButton:isClicked() then
        SFX = not SFX
    elseif self.quitButton:isClicked() then
        love.event.quit()
    end
end

function StartState:render()
    if IS_MOBILE then
        love.graphics.setColor(0.87, 0.72, 0.49, 0.5)
        love.graphics.rectangle("fill", 15, Layout.startState.titleY + 10, 330, 50, 25)
    end
    love.graphics.setFont(Fonts["title"])
    -- draw shadow
    love.graphics.setColor(0.08, 0.20, 0.16, 0.65)
    PrintfScaled(
        "Tropical Match",
        2,
        Layout.startState.titleY - 2,
        VIRTUAL_WIDTH,
        "center"
    )
    -- draw title
    love.graphics.setColor(1.0, 0.82, 0.39, 1.0)
    PrintfScaled("Tropical Match", 0, Layout.startState.titleY, VIRTUAL_WIDTH, "center")
    love.graphics.setColor(1, 1, 1, 1)

    self.startButton:render()
    self.quitButton:render()
    self.musicButton:render()
    self.sfxButton:render()
    if not Music then
        love.graphics.setLineWidth(3)
        love.graphics.setColor(1, 0, 0, 0.8)
        love.graphics.line(
            self.musicButton.left,
            self.musicButton.bottom,
            self.musicButton.right,
            self.musicButton.top
        )
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(1)
    end
    if not SFX then
        love.graphics.setLineWidth(3)
        love.graphics.setColor(1, 0, 0, 0.8)
        love.graphics.line(
            self.sfxButton.left,
            self.sfxButton.bottom,
            self.sfxButton.right,
            self.sfxButton.top
        )
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(1)
    end
end
