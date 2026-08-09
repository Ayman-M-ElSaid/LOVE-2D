local Layout = {}

local fontSizes = {
    desktop = { title = 35, button = 22, large = 24, medium = 16 },
    mobile = { title = 45, button = 38, large = 34, medium = 22 },
}

function Layout.getDimensions()
    if IS_MOBILE then
        return 360, 800
    else
        return 512, 288
    end
end

function Layout.loadFonts(w, h)
    FONT_SCALE = math.min(w / VIRTUAL_WIDTH, h / VIRTUAL_HEIGHT)
    local sizes = IS_MOBILE and fontSizes.mobile or fontSizes.desktop
    Fonts = {
        ["title"] = love.graphics.newFont(
            "assets/fonts/Baloo.ttf",
            sizes.title * FONT_SCALE
        ),
        ["button"] = love.graphics.newFont(
            "assets/fonts/Fredoka.ttf",
            sizes.button * FONT_SCALE
        ),
        ["large"] = love.graphics.newFont(
            "assets/fonts/Butterpop.otf",
            sizes.large * FONT_SCALE
        ),
        ["meduim"] = love.graphics.newFont(
            "assets/fonts/Butterpop.otf",
            sizes.medium * FONT_SCALE
        ),
    }
end

function Layout.getBackground()
    return IS_MOBILE and Textures["background-portrait"]
        or Textures["background-landscape"]
end

local function buildStartState()
    return IS_MOBILE
            and {
                startButton = Button(
                    Textures["button"],
                    0.35,
                    VIRTUAL_WIDTH / 2,
                    0.75 * VIRTUAL_HEIGHT,
                    { 0.86, 0.32, 0.28, 1.0 },
                    "Play",
                    { 1.0, 0.94, 0.75, 1.0 }
                ),
                quitButton = Button(
                    Textures["button"],
                    0.35,
                    VIRTUAL_WIDTH / 2,
                    0.85 * VIRTUAL_HEIGHT,
                    { 0.87, 0.72, 0.49, 1.0 },
                    "Quit",
                    { 0.16, 0.24, 0.20, 1.0 }
                ),
                musicButton = Button(
                    Textures["music"],
                    0.125,
                    0.925 * VIRTUAL_WIDTH,
                    0.03 * VIRTUAL_HEIGHT
                ),
                sfxButton = Button(
                    Textures["sfx"],
                    0.125,
                    0.925 * VIRTUAL_WIDTH,
                    0.09 * VIRTUAL_HEIGHT
                ),
                titleY = 0.225 * VIRTUAL_HEIGHT,
                title = "Tropical\t\t\t\t\t\t\t Match",
            }
        or {
            startButton = Button(
                Textures["button"],
                0.2,
                VIRTUAL_WIDTH / 2,
                0.775 * VIRTUAL_HEIGHT,
                { 0.86, 0.32, 0.28, 1.0 },
                "Play",
                { 1.0, 0.94, 0.75, 1.0 }
            ),
            quitButton = Button(
                Textures["button"],
                0.2,
                VIRTUAL_WIDTH / 2,
                0.9 * VIRTUAL_HEIGHT,
                { 0.87, 0.72, 0.49, 1.0 },
                "Quit",
                { 0.16, 0.24, 0.20, 1.0 }
            ),
            musicButton = Button(
                Textures["music"],
                0.1,
                0.96 * VIRTUAL_WIDTH,
                0.065 * VIRTUAL_HEIGHT
            ),
            sfxButton = Button(
                Textures["sfx"],
                0.1,
                0.96 * VIRTUAL_WIDTH,
                0.175 * VIRTUAL_HEIGHT
            ),
            titleY = 0.3 * VIRTUAL_HEIGHT,
            title = "Tropical Match",
        }
end

local function buildBeginLevelState()
    return IS_MOBILE and { lableY = -80, height = 60 } or { lableY = -60, height = 48 }
end

local function buildPlayState()
    local pauseMenuRect = IS_MOBILE
            and {
                mode = "fill",
                x = 0.2 * VIRTUAL_WIDTH,
                y = 0.3 * VIRTUAL_HEIGHT,
                width = 0.6 * VIRTUAL_WIDTH,
                height = 0.4 * VIRTUAL_HEIGHT,
                rx = 8,
            }
        or {
            mode = "fill",
            x = 0.325 * VIRTUAL_WIDTH,
            y = 0.15 * VIRTUAL_HEIGHT,
            width = 0.35 * VIRTUAL_WIDTH,
            height = VIRTUAL_HEIGHT / 1.5,
            rx = 4,
        }

    return IS_MOBILE
            and {
                uiRect = {
                    mode = "fill",
                    x = 0.05 * VIRTUAL_WIDTH,
                    y = 0.12 * VIRTUAL_HEIGHT,
                    width = 0.9 * VIRTUAL_WIDTH,
                    height = 0.1 * VIRTUAL_HEIGHT,
                    rx = 16,
                },
                pauseButton = Button(
                    Textures["button"],
                    0.35,
                    VIRTUAL_WIDTH / 2,
                    0.85 * VIRTUAL_HEIGHT,
                    { 0.93, 0.72, 0.28, 1.0 },
                    "Pause",
                    { 0.10, 0.25, 0.22, 1.0 }
                ),
                pauseMenuRect = pauseMenuRect,
                pauseMenuShadow = {
                    mode = "fill",
                    x = 0.2 * VIRTUAL_WIDTH - 2,
                    y = 0.3 * VIRTUAL_HEIGHT - 2,
                    width = 0.6 * VIRTUAL_WIDTH + 4,
                    height = 0.4 * VIRTUAL_HEIGHT + 4,
                    rx = 8,
                },
                musicButton = Button(
                    Textures["music"],
                    0.15,
                    pauseMenuRect.x + 0.3 * pauseMenuRect.width,
                    pauseMenuRect.y * 1.3
                ),
                sfxButton = Button(
                    Textures["sfx"],
                    0.15,
                    pauseMenuRect.x + 0.7 * pauseMenuRect.width,
                    pauseMenuRect.y * 1.3
                ),
                resumeButton = Button(
                    Textures["button"],
                    0.35,
                    pauseMenuRect.x + pauseMenuRect.width / 2,
                    pauseMenuRect.y * 1.55,
                    { 0.30, 0.72, 0.45, 1.0 },
                    "Resume",
                    { 0.06, 0.22, 0.16, 1.0 }
                ),
                restartButton = Button(
                    Textures["button"],
                    0.35,
                    pauseMenuRect.x + pauseMenuRect.width / 2,
                    pauseMenuRect.y * 1.85,
                    { 0.95, 0.68, 0.22, 1.0 },
                    "Restart",
                    { 0.10, 0.23, 0.20, 1.0 }
                ),
                quitButton = Button(
                    Textures["button"],
                    0.35,
                    pauseMenuRect.x + pauseMenuRect.width / 2,
                    pauseMenuRect.y * 2.15,
                    { 0.85, 0.27, 0.23, 1.0 },
                    "Quit",
                    { 1.00, 0.94, 0.78, 1.0 }
                ),
                board = function()
                    return Board(11, 9, 0.13, VIRTUAL_WIDTH / 2, VIRTUAL_HEIGHT / 2)
                end,
            }
        or {
            uiRect = {
                mode = "fill",
                x = 0.03 * VIRTUAL_WIDTH,
                y = 0.15 * VIRTUAL_HEIGHT,
                width = 0.35 * VIRTUAL_WIDTH,
                height = 0.35 * VIRTUAL_HEIGHT,
                rx = 4,
            },
            pauseButton = Button(
                Textures["button"],
                0.2,
                0.225 * VIRTUAL_WIDTH,
                0.85 * VIRTUAL_HEIGHT,
                { 0.93, 0.72, 0.28, 1.0 },
                "Pause",
                { 0.10, 0.25, 0.22, 1.0 }
            ),
            pauseMenuRect = pauseMenuRect,
            pauseMenuShadow = {
                mode = "fill",
                x = 0.325 * VIRTUAL_WIDTH - 2,
                y = 0.15 * VIRTUAL_HEIGHT - 2,
                width = 0.35 * VIRTUAL_WIDTH + 4,
                height = VIRTUAL_HEIGHT / 1.5 + 4,
                rx = 4,
            },
            musicButton = Button(
                Textures["music"],
                0.09,
                pauseMenuRect.x + 0.4 * pauseMenuRect.width,
                pauseMenuRect.y * 2
            ),
            sfxButton = Button(
                Textures["sfx"],
                0.09,
                pauseMenuRect.x + 0.6 * pauseMenuRect.width,
                pauseMenuRect.y * 2
            ),
            resumeButton = Button(
                Textures["button"],
                0.2,
                pauseMenuRect.x + pauseMenuRect.width / 2,
                pauseMenuRect.y * 2.75,
                { 0.30, 0.72, 0.45, 1.0 },
                "Resume",
                { 0.06, 0.22, 0.16, 1.0 }
            ),
            restartButton = Button(
                Textures["button"],
                0.2,
                pauseMenuRect.x + pauseMenuRect.width / 2,
                pauseMenuRect.y * 3.75,
                { 0.95, 0.68, 0.22, 1.0 },
                "Restart",
                { 0.10, 0.23, 0.20, 1.0 }
            ),
            quitButton = Button(
                Textures["button"],
                0.2,
                pauseMenuRect.x + pauseMenuRect.width / 2,
                pauseMenuRect.y * 4.75,
                { 0.85, 0.27, 0.23, 1.0 },
                "Quit",
                { 1.00, 0.94, 0.78, 1.0 }
            ),
            board = function()
                return Board(9, 11, 0.09, 0.7 * VIRTUAL_WIDTH, VIRTUAL_HEIGHT / 2)
            end,
        }
end

local function buildGameOverState()
    return IS_MOBILE
            and {
                button = Button(
                    Textures["button"],
                    0.35,
                    VIRTUAL_WIDTH / 2,
                    0.75 * VIRTUAL_HEIGHT,
                    { 0.86, 0.32, 0.28, 1.0 },
                    "Awesome!",
                    { 1.0, 0.94, 0.75, 1.0 }
                ),
                titleY = 0.2 * VIRTUAL_HEIGHT,
                score = 0.45 * VIRTUAL_HEIGHT,
                highScore = 0.5 * VIRTUAL_HEIGHT,
            }
        or {
            button = Button(
                Textures["button"],
                0.2,
                VIRTUAL_WIDTH / 2,
                0.785 * VIRTUAL_HEIGHT,
                { 0.86, 0.32, 0.28, 1.0 },
                "Awesome!",
                { 1.0, 0.94, 0.75, 1.0 }
            ),
            titleY = 0.25 * VIRTUAL_HEIGHT,
            score = 0.5 * VIRTUAL_HEIGHT,
            highScore = 0.6 * VIRTUAL_HEIGHT,
        }
end

function Layout.build()
    Layout.startState = buildStartState()
    Layout.beginLevelState = buildBeginLevelState()
    Layout.playState = buildPlayState()
    Layout.gameOverState = buildGameOverState()
end

return Layout
