Ball = Class({})
function Ball:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt
end

function Ball:collides(Paddle)
    if self.x >= Paddle.x + Paddle.width or self.x + self.width <= Paddle.x then
        return false
    end

    if self.y >= Paddle.y + Paddle.height or self.y + self.height <= Paddle.y then
        return false
    end

    return true
end

function Ball:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
end

return Ball
