Pipe = Class({})

local PIPE_IMAGE = love.graphics.newImage("assets/images/pipe.png")
PIPE_WIDTH = PIPE_IMAGE:getWidth()
PIPE_HEIGHT = PIPE_IMAGE:getHeight()

function Pipe:init(orientation, y)
    self.orientation = orientation
    self.x = VIRTUAL_WIDTH
    self.y = y
end

function Pipe:render()
    love.graphics.draw(
        PIPE_IMAGE,
        self.x,
        self.orientation == "bottom" and self.y or self.y + PIPE_HEIGHT,
        0,
        1,
        self.orientation == "bottom" and 1 or -1
    )
end

return Pipe
