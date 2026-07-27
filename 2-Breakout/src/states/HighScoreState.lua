HighScoreState = Class({ __includes = BaseState })

function HighScoreState:update(dt)
    if love.keyboard.wasPressed("escape") then
        Sounds["wall-hit"]:play()
        GameState:change("start")
    end
end

function HighScoreState:render()
    love.graphics.setFont(Fonts["large"])
    love.graphics.printf("High Scores", 0, 20, VIRTUAL_WIDTH, "center")

    love.graphics.setFont(Fonts["medium"])

    for i = 1, 10 do
        local name = HighScores[i].name or "---"
        local score = HighScores[i].score or "---"

        love.graphics.printf(
            tostring(i) .. ".",
            VIRTUAL_WIDTH / 4,
            60 + i * 13,
            50,
            "left"
        )

        love.graphics.printf(name, VIRTUAL_WIDTH / 4 + 38, 60 + i * 13, 90, "left")

        love.graphics.printf(
            tostring(score),
            VIRTUAL_WIDTH / 4 + 38 + 90,
            60 + i * 13,
            90,
            "right"
        )
    end

    love.graphics.setFont(Fonts["small"])
    love.graphics.printf(
        "Press Escape to return to the main menu!",
        0,
        VIRTUAL_HEIGHT - 18,
        VIRTUAL_WIDTH,
        "center"
    )
end
