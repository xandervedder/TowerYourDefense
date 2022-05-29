local Game = require("src.game.game")

--[[
Every method here is passed to the game defined above, we want to keep
main.lua file clean, since everything is in the src/ folder.
]]--
function love.load()
    Game.load()
end

function love.draw()
    Game.draw()
end

function love.update(dt)
    Game.update(dt)
end

function love.quit()
    Game.quit()
end

function love.keypressed(key)
    Game.keyPressed(key)
end

function love.keyreleased(key)
    Game.keyReleased(key)
end

function love.resize()
    Game.resize()
end

function love.mousemoved(x, y, dx, dy, touch)
    Game.mouseMoved(x, y, dx, dy, touch)
end

function love.mousepressed(x, y, button, touch, presses)
    Game.mousePressed(x, y, button, touch, presses)
end

function love.mousereleased()
    Game.mouseReleased()
end

function love.wheelmoved()
    Game.mouseWheelMoved()
end
