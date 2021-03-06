require("ocean")
require("sub")
require("seamines")
require("menu")

game = {
  state = "menu",
  fullscreen = false,
  score = 0,
  highscore = 0,
  timer = 0,
  difficultyTime = 0.1,
  difficultySpeed = 40,
  difficultySpacing = 150
}

function playingUpdate(dt)
  ocean:update(dt)
  game:checkCollisions()
  sub:update(dt)
  seamines:update(dt)
  game:updateScore(dt)
end

function game:update(dt)
  if game.state == "playing" then
    playingUpdate(dt)
  elseif game.state == "menu" then
    ocean:update(dt)
    sub:update(dt)
  elseif game.state == "gameOver" then
    game.highscore = game.score
    explosion:update(dt)
  end
end

function game:draw()
  ocean:draw_below()
  seamines:draw()
  if game.state ~= "gameOver" then
    sub:draw()
  end
  ocean:draw_above()

  if game.state == "playing" then
    game:drawUi()
  elseif game.state == "paused" then
    game:drawPaused()
  elseif game.state == "gameOver" then
    game:drawGameover()
  elseif game.state == "menu" then
    menu:draw()
  end
end

function game:drawPaused()
  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  love.graphics.setColor(0,0,0, 100)
  love.graphics.rectangle("fill", 0,0, w, h)
  love.graphics.setColor(255,255,255)
  love.graphics.setFont(menuFont)
  love.graphics.printf("PAUSE", 0, h/2, w, "center")
end

function game:drawGameover()
  explosion:draw(dt)

  local w, h = love.graphics.getWidth(), love.graphics.getHeight()
  love.graphics.setColor(0,0,0, 100)
  love.graphics.rectangle("fill", 0,0, w, h)
  love.graphics.setColor(255,255,255)
  love.graphics.setFont(menuFont)
  love.graphics.printf("GAME OVER", 0, h/3, w, "center")
  love.graphics.printf("High Score: " .. math.floor(game.highscore), 0, h/2.5, w, "center")
  love.graphics.printf("Press Enter to play again or Esc to quit", 0, h/2, w, "center")
end

function game:drawUi()
  love.graphics.setColor(50, 150, 250)
  love.graphics.setFont(mainFont)
  love.graphics.print("High Score: " .. math.floor(game.highscore), 10, 10)
  love.graphics.print("Score: " .. math.floor(game.score), 10, 30)
end

function game:new()
  game.difficultyTime = 0.1
  game.difficultySpeed = 40
  game.difficultySpacing = 150
  game.timer = 0
  game.score = 0
  game.state = "playing"

  seamines:reset()
end

function game:updateScore(dt)
  game.score = game.score + dt
end

function game:checkCollisions()
  for index, seamine in ipairs(seamines) do
    for index, segment in ipairs(sub.segments) do
      if (intersects(segment, seamine) or intersects(seamine, segment)) then
        sub.explode()
        game.state = "gameOver"
      end
    end
  end
end

function intersects(rect1, rect2)
  if rect1.x < rect2.x and rect1.x + rect1.w > rect2.x and
  rect1.y < rect2.y and rect1.y + rect1.h > rect2.y then
    return true
  else
    return false
  end
end
