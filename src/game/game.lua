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
    t.vsync = 1
end

function Game.load()
    Publisher.register(Game, "*", Game.on)
    Tiles.initialize()

    Game.scenes = {
        menu = Menu:new(),
        world = World:new(),
    }

    -- Is the current active scene
    Game.scene = Game.scenes.menu
    Game.scenes.menu:initialize()
    Game.scenes.world:initialize()
end

function Game.draw()
    love.graphics.push()

    Game.scene:getCanvas():renderTo(function ()
        Game.scene:draw()
    end)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(Game.scene:getCanvas())
    love.graphics.pop()

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

function Game.mouseMoved()
    Game.scene:mouseMoved()
end

function Game.mousePressed()
    Game.scene:mousePressed()
end

function Game.mouseReleased()
    Game.scene:mouseReleased()
end

function Game.mouseWheelMoved()
    Game.scene:mouseWheelMoved()
end

return Game
