Paddle = Class({})

function Paddle:init(x, y, width, height)
    self.x = x
    self.y = y
    self.width = width
    self.height = height
    self.dy = 0
end

function Paddle:handleInput(dt, upKey, downKey)
    if love.keyboard.isDown(upKey) then
        self.dy = -PADDLE_SPEED
    elseif love.keyboard.isDown(downKey) then
        self.dy = PADDLE_SPEED
    else
        self.dy = 0
    end
    self:update(dt)
end

function Paddle:update(dt)
    if self.dy < 0 then
        self.y = math.max(0, self.y + self.dy * dt)
    else
        self.y = math.min(VIRTUAL_HEIGHT - self.height, self.y + self.dy * dt)
    end
end

function Paddle:render()
    love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
end

return Paddle
