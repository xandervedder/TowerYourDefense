Engine = require("src.engine.engine")

--[[
Every method here is passed to the engine defined above, we want to keep
main.lua file clean, since everything is in the src/ folder.
]]--
function love.conf(t)
    Engine.configure()
end

function love.load()
    Engine.load()
end

function love.draw()
    Engine.draw()
end

function love.update(dt)
    Engine.update(dt)
end

function love.quit()
    Engine.quit()
end

function love.keypressed(key)
    Engine.keyPressed(key)
end

function love.keyreleased(key)
    Engine.keyReleased(key)
end

function love.resize()
    Engine.resize()
end

function love.mousemoved()
    Engine.mouseMoved()
end

function love.mousepressed()
    Engine.mousePressed()
end

function love.mousereleased()
    Engine.mouseReleased()
end

function love.wheelmoved()
    Engine.mouseWheelMoved()
end
