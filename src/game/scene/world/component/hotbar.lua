local PlacementTool = require("src.game.tool.placement-tool")

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

    ---@type string
    self.id = "hotbar"
    ---@type Inventory
    self.inventory = o.inventory
    ---@type PlacementTool
    self.tool = PlacementTool({
        camera = o.camera,
        pool = o.pool,
        object = function() end,
        shouldClick = function()
            return self.mouseEntered
        end
    })
    ---@type Style
    self.style = Style({
        align = Align(false, false, true),
        color = Color(35, 35, 35, 0.9),
        center = DirBool(true),
        padding = Side(10, 10, 10, 10),
        size = Size(370, 120),
    })

    self:addEventListener("click", function(_)
        ---@type HotbarItem[]
        local children = self.child.children

        ---@type HotbarItem|nil
        local activeChild = nil
        for _, child in pairs(children) do
            if child.mouseEntered and not child.constrained then
                child.active = true
                child:configureTool(self.tool, self.inventory)
                self.tool:enable()
                activeChild = child
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
    self.tool:update(dt)

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

function Hotbar:mousePressed(x, y, button, touch, presses)
    Container.mousePressed(self, x, y, button, touch, presses)
    self.tool:mousePressed(nil, nil, button, nil, nil)
end

function Hotbar:mouseMoved(x, y, dx, dy, touch)
    Container.mouseMoved(self, x, y, dx, dy, touch)
    self.tool:mouseMoved(x, y, nil, nil, nil)
end

function Hotbar:getTool()
    return self.tool
end

return Hotbar
