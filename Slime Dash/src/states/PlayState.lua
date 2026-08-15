PlayState = Class({ __includes = BaseState })

function PlayState:init()
    self.retryButton =
        Button(Textures["retry"], 0.45, 0.9 * VIRTUAL_WIDTH, 0.95 * VIRTUAL_HEIGHT)
    self.trialCounter = 1
end

function PlayState:enter(params)
    self.level = params.level or 1
    local r, g, b = love.math.random(), love.math.random(), love.math.random()
    self.tiles, self.startPointx, self.startPointY =
        LevelMaker.makeLevel(self.level, { r, g, b, 0.35 })
    self.slime = Slime(self.startPointx, self.startPointY, { r, g, b, 1 })
end

function PlayState:checkWin()
    if self.slime.isMoving then
        return
    end
    for _, row in ipairs(self.tiles) do
        for _, tile in ipairs(row) do
            if not tile.isPainted then
                return
            end
        end
    end
    GameState:change("play", { level = self.level + 1 })
    love.filesystem.write("level.dat", tostring(self.level + 1))
end

function PlayState:reset()
    self.trialCounter = self.trialCounter + 1
    self.slime.x, self.slime.y = self.startPointx, self.startPointY
    self.slime.direction = 1
    for _, row in ipairs(self.tiles) do
        for _, tile in ipairs(row) do
            if not tile.isSolid then
                tile.isPainted = false
            end
        end
    end
end

function PlayState:update(dt)
    self.slime:update(dt, self.tiles)
    self:checkWin()
    if self.retryButton:isClicked() then
        self:reset()
    end
    -- for testing, to be removed
    if love.keyboard.wasPressed("space") then
        GameState:change("play", { level = self.level + 1 })
    elseif love.keyboard.wasPressed("r") then
        self:reset()
    end
end

function PlayState:render()
    for _, row in ipairs(self.tiles) do
        for _, tile in ipairs(row) do
            tile:render()
        end
    end
    self.slime:render()
    self.retryButton:render()

    love.graphics.setFont(Fonts["large"])
    love.graphics.setColor(0, 0, 0, 0.5)
    PrintfScaled(
        "Level " .. tostring(self.level),
        3,
        0.06 * VIRTUAL_HEIGHT - 3,
        VIRTUAL_WIDTH,
        "center"
    )
    love.graphics.setColor(0, 0, 0, 1)
    PrintfScaled(
        "Level " .. tostring(self.level),
        0,
        0.06 * VIRTUAL_HEIGHT,
        VIRTUAL_WIDTH,
        "center"
    )
end
