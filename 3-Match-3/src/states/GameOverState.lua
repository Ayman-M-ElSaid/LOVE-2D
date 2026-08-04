GameOverState = Class({ __includes = BaseState })

local textColors = { { 0.08, 0.20, 0.16, 0.65 }, { 1.0, 0.82, 0.39, 1.0 } }

function GameOverState:init()
    self.button = Button(
        Textures["button"],
        0.2,
        VIRTUAL_WIDTH / 2,
        0.775 * VIRTUAL_HEIGHT,
        { 0.86, 0.32, 0.28, 1.0 },
        "Awesome!",
        { 1.0, 0.94, 0.75, 1.0 }
    )
end
function GameOverState:enter(params)
    self.score = params.score
end

function GameOverState:update(dt)
    if self.button:isClicked() then
        Transition.to("start")
    end
end

function GameOverState:render()
    for i, color in ipairs(textColors) do
        love.graphics.setColor(color)
        love.graphics.setFont(Fonts["title"])
        PrintfScaled(
            "GAME OVER",
            -2 * i,
            VIRTUAL_HEIGHT / 4 - 2 * i,
            VIRTUAL_WIDTH,
            "center"
        )
        love.graphics.setFont(Fonts["large"])
        PrintfScaled(
            string.format("<Your Score: %d>", self.score),
            -2 * i,
            VIRTUAL_HEIGHT / 2 - 2 * i,
            VIRTUAL_WIDTH,
            "center"
        )
    end

    self.button:render()
end
