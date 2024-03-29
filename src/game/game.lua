local Constants = require("src.game.constants")
local Menu = require("src.game.scenes.menu")
local Publisher = require("src.game.event.publisher")
local SpriteLoader = require("src.game.graphics.loader.sprite-loader")
local World = require("src.game.scenes.world.world")

local HBox = require("src.gui.layout.h-box")
local Container = require("src.gui.layout.container")
local Element = require("src.gui.element")

---@class Game
local Game = {}
Game.dt = 0

function Game.configure(t)
    -- https://love2d.org/wiki/Config_Files
    t.window.title = "Tower Your Defense"
    t.window.display = 2 --* For now...
    t.window.resizable = false
    t.window.fullscreen = true
    t.window.borderless = true
    t.window.highdpi = true
    t.vsync = 0
end

function Game.load()
    SpriteLoader.init()
    Publisher.register(Game, "*", Game.on)

    Game.scenes = {
        menu = Menu(),
        world = World(),
    }

    -- Is the current active scene
    Game.scene = Game.scenes.menu

    Publisher.register(Game, "game.restart", function() Game.restart() end)
end

---Restarts the game by recreating the world.
---Note: this might not be the most efficient way of doing this, but it will do for now.
function Game.restart()
    Game.scene = Game.scenes.menu
    Game.scenes.world = World()
end

function Game.draw()
    Game.scene:draw()

    -- For debugging
    love.graphics.setColor(0, 1, 0)
    love.graphics.setFont(love.graphics.newFont(10))
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

    if Game.scene then
        Game.scene:on(event)
    end
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
