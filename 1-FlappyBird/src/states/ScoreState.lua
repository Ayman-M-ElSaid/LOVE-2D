ScoreState = Class({ __includes = BaseState })

local MEDALS = {
    ["bronze"] = love.graphics.newImage("assets/images/bronze.png"),
    ["silver"] = love.graphics.newImage("assets/images/silver.png"),
    ["gold"] = love.graphics.newImage("assets/images/gold.png"),
}

function ScoreState:init()
    Scrolling = false
end

function ScoreState:enter(params)
    self.score = params.score

    if self.score >= 30 then
        self.medal = MEDALS["gold"]
        self.message = "Whoa! You're a genius!"
    elseif self.score >= 20 then
        self.medal = MEDALS["silver"]
        self.message = "So close to Gold!"
    elseif self.score >= 10 then
        self.medal = MEDALS["bronze"]
        self.message = "Hey, a medal!"
    else
        self.medal = nil
        self.message = "Oof! Try again!"
    end

    if self.score > HighScore then
        HighScore = self.score
        Save.saveHighScore(HighScore)
        self.isNewHighScore = true
    else
        self.isNewHighScore = false
    end
    love.timer.sleep(0.25)
end

function ScoreState:update(dt)
    if love.keyboard.wasPressed("space") or love.mouse.wasPressed(1) then
        GameState:change("countdown")
    elseif love.keyboard.wasPressed("escape") then
        GameState:change("title")
    end
end

function ScoreState:render()
    love.graphics.setFont(Fonts["flappy"])
    love.graphics.printf(self.message, 0, 64, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(Fonts["medium"])
    love.graphics.printf(
        string.format("Score: %d", self.score),
        0,
        100,
        VIRTUAL_WIDTH,
        "center"
    )
    love.graphics.printf(
        self.isNewHighScore and "New High Score!"
            or string.format("High Score: %d", HighScore),
        0,
        120,
        VIRTUAL_WIDTH,
        "center"
    )
    local message = IS_MOBILE and"Tap to Play Again!" or"Press Space to Play Again!"
    love.graphics.printf(message, 0, 190, VIRTUAL_WIDTH, "center")

    if self.medal then
        love.graphics.draw(
            self.medal,
            VIRTUAL_WIDTH / 2 - self.medal:getWidth() / 2,
            VIRTUAL_HEIGHT / 2
        )
    end
end
