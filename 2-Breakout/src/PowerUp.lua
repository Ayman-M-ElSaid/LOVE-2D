PowerUp = Class({})

POWER_UPS = {
    SMALLER_PADDLE = 1,
    LARGER_PADDLE = 2,
    EXTRA_HEART = 3,
    LOST_HEART = 4,
    FASTER_PADDLE = 5,
    SLOWER_PADDLE = 6,
    SMALLER_BALL = 7,
    LARGER_BALL = 8,
    EXTRA_BALLS = 9,
    KEY = 10,
}
local EFFECTS = {
    [POWER_UPS.SMALLER_PADDLE] = function(game)
        game.paddle:changeSize("decrease")
    end,
    [POWER_UPS.LARGER_PADDLE] = function(game)
        game.paddle:changeSize("increase")
    end,
    [POWER_UPS.EXTRA_HEART] = function(game)
        game.health = math.min(5, game.health + 1)
    end,
    [POWER_UPS.LOST_HEART] = function(game)
        game.health = game.health - 1
        if game.health == 0 then
            GameState:change("game-over", { score = game.score })
        end
    end,
    [POWER_UPS.FASTER_PADDLE] = function(game)
        PaddleSpeed = math.min(500, PaddleSpeed * 1.5)
    end,
    [POWER_UPS.SLOWER_PADDLE] = function(game)
        PaddleSpeed = math.max(150, PaddleSpeed * 0.75)
    end,
    [POWER_UPS.SMALLER_BALL] = function(game)
        for _, ball in ipairs(game.balls) do
            ball:changeScale(math.max(0.5, ball.scale - 0.5))
        end
    end,
    [POWER_UPS.LARGER_BALL] = function(game)
        for _, ball in ipairs(game.balls) do
            ball:changeScale(math.min(2, ball.scale + 0.5))
        end
    end,
    [POWER_UPS.EXTRA_BALLS] = function(game)
        for _ = 1, 2 do
            table.insert(
                game.balls,
                Ball(math.random(7), game.paddle.centerX, game.paddle.y)
            )
        end
    end,
    [POWER_UPS.KEY] = function(game)
        for _, brick in ipairs(game.bricks) do
            brick.isLocked = false
        end
    end,
}

local sounds
local function getSound(type)
    if not sounds then
        sounds = {
            [1] = Sounds["negative-effect"],
            [2] = Sounds["positive-effect"],
            [3] = Sounds["positive-effect"],
            [4] = Sounds["negative-effect"],
            [5] = Sounds["positive-effect"],
            [6] = Sounds["negative-effect"],
            [7] = Sounds["negative-effect"],
            [8] = Sounds["positive-effect"],
            [9] = Sounds["positive-effect"],
            [10] = Sounds["unlock"],
        }
    end
    return sounds[type]
end

function PowerUp:init(x, y, type)
    self.type = type or math.random(9)
    self.x = x
    self.y = y
    self.dy = 0
    self.width = 16
    self.height = 16
    self.speed = 100 * (math.random() + 0.5)
    self.inPlay = true
    self.sound = getSound(self.type)
end

function PowerUp:collides(target)
    if self.x > target.x + target.width or self.x + self.width < target.x then
        return false
    end
    if self.y > target.y + target.height or self.y + self.height < target.y then
        return false
    end
    return true
end

function PowerUp:collect(game)
    self.inPlay = false
    self.sound:play()
    EFFECTS[self.type](game)
end

function PowerUp:update(dt)
    self.dy = self.speed * dt
    self.y = self.y + self.dy
end

function PowerUp:render()
    if self.inPlay then
        love.graphics.draw(
            Textures["breakout"],
            Frames["power-ups"][self.type],
            self.x,
            self.y
        )
    end
end

return PowerUp
