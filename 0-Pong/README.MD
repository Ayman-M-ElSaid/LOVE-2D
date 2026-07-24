# Pong

![Lua](https://img.shields.io/badge/Lua-2C2D72?logo=lua&logoColor=white)
![LÖVE](https://img.shields.io/badge/L%C3%96VE-11.5-EA316E)
[![Releases](https://img.shields.io/badge/Releases-Pong-blue)](../../releases?q=pong&expanded=true)

A LÖVE2D (Lua) implementation of Pong, inspired by Lecture 0 of CS50's Introduction to Game Development (CS50 2D).

![Gameplay](https://github.com/user-attachments/assets/ca942ab0-5af0-4af7-b1b3-61c19035ad03)

## Running it

```
love .
```
from inside the `0-Pong/` folder.

Or grab a packaged build (Windows `.exe`, Android `.apk` when available) from the [Pong releases page](../../releases?q=pong&expanded=true) — no LÖVE installation needed.

## Controls

| Action | Key |
|---|---|
| Player 1 move | `W` / `S` |
| Player 2 move (Player mode) | `Up` / `Down` |
| Select opponent (start screen) | `Left`/`A` (Player) or `Right`/`D` (AI) |
| Confirm / Serve | `Space` |
| Quit | `Escape` |

## Features

Beyond base Pong, this version adds:

- **AI opponent** — selectable from the start screen, with a randomized speed factor and aim error margin that reroll each point, so difficulty varies slightly rally to rally instead of playing at one fixed skill level.
- **Blinking selection prompt** — the "vs. Player" / "vs. AI" options on the start screen fade in and out on a timer to indicate the current selection, instead of a static highlight.
- **Score flash effect** — the screen flashes from the edge a point was scored on, giving instant directional feedback on who scored.
- **`StateMachine`-driven flow** — start, serve, play, and victory states are each self-contained state objects, applied here on the Lecture 0 project even though it isn't required until later in the course.

## Screenshots

| Start screen | In-game |
|---|---|
| ![Start screen](https://github.com/user-attachments/assets/b157837b-15af-421e-90d1-fd512460b15d) | ![Gameplay](https://github.com/user-attachments/assets/703672f3-6c34-4edb-88b3-4b0b705acdef) |

## Structure

```
0-Pong/
├── main.lua
├── src/
│   ├── Ball.lua
│   ├── Paddle.lua
│   ├── Flash.lua
│   ├── StateMachine.lua
│   └── states/
│       ├── BaseState.lua
│       ├── StartState.lua
│       ├── ServeState.lua
│       ├── PlayState.lua
│       └── VictoryState.lua
├── libs/        # class.lua, push.lua
├── sounds/
└── font.ttf
```
