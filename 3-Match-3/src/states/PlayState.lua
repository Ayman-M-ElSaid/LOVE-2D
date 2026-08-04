PlayState = Class({ __includes = BaseState })

function PlayState:init()
    self.hasEnded = false
    self.isPaused = false
    self.pauseButton = Button(
        Textures["button"],
        0.2,
        0.2 * VIRTUAL_WIDTH,
        0.85 * VIRTUAL_HEIGHT,
        { 0.93, 0.72, 0.28, 1.0 },
        "Pause",
        { 0.10, 0.25, 0.22, 1.0 }
    )
    self.uiRect = {
        mode = "fill",
        x = 0.025 * VIRTUAL_WIDTH,
        y = 0.15 * VIRTUAL_HEIGHT,
        width = 0.4 * VIRTUAL_WIDTH,
        height = 0.35 * VIRTUAL_HEIGHT,
        rx = 4,
    }
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

local function handlePause(self)
    if self.pauseButton:isClicked() then
        self.isPaused = not self.isPaused
    end
end

local function checkMatches(self)
    local matches = self.board:checkMatches()
    if matches then
        if SFX then
            Sounds["match"]:stop()
            Sounds["match"]:play()
        end
        for _, match in pairs(matches) do
            self.score = self.score + #match * 25
            self.timer = math.min(60, self.timer + #match)
        end
        self.board:removeMatches()
        local tilesToFall = self.board:getFallingTiles()
        Timer.tween(0.25, tilesToFall):group(self.timerGroup):finish(function()
            checkMatches(self)
        end)
    end
end

local function trySwap(self, row1, col1, row2, col2)
    local board = self.board
    local tile1 = board.tiles[row1][col1]
    local tile2 = board.tiles[row2][col2]

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
            if board:checkMatches() then
                checkMatches(self)
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
                }):group(self.timerGroup)
            end
        end)
end

local function swapTiles(self)
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
        local dx = mouseX - self.dragStartX
        local dy = mouseY - self.dragStartY
        local row, col = self.dragRow, self.dragCol
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
            trySwap(self, row, col, targetRow, targetCol)
        end

        self.dragging = false
    end
end

local function checkWin(self)
    if self.hasEnded then
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

local function checkLoss(self)
    if self.hasEnded then
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
    handlePause(self)
    if self.isPaused then
        return
    end
    Timer.update(dt, self.timerGroup)
    swapTiles(self)
    checkWin(self)
    checkLoss(self)
end

local function renderUI(self)
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

local function renderPauseMessage()
    love.graphics.setFont(Fonts["title"])
    love.graphics.setColor(1, 1, 1, 1)
    PrintfScaled("PAUSED", 0, VIRTUAL_HEIGHT / 2 - 20, VIRTUAL_WIDTH, "center")
end

function PlayState:render()
    self.board:render()
    self.pauseButton:render()
    renderUI(self)
    if self.isPaused then
        renderPauseMessage()
    end
end
