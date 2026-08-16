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

--- Prints scaled fonts without blurring.
--- @param text string The text to be printed
--- @param x number The position on the x-axis.
--- @param y number The position on the y-axis
--- @param limit number The maximum line width in horizontal pixels.
--- @param align "left"|"right"|"center"|"justify" The text alignment
function PrintfScaled(text, x, y, limit, align)
    love.graphics.printf(
        text,
        x,
        y,
        limit * FONT_SCALE,
        align,
        0,
        1 / FONT_SCALE,
        1 / FONT_SCALE
    )
end

--- Generates a random RGBA color.
---@param alpha number? The alpha value of the color. Defaults to 1.
---@return number[] A table containing random red, green, blue, and alpha values.
function RandomColor(alpha)
    return { love.math.random(), love.math.random(), love.math.random(), alpha or 1 }
end
