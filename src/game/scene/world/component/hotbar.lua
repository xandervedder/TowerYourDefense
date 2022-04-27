local Align = require("src.gui.style.property.align")
local Color = require("src.gui.style.property.color")
local Container = require("src.gui.layout.container")
local DirBool = require("src.gui.style.property.dir-bool")
local HBox = require("src.gui.layout.h-box")
local Side = require("src.gui.style.property.side")
local Size = require("src.gui.style.property.size")
local Style = require("src.gui.style.style")

---@class Hotbar : Container
local Hotbar = {}
Hotbar.__index = Hotbar

setmetatable(Hotbar, {
    __index = Container,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Hotbar:init(o)
    o.children = {
        HBox({
            -- Eventually, this should come from the inventory.
            -- As the inventory will have all your placeables.
            children = o.children
        })
    }

    Container.init(self, o)
    ---@type Inventory
    self.inventory = o.inventory
    ---@type PlacementTool
    self.tool = o.tool
    self.tool.setInventory(self.inventory)
    self.tool.setHotbar(self)
    ---@type Style
    self.style = Style({
        align = Align(false, false, true),
        color = Color(35, 35, 35, 0.9),
        center = DirBool(true),
        padding = Side(10, 10, 10, 10),
        size = Size(280, 120),
    })

    self:addEventListener("click", function(_)
        ---@type HotbarItem[]
        local children = self.child.children

        ---@type HotbarItem|nil
        local activeChild = nil
        for _, child in pairs(children) do
            if child.mouseEntered and not child.constrained then
                child.active = true
                activeChild = child
                self.tool.enable()
                self.tool.getObject():setTurret(child.turretType({}))
                self.tool.setTurret(child.turretType)
                self.tool.setHotbarItem(child)
                break
            end
        end

        for _, child in pairs(children) do
            if not (child == activeChild) then
                child.active = false
            end
        end
    end)
end

function Hotbar:update(dt)
    Container.update(self, dt)

    self:checkConstraints()
end

function Hotbar:checkConstraints()
    ---@type HotbarItem[]
    local children = self.child.children
    local amount = self.inventory:getAmount()
    for _, child in pairs(children) do
        if child.constraint > amount then
            child.constrained = true
            child.active = false
        else
            child.constrained = false
        end
    end
end

return Hotbar
