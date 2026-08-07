Board = Class({})

local FruitColors = {
    { r = 0.82, g = 0.06, b = 0.00 },
    { r = 0.95, g = 0.40, b = 0.00 },
    { r = 0.16, g = 0.35, b = 0.12 },
    { r = 0.95, g = 0.53, b = 0.00 },
    { r = 0.40, g = 0.26, b = 0.87 },
    { r = 0.98, g = 0.55, b = 0.00 },
    { r = 0.58, g = 0.00, b = 0.12 },
    { r = 0.93, g = 0.71, b = 0.08 },
    { r = 0.19, g = 0.10, b = 0.22 },
}

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
    self:initializeParticleSystem()
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

--- Initializes the particle system used for board effects.
function Board:initializeParticleSystem()
    self.particleSystem = love.graphics.newParticleSystem(Textures["particles"])
    self.particleSystem:setQuads(Frames["particles"])
    self.particleSystem:setEmissionRate(0)
    self.particleSystem:setParticleLifetime(0.35, 0.60)
    self.particleSystem:setDirection(-math.pi / 2)
    self.particleSystem:setSpread(math.pi)
    self.particleSystem:setSpeed(150, 280)
    self.particleSystem:setLinearAcceleration(0, 250, 0, 450)
    self.particleSystem:setTangentialAcceleration(-60, 60)
    self.particleSystem:setSpin(-8, 8)
    self.particleSystem:setRotation(0, math.pi * 2)
    self.particleSystem:setSizes(0.35, 0.25, 0.125, 0)
    self.activeParticles = {}
end

--- Checks each row for horizontal matches of three or more fruits.
---@return table matches A list of detected horizontal matches.
local function checkHorizontalMatches(self)
    local matches = {}
    local matchNum = 1

    for row = 1, self.rows do
        local colorToMatch = self.tiles[row][1].color
        matchNum = 1
        for col = 2, self.cols do
            if self.tiles[row][col].color == colorToMatch then
                matchNum = matchNum + 1
            else
                if matchNum >= 3 then
                    local startCol = col - matchNum
                    local spawnCol = startCol + math.floor((matchNum - 1) / 2)
                    local match = {
                        tiles = {},
                        spawnCol = spawnCol,
                        spawnRow = row,
                        matchType = "horizontal",
                        matchNum = matchNum,
                        color = colorToMatch,
                    }
                    for tileX = col - 1, startCol, -1 do
                        table.insert(match.tiles, self.tiles[row][tileX])
                    end
                    table.insert(matches, match)
                end
                colorToMatch = self.tiles[row][col].color
                matchNum = 1
                if col >= self.cols - 1 then
                    break
                end
            end
        end
        if matchNum >= 3 then
            local startCol = self.cols - matchNum + 1
            local spawnCol = startCol + math.floor(matchNum / 2)
            local match = {
                tiles = {},
                spawnCol = spawnCol,
                spawnRow = row,
                matchType = "horizontal",
                matchNum = matchNum,
                color = colorToMatch,
            }
            for tileX = self.cols, startCol, -1 do
                table.insert(match.tiles, self.tiles[row][tileX])
            end
            table.insert(matches, match)
        end
    end
    return matches
end

--- Checks each column for vertical matches of three or more fruits.
---@return table matches A list of detected vertical matches.
local function checkVerticalMatches(self)
    local matches = {}
    local matchNum = 1

    for col = 1, self.cols do
        local colorToMatch = self.tiles[1][col].color
        matchNum = 1
        for row = 2, self.rows do
            if self.tiles[row][col].color == colorToMatch then
                matchNum = matchNum + 1
            else
                if matchNum >= 3 then
                    local startRow = row - matchNum
                    local spawnRow = startRow + love.math.random(2)
                    local match = {
                        tiles = {},
                        spawnCol = col,
                        spawnRow = spawnRow,
                        matchType = "vertical",
                        matchNum = matchNum,
                        color = colorToMatch,
                    }
                    for tileY = row - 1, startRow, -1 do
                        table.insert(match.tiles, self.tiles[tileY][col])
                    end
                    table.insert(matches, match)
                end
                colorToMatch = self.tiles[row][col].color
                matchNum = 1
                if row >= self.rows - 1 then
                    break
                end
            end
        end
        if matchNum >= 3 then
            local startRow = self.rows - matchNum + 1
            local spawnRow = startRow + math.floor(matchNum / 2)
            local match = {
                tiles = {},
                spawnCol = col,
                spawnRow = spawnRow,
                matchType = "vertical",
                matchNum = matchNum,
                color = colorToMatch,
            }
            for tileY = self.rows, startRow, -1 do
                table.insert(match.tiles, self.tiles[tileY][col])
            end
            table.insert(matches, match)
        end
    end
    return matches
end

--- Combines horizontal and vertical matches that share a tile into mixed matches.
---@param matches table The list of horizontal and vertical matches to inspect.
local function checkIntersectionMatches(matches)
    -- check horizontal and vertical matches intersections
    for i = 1, #matches - 1 do
        local match1 = matches[i]

        if not match1.ignore then
            for j = i + 1, #matches do
                local match2 = matches[j]

                if not match2.ignore and match1.matchType ~= match2.matchType then
                    local lookup = {}

                    -- Build a lookup table for the first match's tiles.
                    for _, tile in ipairs(match1.tiles) do
                        lookup[tile] = true
                    end

                    -- Look for a shared tile.
                    for _, tile in ipairs(match2.tiles) do
                        if lookup[tile] then
                            -- Merge the second match's unique tiles.
                            for _, otherTile in ipairs(match2.tiles) do
                                if not lookup[otherTile] then
                                    table.insert(match1.tiles, otherTile)
                                    lookup[otherTile] = true
                                end
                            end
                            match1.matchType = "3x3"
                            match1.matchNum = #match1.tiles
                            match1.spawnCol = tile.gridX
                            match1.spawnRow = tile.gridY

                            -- Prevent the second match from being processed.
                            match2.ignore = true

                            break
                        end
                    end
                end
            end
        end
    end

    -- Remove merged matches.
    for i = #matches, 1, -1 do
        if matches[i].ignore then
            table.remove(matches, i)
        end
    end
end

--- Checks the board for horizontal and vertical matches of three or more fruits.
--- Intersecting horizontal and vertical matches are combined into mixed matches.
---@return boolean Whether any matches are found.
function Board:checkMatches()
    local matches = {}

    for _, match in ipairs(checkHorizontalMatches(self)) do
        table.insert(matches, match)
    end

    for _, match in ipairs(checkVerticalMatches(self)) do
        table.insert(matches, match)
    end

    checkIntersectionMatches(matches)

    self.matches = matches
    return #self.matches > 0
end

--- Checks whether two swapped tiles create a special combination.
--- Handles rainbow fruits, strips, and 3×3 SuperFruit combinations.
---@param tile1 table The first tile involved in the swap.
---@param tile2 table The second tile involved in the swap.
---@return boolean Whether a special combination was detected.
function Board:checkSpecialMatches(tile1, tile2)
    local matches = { tiles = {}, matchNum = 0 }

    local power1 = tile1.powerID or 0
    local power2 = tile2.powerID or 0

    if power1 == 25 or power2 == 25 then
        if power1 == 25 and power2 == 25 then
            for row = 1, self.rows do
                for col = 1, self.cols do
                    local tile = self.tiles[row][col]
                    table.insert(matches.tiles, tile)
                    matches.matchNum = matches.matchNum + 1
                end
            end
        else
            local rainbowFruit = power1 == 25 and tile1 or tile2
            local targetColor = power1 == 25 and tile2.color or tile1.color

            local isSuper = power1 == 25 and power2 or power1
            table.insert(matches.tiles, rainbowFruit)

            for row = 1, self.rows do
                for col = 1, self.cols do
                    local tile = self.tiles[row][col]
                    local newTile = tile
                    if tile.color == targetColor then
                        if isSuper > 0 then
                            newTile = SuperFruit(
                                isSuper,
                                tile.scale,
                                tile.gridX,
                                tile.gridY,
                                self.x,
                                self.y
                            )
                            self.tiles[row][col] = newTile
                        end
                        table.insert(matches.tiles, newTile)
                        matches.matchNum = matches.matchNum + 1
                    end
                end
            end
        end
    elseif
        (power1 >= 17 and power1 <= 24 and power2 >= 1 and power2 <= 16)
        or (power1 >= 1 and power1 <= 16 and power2 >= 17 and power2 <= 24)
    then
        local startRow = math.max(1, tile1.gridY - 1)
        local endRow = math.min(self.rows, tile1.gridY + 1)
        local startCol = math.max(1, tile1.gridX - 1)
        local endCol = math.min(self.cols, tile1.gridX + 1)

        for row = startRow, endRow do
            for col = 1, self.cols do
                table.insert(matches.tiles, self.tiles[row][col])
            end
        end
        for col = startCol, endCol do
            for row = 1, self.rows do
                table.insert(matches.tiles, self.tiles[row][col])
            end
        end
    elseif power1 >= 1 and power1 <= 16 and power2 >= 1 and power2 <= 16 then
        for col = 1, self.cols do
            table.insert(matches.tiles, self.tiles[tile1.gridY][col])
        end
        for row = 1, self.rows do
            table.insert(matches.tiles, self.tiles[row][tile1.gridX])
        end
    elseif power1 >= 17 and power1 <= 24 and power2 >= 17 and power2 <= 24 then
        local startRow, endRow =
            math.max(1, tile1.gridY - 2), math.min(self.rows, tile1.gridY + 2)
        local startCol, endCol =
            math.max(1, tile1.gridX - 2), math.min(self.cols, tile1.gridX + 2)
        for row = startRow, endRow do
            for col = startCol, endCol do
                table.insert(matches.tiles, self.tiles[row][col])
            end
        end
    end
    matches.comboOrigins = { [tile1] = true, [tile2] = true }

    self.matches = { matches }
    return #matches.tiles > 0
end

--- Removes all currently detected matches and activates any SuperFruits contained within them.
---@return integer removedCount The number of unique tiles removed from the board.
function Board:removeMatches()
    local removed = {}
    local removedCount = 0

    local function removeTile(tile)
        if tile and not removed[tile] then
            removed[tile] = true
            local r, g, b =
                FruitColors[tile.color].r,
                FruitColors[tile.color].g,
                FruitColors[tile.color].b

            local particles = self.particleSystem:clone()
            particles:setColors(r, g, b, 1, r, g, b, 0.8, r, g, b, 0)
            particles:setPosition(tile.x + tile.width / 2, tile.y + tile.height / 2)
            particles:emit(10)
            table.insert(self.activeParticles, particles)

            self.tiles[tile.gridY][tile.gridX] = nil
            removedCount = removedCount + 1
        end
    end

    for _, match in ipairs(self.matches) do
        for _, tile in ipairs(match.tiles) do
            if
                getmetatable(tile) == SuperFruit
                and not (match.comboOrigins and match.comboOrigins[tile])
            then
                if tile.powerID == 25 then -- borrow a neighbor's color and activate it
                    local adjacents = { { 0, -1 }, { 0, 1 }, { -1, 0 }, { 1, 0 } }
                    local neighbors = {}
                    -- check for neighboring fruits
                    for _, adjacent in ipairs(adjacents) do
                        local nearbyCol, nearbyRow =
                            tile.gridX + adjacent[1], tile.gridY + adjacent[2]
                        if
                            nearbyRow >= 1
                            and nearbyRow <= self.rows
                            and nearbyCol >= 1
                            and nearbyCol <= self.cols
                        then
                            local neighbor = self.tiles[nearbyRow][nearbyCol]
                            if neighbor and not removed[neighbor] then
                                table.insert(neighbors, neighbor)
                            end
                        end
                    end
                    -- choose one random neighboring fruit and activate the Rainbow Bomb
                    if #neighbors > 0 then
                        local targetColor =
                            neighbors[love.math.random(#neighbors)].color
                        for row = 1, self.rows do
                            for col = 1, self.cols do
                                tile = self.tiles[row][col]
                                if tile.color == targetColor then
                                    removeTile(tile)
                                end
                            end
                        end
                    end
                elseif tile.powerID > 16 then -- clear a 3×3 area
                    local startRow, endRow =
                        math.max(1, tile.gridY - 1), math.min(self.rows, tile.gridY + 1)
                    local startCol, endCol =
                        math.max(1, tile.gridX - 1), math.min(self.cols, tile.gridX + 1)
                    for row = startRow, endRow do
                        for col = startCol, endCol do
                            removeTile(self.tiles[row][col])
                        end
                    end
                elseif tile.powerID > 8 then -- clear the row
                    for col = 1, self.cols do
                        removeTile(self.tiles[tile.gridY][col])
                    end
                else -- clear the column
                    for row = 1, self.rows do
                        removeTile(self.tiles[row][tile.gridX])
                    end
                end
            end
        end

        for _, tile in ipairs(match.tiles) do
            removeTile(tile)
        end

        local powerID
        if match.matchNum == 4 and match.matchType == "horizontal" then
            powerID = match.color -- 1-8: clears column
        elseif match.matchNum == 4 and match.matchType == "vertical" then
            powerID = match.color + 8 -- 9-16: clears row
        elseif match.matchType == "3x3" then
            powerID = match.color + 16 --17-24: clears 3×3
        elseif match.matchNum == 5 then
            powerID = 25
        end

        if powerID then
            self.tiles[match.spawnRow][match.spawnCol] = SuperFruit(
                powerID,
                self.tileSize / 128,
                match.spawnCol,
                match.spawnRow,
                self.x,
                self.y
            )
        end
    end
    self.matches = nil
    return removedCount
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

--- Shuffles existing tiles into new positions and prepares them to fall onto the board.
---@return table tweens A table containing the target positions of the shuffled tiles.
function Board:reshuffle()
    -- collect all tiles into a flat list
    local oldTiles = {}
    for row = 1, self.rows do
        for col = 1, self.cols do
            oldTiles[#oldTiles + 1] = self.tiles[row][col]
        end
    end
    -- shuffle
    for i = #oldTiles, 2, -1 do
        local j = love.math.random(i)
        oldTiles[i], oldTiles[j] = oldTiles[j], oldTiles[i]
    end
    -- redistribute back onto the grid
    local tweens = {}
    local idx = 1
    for row = 1, self.rows do
        for col = 1, self.cols do
            local tile = oldTiles[idx]
            idx = idx + 1

            tile.gridX = col
            tile.gridY = row
            -- start above the board so they fall in
            tile.x = self.x + (col - 1) * self.tileSize
            tile.y = self.y - self.tileSize * row
            self.tiles[row][col] = tile

            tweens[tile] = { y = self.y + (row - 1) * self.tileSize }
        end
    end
    return tweens
end
--- Update the active particles on the board
function Board:update(dt)
    for i = #self.activeParticles, 1, -1 do
        local particles = self.activeParticles[i]
        particles:update(dt)
        if particles:getCount() == 0 then
            table.remove(self.activeParticles, i)
        end
    end
end

--- Renders the board background and all fruit tiles.
function Board:render()
    for _, particles in ipairs(self.activeParticles) do
        love.graphics.draw(particles)
    end
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
