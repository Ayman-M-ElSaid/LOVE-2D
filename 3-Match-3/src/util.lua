--- Generate quads/frames from a large atlas/sprite sheet.
--- @param sheet love.Image The large texture to be sliced up into smaller quads/frames.
--- @param x1 number The starting position along the x-axis to start generating frames.
--- @param y1 number The starting position along the y-axis to start generating frames.
--- @param w number The width of each generated frame.
--- @param h number The height of each generated frame.
---@return love.Quad[] quads The generated quads.
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

--- Draws a rectangle with a table as the only input parameter.
--- @param rect table A table containing the rectangle parameters (mode, x, y, width, height, rx?, ry?, segments?)
function DrawRect(rect)
    love.graphics.rectangle(
        rect.mode,
        rect.x,
        rect.y,
        rect.width,
        rect.height,
        rect.rx,
        rect.ry,
        rect.segments
    )
end

--- Draws a rounded progress bar with a layered background and fill effect.
---@param centerX number The x-coordinate of the progress bar's center.
---@param centerY number The y-coordinate of the progress bar's center.
---@param width number The width of the progress bar.
---@param height number The height of the progress bar.
---@param progress number The progress value from 0 to 1.
function DrawProgressBar(centerX, centerY, width, height, progress)
    progress = math.max(0, math.min(progress, 1))
    local x = centerX - width / 2
    local y = centerY - height / 2
    local radius = height / 2
    local fillWidth = width * progress

    love.graphics.setColor(0.55, 0.54, 0.40, 0.45)
    love.graphics.rectangle("fill", x, y + 2, width, height, radius)

    love.graphics.setColor(0.76, 0.74, 0.58, 0.95)
    love.graphics.rectangle("fill", x, y, width, height, radius)

    love.graphics.setColor(0.62, 0.62, 0.48, 0.75)
    love.graphics.rectangle("fill", x + 2, y + 2, width - 4, height - 4, radius - 2)

    if fillWidth <= 0 then
        return
    end

    love.graphics.setColor(0.52, 1, 1, 1)
    love.graphics.rectangle("fill", x, y + 2, fillWidth, height - 2, radius)

    love.graphics.setColor(0.52, 0.94, 1, 0.75)
    love.graphics.rectangle("fill", x, y, fillWidth, height - 2, radius)
end

--- Returns the sign of a number.
---@param x number The number to determine the sign of.
---@return -1|0|1 The sign of x.
function math.sign(x)
    return (x == 0) and 0 or (x / math.abs(x))
end
