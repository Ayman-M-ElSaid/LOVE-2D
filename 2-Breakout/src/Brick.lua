Brick = Class({})
local PALETTE_COLORS = {
    [1] = { r = 99, g = 155, b = 255 }, -- blue
    [2] = { r = 106, g = 190, b = 47 }, -- green
    [3] = { r = 217, g = 87, b = 99 }, -- red
    [4] = { r = 215, g = 123, b = 186 }, -- purple
    [5] = { r = 251, g = 242, b = 54 }, -- gold
}
for _, color in ipairs(PALETTE_COLORS) do
    for channel, value in pairs(color) do
        color[channel] = value / 255
    end
end

function Brick:init(x, y, color, tier)
    self.x = x
    self.y = y
    self.width = 32
    self.height = 16
    self.centerX = self.x + self.width / 2
    self.centerY = self.y + self.height / 2

    self.color = color
    self.tier = tier
    self.originalTier = tier
    self.inPlay = true
    self.isLocked = false
    self.score = color * 25 + (tier - 1) * 200

    self.particles = love.graphics.newParticleSystem(Textures["particle"], 64)
    self.particles:setParticleLifetime(0.3, 0.6)
    self.particles:setLinearAcceleration(-15, 0, 15, 80)
    self.particles:setEmissionArea("normal", 10, 10)
end

function Brick:update(dt)
    self.particles:update(dt)
end

function Brick:hit()
    self.score = self.color * 25 + (self.tier - 1) * 200

    self.particles:setColors(
        PALETTE_COLORS[self.color].r,
        PALETTE_COLORS[self.color].g,
        PALETTE_COLORS[self.color].b,
        55 * (self.tier + 1) / 255,
        PALETTE_COLORS[self.color].r,
        PALETTE_COLORS[self.color].g,
        PALETTE_COLORS[self.color].b,
        0
    )
    self.particles:emit(64)

    Sounds["brick-hit-2"]:stop()
    Sounds["brick-hit-2"]:play()

    if self.tier > 1 then
        self.tier = self.tier - 1
    else
        self.tier = self.originalTier
        if self.color > 1 then
            self.color = self.color - 1
        else
            self.inPlay = false
            Sounds["brick-hit-1"]:stop()
            Sounds["brick-hit-1"]:play()
        end
    end
end

function Brick:render()
    if self.inPlay then
        love.graphics.draw(
            Textures["breakout"],
            Frames["bricks"][4 * (self.color - 1) + self.tier],
            self.x,
            self.y
        )
        if self.isLocked then
            love.graphics.draw(Textures["locked-brick"], self.x, self.y)
        end
    end
end

function Brick:renderParticles()
    love.graphics.draw(self.particles, self.centerX, self.centerY)
end

return Brick
