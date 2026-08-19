LevelCompleteState = Class({ __includes = BaseState })
local Bubble = require("src.Bubble")

local WINDOW_WIDTH, WINDOW_HEIGHT = 280, 300
local WINDOW_Y = (VIRTUAL_HEIGHT - WINDOW_HEIGHT) / 2 - 50
local PANEL_WIDTH, PANEL_HEIGHT = 240, 130
local PANEL_X = (WINDOW_WIDTH - PANEL_WIDTH) / 2
local PANEL_Y = WINDOW_Y + 120
RECTS = {
    {
        color = { 0.09, 0.49, 0.66, 1 },
        mode = "fill",
        x = 0,
        y = WINDOW_Y,
        width = WINDOW_WIDTH,
        height = WINDOW_HEIGHT,
        offset = 0,
        rx = 8,
    },
    {
        color = { 0.21, 0.74, 0.97, 1 },
        mode = "fill",
        x = 0,
        y = WINDOW_Y,
        width = WINDOW_WIDTH,
        height = WINDOW_HEIGHT,
        offset = 5,
        rx = 8,
    },
    {
        color = { 0.87, 0.64, 0.07, 1 },
        mode = "line",
        x = PANEL_X,
        y = PANEL_Y,
        width = PANEL_WIDTH,
        height = PANEL_HEIGHT,
        offset = 0,
        rx = 6,
    },
    {
        color = { 1, 0.92, 0.61, 1 },
        mode = "line",
        x = PANEL_X,
        y = PANEL_Y,
        width = PANEL_WIDTH,
        height = PANEL_HEIGHT,
        offset = 3,
        rx = 3,
    },
    {
        color = { 1, 0.8, 0, 1 },
        mode = "line",
        x = PANEL_X,
        y = PANEL_Y,
        width = PANEL_WIDTH,
        height = PANEL_HEIGHT,
        offset = 4,
        rx = 3,
    },
    {
        color = { 0.9, 0.9, 0.9, 1 },
        mode = "fill",
        x = PANEL_X,
        y = PANEL_Y,
        width = PANEL_WIDTH,
        height = PANEL_HEIGHT,
        offset = 5,
        rx = 3,
    },
}

function LevelCompleteState:init()
    self.x = -300
    self.playButton = Button(
        Textures["play"],
        0.5,
        VIRTUAL_WIDTH / 2 + self.x - 40,
        0.625 * VIRTUAL_HEIGHT
    )
    local STAR_WIDTH, STAR_HEIGHT =
        Textures["star"]:getWidth(), Textures["star"]:getHeight()
    self.STARS = {
        {
            x = PANEL_X + PANEL_WIDTH / 2 - 85,
            y = WINDOW_Y + 18,
            rotation = 50,
            scale = 0.6,
            ox = STAR_WIDTH / 2,
            oy = STAR_HEIGHT / 2,
        },
        {
            x = PANEL_X + PANEL_WIDTH / 2 + 65,
            y = WINDOW_Y + 10,
            rotation = -50,
            scale = 0.6,
            ox = STAR_WIDTH / 2,
            oy = STAR_HEIGHT / 2,
        },
        {
            x = PANEL_X + PANEL_WIDTH / 2 - 5,
            y = WINDOW_Y,
            rotation = 0,
            scale = 0.8,
            ox = STAR_WIDTH / 2,
            oy = STAR_HEIGHT / 2,
        },
    }
    self.starScale = { 0, 0, 0 }

    self.bubbles = {}
    for _ = 1, 20 do
        table.insert(self.bubbles, Bubble())
    end
end

function LevelCompleteState:enter(params)
    self.level = params.level
    self.moves = params.moves
    local trails = params.trails
    self.msg = (trails <= 1 and "Flawless!") or (trails <= 3 and "Skilled!" or "Nice!")

    if Progress[self.level].stars == 0 then
        self.stars = (trails <= 1 and 3) or (trails <= 3 and 2 or 1)
    else
        self.stars = Progress[self.level].stars
    end
    local bestMoves = 100
    if Progress[self.level].moves > self.moves then
        bestMoves = self.moves
    else
        bestMoves = Progress[self.level].moves
    end
    Progress[self.level] =
        { completed = true, stars = self.stars, moves = bestMoves, trails = trails }
    Progress[self.level + 1] = { completed = false, stars = 0, moves = 100 }
    Save.write(Progress)

    Timer.tween(0.2, { [self] = { x = 40 } }):finish(function()
        if self.stars >= 1 then
            Timer.tween(0.1, { [self.starScale] = { [1] = 0.6 } }):finish(function()
                local copy1 = Sounds["star"]:clone()
                copy1:play()
                if self.stars >= 2 then
                    Timer.tween(0.1, { [self.starScale] = { [2] = 0.8 } })
                        :finish(function()
                            local copy2 = Sounds["star"]:clone()
                            copy2:play()
                            if self.stars >= 3 then
                                Timer.tween(0.1, { [self.starScale] = { [3] = 0.6 } })
                                    :finish(function()
                                        local copy3 = Sounds["star"]:clone()
                                        copy3:play()
                                    end)
                            end
                        end)
                end
            end)
        end
    end)
    love.graphics.setLineWidth(4)
end

function LevelCompleteState:exit()
    Timer.clear()
    love.graphics.setLineWidth(1)
end

function LevelCompleteState:update(dt)
    if love.keyboard.wasPressed("escape") then
        GameState:change("start")
    end

    local centerX = VIRTUAL_WIDTH / 2 + self.x - 40
    self.playButton.left = centerX - self.playButton.width / 2
    self.playButton.right = centerX + self.playButton.width / 2
    if self.playButton:isClicked() then
        Timer.tween(0.2, { [self] = { x = 360 } }):finish(function()
            GameState:change("play", { level = self.level + 1 })
        end)
    end

    Timer.update(dt)

    for _, bubble in ipairs(self.bubbles) do
        bubble:update(dt)
    end
    for i, bubble in ipairs(self.bubbles) do
        if bubble.shouldRemove then
            table.remove(self.bubbles, i)
            table.insert(self.bubbles, Bubble())
        end
    end
end

function LevelCompleteState:render()
    -- draw animated bubbles
    for _, bubble in ipairs(self.bubbles) do
        bubble:render()
    end
    -- draw UI window
    for _, rect in ipairs(RECTS) do
        love.graphics.setColor(rect.color)
        love.graphics.rectangle(
            rect.mode,
            self.x + rect.x + rect.offset,
            rect.y + rect.offset,
            rect.width - 2 * rect.offset,
            rect.height - 2 * rect.offset,
            rect.rx
        )
    end
    love.graphics.setColor(1, 1, 1, 1)
    -- draw star outline
    for _, star in ipairs(self.STARS) do
        love.graphics.draw(
            Textures["star-outline"],
            self.x + star.x,
            star.y,
            star.rotation,
            star.scale,
            star.scale,
            star.ox * star.scale,
            star.oy * star.scale
        )
    end
    -- draw the stars earned
    local starOrder = {
        [1] = 1,
        [2] = 3,
        [3] = 2,
    }
    for i = 1, self.stars do
        love.graphics.draw(
            Textures["star"],
            self.x + self.STARS[starOrder[i]].x,
            self.STARS[starOrder[i]].y,
            self.STARS[starOrder[i]].rotation,
            self.starScale[i],
            self.starScale[i],
            self.STARS[starOrder[i]].ox * self.STARS[starOrder[i]].scale,
            self.STARS[starOrder[i]].oy * self.STARS[starOrder[i]].scale
        )
    end
    -- print UI messages
    love.graphics.setFont(Fonts["medium "])
    PrintfScaled(
        "Level " .. tostring(self.level),
        self.x,
        WINDOW_Y + 70,
        WINDOW_WIDTH,
        "center"
    )
    love.graphics.setFont(Fonts["small"])
    local fontHeight = Fonts["small"]:getHeight()
    love.graphics.setColor(0, 0, 0, 1)
    PrintfScaled(self.msg, self.x, PANEL_Y + 0.5 * fontHeight, WINDOW_WIDTH, "center")
    PrintfScaled(
        "Moves: " .. tostring(self.moves),
        self.x,
        PANEL_Y + 2.5 * fontHeight,
        WINDOW_WIDTH,
        "center"
    )
    PrintfScaled(
        "Best Moves: " .. tostring(Progress[self.level].moves),
        self.x,
        PANEL_Y + 3.5 * fontHeight,
        WINDOW_WIDTH,
        "center"
    )
    love.graphics.setColor(1, 1, 1, 1)

    self.playButton:render()
end

return LevelCompleteState
