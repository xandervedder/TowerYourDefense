local Tower = require("src.game.objects.tower.tower")

local HotbarItem = require("src.game.scenes.world.component.hotbar-item.hotbar-item")

---@class TowerHotbarItem : HotbarItem
local TowerHotbarItem = {}
TowerHotbarItem.__index = TowerHotbarItem

setmetatable(TowerHotbarItem, {
    __index = HotbarItem,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function TowerHotbarItem:init(o)
    HotbarItem.init(self, o)

    ---@private
    ---@type Turret
    self.turretType = o.turretType
end

---Configures the tool before it gets enabled.
---@param tool PlacementTool
---@param inventory Inventory
function TowerHotbarItem:configureTool(tool, inventory)
    HotbarItem.configureTool(self, tool, inventory)

    -- The first setting is for rendering the preview
    local tower = Tower({ turret = self.turretType({})})
    tool:setGameObject(tower)
    tool:setRef(Tower)

    ---@param object Tower
    tool.objectCreatedLambda = function(object)
        -- This is for actually placing the game object.
        object:setTurret(self.turretType({ point = object:getPoint() }))
    end
end

return TowerHotbarItem
