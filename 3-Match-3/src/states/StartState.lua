StartState = Class({ __includes = BaseState })

function StartState:init()
    self.startButton = Button(
        Textures["button"],
        0.2,
        VIRTUAL_WIDTH / 2,
        0.775 * VIRTUAL_HEIGHT,
        { 0.86, 0.32, 0.28, 1.0 },
        "Start",
        { 1.0, 0.94, 0.75, 1.0 }
    )
    self.quitButton = Button(
        Textures["button"],
        0.2,
        VIRTUAL_WIDTH / 2,
        0.9 * VIRTUAL_HEIGHT,
        { 0.87, 0.72, 0.49, 1.0 },
        "Quit",
        { 0.16, 0.24, 0.20, 1.0 }
    )
    self.musicButton = Button(
        Textures["music"],
        0.1,
        0.96 * VIRTUAL_WIDTH,
        0.065 * VIRTUAL_HEIGHT,
        { 1, 1, 1, 0.88 }
    )
    self.sfxButton = Button(
        Textures["sfx"],
        0.1,
        0.96 * VIRTUAL_WIDTH,
        0.175 * VIRTUAL_HEIGHT,
        { 1, 1, 1, 0.88 }
    )
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
    end

    if love.keyboard.wasPressed("escape") or self.quitButton:isClicked() then
        love.event.quit()
    end
end

function StartState:render()
    love.graphics.setFont(Fonts["title"])
    -- draw shadow
    love.graphics.setColor(0.08, 0.20, 0.16, 0.65)
    PrintfScaled("Tropical Match", 2, 0.3 * VIRTUAL_HEIGHT - 2, VIRTUAL_WIDTH, "center")
    -- draw title
    love.graphics.setColor(1.0, 0.82, 0.39, 1.0)
    PrintfScaled("Tropical Match", 0, 0.3 * VIRTUAL_HEIGHT, VIRTUAL_WIDTH, "center")
    love.graphics.setColor(1, 1, 1, 1)

    self.startButton:render()
    self.quitButton:render()
    self.musicButton:render()
    self.sfxButton:render()
    if not Music then
        love.graphics.setLineWidth(3)
        love.graphics.setColor(1, 0, 0, 0.88)
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
        love.graphics.setColor(1, 0, 0, 0.88)
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
