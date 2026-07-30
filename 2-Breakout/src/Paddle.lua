Paddle = Class({})

PaddleSpeed = 250

function Paddle:init(skin)
    self.skin = skin
    self.size = 2
    self.width = 32 * self.size
    self.height = 16
    self.x = VIRTUAL_WIDTH / 2 - self.width / 2
    self.y = VIRTUAL_HEIGHT - 2 * self.height
    self.centerX = self.x + self.width / 2
    self.dx = 0
end

function Paddle:update(dt)
    if not IS_MOBILE then
        if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
            self.dx = PaddleSpeed * dt
        elseif love.keyboard.isDown("left") or love.keyboard.isDown("a") then
            self.dx = -PaddleSpeed * dt
        else
            self.dx = 0
        end
    else
        self.dx = 0
        local DEADZONE = 4

        if love.mouse.isDown(1) then
            local x, y = Push.toGame(love.mouse.getPosition())
            if x then
                local scale = 1
                    + 1.5 * math.min(math.abs(self.centerX - x) / VIRTUAL_WIDTH, 1)
                if x > self.centerX + DEADZONE then
                    self.dx = PaddleSpeed * scale * dt
                elseif x < self.centerX - DEADZONE then
                    self.dx = -PaddleSpeed * scale * dt
                end
            end
        end
    end

    self.x = math.min(math.max(self.x + self.dx, 0), VIRTUAL_WIDTH - self.width)
    self.centerX = self.x + self.width / 2
end

function Paddle:changeSize(change)
    local oldsize = self.size
    if change == "increase" then
        self.size = math.min(self.size + 1, 4)
    else
        self.size = math.max(self.size - 1, 1)
    end
    if self.size ~= oldsize then
        self.x = self.x - (self.size - oldsize) * 16
    end
    self.width = 32 * self.size
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
