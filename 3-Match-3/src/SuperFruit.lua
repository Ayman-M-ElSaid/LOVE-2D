SuperFruit = Class({ __includes = Fruit })

--- Creates a new super fruit.
---@param id number The sprite frame and power-up ID: 1-8 for vertical strips, 9-16 for horizontal strips, 17-24 for 3x3 blasts, and 25 for the rainbow bomb.
function SuperFruit:init(id, scale, x, y, offsetX, offsetY)
    self.powerID = id
    local color = id ~= 25 and (id - 1) % 8 + 1 or 9
    Fruit.init(self, color, scale, x, y, offsetX, offsetY)
end

--- Renders the fruit using its corresponding sprite frame.
function SuperFruit:render()
    love.graphics.draw(
        Textures["super-fruits"],
        Frames["super-fruits"][self.powerID],
        self.x,
        self.y,
        0,
        self.scale
    )
end

return SuperFruit
