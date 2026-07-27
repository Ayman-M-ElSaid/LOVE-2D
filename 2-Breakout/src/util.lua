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

function GenerateBrickQuads(sheet)
    sheet = sheet or Textures["breakout"]

    local quads = {}
    local counter = 1

    for y = 0, 48, 16 do
        for x = 0, 160, 32 do
            quads[counter] = love.graphics.newQuad(x, y, 32, 16, sheet)
            counter = counter + 1
        end
    end

    quads = { unpack(quads, 1, 20) }
    return quads
end
