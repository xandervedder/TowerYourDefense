local Base = require("src.game.object.tower.base.base")
local Damageable = require("src.game.object.damageable")
local GameObject = require("src.game.object.gameobject")
local SingleBarrelTurret = require("src.game.object.tower.turret.single-barrel-turret")

---@class Tower : Damageable
local Tower = {}
Tower.__index = Tower

setmetatable(Tower, {
    __index = Damageable,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

Tower.bulletSize = 0.75

---Constructor
---@param o any
---@param gameObjects Pool
function Tower:init(o, gameObjects)
    Damageable.init(self, o, 1000)

    -- Attributes of the Tower
    ---@type TowerBase
    self.base = o.base or Base({ point = self.point, scale = self.scale })
    -- TODO:
    self.barrel = nil
    ---@type Turret
    self.turret = o.turret or SingleBarrelTurret({ point = self.point, })
    ---@type string
    self.type = "Tower"
    -- TODO:
    self.shell = nil
    ---@type Pool
    self.gameObjects = gameObjects
end

function Tower:draw()
    Damageable.draw(self)

    self.base:draw()
    self.turret:draw()
end

function Tower:update(dt)
    Damageable.update(self, dt)

    self.turret:update(dt)
end

---Sets the turret to a new instance.
---@param turret Turret
function Tower:setTurret(turret)
    self.turret = turret
    self.turret:setPoint(self.point)
end

function Tower:getSheets()
    return { self.turret.sheet, self.base.sheet }
end

function Tower:getQuads()
    return { self.turret.quad, self.base.quad }
end

function Tower:toImage()
    local baseImages = GameObject.imagesFromQuads(self.base.sheetData, self.base:getQuads())
    local turretImages = GameObject.imagesFromQuads(self.turret.sheetData, self.turret:getQuads())
    for _, value in pairs(turretImages) do
        table.insert(baseImages, value)
    end

    return baseImages
end

function Tower:die()
    Damageable.die(self)

    self.gameObjects:delete(self)
end

return Tower
