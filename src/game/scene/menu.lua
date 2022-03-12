local Button = require("src.gui.button")
local Container = require("src.gui.container")
local Event = require("src.game.event.event")
local Scene = require("src.game.scene.scene")
local Style = require("src.gui.style.style")
local SideProperty = require("src.gui.style.side-property")

local Menu = Scene:new({ name = "Menu" })

function Menu:initialize()
    self.canvas = self:_getCanvas()
    self.element = Container({
        style = Style({
            center = { x = true, y = true, },
            padding = 20,
            size = { w = 600, h = 600, },
        }),
        children = {
            Container({
                style = Style({
                    center = { x = false, y = false, },
                    color = { r = 0, g = 1, b = 0, a = 1, },
                    grow = { x = true, y = false },
                    size = { w = 100, h = 250, },
                }),
                children = {
                    Container({
                        style = Style({
                            center = { x = true, y = true, },
                            color = { r = 0, g = 0, b = 1, a = 1, },
                            size = { w = 50, h = 50, },
                        }),
                    }),
                }
            }),
        },
    })

    -- TODO:
    -- self.buttons = {
    --     Button:new({
    --         text = "Play",
    --         position = { x = 25, y = 25 },
    --         event = Event:new({ name = "events.scene.switch" })
    --     }),
    --     Button:new({
    --         text = "Settings",
    --         position = { x = 25, y = 200 },
    --         event = Event:new({ name = "events.scene.switch" })
    --     }),
    --     Button:new({
    --         text = "Quit",
    --         position = { x = 25, y = 375 },
    --         event = Event:new({ name = "events.game.quit" })
    --     }),
    -- }

    -- for i = 1, #self.buttons, 1 do
    --     self.buttons[i]:initialize()
    -- end
end

function Menu:draw()
    love.graphics.clear()
    self.element:draw()
end

function Menu:update()
    self.element:update()
end

function Menu:resize()
    self.canvas = self:_getCanvas()
    self.element:resize()
end

function Menu:mousePressed()
end

function Menu:mouseReleased()
end

return Menu
