local Event = require("src.game.event.event")
local Publisher = require("src.game.event.publisher")
local Scene = require("src.game.scene.scene")

local Button = require("src.gui.button")
local Color = require("src.gui.style.property.color")
local Container = require("src.gui.layout.container")
local DirBool = require("src.gui.style.property.dir-bool")
local Size = require("src.gui.style.property.size")
local Style = require("src.gui.style.style")
local VBox = require("src.gui.layout.v-box")

local Menu = Scene:new({ name = "Menu" })

function Menu:initialize()
    self.canvas = self:_getCanvas()
    ---@type Element
    self.element = Container({
        root = true,
        style = Style({
            center = DirBool(true, true),
            color = Color(1, 0, 0, 1),
            padding = 20,
            size = Size(600, 600),
        }),
        children = {
            VBox({
                style = Style({ grow = DirBool(true, true) }),
                children = {
                    Button({
                        text = "Play",
                        method = function()
                            Publisher.publish(Event:new({ name = "events.scene.switch" })) 
                        end,
                        style = Style({
                            size = Size(0, 100),
                            color = Color(1, 1, 1, 1),
                            margin = 20
                        }),
                    }),
                    Button({
                        text = "Settings",
                        style = Style({
                            size = Size(0, 100),
                            color = Color(1, 1, 1, 1),
                            margin = 20
                        }),
                    }),
                    Button({
                        text = "Quit",
                        method = function()
                            Publisher.publish(Event:new({ name = "events.game.quit" }))
                        end,
                        style = Style({
                            size = Size(0, 100),
                            color = Color(1, 1, 1, 1),
                            margin = 20
                        }),
                    }),
                }
            }),
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
