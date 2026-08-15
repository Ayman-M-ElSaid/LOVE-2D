local LevelMaker = {}

local MIN_COLS, MAX_COLS = 6, 9
local MIN_ROWS, MAX_ROWS = 10, 22
local MAX_ATTEMPTS = 10

local DIRECTIONS = {
    up = { dy = -1, dx = 0 },
    down = { dy = 1, dx = 0 },
    left = { dy = 0, dx = -1 },
    right = { dy = 0, dx = 1 },
}

local function getLevelSize(rng, level)
    local maxCols = math.min(MAX_COLS, MIN_COLS + level)
    local maxRows = math.min(MAX_ROWS, MIN_ROWS + level)
    return rng:random(MIN_ROWS, maxRows), rng:random(MIN_COLS, maxCols)
end

local function openRatioForLevel(level)
    return math.min(0.95, 0.75 + (level - 1) * 0.02)
end

local function inInterior(row, col, rows, cols)
    return row > 1 and row < rows and col > 1 and col < cols
end

local function wouldCreate2x2(openTiles, row, col)
    local function isOpen(row, col)
        return openTiles[row] and openTiles[row][col]
    end
    if isOpen(row - 1, col - 1) and isOpen(row - 1, col) and isOpen(row, col - 1) then
        return true
    end
    if isOpen(row - 1, col) and isOpen(row - 1, col + 1) and isOpen(row, col + 1) then
        return true
    end
    if isOpen(row, col - 1) and isOpen(row + 1, col - 1) and isOpen(row + 1, col) then
        return true
    end
    if isOpen(row, col + 1) and isOpen(row + 1, col) and isOpen(row + 1, col + 1) then
        return true
    end
    return false
end

local function canOpen(openTiles, blocked, row, col, rows, cols)
    if not inInterior(row, col, rows, cols) then
        return false
    end
    if openTiles[row][col] then
        return false
    end
    if blocked[row][col] then
        return false
    end
    if wouldCreate2x2(openTiles, row, col) then
        return false
    end
    return true
end

local function reserveWallBeyond(
    openTiles,
    blocked,
    row,
    col,
    dir,
    rows,
    cols,
    skipRow,
    skipCol
)
    local wr, wc = row + dir.dy, col + dir.dx
    if skipRow and wr == skipRow and wc == skipCol then
        return
    end
    if inInterior(wr, wc, rows, cols) and not openTiles[wr][wc] then
        blocked[wr][wc] = true
    end
end

local function slideAcrossOpenTiles(openTiles, row, col, dir, rows, cols)
    while true do
        local nextRow, nextCol = row + dir.dy, col + dir.dx
        if nextRow < 1 or nextRow > rows or nextCol < 1 or nextCol > cols then
            break
        end
        if not openTiles[nextRow][nextCol] then
            break
        end
        row, col = nextRow, nextCol
    end
    return row, col
end

local function bfsReachable(openTiles, rows, cols, startRow, startCol)
    local visited = {}
    for r = 1, rows do
        visited[r] = {}
    end
    visited[startRow][startCol] = { root = true }
    local queue, queueIndex = { { startRow, startCol } }, 1
    while queueIndex <= #queue do
        local currentRow, currentCol = queue[queueIndex][1], queue[queueIndex][2]
        queueIndex = queueIndex + 1
        for _, direction in pairs(DIRECTIONS) do
            local newRow, newCol = slideAcrossOpenTiles(
                openTiles,
                currentRow,
                currentCol,
                direction,
                rows,
                cols
            )
            if
                (newRow ~= currentRow or newCol ~= currentCol)
                and not visited[newRow][newCol]
            then
                visited[newRow][newCol] =
                    { parentRow = currentRow, parentCol = currentCol, dir = direction }
                table.insert(queue, { newRow, newCol })
            end
        end
    end
    return visited
end

local function reservePathWalls(
    visited,
    targetRow,
    targetCol,
    openTiles,
    blocked,
    rows,
    cols,
    skipRow,
    skipCol
)
    local row, col = targetRow, targetCol
    while visited[row][col] and not visited[row][col].root do
        local node = visited[row][col]
        reserveWallBeyond(
            openTiles,
            blocked,
            row,
            col,
            node.dir,
            rows,
            cols,
            skipRow,
            skipCol
        )
        row, col = node.parentRow, node.parentCol
    end
end

local function slideAndCarve(openTiles, blocked, row, col, dir, rows, cols)
    local opened = 0
    while canOpen(openTiles, blocked, row + dir.dy, col + dir.dx, rows, cols) do
        row, col = row + dir.dy, col + dir.dx
        openTiles[row][col] = true
        opened = opened + 1
    end
    reserveWallBeyond(openTiles, blocked, row, col, dir, rows, cols)
    return row, col, opened
end

local function carveLevel(rng, level)
    local rows, cols = getLevelSize(rng, level)
    local interiorArea = (rows - 2) * (cols - 2)
    local targetOpen = math.max(1, math.floor(interiorArea * openRatioForLevel(level)))

    local openTiles, blocked = {}, {}
    for row = 1, rows do
        openTiles[row] = {}
        blocked[row] = {}
    end

    local startRow = rng:random(2, rows - 1)
    local startCol = rng:random(2, cols - 1)
    openTiles[startRow][startCol] = true
    local openCount = 1
    local currentRow, currentCol = startRow, startCol

    while openCount < targetOpen do
        local visited = bfsReachable(openTiles, rows, cols, currentRow, currentCol)

        local candidates = {}
        for row = 1, rows do
            for col = 1, cols do
                if visited[row][col] then
                    for _, direction in pairs(DIRECTIONS) do
                        if
                            canOpen(
                                openTiles,
                                blocked,
                                row + direction.dy,
                                col + direction.dx,
                                rows,
                                cols
                            )
                        then
                            table.insert(
                                candidates,
                                { row = row, col = col, dir = direction }
                            )
                        end
                    end
                end
            end
        end

        if #candidates == 0 then
            break
        end

        local choice = candidates[rng:random(#candidates)]
        local carveTargetR = choice.row + choice.dir.dy
        local carveTargetC = choice.col + choice.dir.dx

        reservePathWalls(
            visited,
            choice.row,
            choice.col,
            openTiles,
            blocked,
            rows,
            cols,
            carveTargetR,
            carveTargetC
        )

        local endRow, endCol, opened = slideAndCarve(
            openTiles,
            blocked,
            choice.row,
            choice.col,
            choice.dir,
            rows,
            cols
        )
        openCount = openCount + opened
        currentRow, currentCol = endRow, endCol
    end

    return openTiles, rows, cols, startRow, startCol
end

local function verifySolvable(openTiles, rows, cols, startRow, startCol)
    local painted, visited = {}, {}
    for row = 1, rows do
        painted[row] = {}
        visited[row] = {}
    end

    local function slideAndPaint(row, col, dir)
        while true do
            local nr, nc = row + dir.dy, col + dir.dx
            if nr < 1 or nr > rows or nc < 1 or nc > cols then
                break
            end
            if not openTiles[nr][nc] then
                break
            end
            row, col = nr, nc
            painted[row][col] = true
        end
        return row, col
    end

    painted[startRow][startCol] = true
    visited[startRow][startCol] = true
    local stack = { { startRow, startCol } }
    while #stack > 0 do
        local pos = table.remove(stack)
        for _, d in pairs(DIRECTIONS) do
            local nr, nc = slideAndPaint(pos[1], pos[2], d)
            if not visited[nr][nc] then
                visited[nr][nc] = true
                table.insert(stack, { nr, nc })
            end
        end
    end

    for r = 1, rows do
        for c = 1, cols do
            if openTiles[r][c] and not painted[r][c] then
                return false
            end
        end
    end
    return true
end

function LevelMaker.makeLevel(level, color)
    local openTiles, rows, cols, startRow, startCol

    for attempt = 1, MAX_ATTEMPTS do
        local rng = love.math.newRandomGenerator(level * 1000 + attempt)
        openTiles, rows, cols, startRow, startCol = carveLevel(rng, level)
        if verifySolvable(openTiles, rows, cols, startRow, startCol) then
            break
        end
    end

    local colOffset = math.floor((VIRTUAL_WIDTH - cols * TILE_SIZE) / 2)
    local rowOffset = math.floor((VIRTUAL_HEIGHT - rows * TILE_SIZE) / 2)

    local tiles = {}
    for row = 1, rows do
        tiles[row] = {}
        for col = 1, cols do
            local isSolid = not openTiles[row][col]
            local tile = Tile(
                (col - 1) * TILE_SIZE + colOffset,
                (row - 1) * TILE_SIZE + rowOffset,
                color
            )
            tile.isSolid = isSolid
            tile.isPainted = isSolid
            tiles[row][col] = tile
        end
    end
    for row = 1, rows do
        for col = 1, cols do
            local tile = tiles[row][col]
            if tile.isSolid then
                tile.edges = {}
                for name, direction in pairs(DIRECTIONS) do
                    local nextRow, nextCol = row + direction.dy, col + direction.dx
                    local neighbor = tiles[nextRow] and tiles[nextRow][nextCol]
                    tile.edges[name] = neighbor ~= nil and not neighbor.isSolid
                end
            end
        end
    end

    local startX = (startCol - 1) * TILE_SIZE + colOffset
    local startY = (startRow - 1) * TILE_SIZE + rowOffset

    return tiles, startX, startY
end

return LevelMaker
