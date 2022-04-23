local Event = require("src.game.event.event")
local Publisher = require("src.game.event.publisher")
local Scene = require("src.game.scene.scene")

local Button = require("src.gui.button")
local Color = require("src.gui.style.property.color")
local Container = require("src.gui.layout.container")
local DirBool = require("src.gui.style.property.dir-bool")
local HBox = require("src.gui.layout.h-box")
local Side = require("src.gui.style.property.side")
local Size = require("src.gui.style.property.size")
local Style = require("src.gui.style.style")
local VBox = require("src.gui.layout.v-box")

local Menu = {}
Menu.__index = Menu

setmetatable(Menu, {
    __index = Scene,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Menu:init()
    self.canvas = self:_getCanvas()

    ---@type Element
    self.element = Container({
        root = true,
        style = Style({
            color = Color(35, 35, 35, 1),
            padding = 20,
            grow = DirBool(true, true),
        }),
        children = {
            Container({
                style = Style({
                    center = DirBool(true, true),
                    color = Color(76, 76, 76, 1),
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
                                    Publisher.publish(Event("events.scene.switch"))
                                end,
                                style = Style({
                                    size = Size(0, 100),
                                    color = Color(127, 127, 127, 1),
                                    margin = 20
                                }),
                            }),
                            HBox({
                                style = Style({ grow = DirBool(true, false), size = Size(100, 100), margin = 20 }),
                                children = {
                                    Button({
                                        text = "Se",
                                        style = Style({
                                            size = Size(100, 100),
                                            color = Color(127, 127, 127, 1),
                                            margin = Side(0, 20, 0, 0)
                                        }),
                                    }),
                                    Button({
                                        text = "tt",
                                        style = Style({
                                            size = Size(100, 100),
                                            color = Color(127, 127, 127, 1),
                                            margin = Side(0, 20, 0, 0)
                                        }),
                                    }),
                                    Button({
                                        text = "ings",
                                        style = Style({
                                            size = Size(100, 100),
                                            color = Color(127, 127, 127, 1),
                                            margin = Side(0, 20, 0, 0)
                                        }),
                                    }),
                                }
                            }),
                            Button({
                                text = "Quit",
                                method = function()
                                    Publisher.publish(Event("events.game.quit"))
                                end,
                                style = Style({
                                    size = Size(0, 100),
                                    color = Color(127, 127, 127, 1),
                                    margin = 20
                                }),
                            }),

                        }
                    }),
                },
            })
        }
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

function Menu:mousePressed(x, y, button, touch, presses)
    self.element:mousePressed(x, y, button, touch, presses)
end

function Menu:mouseReleased()
    self.element:mouseReleased()
end

return Menu
