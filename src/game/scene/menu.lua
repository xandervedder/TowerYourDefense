local Event = require("src.game.event.event")
local Publisher = require("src.game.event.publisher")
local Scene = require("src.game.scene.scene")

local Button = require("src.gui.button")
local Container = require("src.gui.container")
local SideProperty = require("src.gui.style.side-property")
local Style = require("src.gui.style.style")
local VBox = require("src.gui.layout.v-box")

local Menu = Scene:new({ name = "Menu" })

function Menu:initialize()
    self.canvas = self:_getCanvas()
    ---@type Element
    self.element = Container({
        style = Style({
            center = { x = true, y = false, },
            padding = 20,
            size = { w = 600, h = 600, },
        }),
        children = {
            VBox({
                style = Style({ grow = { x = true, y = true, }, size =  { w = 600, h = 600, } }),
                children = {
                    Button({
                        text = "Play",
                        method = function()
                            Publisher.publish(Event:new({ name = "events.scene.switch" })) 
                        end,
                        style = Style({
                            size = { w = 0, h = 100 },
                            color = { r = 1, g = 0, b = 0, a = 1},
                            margin = 20
                        }),
                    }),
                    Button({
                        text = "Settings",
                        style = Style({
                            size = { w = 0, h = 100 },
                            color = { r = 0, g = 1, b = 0, a = 1},
                            margin = 20
                        }),
                    }),
                    Button({
                        text = "Quit",
                        method = function()
                            Publisher.publish(Event:new({ name = "events.game.quit" }))
                        end,
                        style = Style({
                            size = { w = 0, h = 100 },
                            color = { r = 0, g = 0, b = 1, a = 1},
                            margin = 20
                        }),
                    }),
                }
            })
        },
    })
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
    self.element:mousePressed()
end

function Menu:mouseReleased()
    self.element:mouseReleased()
end

return Menu
