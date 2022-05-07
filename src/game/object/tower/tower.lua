local Base = require("src.game.object.tower.base.base")
local GameObject = require("src.game.object.gameobject")
local SingleBarrelTurret = require("src.game.object.tower.turret.single-barrel-turret")

---@class Tower : GameObject
local Tower = {}
Tower.__index = Tower

setmetatable(Tower, {
    __index = GameObject,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

Tower.bulletSize = 0.75

function Tower:init(o)
    GameObject.init(self, o)

    -- Attributes of the Tower
    ---@type Base
    self.base = o.base or Base({ position = self.position, scale = self.scale })
    -- TODO:
    self.barrel = nil
    ---@type Turret
    self.turret = o.turret or SingleBarrelTurret({ position = self.position, })
    ---@type string
    self.type = "Tower"
    -- TODO:
    self.shell = nil
end

function Tower:draw()
    self.base:draw()
    self.turret:draw()
end

function Tower:update(dt)
    self.turret:update(dt)
end

---Sets the turret to a new instance.
---@param turret Turret
function Tower:setTurret(turret)
    self.turret = turret
    self.turret:setPosition(self.position)
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

return Tower
