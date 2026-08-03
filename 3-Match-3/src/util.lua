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

function PrintfScaled(text, x, y, limit, align)
    love.graphics.printf(
        text,
        x,
        y,
        limit * FONT_SCALE,
        align or "left",
        0,
        1 / FONT_SCALE,
        1 / FONT_SCALE
    )
end

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
