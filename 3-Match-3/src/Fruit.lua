Fruit = Class({})

function Fruit:init(id, scale, x, y, offsetX, offsetY)
    self.id = id
    self.scale = scale
    self.gridX = x
    self.gridY = y

    local width, height = 128, 128
    self.width, self.height = width * scale, height * scale
    self.x = (self.gridX - 1) * self.width + offsetX
    self.y = (self.gridY - 1) * self.height + offsetY
end

function Fruit:update() end

function Fruit:render()
    love.graphics.draw(
    Textures["fruits"],
        Frames["fruits"][self.id],
        self.x,
        self.y,
        0,
        self.scale
    )
end

return Fruit
