local Align = require("src.gui.style.property.align")
local Color = require("src.gui.style.property.color")
local Container = require("src.gui.layout.container")
local DirBool = require("src.gui.style.property.dir-bool")
local Image = require("src.gui.image")
local Side = require("src.gui.style.property.side")
local Size = require("src.gui.style.property.size")
local Style = require("src.gui.style.style")
local TextView = require("src.gui.text-view")
local VBox = require("src.gui.layout.v-box")

---@class HotbarItem : Container
local HotbarItem = {}
HotbarItem.__index = HotbarItem

setmetatable(HotbarItem, {
    __index = Container,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function HotbarItem:init(o)
    o.children = {
        VBox({
            style = Style({
                size = Size(80, 100),
            }),
            children = {
                Image({
                    id = "image",
                    images = o.images,
                    style = Style({
                        color = Color(255, 255, 255, 1),
                        size = Size(80, 80),
                    }),
                }),
                TextView({
                    style = Style({
                        margin = Side(5, 0, 0, 0),
                        size = Size(100, 20),
                    }),
                    fontSize = 14,
                    text = tostring(o.constraint),
                })
            }
        }),
    }

    Container.init(self, o)

    ---@type boolean
    self.active = false
    ---@type boolean
    self.constrained = false
    ---@type number
    self.constraint = o.constraint
    --! TODO: this is very specific to the turrets,
    --! we should make this more generic.
    ---@type Turret
    self.turretType = o.turretType

    ---@type Style
    self.style = Style({
        color = Color(0, 0, 0, 1),
        margin = Side(0, 10),
        size = Size(80, 80),
    })

    self:addEventListener("mouseenter", function(_)
        love.mouse.setCursor(love.mouse.getSystemCursor("hand"))

        if self.active or self.constrained then return end

        self.style.color = Color(255, 255, 255, 1)
    end)

    self:addEventListener("mouseout", function(_)
        love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))

        if self.active or self.constrained then return end

        self.style.color = Color(0, 0, 0, 1)
    end)
end

function HotbarItem:update(dt)
    Container.update(self, dt)

    ---@type Element
    local child = self:querySelector("image")
    if self.constrained then
        child.style.color = Color(255, 255, 255, 0.5)
    else
        child.style.color = Color(255, 255, 255, 1)
    end

    if self.active then
        self.style.color = Color(30, 189, 252, 1)
    else
        self.style.color = Color(0, 0, 0, 1)
    end
end

return HotbarItem
