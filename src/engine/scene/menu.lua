local Button = require("src.engine.gui.button")
local Event = require("src.engine.event.event")
local Scene = require("src.engine.scene.scene")

Menu = Scene:new({ name = "Menu" })

function Menu:initialize()
    self.canvas = love.graphics.newCanvas(love.graphics.getDimensions())
    self.buttons = {
        -- TODO: Layout management?
        Button:new({
            text = "Play",
            position = { x = 25, y = 25 },
            event = Event:new({ name = "events.scene.switch" })
        }),
        Button:new({
            text = "Settings",
            position = { x = 25, y = 200 },
            event = Event:new({ name = "events.scene.switch" })
        }),
        Button:new({
            text = "Quit",
            position = { x = 25, y = 375 },
            event = Event:new({ name = "events.game.quit" })
        }),
    }

    for i = 1, #self.buttons, 1 do
        self.buttons[i]:initialize()
    end
end

function Menu:draw()
    for i = 1, #self.buttons, 1 do
        self.buttons[i]:draw()
    end
end

function Menu:mousePressed()
    for i = 1, #self.buttons, 1 do
        self.buttons[i]:mousePressed()
    end
end

function Menu:mouseReleased()
    for i = 1, #self.buttons, 1 do
        self.buttons[i]:mouseReleased()
    end
end

return Menu
