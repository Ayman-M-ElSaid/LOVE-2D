BeginLevelState = Class({ __includes = BaseState })

function BeginLevelState:init()
    self.labelY = Layout.beginLevelState.lableY
    self.height = Layout.beginLevelState.height
end

function BeginLevelState:enter(params)
    self.level = params.level
    self.accumulativeScore = params.accumulativeScore or 0
    self.board = params.board
    Timer.tween(0.5, { [self] = { labelY = VIRTUAL_HEIGHT / 2 - 24 } })
        :finish(function()
            Timer.after(0.75, function()
                Timer.tween(0.5, { [self] = { labelY = VIRTUAL_HEIGHT } })
                    :finish(function()
                        GameState:change("play", {
                            level = self.level,
                            accumulativeScore = self.accumulativeScore,
                            board = self.board,
                        })
                    end)
            end)
        end)
end

function BeginLevelState:render()
    love.graphics.setColor(0.37, 0.8, 0.89, 0.78)
    love.graphics.rectangle("fill", 0, self.labelY, VIRTUAL_WIDTH, self.height)
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
