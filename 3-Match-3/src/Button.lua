Button = Class({})

--- Creates a new button.
---@param image love.Image The image used for the button.
---@param scale number The scale at which to render the button.
---@param centerX number The x-coordinate of the button's center.
---@param centerY number The y-coordinate of the button's center.
---@param color table? The color to apply to the button image.
---@param text string? The optional text to display on the button.
---@param txtColor table? The color of the button's text.
function Button:init(image, scale, centerX, centerY, color, text, txtColor)
    self.image = image
    self.scale = scale
    local width, height = self.image:getDimensions()
    self.width, self.height = width * self.scale, height * self.scale
    self.left, self.right = centerX - self.width / 2, centerX + self.width / 2
    self.top, self.bottom = centerY - self.height / 2, centerY + self.height / 2
    self.color = color
    self.text = text
    self.txtColor = txtColor
end

--- Checks whether the mouse is currently hovering over the button.
---@return boolean Whether the mouse is hovering over the button.
function Button:isHovered()
    local x, y = love.mouse.getPosition()
    local mouseX, mouseY = Push.toGame(x, y)
    if mouseX and mouseY then
        return mouseX >= self.left
            and mouseX <= self.right
            and mouseY >= self.top
            and mouseY <= self.bottom
    end
    return false
end

--- Checks whether the button is hovered and has been clicked.
---@return boolean Whether the button was clicked.
function Button:isClicked()
    if self:isHovered() and love.mouse.wasPressed(1) then
        if SFX then
            Sounds["select"]:play()
        end
        return true
    else
        return false
    end
end

--- Renders the button, its label, and its hover effect.
function Button:render()
    -- set the ccolor of the button if provided
    if self.color then
        love.graphics.setColor(self.color)
    end
    -- draw the button
    love.graphics.draw(self.image, self.left, self.top, 0, self.scale)
    love.graphics.setColor(1, 1, 1, 1)
    -- if a label is set to appear on the button set its color and print it
    if self.text then
        love.graphics.setColor(self.txtColor)
        love.graphics.setFont(Fonts["button"])
        PrintfScaled(self.text, self.left, self.top, self.width, "center")
        love.graphics.setColor(1, 1, 1, 1)
    end
    -- add a tint above the button as it's hovered
    if self:isHovered() then
        love.graphics.setColor(0.8, 0.8, 0.8, 0.5)
        love.graphics.draw(self.image, self.left, self.top, 0, self.scale)
        love.graphics.setColor(1, 1, 1, 1)
    end
end

return Button
