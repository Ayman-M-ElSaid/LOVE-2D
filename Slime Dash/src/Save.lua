local Save = {}

local SAVE_FILE = "progress.lua"

function Save.load()
    if not love.filesystem.getInfo(SAVE_FILE) then
        love.filesystem.write(
            SAVE_FILE,
            "return {[1]={completed = false, stars = 0, moves = 100}}"
        )
    end
    local ok, data = pcall(function()
        return love.filesystem.load(SAVE_FILE)()
    end)
    return ok and data
end

function Save.write(progress)
    local lines = {}
    for i, data in ipairs(progress) do
        lines[#lines + 1] = string.format(
            "[%d]={completed = %s, stars = %d, moves = %d},",
            i,
            data.completed,
            data.stars or 0,
            data.moves or 100
        )
    end
    love.filesystem.write(SAVE_FILE, "return {" .. table.concat(lines) .. "}")
end

return Save
