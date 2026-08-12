local LevelMaker = {}

function LevelMaker.makeLevel(level)
    local tiles = {}
    local rng = love.math.newRandomGenerator(level)

    for row = 1, 20, 1 do
        table.insert(tiles, {})
        for col = 1, 9, 1 do
            table.insert(tiles[row], Tile((col - 1) * 40, (row - 1) * 40, "solid"))
        end
    end

    for _ = 1, 90 do
        local row, col = rng:random(20), rng:random(9)
        tiles[row][col].isSolid = false
        tiles[row][col].isPainted = false
    end

    return tiles
end

return LevelMaker
