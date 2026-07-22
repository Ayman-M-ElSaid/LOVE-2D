PlayState = Class({ __includes = BaseState })

local Bird = require("src.Bird")
local PipePair = require("src.PipePair")

function PlayState:init()
    Scrolling = true
    self.bird = Bird()
    self.pipePairs = { PipePair(-PIPE_HEIGHT + math.random(80) + 20) }
    self.timer = 0
    self.score = 0
end

function PlayState:update(dt)
    -- self.timer = self.timer + dt

    -- local minSpawnInterval = (PIPE_WIDTH / PIPE_SPEED)
    -- if
    --     self.timer
    --     >= math.max(minSpawnInterval, minSpawnInterval + 1.5 - self.score / 15)
    -- then
    --     table.insert(self.pipePairs, PipePair(-PIPE_HEIGHT + math.random(80) + 30))
    --     self.timer = 0
    -- end
    local minSpawnInterval = (PIPE_WIDTH / PIPE_SPEED)
    local maxSpawnInterval = minSpawnInterval + 1.5

    self.timer = self.timer + dt

    if self.timer >= math.max(minSpawnInterval, maxSpawnInterval - self.score / 25) then
        local spawnRange = math.max(10, math.floor(80 * (self.timer / maxSpawnInterval)))
        table.insert(
            self.pipePairs,
            PipePair(-PIPE_HEIGHT + math.random(spawnRange) + 30)
        )
        self.timer = 0
    end
    

    self.bird:update(dt)

    for _, pipePair in ipairs(self.pipePairs) do
        pipePair:update(dt)
        if self.bird.x > pipePair.x + PIPE_WIDTH and not pipePair.scored then
            self.score = self.score + 1
            pipePair.scored = true
            Sounds["score"]:play()
        end
        for _, pipe in ipairs(pipePair.pipes) do
            if self.bird:collides(pipe) then
                Sounds["explosion"]:play()
                Sounds["hurt"]:play()
                GameState:change("score", { score = self.score })
            end
        end
    end

    if
        self.bird.y + self.bird.height > VIRTUAL_HEIGHT - Ground:getHeight()
        or self.bird.y < 0
    then
        Sounds["explosion"]:play()
        Sounds["hurt"]:play()
        GameState:change("score", { score = self.score })
    end

    for i, pipePair in ipairs(self.pipePairs) do
        if pipePair.remove then
            table.remove(self.pipePairs, i)
        end
    end
end

function PlayState:render()
    for _, pipePair in ipairs(self.pipePairs) do
        pipePair:render()
    end
    love.graphics.setFont(Fonts["flappy"])
    love.graphics.print(string.format("Score: %d", self.score), 8, 8)

    self.bird:render()
end
