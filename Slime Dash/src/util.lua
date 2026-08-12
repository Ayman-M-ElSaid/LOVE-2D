--- Generate quads/frames from a large atlas/sprite sheet.
--- @param sheet love.Image The large texture to be sliced up into smaller quads/frames.
--- @param x1 number The starting position along the x-axis to start generating frames.
--- @param y1 number The starting position along the y-axis to start generating frames.
--- @param w number The width of each generated frame.
--- @param h number The height of each generated frame.
--- @return love.Quad[] quads The generated quads.
function GenerateQuads(sheet, x1, y1, w, h)
    local quads = {}
    local counter = 1
    local x2, y2 = sheet:getDimensions()
    for y = y1, y2 - h, h do
        for x = x1, x2 - w, w do
            quads[counter] = love.graphics.newQuad(x, y, w, h, sheet)
            counter = counter + 1
        end
    end

    return quads
end
