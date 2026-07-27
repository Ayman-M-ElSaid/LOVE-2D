Paddle = Class({})

function Paddle:init(skin)
    self.width = 64
    self.height = 16
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT - 1.5 * self.height
    self.centerX = self.x + self.width / 2
    self.dx = 0
    self.size = 2
    self.skin = skin
end

function Paddle:update(dt)
    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        self.dx = PADDLE_SPEED * dt
    elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        self.dx = -PADDLE_SPEED * dt
    else
        self.dx = 0
    end
    self.x = math.min(math.max(self.x + self.dx, 0), VIRTUAL_WIDTH - self.width)
    self.centerX = self.x + self.width / 2
end

function Paddle:render()
    love.graphics.draw(
        Textures["breakout"],
        Frames["paddles"][self.size + 4 * (self.skin - 1)],
        self.x,
        self.y
    )
end

return Paddle
