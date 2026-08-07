PlayState = Class({ __includes = BaseState })

function PlayState:init()
    self.isPaused = false
    self.hasEnded = false
    self.isTweening = false
    self.isReshuffling = false
    self.uiRect = {
        mode = "fill",
        x = 0.025 * VIRTUAL_WIDTH,
        y = 0.15 * VIRTUAL_HEIGHT,
        width = 0.4 * VIRTUAL_WIDTH,
        height = 0.35 * VIRTUAL_HEIGHT,
        rx = 4,
    }
    self.pauseButton = Button(
        Textures["button"],
        0.2,
        0.225 * VIRTUAL_WIDTH,
        0.85 * VIRTUAL_HEIGHT,
        { 0.93, 0.72, 0.28, 1.0 },
        "Pause",
        { 0.10, 0.25, 0.22, 1.0 }
    )
    self.pauseMenuRect = {
        mode = "fill",
        x = 0.325 * VIRTUAL_WIDTH,
        y = 0.15 * VIRTUAL_HEIGHT,
        width = 0.35 * VIRTUAL_WIDTH,
        height = VIRTUAL_HEIGHT / 1.5,
        rx = 4,
    }
    self.pauseMenuShadow = {
        mode = "fill",
        x = 0.325 * VIRTUAL_WIDTH - 2,
        y = 0.15 * VIRTUAL_HEIGHT - 2,
        width = 0.35 * VIRTUAL_WIDTH + 4,
        height = VIRTUAL_HEIGHT / 1.5 + 4,
        rx = 4,
    }
    self.musicButton = Button(
        Textures["music"],
        0.09,
        self.pauseMenuRect.x + 0.4 * self.pauseMenuRect.width,
        self.pauseMenuRect.y * 2
    )
    self.sfxButton = Button(
        Textures["sfx"],
        0.09,
        self.pauseMenuRect.x + 0.6 * self.pauseMenuRect.width,
        self.pauseMenuRect.y * 2
    )
    self.resumeButton = Button(
        Textures["button"],
        0.2,
        self.pauseMenuRect.x + self.pauseMenuRect.width / 2,
        self.pauseMenuRect.y * 2.75,
        { 0.30, 0.72, 0.45, 1.0 },
        "Resume",
        { 0.06, 0.22, 0.16, 1.0 }
    )
    self.restartButton = Button(
        Textures["button"],
        0.2,
        self.pauseMenuRect.x + self.pauseMenuRect.width / 2,
        self.pauseMenuRect.y * 3.75,
        { 0.95, 0.68, 0.22, 1.0 },
        "Restart",
        { 0.10, 0.23, 0.20, 1.0 }
    )
    self.quitButton = Button(
        Textures["button"],
        0.2,
        self.pauseMenuRect.x + self.pauseMenuRect.width / 2,
        self.pauseMenuRect.y * 4.75,
        { 0.85, 0.27, 0.23, 1.0 },
        "Quit",
        { 1.00, 0.94, 0.78, 1.0 }
    )

    self.timerGroup = {}
    Timer.every(1, function()
        self.timer = self.timer - 1
        if self.timer <= 5 and SFX then
            Sounds["clock"]:play()
        end
    end):group(self.timerGroup)
end

function PlayState:enter(params)
    self.level = params.level
    self.board = params.board
        or Board(9, 9, 0.09, 0.7 * VIRTUAL_WIDTH, VIRTUAL_HEIGHT / 2)
    self.score = params.score or 0
    self.scoreGoal = math.ceil(1.6 ^ (self.level - 1)) * 500
    self.timer = math.floor(60 * 0.95 ^ (self.level - 1))
end

function PlayState:swapTiles()
    if self.isTweening then
        return
    end

    local mouseX, mouseY = Push.toGame(love.mouse.getPosition())
    if not mouseX or not mouseY then
        return
    end

    if love.mouse.wasPressed(1) then
        for row = 1, self.board.rows do
            for col = 1, self.board.cols do
                local tile = self.board.tiles[row][col]
                if
                    mouseX >= tile.x
                    and mouseX <= tile.x + tile.width
                    and mouseY >= tile.y
                    and mouseY <= tile.y + tile.height
                then
                    self.dragging = true
                    self.dragRow, self.dragCol = row, col
                    self.dragStartX, self.dragStartY = mouseX, mouseY
                end
            end
        end
    end

    if self.dragging and love.mouse.wasReleased(1) then
        self.dragging = false
        local dx = mouseX - self.dragStartX
        local dy = mouseY - self.dragStartY
        local row, col = self.dragRow, self.dragCol
        local threshold = self.board.tileSize * 0.25

        if math.abs(dx) < threshold and math.abs(dy) < threshold then
            self:handleTap(row, col)
        else
            self.selectedRow, self.selectedCol = nil, nil

            local targetRow, targetCol = row, col
            if math.abs(dx) > math.abs(dy) then
                targetCol = col + math.sign(dx)
            else
                targetRow = row + math.sign(dy)
            end

            if
                targetRow >= 1
                and targetRow <= self.board.rows
                and targetCol >= 1
                and targetCol <= self.board.cols
            then
                self:trySwap(row, col, targetRow, targetCol)
            end
        end
    end
end

function PlayState:handleTap(row, col)
    if not self.selectedRow then
        self.selectedRow, self.selectedCol = row, col
        return
    end

    if self.selectedRow == row and self.selectedCol == col then
        self.selectedRow, self.selectedCol = nil, nil
        return
    end

    local rowDiff = math.abs(self.selectedRow - row)
    local colDiff = math.abs(self.selectedCol - col)

    if rowDiff + colDiff == 1 then
        self:trySwap(self.selectedRow, self.selectedCol, row, col)
        self.selectedRow, self.selectedCol = nil, nil
    else
        self.selectedRow, self.selectedCol = row, col
    end
end

function PlayState:trySwap(row1, col1, row2, col2)
    local board = self.board
    local tile1 = board.tiles[row1][col1]
    local tile2 = board.tiles[row2][col2]
    if tile1 == tile2 then
        return
    end
    self.isTweening = true

    board.tiles[row1][col1] = tile2
    board.tiles[row2][col2] = tile1

    tile1.gridX, tile2.gridX = tile2.gridX, tile1.gridX
    tile1.gridY, tile2.gridY = tile2.gridY, tile1.gridY

    local x1, y1 = tile1.x, tile1.y
    local x2, y2 = tile2.x, tile2.y

    Timer.tween(0.15, {
        [tile1] = { x = x2, y = y2 },
        [tile2] = { x = x1, y = y1 },
    })
        :group(self.timerGroup)
        :finish(function()
            if board:checkSpecialMatches(tile1, tile2) or board:checkMatches() then
                self:checkMatches()
            else
                board.tiles[row1][col1] = tile1
                board.tiles[row2][col2] = tile2
                tile1.gridX, tile2.gridX = tile2.gridX, tile1.gridX
                tile1.gridY, tile2.gridY = tile2.gridY, tile1.gridY
                if SFX then
                    Sounds["error"]:play()
                end
                Timer.tween(0.15, {
                    [tile1] = { x = x1, y = y1 },
                    [tile2] = { x = x2, y = y2 },
                })
                    :group(self.timerGroup)
                    :finish(function()
                        self.isTweening = false
                    end)
            end
        end)
end

function PlayState:checkMatches()
    if SFX then
        Sounds["match"]:stop()
        Sounds["match"]:play()
    end

    local removedTiles = self.board:removeMatches()
    self.score = self.score + removedTiles * 25
    self.timer = math.min(60, self.timer + removedTiles)

    local tilesToFall = self.board:getFallingTiles()
    Timer.tween(0.25, tilesToFall):group(self.timerGroup):finish(function()
        if self.board:checkMatches() then
            self:checkMatches()
        elseif not self.board:hasPossibleMoves() then
            self.isReshuffling = true
            self:reshuffleBoard()
        else
            self.isTweening = false
        end
    end)
end

function PlayState:reshuffleBoard()
    local tweens = self.board:reshuffle()
    Timer.tween(1, tweens):group(self.timerGroup):finish(function()
        self.isReshuffling = false

        if self.board:checkMatches() then
            self:checkMatches()
        elseif not self.board:hasPossibleMoves() then
            self.isReshuffling = true
            self:reshuffleBoard()
        else
            self.isTweening = false
        end
    end)
end

function PlayState:handlePause()
    if self.pauseButton:isClicked() then
        self.isPaused = true
    end
    if self.isPaused then
        if self.resumeButton:isClicked() then
            self.isPaused = false
        elseif self.restartButton:isClicked() then
            Transition.to("begin-level", { level = 1 })
        elseif self.quitButton:isClicked() then
            Transition.to("start")
        elseif self.sfxButton:isClicked() then
            SFX = not SFX
        elseif self.musicButton:isClicked() then
            Music = not Music
            if Music then
                Sounds["music"]:play()
            else
                Sounds["music"]:stop()
            end
        end
    end
end

function PlayState:checkWin()
    if self.hasEnded or self.isTweening then
        return
    end
    if self.score >= self.scoreGoal then
        self.hasEnded = true
        if SFX then
            Sounds["next-level"]:play()
        end
        Transition.to("begin-level", {
            level = self.level + 1,
            score = self.score,
            board = self.board,
        })
    end
end

function PlayState:checkLoss()
    if self.hasEnded or self.isTweening then
        return
    end
    if self.timer <= 0 then
        self.hasEnded = true
        if SFX then
            Sounds["game-over"]:play()
        end
        Transition.to("game-over", { score = self.score })
    end
end

function PlayState:update(dt)
    self:handlePause()
    if self.isPaused then
        return
    end
    Timer.update(dt, self.timerGroup)
    self.board:update(dt)
    self:swapTiles()
    self:checkWin()
    self:checkLoss()
end

function PlayState:renderUI()
    love.graphics.setColor(0.95, 0.88, 0.70, 0.88)
    DrawRect(self.uiRect)
    love.graphics.push()
    love.graphics.translate(self.uiRect.x, self.uiRect.y)
    love.graphics.setColor(0.16, 0.24, 0.20, 1.0)
    love.graphics.setFont(Fonts["meduim"])
    local lines = {
        "Level: " .. tostring(self.level),
        "Score: " .. tostring(self.score),
        "Goal : " .. tostring(self.scoreGoal),
        "Time : " .. tostring(self.timer),
    }
    local lineHeight = Fonts["meduim"]:getHeight() / FONT_SCALE
    for i, line in ipairs(lines) do
        PrintfScaled(
            line,
            0,
            5 + (i - 1) * (lineHeight + 5),
            self.uiRect.width,
            "center"
        )
    end
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.pop()
end

function PlayState:renderPauseMenu()
    love.graphics.setColor({ 0.08, 0.22, 0.19, 0.65 })
    DrawRect(self.pauseMenuShadow)
    love.graphics.setColor(0.94, 0.88, 0.72, 0.96)
    DrawRect(self.pauseMenuRect)

    self.resumeButton:render()
    self.restartButton:render()
    self.quitButton:render()
    self.musicButton:render()
    if not Music then
        love.graphics.setLineWidth(3)
        love.graphics.setColor(1, 0, 0, 0.8)
        love.graphics.line(
            self.musicButton.left,
            self.musicButton.bottom,
            self.musicButton.right,
            self.musicButton.top
        )
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(1)
    end
    self.sfxButton:render()
    if not SFX then
        love.graphics.setLineWidth(3)
        love.graphics.setColor(1, 0, 0, 0.8)
        love.graphics.line(
            self.sfxButton.left,
            self.sfxButton.bottom,
            self.sfxButton.right,
            self.sfxButton.top
        )
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.setLineWidth(1)
    end

    love.graphics.setFont(Fonts["large"])
    love.graphics.setColor(0.08, 0.22, 0.19, 1.0)
    PrintfScaled(
        "<PAUSED>",
        self.pauseMenuRect.x,
        self.pauseMenuRect.y + 2,
        self.pauseMenuRect.width,
        "center"
    )
    love.graphics.setColor(1, 1, 1, 1)
end

function PlayState:render()
    self.board:render()
    self.pauseButton:render()
    self:renderUI()

    if self.selectedRow then
        local tile = self.board.tiles[self.selectedRow][self.selectedCol]
        love.graphics.setColor(0.52, 0.94, 1, 0.75)
        love.graphics.rectangle("line", tile.x, tile.y, tile.width, tile.height,4)
        love.graphics.setColor(1, 1, 1, 1)
    end
    if self.isPaused then
        self:renderPauseMenu()
    end
    if self.isReshuffling then
        love.graphics.setFont(Fonts["large"])
        love.graphics.setColor(0.08, 0.20, 0.16, 0.65)
        PrintfScaled("<Reshuffling>", 0, VIRTUAL_HEIGHT / 2, VIRTUAL_WIDTH, "center")
        love.graphics.setColor(1, 1, 1, 1)
        PrintfScaled(
            "<Reshuffling>",
            -2,
            VIRTUAL_HEIGHT / 2 - 2,
            VIRTUAL_WIDTH,
            "center"
        )
    end
end
