local defineClass = require("src.common.objects.define-class")

local Collector = require("src.game.objects.collector.collector")
local HotbarItem = require("src.game.scenes.world.component.hotbar-item.hotbar-item")
local Util = require("src.game.util.util")

---@class CollectorHotbarItem : HotbarItem
local CollectorHotbarItem = defineClass(HotbarItem)

function CollectorHotbarItem:init(o)
    ---@type Collector
    self.collector = Collector({})

    o.images = self.collector:toImages()

    HotbarItem.init(self, o)

    ---@private
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
