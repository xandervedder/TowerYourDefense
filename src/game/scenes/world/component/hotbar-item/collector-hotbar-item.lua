local Collector = require("src.game.object.collector.collector")
local Util = require("src.game.util.util")

local HotbarItem = require("src.game.scenes.world.component.hotbar-item.hotbar-item")

---@class CollectorHotbarItem : HotbarItem
local CollectorHotbarItem = {}
CollectorHotbarItem.__index = CollectorHotbarItem

setmetatable(CollectorHotbarItem, {
    __index = HotbarItem,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function CollectorHotbarItem:init(o)
    ---@type Collector
    self.collector = Collector({})

    o.images = self.collector:toImages()

    HotbarItem.init(self, o)

    ---@type table<number, Point>
    self.allowedPoints = o.allowedPoints
end

---Configures the tool before it gets enabled.
---@param tool PlacementTool
---@param inventory Inventory
function CollectorHotbarItem:configureTool(tool, inventory)
    HotbarItem.configureTool(self, tool, inventory)

    -- The first setting is for rendering the preview
    tool:setGameObject(Collector({}))
    tool:setRef(Collector)

    ---@param object Tower
    tool.objectCreatedLambda = function(object)
        return object
    end
    tool.obstructionLambda = function()
        if not self.active then return false end

        local mouse = Util.toGridPoint(nil, tool.mouse.x, tool.mouse.y)
        for _, point in pairs(self.allowedPoints) do
            -- TODO: util/common method (in point)
            if point.x == mouse.x and point.y == mouse.y then
                return false
            end
        end

        return true
    end
end

return CollectorHotbarItem
