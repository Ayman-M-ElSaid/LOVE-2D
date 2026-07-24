Save = {}

local FILENAME = "highscore.txt"

function Save.loadHighScore()
    if love.filesystem.getInfo(FILENAME) then
        local contents = love.filesystem.read(FILENAME)
        return tonumber(contents) or 0
    end
    return 0
end

function Save.saveHighScore(score)
    love.filesystem.write(FILENAME, tostring(score))
end

return Save
