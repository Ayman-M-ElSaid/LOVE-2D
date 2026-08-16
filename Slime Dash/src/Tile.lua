Tile = Class({})

TILE_SIZE = 30

function Tile:init(x, y, color)
    self.x = x
    self.y = y
    self.width = TILE_SIZE
    self.height = TILE_SIZE
    self.paintColor = color
    self.isSolid = true
    self.isPainted = true
    self:initializeParticleSystem(color)
end

function Tile:initializeParticleSystem(color)
    self.particles = love.graphics.newParticleSystem(Textures["particle"])
    self.particles:setColors(color)
    self.particles:setPosition(self.x + TILE_SIZE / 2, self.y + TILE_SIZE / 2)
    self.particles:setParticleLifetime(0.25, 0.35)
    self.particles:setSpeed(25, 45)
    self.particles:setSpread(math.pi * 2)
    self.particles:setLinearDamping(6, 8)
    self.particles:setSizes(1, 0)
    self.particles:setSizeVariation(0.4)
end

function Tile:render()
    if self.isSolid then
        love.graphics.setColor(0.96, 0.96, 0.86, 1)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)

        local bevel = 3
        love.graphics.setColor(1, 1, 1, 0.25)
        if self.edges.up then
            love.graphics.rectangle("fill", self.x, self.y, self.width, bevel)
        end
        if self.edges.left then
            love.graphics.rectangle("fill", self.x, self.y, bevel, self.height)
        end

        love.graphics.setColor(0, 0, 0, 0.3)
        if self.edges.down then
            love.graphics.rectangle(
                "fill",
                self.x,
                self.y + self.height - bevel,
                self.width,
                bevel
            )
        end
        if self.edges.right then
            love.graphics.rectangle(
                "fill",
                self.x + self.width - bevel,
                self.y,
                bevel,
                self.height
            )
        end
    else
        love.graphics.setColor(0.2, 0.2, 0.2, 0.7)
        love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
        if self.isPainted then
            love.graphics.setColor(self.paintColor)
            love.graphics.rectangle("fill", self.x, self.y, self.width, self.height)
            love.graphics.setColor(1, 1, 1, 1)
        end
    end
    love.graphics.draw(self.particles)
end

return Tile
