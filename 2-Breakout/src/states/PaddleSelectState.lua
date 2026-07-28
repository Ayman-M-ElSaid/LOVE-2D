PaddleSelectState = Class({ __includes = BaseState })

function PaddleSelectState:init()
    self.selection = 1
end

function PaddleSelectState:update(dt)
    if
        love.keyboard.wasPressed("left")
        or love.keyboard.wasPressed("a")
        or love.mouse.wasPressedAt(
            VIRTUAL_WIDTH / 4 - 24,
            VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3,
            VIRTUAL_WIDTH / 4,
            VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3 + 24
        )
    then
        if self.selection == 1 then
            Sounds["no-select"]:play()
        else
            Sounds["select"]:play()
            self.selection = self.selection - 1
        end
    elseif
        love.keyboard.wasPressed("right")
        or love.keyboard.wasPressed("d")
        or love.mouse.wasPressedAt(
            VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4,
            VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3,
            VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4 + 24,
            VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3 + 24
        )
    then
        if self.selection == 4 then
            Sounds["no-select"]:play()
        else
            Sounds["select"]:play()
            self.selection = self.selection + 1
        end
    end

    if
        love.keyboard.wasPressed("return")
        or love.keyboard.wasPressed("space")
        or love.mouse.wasPressedAt(
            VIRTUAL_WIDTH / 2 - 32,
            VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3,
            VIRTUAL_WIDTH / 2 - 32 + 64,
            VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3 + 16
        )
    then
        Sounds["confirm"]:play()

        GameState:change("serve", {
            paddle = Paddle(self.selection),
            ball = Ball(self.selection),
            bricks = LevelMaker.createMap(1),
            health = 3,
            score = 0,
            level = 1,
        })
    end

    if love.keyboard.wasPressed("escape") then
        GameState:change("start")
        Sounds["wall-hit"]:play()
    end
end

function PaddleSelectState:render()
    love.graphics.setFont(Fonts["medium"])
    love.graphics.printf(
        "Select your paddle!",
        0,
        VIRTUAL_HEIGHT / 4,
        VIRTUAL_WIDTH,
        "center"
    )
    love.graphics.setFont(Fonts["small"])
    love.graphics.printf(
        "(" .. GetConfirmMessage() .. "to continue!)",
        0,
        VIRTUAL_HEIGHT / 3,
        VIRTUAL_WIDTH,
        "center"
    )

    local tint = { 40 / 255, 40 / 255, 40 / 255, 128 / 255 }
    if self.selection == 1 then
        love.graphics.setColor(tint)
    end
    love.graphics.draw(
        Textures["arrow"],
        VIRTUAL_WIDTH / 4 - 24,
        VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3
    )
    love.graphics.setColor(1, 1, 1, 1)

    if self.selection == 4 then
        love.graphics.setColor(tint)
    end
    love.graphics.draw(
        Textures["arrow"],
        VIRTUAL_WIDTH - VIRTUAL_WIDTH / 4 + Textures["arrow"]:getWidth(),
        VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3,
        0,
        -1,
        1
    )
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.draw(
        Textures["breakout"],
        Frames["paddles"][2 + 4 * (self.selection - 1)],
        VIRTUAL_WIDTH / 2 - 32,
        VIRTUAL_HEIGHT - VIRTUAL_HEIGHT / 3
    )
end
