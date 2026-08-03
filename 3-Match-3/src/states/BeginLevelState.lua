BeginLevelState = Class({})

function BeginLevelState:init()
    self.labelY = -48
end

function BeginLevelState:enter(params)
    self.level = params.level
    Timer.tween(0.5, { [self] = { labelY = VIRTUAL_HEIGHT / 2 - 32 } })
        :finish(function()
            Timer.after(0.75, function()
                Timer.tween(0.5, { [self] = { labelY = VIRTUAL_HEIGHT } })
                    :finish(function()
                        GameState:change("play", { level = self.level })
                    end)
            end)
        end)
end

function BeginLevelState:update() end
function BeginLevelState:render()
    love.graphics.setColor(95 / 255, 205 / 255, 228 / 255, 200 / 255)
    love.graphics.rectangle("fill", 0, self.labelY, VIRTUAL_WIDTH, 48)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(Fonts["button"])
    PrintfScaled(
        "Level " .. tostring(self.level),
        0,
        self.labelY + Fonts["button"]:getHeight() / 10,
        VIRTUAL_WIDTH,
        "center"
    )
end
