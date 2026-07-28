EnterHighScoreState = Class({ __includes = BaseState })

local maxNameLength = 7

function EnterHighScoreState:enter(params)
    self.score = params.score
    self.scoreIndex = params.scoreIndex
    self.name = ""

    love.textinput = function(text)
        if #self.name < maxNameLength and text:match("%a") then
            self.name = self.name .. text:upper()
            Sounds["select"]:stop()
            Sounds["select"]:play()
        else
            Sounds["no-select"]:play()
        end
    end
end

function EnterHighScoreState:exit()
    love.textinput = nil
end

function EnterHighScoreState:update(dt)
    if love.keyboard.wasPressed("backspace") then
        self.name = self.name:sub(1, -2)
    end

    if
        (love.keyboard.wasPressed("return") or love.keyboard.wasPressed("space"))
        and #self.name > 0
    then
        local name = self.name

        for i = 10, self.scoreIndex, -1 do
            HighScores[i + 1] = {
                name = HighScores[i].name,
                score = HighScores[i].score,
            }
        end

        HighScores[self.scoreIndex].name = name
        HighScores[self.scoreIndex].score = self.score

        local scoresStr = ""
        for i = 1, 10 do
            scoresStr = scoresStr
                .. HighScores[i].name
                .. ","
                .. tostring(HighScores[i].score)
                .. "\n"
        end
        love.filesystem.write("breakout.dat", scoresStr)

        GameState:change("high-scores")
    end
end

function EnterHighScoreState:render()
    love.graphics.setFont(Fonts["large"])
    love.graphics.printf("HighScore!", 0, 25, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(Fonts["medium"])
    love.graphics.printf(
        "Your score: " .. tostring(self.score),
        0,
        60,
        VIRTUAL_WIDTH,
        "center"
    )

    love.graphics.printf(
        "Enter your name",
        0,
        VIRTUAL_HEIGHT / 2 - 20,
        VIRTUAL_WIDTH,
        "center"
    )
    love.graphics.setFont(Fonts["large"])
    love.graphics.printf(self.name, 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(Fonts["small"])
    love.graphics.printf(
        GetConfirmMessage() .. "to confirm!",
        0,
        VIRTUAL_HEIGHT - 18,
        VIRTUAL_WIDTH,
        "center"
    )
end
