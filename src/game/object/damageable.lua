local GameObject = require("src.game.object.gameobject")

--[[
    Represents a damageable type, everything related to dealing damage.
]]--

---@class Damageable : GameObject
local Damageable = {}
Damageable.__index = Damageable

setmetatable(Damageable, {
    __index = GameObject,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---Constructor
---@param o any
---@param health number
function Damageable:init(o, health)
    GameObject.init(self, o)

    ---@type number
    self.health = health
    ---@type boolean
    self.dead = false
end

---Damages the damageable.
---@param amount number
function Damageable:damage(amount)
    if self.dead then return end

    self.health = self.health - amount
    if self.health <= 0 then
        self:die()
    end
end

---Kills the damageable.
function Damageable:die()
    self.dead = true
    -- release from object pool
end

---Returns whether the damageable is dead.
---@return boolean
function Damageable:isDead()
    return self.dead
end

---Overrides the GameObject method, ideally we would use types for this.
---@return boolean
function Damageable:isDamageable() return true end

return Damageable
