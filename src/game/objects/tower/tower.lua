local defineClass = require("src.common.objects.define-class")

local Base = require("src.game.objects.tower.base.base")
local Damageable = require("src.game.objects.damageable")
local SingleBarrelTurret = require("src.game.objects.tower.turret.single-barrel-turret")

---@class Tower : Damageable
local Tower = defineClass(Damageable)

---@private
Tower.bulletSize = 0.75

---Constructor
---@param o any
---@param gameObjects Pool
function Tower:init(o, gameObjects)
    Damageable.init(self, o, 1000)

    -- TODO:
    ---@private
    self.barrel = nil
    -- TODO:
    ---@private
    self.shell = nil
    ---@private
    ---@type Pool
    self.gameObjects = gameObjects

    ---@type string
    self.type = "Tower"
    ---@type Turret
    self.turret = o.turret or SingleBarrelTurret({ point = self.point, })
    ---@type TowerBase
    self.base = o.base or Base({ point = self.point, scale = self.scale })
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

function Tower:toImages()
    local baseImages = self.base:toImages()
    local turretImages = self.turret:toImages()
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
