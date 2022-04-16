local Base = require("src.game.object.tower.base.base")
local GameObject = require("src.game.object.gameobject")
local SingleBarrelTurret = require("src.game.object.tower.turret.single-barrel-turret")
local DoubleBarrelTurret = require("src.game.object.tower.turret.double-barrel-turret")

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
    self.base = o.base or Base({ position = self.position })
    -- TODO:
    self.barrel = nil
    ---@type Turret
    self.turret = o.turret or DoubleBarrelTurret({ position = self.position })
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

function Tower:getSheets()
    return { self.turret.sheet, self.base.sheet }
end

function Tower:getQuads()
    return { self.turret.quad, self.base.quad }
end

return Tower