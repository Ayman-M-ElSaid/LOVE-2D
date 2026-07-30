Ball = Class({})

function Ball:init(skin, x, y)
    self.x = x or VIRTUAL_WIDTH / 2 - 4
    self.y = y or VIRTUAL_HEIGHT - 42
    self.scale = 1
    self.width = 8 * self.scale
    self.height = 8 * self.scale
    self.dx = 0
    self.dy = 0
    self.skin = skin
    self.dx = math.random(-250, 250)
    self.dy = math.random(-50, -60)
end

function Ball:collides(target)
    if self.x > target.x + target.width or self.x + self.width < target.x then
        return false
    end
    if self.y > target.y + target.height or self.y + self.height < target.y then
        return false
    end
    return true
end

function Ball:penetration(target)
    local ballCenterX = self.x + self.width / 2
    local ballCenterY = self.y + self.height / 2
    local targetCenterX = target.centerX or (target.x + target.width / 2)
    local targetCenterY = target.centerY or (target.y + target.height / 2)

    local offsetX = targetCenterX - ballCenterX
    local offsetY = targetCenterY - ballCenterY
    local penetrationX = target.width / 2 + self.width / 2 - math.abs(offsetX)
    local penetrationY = target.height / 2 + self.height / 2 - math.abs(offsetY)

    return penetrationX, penetrationY, offsetX, offsetY
end

function Ball:update(dt)
    self.x = self.x + self.dx * dt
    self.y = self.y + self.dy * dt

    if self.x <= 0 or self.x + self.width >= VIRTUAL_WIDTH then
        self.dx = -self.dx
        Sounds["wall-hit"]:play()
        if self.x <= 0 then
            self.x = 0
        else
            self.x = VIRTUAL_WIDTH - self.width
        end
    end

    if self.y <= 0 then
        self.y = 0
        self.dy = -self.dy
        Sounds["wall-hit"]:play()
    end
end

function Ball:changeScale(scale)
    self.scale = scale
    self.width = 8 * self.scale
    self.height = 8 * self.scale
end

function Ball:render()
    love.graphics.draw(
        Textures["breakout"],
        Frames["balls"][self.skin],
        self.x,
        self.y,
        0,
        self.scale,
        self.scale
    )
end

return Ball
