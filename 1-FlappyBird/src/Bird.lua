Bird = Class({})

local GRAVITY = 850
local SPRITE_SHEET = love.graphics.newImage("assets/images/bird.png")

function Bird:init()
    self.width = 34
    self.height = 32

    self.frames = {}
    local i = 1
    for x = 0, SPRITE_SHEET:getWidth() - 1, self.width do
        self.frames[i] =
            love.graphics.newQuad(x, 0, self.width, self.height, SPRITE_SHEET)
        i = i + 1
    end

    self.animationTimer = 0
    self.frameDuration = 0.1
    self.currentFrame = 1
    self.animating = false

    self.x = (VIRTUAL_WIDTH - self.width) / 2
    self.y = (VIRTUAL_HEIGHT - self.height) / 2
    self.dy = 0
end

local function animate(self, dt)
    if self.animating then
        self.animationTimer = self.animationTimer + dt
        self.currentFrame = math.floor(self.animationTimer / self.frameDuration) + 1
    
    if self.currentFrame >= #self.frames then
        self.currentFrame = 1
        self.animating = false
    end end
end

function Bird:update(dt)
    animate(self, dt)
    if love.keyboard.wasPressed("space") or love.mouse.wasPressed(1) then
        self.dy = -200
        Sounds["jump"]:play()
        self.animating = true
        self.animationTimer=0
    else
        self.dy = self.dy + GRAVITY * dt
    end

    self.y = self.y + self.dy * dt
end

function Bird:render()
    love.graphics.draw(SPRITE_SHEET, self.frames[self.currentFrame], self.x, self.y)
end

function Bird:collides(pipe)
    if
        self.x + 2 <= pipe.x + PIPE_WIDTH
        and (self.x + 2) + (self.width - 4) >= pipe.x
    then
        if
            self.y + 6 <= pipe.y + PIPE_HEIGHT
            and (self.y + 6) + (self.height - 12) >= pipe.y
        then
            return true
        end
    end
    return false
end

return Bird
