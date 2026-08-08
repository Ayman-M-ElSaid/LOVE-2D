local Layout = {}

function Layout.getDimensions()
    return 512, 288
end

function Layout.getBackground()
    return Textures["background"]
end

local function buildStartState()
    return {
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
    }
end

local function buildPlayState()
    local pauseMenuRect = {
        mode = "fill",
        x = 0.325 * VIRTUAL_WIDTH,
        y = 0.15 * VIRTUAL_HEIGHT,
        width = 0.35 * VIRTUAL_WIDTH,
        height = VIRTUAL_HEIGHT / 1.5,
        rx = 4,
    }

    return {
        uiRect = {
            mode = "fill",
            x = 0.025 * VIRTUAL_WIDTH,
            y = 0.15 * VIRTUAL_HEIGHT,
            width = 0.4 * VIRTUAL_WIDTH,
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
            return Board(9, 9, 0.09, 0.7 * VIRTUAL_WIDTH, VIRTUAL_HEIGHT / 2)
        end,
    }
end

local function buildGameOverState()
    return {
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
    Layout.playState = buildPlayState()
    Layout.gameOverState = buildGameOverState()
end

return Layout
