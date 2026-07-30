function GeneratePaddleQuads(sheet)
    sheet = sheet or Textures["breakout"]
    local x = 0
    local y = 64
    local quads = {}
    local counter = 1
    for _ = 0, 3 do
        quads[counter] = love.graphics.newQuad(x, y, 32, 16, sheet)
        counter = counter + 1
        quads[counter] = love.graphics.newQuad(x + 32, y, 64, 16, sheet)
        counter = counter + 1
        quads[counter] = love.graphics.newQuad(x + 96, y, 96, 16, sheet)
        counter = counter + 1
        quads[counter] = love.graphics.newQuad(x, y + 16, 128, 16, sheet)
        counter = counter + 1
        x = 0
        y = y + 32
    end
    return quads
end

function GenerateBallQuads(sheet)
    sheet = sheet or Textures["breakout"]
    local x = 96
    local y = 48
    local quads = {}
    local counter = 1
    for i = 0, 3 do
        quads[counter] = love.graphics.newQuad(x + 8 * i, y, 8, 8, sheet)
        counter = counter + 1
    end
    x = 96
    y = 56
    for i = 0, 2 do
        quads[counter] = love.graphics.newQuad(x + 8 * i, y, 8, 8, sheet)
        counter = counter + 1
    end

    return quads
end

function GenerateQuads(sheet, x1, y1, x2, y2, w, h)
    local quads = {}
    local counter = 1

    for y = y1, y2 - h, h do
        for x = x1, x2 - w, w do
            quads[counter] = love.graphics.newQuad(x, y, w, h, sheet)
            counter = counter + 1
        end
    end

    return quads
end

function GenerateBrickQuads(sheet)
    sheet = sheet or Textures["breakout"]
    local quads = GenerateQuads(sheet, 0, 0, 192, 64, 32, 16)
    return { unpack(quads, 1, 20) }
end

function GeneratePowerUpQuads(sheet)
    sheet = sheet or Textures["breakout"]
    return GenerateQuads(sheet, 0, 192, 160, 208, 16, 16)
end
