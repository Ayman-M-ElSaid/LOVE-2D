StartState = Class({ __includes = BaseState })

local Bubble = require("src.Bubble")

function StartState:init()
    self.startButton =
        Button(Textures["button"], 0.5, VIRTUAL_WIDTH / 2, 0.75 * VIRTUAL_HEIGHT)
    self.levelsButton = Button(
        Textures["button"],
        0.4,
        VIRTUAL_WIDTH / 2,
        0.85 * VIRTUAL_HEIGHT,
        { 1, 1, 1, 1 },
        "Levels",
        { 0.12, 0.17, 0.34, 1 }
    )
    self.level = #Progress
    self.frameIndex = 1
    self.slimeColor = RandomColor()
    Timer.every(0.25, function()
        self.frameIndex = self.frameIndex % 8 + 1
    end)
    Timer.every(2, function()
        self.slimeColor = RandomColor()
    end)

    self.bubbles = {}
    for _ = 1, 20 do
        table.insert(self.bubbles, Bubble(love.math.random(VIRTUAL_HEIGHT)))
    end
end

function StartState:update(dt)
    if self.startButton:isClicked() then
        GameState:change("play", { level = self.level })
    elseif self.levelsButton:isClicked() then
        GameState:change("level-select", { level = self.level })
    end

    if love.keyboard.wasPressed("escape") then
        love.event.quit()
    end

    for _, bubble in ipairs(self.bubbles) do
        bubble:update(dt)
    end
    for i, bubble in ipairs(self.bubbles) do
        if bubble.shouldRemove then
            table.remove(self.bubbles, i)
            table.insert(self.bubbles, Bubble())
        end
    end
    Timer.update(dt)
end

function StartState:render()
    love.graphics.draw(Textures["background"])
    -- draw animated slime logo
    love.graphics.setColor(self.slimeColor)
    love.graphics.draw(
        Textures["logo"],
        Frames["logo"][self.frameIndex],
        (VIRTUAL_WIDTH - 156.75) / 2,
        0.45 * (VIRTUAL_HEIGHT - 157)
    )
    love.graphics.setColor(1, 1, 1, 1)
    -- draw animated bubbles
    for _, bubble in ipairs(self.bubbles) do
        bubble:render()
    end
    -- draw title with shadow
    love.graphics.setFont(Fonts["title"])
    love.graphics.setColor(1, 1, 1, 1)
    PrintfScaled("Slime Dash", 0, 0.125 * VIRTUAL_HEIGHT + 3, VIRTUAL_WIDTH, "center")
    love.graphics.setColor(0.12, 0.17, 0.34, 1)
    PrintfScaled("Slime Dash", 0, 0.125 * VIRTUAL_HEIGHT, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(Fonts["small"])
    PrintfScaled(
        "A SLIDING PAINT PUZZLE!",
        0,
        0.21 * VIRTUAL_HEIGHT,
        VIRTUAL_WIDTH,
        "center"
    )
    love.graphics.setColor(1, 1, 1, 1)
    -- draw buttons
    self.startButton:render()
    love.graphics.setColor(0.12, 0.17, 0.34, 1)
    love.graphics.setFont(Fonts["button"])
    PrintfScaled("Play", 0, 0.705 * VIRTUAL_HEIGHT, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(Fonts["small"])
    PrintfScaled(
        "Level " .. tostring(self.level),
        0,
        0.755 * VIRTUAL_HEIGHT,
        VIRTUAL_WIDTH,
        "center"
    )
    self.levelsButton:render()
end
