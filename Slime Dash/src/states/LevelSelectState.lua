LevelSelectState = Class({ __includes = BaseState })

local RECT_SIZE = 65
local ROW_HEIGHT = RECT_SIZE + 20
local HEADER_HEIGHT = 120
local TAP_THRESHOLD = 10

function LevelSelectState:init()
    self.backButton =
        Button(Textures["back"], 0.45, 0.1 * VIRTUAL_WIDTH, 0.05 * VIRTUAL_HEIGHT)
    self.activeTouchY = {}
    self.touchStartY = {}

    self.grid = {}
    local numRows = math.ceil(#Progress / 4)
    for row = 0, numRows - 1 do
        for col = 0, 3 do
            local x = col * RECT_SIZE + 20 * (col + 1)
            local y = 110 + row * RECT_SIZE + 20 * (row + 1)
            local level = 4 * row + col + 1
            if Progress[level] then
                table.insert(self.grid, { x = x, y = y, stars = Progress[level].stars })
            end
        end
    end

    local bandHeight = VIRTUAL_HEIGHT - HEADER_HEIGHT
    self.maxScrollY = 0
    self.minScrollY =
        math.min(0, bandHeight / 2 - RECT_SIZE / 2 - (numRows - 1) * ROW_HEIGHT)
end

function LevelSelectState:enter(params)
    local rowCenterY = HEADER_HEIGHT
        + (math.ceil(params.level / 4) - 1) * ROW_HEIGHT
        + RECT_SIZE / 2
    local viewportCenterY = HEADER_HEIGHT + (VIRTUAL_HEIGHT - HEADER_HEIGHT) / 2
    self.scrollY = viewportCenterY - rowCenterY
    self:clampScroll()
end

function LevelSelectState:clampScroll()
    self.scrollY = math.max(self.minScrollY, math.min(self.maxScrollY, self.scrollY))
end

function LevelSelectState:update(dt)
    if self.backButton:isClicked() or love.keyboard.wasPressed("escape") then
        GameState:change("start")
    end

    for _, touch in ipairs(love.touch.pressed) do
        self.activeTouchY[touch.id] = touch.y
        self.touchStartY[touch.id] = touch.y
    end
    for _, touch in ipairs(love.touch.released) do
        local startY = self.touchStartY[touch.id]
        self.activeTouchY[touch.id] = nil
        self.touchStartY[touch.id] = nil
        local x, y = touch.x, touch.y
        local worldY = y - self.scrollY
        if x and y and startY and math.abs(y - startY) <= TAP_THRESHOLD then
            for level, rect in ipairs(self.grid) do
                if
                    x >= rect.x
                    and x <= rect.x + RECT_SIZE
                    and worldY >= rect.y
                    and worldY <= rect.y + RECT_SIZE
                    and y >= HEADER_HEIGHT - RECT_SIZE / 2
                then
                    GameState:change("play", { level = level })
                end
            end
        end
    end
    for id, lastY in pairs(self.activeTouchY) do
        local _, y = Push.toGame(love.touch.getPosition(id))
        self.scrollY = self.scrollY + y - lastY
        self.activeTouchY[id] = y
    end
    self:clampScroll()
end

function LevelSelectState:render()
    love.graphics.setColor(1, 1, 1, 0.5)
    love.graphics.draw(Textures["background"])

    love.graphics.push()
    love.graphics.translate(0, self.scrollY)
    love.graphics.setFont(Fonts["small"])
    for level, rect in ipairs(self.grid) do
        local screenY = rect.y + self.scrollY
        if screenY >= HEADER_HEIGHT - RECT_SIZE / 2 and screenY <= VIRTUAL_HEIGHT then
            local x, y = rect.x, rect.y
            love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
            love.graphics.rectangle("fill", x - 2, y + 2, RECT_SIZE, RECT_SIZE, 8)
            love.graphics.setColor(1, 1, 1, 1)
            love.graphics.rectangle("fill", x, y, RECT_SIZE, RECT_SIZE, 8)
            love.graphics.setColor(0, 0, 0, 1)
            PrintfScaled(tostring(level), x, y + 10, RECT_SIZE, "center")
            love.graphics.setColor(1, 1, 1, 1)
            for i = 1, rect.stars do
                local totalWidth = (rect.stars - 1) * 21.1 + 19.2
                local startX = rect.x + (RECT_SIZE - totalWidth) / 2
                love.graphics.draw(
                    Textures["small-star"],
                    startX + 21.2 * (i - 1),
                    y + 35,
                    0,
                    0.285
                )
            end
        end
    end
    love.graphics.pop()

    self.backButton:render()
    love.graphics.setFont(Fonts["large"])
    love.graphics.setColor(0.8, 0.8, 0.8, 0.8)
    PrintfScaled("Levels", 3, 0.06 * VIRTUAL_HEIGHT - 2, VIRTUAL_WIDTH, "center")
    love.graphics.setColor(0, 0, 0, 1)
    PrintfScaled("Levels", 0, 0.06 * VIRTUAL_HEIGHT, VIRTUAL_WIDTH, "center")
    love.graphics.setColor(1, 1, 1, 1)
end

return LevelSelectState
