Fruit = Class({})

--- Creates a new fruit.
---@param id number The ID of the fruit's sprite frame.
---@param scale number The scale at which to render the fruit.
---@param x number The fruit's starting grid position along the x-axis.
---@param y number The fruit's starting grid position along the y-axis.
---@param offsetX number The x-axis offset of the board.
---@param offsetY number The y-axis offset of the board.
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

--- Renders the fruit using its corresponding sprite frame.
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
