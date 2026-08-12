Tile = Class({})

function Tile:init(x, y, type)
    self.x = x
    self.y = y
    self.width = 40
    self.height = 40
    self.isSolid = type == "solid"
    self.isPainted = true
end

function Tile:render()
    if self.isSolid then
        love.graphics.setColor(1, 0, 0, 1)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    elseif self.isPainted then
        love.graphics.setColor(1, 0, 0, 0.5)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
    end
end
return Tile
