local Save = {}

local SAVE_FILE = "progress.sav"

function Save.load()
    local progress = {}

    if not love.filesystem.getInfo(SAVE_FILE) then
        return progress
    end

    for line in love.filesystem.lines(SAVE_FILE) do
        local id, score = line:match("^(%-?%d+),(%-?%d+)$")
        if id then
            progress[tonumber(id)] = tonumber(score)
        end
    end

    return progress
end

function Save.write(progress)
    local lines = {}
    for id, score in pairs(progress) do
        lines[#lines + 1] = string.format("%d,%d", id, score)
    end
    love.filesystem.write(SAVE_FILE, table.concat(lines, "\n"))
end

return Save
