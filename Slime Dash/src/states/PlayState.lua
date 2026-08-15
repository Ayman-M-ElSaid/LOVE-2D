PlayState = Class({ __includes = BaseState })

function PlayState:init() end

function PlayState:enter(params)
    self.level = params.level or 1
    local startPointx, startPointY
    local r, g, b = love.math.random(), love.math.random(), love.math.random()
    self.tiles, startPointx, startPointY =
        LevelMaker.makeLevel(self.level, { r, g, b, 0.35 })
    self.slime = Slime(startPointx, startPointY, { r, g, b, 1 })
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
end

function PlayState:update(dt)
    if self.isPaused then
        return
    end
    self.slime:update(dt, self.tiles)
    self:checkWin()

    -- for testing, to be removed
    if love.keyboard.wasPressed("space") then
        GameState:change("play", { level = self.level + 1 })
    end
end

function PlayState:render()
    for _, row in ipairs(self.tiles) do
        for _, tile in ipairs(row) do
            tile:render()
        end
    end
    self.slime:render()

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
