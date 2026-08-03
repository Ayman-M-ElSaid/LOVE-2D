Board = Class({})

function Board:init(rows, cols, scale, centerX, centerY)
    self.rows, self.cols = rows, cols
    self.scale = scale
    self.tileSize = Textures["tile"]:getWidth() * scale
    self.x = centerX - (self.tileSize * cols) / 2
    self.y = centerY - (self.tileSize * rows) / 2
    self.matches = {}
    self:initializeTiles()
end

function Board:initializeTiles()
    self.tiles = {}

    for tileY = 1, self.rows do
        table.insert(self.tiles, {})

        for tileX = 1, self.cols do
            table.insert(
                self.tiles[tileY],
                Fruit(
                    love.math.random(8),
                    self.tileSize / 128,
                    tileX,
                    tileY,
                    self.x,
                    self.y
                )
            )
        end
    end

    while self:checkMatches() do
        self:initializeTiles()
    end
end

function Board:checkMatches()
    local matches = {}
    local matchNum = 1
    for row = 1, self.rows do
        local colorToMatch = self.tiles[row][1].id
        matchNum = 1
        for col = 2, self.cols do
            if self.tiles[row][col].id == colorToMatch then
                matchNum = matchNum + 1
            else
                if matchNum >= 3 then
                    local match = {}
                    for tileX = col - 1, col - matchNum, -1 do
                        table.insert(match, self.tiles[row][tileX])
                    end
                    table.insert(matches, match)
                end
                colorToMatch = self.tiles[row][col].id
                matchNum = 1
                if col >= self.cols - 1 then
                    break
                end
            end
        end
        if matchNum >= 3 then
            local match = {}
            for tileX = self.cols, self.cols - matchNum + 1, -1 do
                table.insert(match, self.tiles[row][tileX])
            end
            table.insert(matches, match)
        end
    end

    for col = 1, self.cols do
        local colorToMatch = self.tiles[1][col].id
        matchNum = 1
        for row = 2, self.rows do
            if self.tiles[row][col].id == colorToMatch then
                matchNum = matchNum + 1
            else
                if matchNum >= 3 then
                    local match = {}
                    for tileY = row - 1, row - matchNum, -1 do
                        table.insert(match, self.tiles[tileY][col])
                    end
                    table.insert(matches, match)
                end
                colorToMatch = self.tiles[row][col].id
                matchNum = 1
                if row >= self.rows - 1 then
                    break
                end
            end
        end
        if matchNum >= 3 then
            local match = {}
            for tileY = self.rows, self.rows - matchNum + 1, -1 do
                table.insert(match, self.tiles[tileY][col])
            end
            table.insert(matches, match)
        end
    end

    self.matches = matches
    return #self.matches > 0 and self.matches or false
end

function Board:removeMatches()
    for _, match in ipairs(self.matches) do
        for _, tile in ipairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end
    self.matches = nil
end

function Board:getFallingTiles()
    local tweens = {}

    for col = 1, self.cols do
        local spaceFound = false
        local spaceY = 0
        local row = self.rows
        while row >= 1 do
            local tile = self.tiles[row][col]
            if tile == nil then
                spaceFound = true
                if spaceY == 0 then
                    spaceY = row
                end
            elseif spaceFound then
                if tile then
                    self.tiles[spaceY][col] = tile
                    tile.gridY = spaceY
                    self.tiles[row][col] = nil
                    tweens[tile] = {
                        y = self.y + (tile.gridY - 1) * tile.width,
                    }
                    spaceFound = false
                    row = spaceY
                    spaceY = 0
                end
            end
            row = row - 1
        end
    end

    for col = 1, self.cols do
        for row = self.rows, 1, -1 do
            local tile = self.tiles[row][col]

            if not tile then
                local newTile = Fruit(
                    love.math.random(8),
                    self.tileSize / 128,
                    col,
                    row,
                    self.x,
                    self.y
                )
                newTile.y = self.y - self.tileSize
                self.tiles[row][col] = newTile
                tweens[newTile] = {
                    y = self.y + (newTile.gridY - 1) * self.tileSize,
                }
            end
        end
    end
    return tweens
end

function Board:render()
    love.graphics.setColor(0.3, 0.3, 0.3, 0.8)
    for row = 1, self.rows do
        for col = 1, self.cols do
            love.graphics.draw(
                Textures["tile"],
                self.x + (col - 1) * self.tileSize,
                self.y + (row - 1) * self.tileSize,
                0,
                self.scale
            )
        end
    end
    love.graphics.setColor(1, 1, 1, 1)

    for y = 1, self.rows do
        for x = 1, self.cols do
            self.tiles[y][x]:render()
        end
    end
end

return Board
