Slime = Class({})

local DIRECTIONS = { DOWN = 1, UP = 2, LEFT = 3, RIGHT = 4 }
local SPEED = 750
local SWIPE_THRESHOLD = 60
local MAX_QUEUE = 3

function Slime:init(x, y, color)
    self.x = x
    self.y = y
    self.width = 30
    self.height = 30
    self.dx = 0
    self.dy = 0
    self.activeTouch = {}
    self.moveQueue = {}
    self.isMoving = false
    self.moveCount = 0
    self.direction = DIRECTIONS.DOWN
    self.color = color
    self.frame = 1
    self.animationTimer = Timer.every(0.3, function()
        self.frame = self.frame % 8 + 1
    end)
end

function Slime:checkInput()
    for _, touch in ipairs(love.touch.pressed) do
        self.activeTouch[touch.id] = { x = touch.x, y = touch.y }
    end

    for _, touch in ipairs(love.touch.released) do
        local start = self.activeTouch[touch.id]
        local x, y = touch.x, touch.y
        if start and x and y then
            local dx = x - start.x
            local dy = y - start.y
            local direction
            if math.abs(dx) > math.abs(dy) then
                if dx >= SWIPE_THRESHOLD then
                    direction = DIRECTIONS.RIGHT
                elseif dx <= -SWIPE_THRESHOLD then
                    direction = DIRECTIONS.LEFT
                end
            else
                if dy <= -SWIPE_THRESHOLD then
                    direction = DIRECTIONS.UP
                elseif dy >= SWIPE_THRESHOLD then
                    direction = DIRECTIONS.DOWN
                end
            end
            if direction then
                if #self.moveQueue < MAX_QUEUE then
                    table.insert(self.moveQueue, direction)
                end
            end
            self.activeTouch[touch.id] = nil
        end
    end

    if self.isMoving then
        return
    end
    local direction = table.remove(self.moveQueue, 1)
    if not direction then
        return
    end

    self.direction = direction
    if direction == DIRECTIONS.RIGHT then
        self.dx = SPEED
    elseif direction == DIRECTIONS.LEFT then
        self.dx = -SPEED
    elseif direction == DIRECTIONS.UP then
        self.dy = -SPEED
    elseif direction == DIRECTIONS.DOWN then
        self.dy = SPEED
    end

    self.isMoving = true
    self.moveCount = self.moveCount + 1
    self.animationTimer.interval = 0.15
end

function Slime:checkCollision(tiles)
    for _, row in ipairs(tiles) do
        for _, tile in ipairs(row) do
            if
                self.x < tile.x + tile.width
                and self.x + self.width > tile.x
                and self.y < tile.y + tile.height
                and self.y + self.height > tile.y
            then
                if tile.isSolid then
                    if self.dx > 0 then
                        self.x = tile.x - self.width
                    elseif self.dx < 0 then
                        self.x = tile.x + tile.width
                    elseif self.dy > 0 then
                        self.y = tile.y - self.height
                    elseif self.dy < 0 then
                        self.y = tile.y + tile.height
                    end
                    Sounds["hit"]:stop()
                    Sounds["hit"]:play()
                    self.dx = 0
                    self.dy = 0
                    self.isMoving = false
                    self.animationTimer.interval = 0.3
                    return
                elseif not tile.isPainted then
                    tile.isPainted = true
                    tile.particles:emit(15)
                    return
                end
            end
        end
    end
end

function Slime:update(dt, tiles)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
    self:checkCollision(tiles)
    self:checkInput()
    Timer.update(dt)
end

function Slime:render()
    love.graphics.setColor(self.color)
    local frame = self.frame + (self.direction - 1) * 8 + (self.isMoving and 32 or 0)
    love.graphics.draw(
        Textures["slime"],
        Frames["slime"][frame],
        self.x,
        self.y,
        0,
        30 / 40
    )
    love.graphics.setColor(1, 1, 1, 1)
end

return Slime
