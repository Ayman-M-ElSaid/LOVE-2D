PipePair = Class({})

local Pipe = require("src.Pipe")

PIPE_SPEED = 60
local GAP_HEIGHT = 90

function PipePair:init(y)
    self.x = VIRTUAL_WIDTH
    self.y = y
    self.pipes = {
        Pipe("top", self.y),
        Pipe("bottom", self.y + PIPE_HEIGHT + GAP_HEIGHT),
    }
    self.scored = false
    self.remove = false
end

function PipePair:update(dt)
    if self.x > -PIPE_WIDTH then
        self.x = self.x - PIPE_SPEED * dt
        for _, pipe in ipairs(self.pipes) do
            pipe.x = self.x
        end
    else
        self.remove = true
    end
end

function PipePair:render()
    for _, pipe in ipairs(self.pipes) do
        pipe:render()
    end
end

return PipePair
