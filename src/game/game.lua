local Publisher = require("src.game.event.publisher")
local Menu = require("src.game.scene.menu")
local Tiles = require("src.game.graphics.tiles")
local World = require("src.game.scene.world")
local Constants = require("src.game.constants")

local Game = {}
Game.dt = 0

function Game.configure(t)
    t.window.title = "Tower Your Defense"
    t.window.width = 1024
    t.window.height = 1024
    t.window.display = 2 --* For now...
    t.window.resizable = true
    t.vsync = 1
end

function Game.load()
    Publisher.register(Game, "*", Game.on)
    Tiles.initialize()

    Game.scenes = {
        menu = Menu(),
        world = World(),
    }

    -- Is the current active scene
    Game.scene = Game.scenes.menu
    Game.scenes.menu:initialize()
    Game.scenes.world:initialize()
end

function Game.draw()
    Game.scene:draw()

    -- For debugging
    love.graphics.setColor(0, 1, 0)
    love.graphics.print("FPS: " .. tostring(love.timer.getFPS()), 5, 5)
end

function Game.update(dt)
    Game.scene:update(dt)

    Game.dt = Game.dt + dt
    if Game.dt >= Constants.physics.timing then
        Game.fixedUpdate(dt)
        Game.dt = 0
    end
end

function Game.fixedUpdate(dt)
    Game.scene:fixedUpdate(dt)
end

function Game.on(event)
    if event:getName() == "events.scene.switch" then
        if Game.scene == Game.scenes.menu then
            Game.scene = Game.scenes.world
        else
            Game.scene = Game.scenes.menu
        end
    end

    if event:getName() == "events.game.quit" then
        love.event.quit()
    end

    Game.scene:on(event)
end

function Game.resize()
    Game.scene:resize()
end

function Game.quit()
    Game.scene:quit()
end

function Game.keyPressed(key)
    if key == "escape" then
        Game.scene = Game.scenes.menu
    end

    Game.scene:keyPressed(key)
end

function Game.keyReleased(key)
    Game.scene:keyReleased(key)
end

function Game.mouseMoved(x, y, dx, dy, touch)
    Game.scene:mouseMoved(x, y, dx, dy, touch)
end

function Game.mousePressed(x, y, button, touch, presses)
    Game.scene:mousePressed(x, y, button, touch, presses)
end

function Game.mouseReleased()
    Game.scene:mouseReleased()
end

function Game.mouseWheelMoved()
    Game.scene:mouseWheelMoved()
end

return Game
