Board = Class({})

--- Creates a new game board.
---@param rows number The number of rows on the board.
---@param cols number The number of columns on the board.
---@param scale number The scale at which to render the board tiles.
---@param centerX number The x-coordinate of the board's center.
---@param centerY number The y-coordinate of the board's center.
function Board:init(rows, cols, scale, centerX, centerY)
    self.rows, self.cols = rows, cols
    self.scale = scale
    self.tileSize = Textures["tile"]:getWidth() * scale
    self.x = centerX - (self.tileSize * cols) / 2
    self.y = centerY - (self.tileSize * rows) / 2
    self.matches = {}
    self:initializeTiles()
end

--- Creates the board's initial set of fruit tiles.
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

    -- recreates the board until no initial matches are present.
    while self:checkMatches() do
        self:initializeTiles()
    end
end

--- Checks the board for horizontal and vertical matches of three or more fruits.
---@return table|boolean The detected matches, or false if no matches are found.
function Board:checkMatches()
    local matches = {}
    local matchNum = 1
    -- check horizontal matches
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
    -- check vertical matches
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

--- Removes all currently detected matches from the board.
function Board:removeMatches()
    for _, match in ipairs(self.matches) do
        for _, tile in ipairs(match) do
            self.tiles[tile.gridY][tile.gridX] = nil
        end
    end
    self.matches = nil
end

--- Moves existing tiles down to fill empty spaces and creates new tiles.
---@return table tweens A table containing the target positions of falling and new tiles.
function Board:getFallingTiles()
    local tweens = {}
    -- fill empty spaces by moving existing fruits downward
    for col = 1, self.cols do
        local spaceFound = false
        local spaceY = 0
        local row = self.rows
        while row >= 1 do
            local tile = self.tiles[row][col]
            -- if there is an empty space, store its position
            if tile == nil then
                spaceFound = true
                if spaceY == 0 then
                    spaceY = row
                end
            -- if tile is found and found an empty space below it, swap the tile with empty space
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
    -- create new fruits to fill the empty spaces at top
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

--- Checks whether any adjacent tile swap can create a match.
---@return boolean Whether a possible matching move exists.
function Board:hasPossibleMoves()
    for row = 1, self.rows do
        for col = 1, self.cols do
            if col < self.cols then
                -- swap two adjacent tiles on the same row
                self.tiles[row][col], self.tiles[row][col + 1] =
                    self.tiles[row][col + 1], self.tiles[row][col]
                -- ater a hypothetical swap, check if there is any matches
                local found = self:checkMatches()
                -- swap back regardless, as this is just a possibility check.
                self.tiles[row][col], self.tiles[row][col + 1] =
                    self.tiles[row][col + 1], self.tiles[row][col]
                if found then
                    return true
                end
            end
            -- do the same steps for tiles in the same column
            if row < self.rows then
                self.tiles[row][col], self.tiles[row + 1][col] =
                    self.tiles[row + 1][col], self.tiles[row][col]
                local found = self:checkMatches()
                self.tiles[row][col], self.tiles[row + 1][col] =
                    self.tiles[row + 1][col], self.tiles[row][col]
                if found then
                    return true
                end
            end
        end
    end
    return false
end

--- Replaces all tiles with new random tiles and prepares them to fall onto the board.
---@return table tweens A table containing the target positions of the new tiles.
function Board:reshuffle()
    local tweens = {}
    for row = 1, self.rows do
        for col = 1, self.cols do
            local newTile = Fruit(
                love.math.random(8),
                self.tileSize / 128,
                col,
                row,
                self.x,
                self.y
            )
            newTile.y = self.y - self.tileSize * row
            self.tiles[row][col] = newTile
            tweens[newTile] = { y = self.y + (row - 1) * self.tileSize }
        end
    end
    return tweens
end

--- Renders the board background and all fruit tiles.
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
