LevelMaker = Class({})

local Brick = require("src.Brick")

function LevelMaker.createMap(level)
    local bricks = {}
    local rows = math.min(math.random(1, math.floor(level / 3) + 1), 7)
    local columns = math.random(7, 13)
    columns = columns % 2 == 0 and (columns + 1) or columns

    local highestColor = math.min(5, math.floor(level / 3) + 1)
    local highestTier = math.min(4, math.floor(level / 5) + 1)

    for y = 1, rows do
        local skipRow = rows > 4 and math.random(0, 1) or false
        if skipRow == 1 then
            goto continue_rows
        end

        local skipPattern = math.random(1, 2) == 1 and true or false
        local skipFlag = math.random(2) == 1 and true or false

        local alternatePattern = math.random(1, 2) == 1 and true or false
        local alternateFlag = math.random(2) == 1 and true or false
        local alternateColor1 = math.random(1, highestColor)
        local alternateColor2 = math.random(1, highestColor)
        local alternateTier1 = math.random(1, highestTier)
        local alternateTier2 = math.random(1, highestTier)

        for x = 0, columns - 1 do
            skipFlag = not skipFlag
            if skipPattern and skipFlag then
                goto continue_cols
            end

            local color, tier
            if alternatePattern then
                if alternateFlag then
                    color = alternateColor1
                    tier = alternateTier1
                else
                    color = alternateColor2
                    tier = alternateTier2
                end
                alternateFlag = not alternateFlag
            else
                color = alternateColor1
                tier = alternateTier1
            end

            table.insert(
                bricks,
                Brick(x * 32 + 8 + 16 * (13 - columns), 16 * y, color, tier)
            )
            ::continue_cols::
        end
        ::continue_rows::
    end
    return bricks
end
