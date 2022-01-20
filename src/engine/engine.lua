local Publisher = require("src.engine.event.publisher")
local Menu = require("src.engine.scene.menu")
local Tiles = require("src.engine.graphics.tiles")
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
    Publisher.register(Engine.on)
    Tiles.initialize()

    Engine.scenes = {
        menu = Menu:new(),
        world = World:new(),
    }

    Engine.scenes.menu:initialize()
    Engine.scenes.world:initialize()
    -- Is the current active scene
    Engine.scene = Engine.scenes.menu
end

function Engine.draw()
    love.graphics.push()

    Engine.scene:getCanvas():renderTo(function ()
        Engine.scene:draw()
    end)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Engine.scene:getCanvas())
    love.graphics.pop()

    -- For debugging
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 5, 5)
end

function Engine.update(dt)
    Engine.scene:update(dt)
end

function Engine.on(event)
    if event:getName() == "events.scene.switch" then
        if Engine.scene == Engine.scenes.menu then
            Engine.scene = Engine.scenes.world
        else
            Engine.scene = Engine.scenes.menu
        end
    end

    if event:getName() == "events.game.quit" then
        love.event.quit()
    end

    Engine.scene:on(event)
end

function Engine.resize()
    Engine.scene:resize()
end

function Engine.quit()
    Engine.scene:quit()
end

function Engine.keyPressed(key)
    if key == "escape" then
        Engine.scene = Engine.scenes.menu
    end

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
