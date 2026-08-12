PlayState = Class({ __includes = BaseState })

function PlayState:init()
    self.slime = Slime(200, 440, { 1, 1, 1, 1 })
    self.tiles = LevelMaker.makeLevel(1)
end

function PlayState:enter(params) end

function PlayState:update(dt)
    if self.isPaused then
        return
    end
    self.slime:update(dt, self.tiles)
end

function PlayState:render()
    for _, row in ipairs(self.tiles) do
        for _, tile in ipairs(row) do
            tile:render()
        end
    end
    self.slime:render()
end
