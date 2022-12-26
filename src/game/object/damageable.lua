local GameObject = require("src.game.object.game-object")

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
    self.originalHealth = health
    ---@type number
    self.health = health
    ---@type boolean
    self.dead = false
    ---@type boolean
    self.damaged = false
    ---@type number
    self.percentage = 1
end

---Draw method
function Damageable:draw()
    --? Only draw if the damageable has been damaged.
    if not self.damaged then return end

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle(
        "fill",
        self.point.x,
        self.point.y + self.size.h + 5, -- Offset
        self.size.w,
        10
    )

    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle(
        "fill",
        self.point.x,
        self.point.y + self.size.h + 5, -- Offset
        self.size.w * self.percentage,
        10
    )
end

---Update method.
---@param dt number
function Damageable:update(dt)
    self.percentage = 1 * self.health / self.originalHealth
    
    if self.health ~= self.originalHealth then
        self.damaged = true
    end
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
