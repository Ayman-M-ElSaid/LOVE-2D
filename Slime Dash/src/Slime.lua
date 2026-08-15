Slime = Class({})

local DIRECTIONS = { DOWN = 1, UP = 2, LEFT = 3, RIGHT = 4 }
local SPEED = 600

function Slime:init(x, y, color)
    self.x = x
    self.y = y
    self.width = 30
    self.height = 30
    self.dx = 0
    self.dy = 0
    self.activeTouch = {}
    self.isMoving = false
    self.color = color
    self.direction = DIRECTIONS.DOWN
    self.frame = 1
    self.animationTimer = Timer.every(0.3, function()
        self.frame = self.frame % 8 + 1
    end)
end

function Slime:checkInput()
    if self.isMoving then
        return
    end

    for _, touch in ipairs(love.touch.pressed) do
        self.activeTouch[touch.id] = { startX = touch.x, startY = touch.y }
    end
    local dx, dy = 0, 0
    local SWIPE_THRESHOLD = 30
    for _, touch in ipairs(love.touch.released) do
        local start = self.activeTouch[touch.id]
        if start then
            dx = touch.x - start.startX
            dy = touch.y - start.startY
            self.activeTouch[touch.id] = nil
        end
    end
    if love.keyboard.wasPressed("right") or dx >= SWIPE_THRESHOLD then
        self.dx = SPEED
        self.direction = DIRECTIONS.RIGHT
    elseif love.keyboard.wasPressed("left") or dx <= -SWIPE_THRESHOLD then
        self.dx = -SPEED
        self.direction = DIRECTIONS.LEFT
    elseif love.keyboard.wasPressed("up") or dy <= -SWIPE_THRESHOLD then
        self.dy = -SPEED
        self.direction = DIRECTIONS.UP
    elseif love.keyboard.wasPressed("down") or dy >= SWIPE_THRESHOLD then
        self.dy = SPEED
        self.direction = DIRECTIONS.DOWN
    end

    if math.abs(self.dx) > 0 or math.abs(self.dy) > 0 then
        self.isMoving = true
        self.animationTimer.interval = 0.15
    end
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
