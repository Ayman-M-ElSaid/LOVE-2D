Flash = Class({})

function Flash:init()
    self.timer = 0
    self.x = 0
    self.direction = 1
end

function Flash:trigger(x, direction)
    self.timer = FLASH_DURATION
    self.x = x
    self.direction = direction
end

function Flash:update(dt)
    if self.timer > 0 then
        self.timer = self.timer - dt
    end
end

function Flash:render()
    if self.timer > 0 then
        for i = self.x, self.x + 10 * self.direction, self.direction / 2 do
            love.graphics.setColor(
                1,
                1,
                1,
                FLASH_INTENSITY * self.timer * (1 - math.abs(i - self.x) / 10)
            )
            love.graphics.rectangle("fill", i, 0, 0.5, VIRTUAL_HEIGHT)
        end
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return Flash
