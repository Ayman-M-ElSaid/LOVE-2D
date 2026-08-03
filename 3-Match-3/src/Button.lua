Button = Class({})

function Button:init(image, scale, centerX, centerY, color, text, txtColor)
    self.image = image
    self.scale = scale or 1
    local width, height = self.image:getDimensions()
    self.width, self.height = width * scale, height * scale
    self.left, self.right = centerX - self.width / 2, centerX + self.width / 2
    self.top, self.bottom = centerY - self.height / 2, centerY + self.height / 2
    self.color = color
    self.text = text
    self.txtColor = txtColor
end

function Button:isHovered()
    local x, y = love.mouse.getPosition()
    local mouseX, mouseY = Push.toGame(x, y)
    if mouseX and mouseY then
        return mouseX >= self.left
            and mouseX <= self.right
            and mouseY >= self.top
            and mouseY <= self.bottom
    end
end

function Button:isClicked()
    if self:isHovered() and love.mouse.wasPressed(1) then
        if SFX then
            Sounds["select"]:play()
        end
        return true
    end
end

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
