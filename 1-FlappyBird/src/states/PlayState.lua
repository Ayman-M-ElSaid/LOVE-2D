PlayState = Class({ __includes = BaseState })

local Bird = require("src.Bird")
local PipePair = require("src.PipePair")

function PlayState:init()
    Scrolling = true
    self.bird = Bird()
    self.pipePairs = { PipePair(-PIPE_HEIGHT + math.random(80) + 20) }
    self.spawnTimer = 0
    self.score = 0

    self.isPaused = false
    self.isResumed = false
    self.resumeCountdown = 3
    self.resumeTimer = 0
end

local function handlePause(self)
    if not self.isPaused then
        -- pause the game if the player presses p or escape
        if love.keyboard.wasPressed("p") or love.keyboard.wasPressed("escape") then
            Sounds["pause"]:play()
            self.isPaused = true
            Scrolling = false
            Sounds["music"]:pause()
        end
    else
        -- resume the game if the player presses p or space; or quit to title screen if they press escape
        if
            love.keyboard.wasPressed("space")
            or love.mouse.wasPressed(1)
            or love.keyboard.wasPressed("p")
        then
            self.isResumed = true
            Sounds["music"]:play()
            Sounds["countdown"]:play()
        elseif love.keyboard.wasPressed("escape") then
            Sounds["music"]:play()
            GameState:change("title")
        end
    end
end

local function handleResume(dt, self)
    -- update the countdown timer and resume the game when it reaches 0
    self.resumeCountdown, self.resumeTimer =
        Countdown(dt, self.resumeCountdown, self.resumeTimer)
    if self.resumeCountdown <= 0 then
        self.isPaused = false
        self.isResumed = false
        Scrolling = true
        self.resumeCountdown = 3
        self.resumeTimer = 0
    end
end

function PlayState:update(dt)
    handlePause(self)

    if self.isResumed then
        handleResume(dt, self)
    end

    -- if the game is paused, don't update any game logic
    if self.isPaused then
        return
    end

    -- update the timer for pipe spawning
    self.spawnTimer = self.spawnTimer + dt
    local minSpawnInterval = (PIPE_WIDTH / PIPE_SPEED)
    local maxSpawnInterval = minSpawnInterval + 1.5
    if
        self.spawnTimer
        >= math.max(minSpawnInterval, maxSpawnInterval - self.score / 30)
    then
        local spawnRange =
            math.max(15, math.floor(80 * (self.spawnTimer / maxSpawnInterval)))
        table.insert(
            self.pipePairs,
            PipePair(-PIPE_HEIGHT + math.random(spawnRange) + 30)
        )
        self.spawnTimer = 0
    end

    -- update the position of the pipes and check for collisions
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

    self.bird:update(dt)

    -- check if the bird has hit the ground or ceiling
    if
        self.bird.y + self.bird.height > VIRTUAL_HEIGHT - Ground:getHeight()
        or self.bird.y < 0
    then
        Sounds["explosion"]:play()
        Sounds["hurt"]:play()
        GameState:change("score", { score = self.score })
    end

    -- remove any pipes that have gone off screen
    for i, pipePair in ipairs(self.pipePairs) do
        if pipePair.remove then
            table.remove(self.pipePairs, i)
        end
    end
end

local function renderPauseMessage()
    love.graphics.rectangle(
        "fill",
        VIRTUAL_WIDTH / 2 - 20,
        VIRTUAL_HEIGHT / 2 - 60,
        15,
        60
    )
    love.graphics.rectangle(
        "fill",
        VIRTUAL_WIDTH / 2 + 5,
        VIRTUAL_HEIGHT / 2 - 60,
        15,
        60
    )
    love.graphics.circle("line", VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2 - 30, 40)
    love.graphics.setFont(Fonts["flappy"])
    love.graphics.printf("Paused", 0, VIRTUAL_HEIGHT / 2 + 25, VIRTUAL_WIDTH, "center")
    love.graphics.setFont(Fonts["medium"])
    local message = IS_MOBILE and "tap to resume" or "presses space to resume"
    love.graphics.printf(message, 0, VIRTUAL_HEIGHT / 2 + 55, VIRTUAL_WIDTH, "center")
end

function PlayState:render()
    for _, pipePair in ipairs(self.pipePairs) do
        pipePair:render()
    end
    love.graphics.setFont(Fonts["flappy"])
    love.graphics.print(string.format("Score: %d", self.score), 8, 8)

    self.bird:render()

    if self.isPaused and not self.isResumed then
        renderPauseMessage()
    end

    if self.isResumed then
        RenderCountdown(self.resumeCountdown)
    end
end
