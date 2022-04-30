local Collector = require("src.game.object.collector.collector")
local Util = require("src.game.util.util")

local HotbarItem = require("src.game.scene.world.component.hotbar-item.hotbar-item")

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

    o.images = self.collector:toImage()

    HotbarItem.init(self, o)

    self.allowedPositions = o.allowedPositions
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
        local mouse = Util.positionFromXY(tool.mouse.x, tool.mouse.y).position
        for _, aPosition in pairs(self.allowedPositions) do
            local aGrid = Util.positionFromXY(aPosition.x, aPosition.y).position
            -- TODO: util/common method
            if aGrid.x == mouse.x and aGrid.y == mouse.y then
                return false
            end
        end

        return true
    end
end

return CollectorHotbarItem
