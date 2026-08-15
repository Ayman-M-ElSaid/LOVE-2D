StartState = Class({ __includes = BaseState })

local function loadLevelData()
    if not love.filesystem.getInfo("level.dat") then
        love.filesystem.write("level.dat", "1")
    end
    local level
    for line in love.filesystem.lines("level.dat") do
        level = line:match("^(%d+)$")
    end

    return level
end

function StartState:init()
    self.button = Button(
        Textures["button"],
        0.45,
        VIRTUAL_WIDTH / 2,
        0.8 * VIRTUAL_HEIGHT,
        { 0.5, 0.5, 0.5, 1 },
        "Play"
    )
    self.frameIndex = 1
    Timer.every(0.2, function()
        self.frameIndex = self.frameIndex % 8 + 1
    end)
end

function StartState:update(dt)
    if self.button:isClicked() or love.keyboard.wasPressed("space") then
        GameState:change("play", { level = loadLevelData() })
    end
    Timer.update(dt)
end

function StartState:render()
    love.graphics.draw(Textures["background"])
    love.graphics.setFont(Fonts["title"])
    love.graphics.setColor(1, 1, 1, 1)
    PrintfScaled("Slime Dash", 0, 0.125 * VIRTUAL_HEIGHT + 3, VIRTUAL_WIDTH, "center")
    love.graphics.setColor(0.12, 0.17, 0.34, 1)
    PrintfScaled("Slime Dash", 0, 0.125 * VIRTUAL_HEIGHT, VIRTUAL_WIDTH, "center")
    self.button:render()
    love.graphics.setColor(0.52, 0.94, 1, 1)
    love.graphics.draw(
        Textures["logo"],
        Frames["logo"][self.frameIndex],
        (VIRTUAL_WIDTH - 200) / 2,
        (VIRTUAL_HEIGHT - 200) / 2.5
    )
    love.graphics.setColor(1, 1, 1, 1)
end
