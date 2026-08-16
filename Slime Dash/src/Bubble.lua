local Bubble = Class({})

function Bubble:init()
    self.time = 0
    self.back = love.math.random() < 0.4
    self.baseX = love.math.random(0, 360)
    self.x = self.baseX
    self.y = love.math.random(800)
    self.radius = self.back and love.math.random(3, 6) or love.math.random(6, 10)
    self.speed = self.back and (10 + love.math.random() * 8)
        or (20 + love.math.random() * 14)
    self.alpha = self.back and (0.15 + love.math.random() * 0.15)
        or (0.35 + love.math.random() * 0.3)
    self.driftAmp = 6 + love.math.random() * 10
    self.driftFreq = 0.4 + love.math.random() * 0.5
    self.phase = love.math.random() * math.pi * 2
    self.color = RandomColor()
    self.shouldRemove = false
    self.isClicked = false
end

function Bubble:update(dt)
    self.time = self.time + dt
    self.y = self.y - self.speed * dt
    self.x = self.baseX
        + math.sin(self.time * self.driftFreq + self.phase) * self.driftAmp

    for _, touch in ipairs(love.touch.pressed) do
        local x, y = touch.x, touch.y
        if x and y then
            if
                x >= self.x - self.radius
                and x <= self.x + self.radius
                and y >= self.y - self.radius
                and y <= self.y + self.radius
            then
                Sounds["pop"]:play()
                self.isClicked = true
            end
        end
    end

    if self.y < -self.radius or self.isClicked then
        self.shouldRemove = true
    end
end

function Bubble:render()
    love.graphics.setColor(self.color[1], self.color[2], self.color[3], self.alpha)
    love.graphics.circle("fill", self.x, self.y, self.radius)
    love.graphics.setColor(1, 1, 1, self.alpha * 0.8)
    love.graphics.circle(
        "fill",
        self.x - self.radius * 0.3,
        self.y - self.radius * 0.3,
        self.radius * 0.35
    )
    love.graphics.setColor(1, 1, 1, 1)
end

return Bubble
