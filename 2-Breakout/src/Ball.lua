Ball = Class({})

function Ball:init(skin)
    self.x = VIRTUAL_WIDTH / 2 - 4
    self.y = VIRTUAL_HEIGHT - 42
    self.width = 8
    self.height = 8
    self.dx = 0
    self.dy = 0
    self.skin = skin
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

function Ball:reset()
    self.x = VIRTUAL_WIDTH / 2 - 2
    self.y = VIRTUAL_HEIGHT / 2 - 2
    self.dx = 0
    self.dy = 0
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
            self.x = VIRTUAL_WIDTH - 8
        end
    end

    if self.y <= 0 then
        self.y = 0
        self.dy = -self.dy
        Sounds["wall-hit"]:play()
    end
end

function Ball:render()
    love.graphics.draw(Textures["breakout"], Frames["balls"][self.skin], self.x, self.y)
end

return Ball
