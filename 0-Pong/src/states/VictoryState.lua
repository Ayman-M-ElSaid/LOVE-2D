VictoryState = Class({ __includes = BaseState })

function VictoryState:init()
	self.showScore = true
	if not AI then
		self.message = string.format("Player %d wins!", Winner)
	else
		self.message = Winner == 1 and "You win!" or "The AI wins!"
	end
end

function VictoryState:update(dt)
	if love.keyboard.wasPressed("space") then
		Scores = { 0, 0 }
		ServingPlayer = Winner == 1 and 2 or 1
		GameState:change("start")
	end
end

function VictoryState:render()
	love.graphics.setFont(Fonts["medium"])
	love.graphics.printf(self.message, 0, 15, VIRTUAL_WIDTH, "center")
	love.graphics.setFont(Fonts["small"])
	love.graphics.printf("Press Space to restart!", 0, 35, VIRTUAL_WIDTH, "center")
end
