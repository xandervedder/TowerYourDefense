local World = require("src.engine.scene.world")

Engine = {}

function Engine.configure(t)
    t.window.title = "Tower Your Defense"
    t.window.width = 1024
    t.window.height = 1024
    t.window.display = 2 --* For now...
    t.vsync = 1
end

function Engine.load()
    -- Should eventually be a table of scenes
    Engine.scene = World:new()
    Engine.scene:initialize()
end

function Engine.draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.push()

    Engine.scene:getCanvas():renderTo(function ()
        Engine.scene:draw()
    end)

    love.graphics.draw(Engine.scene:getCanvas())
    love.graphics.pop()

    -- For debugging
    love.graphics.setColor(0, 1, 0, 1)
    love.graphics.print("Current FPS: " .. tostring(love.timer.getFPS()), 10, 10)
end

function Engine.update(dt)
    Engine.scene:update(dt)
end

function Engine.resize()
    Engine.scene:resize()
end

function Engine.quit()
    Engine.scene:quit()
end

function Engine.keyPressed(key)
    Engine.scene:keyPressed(key)
end

function Engine.keyReleased(key)
    Engine.scene:keyReleased(key)
end

function Engine.mouseMoved()
    Engine.scene:mouseMoved()
end

function Engine.mousePressed()
    Engine.scene:mousePressed()
end

function Engine.mouseReleased()
    Engine.scene:mouseReleased()
end

function Engine.mouseWheelMoved()
    Engine.scene:mouseWheelMoved()
end

return Engine
