local defineClass = require("src.common.objects.define-class")

local GameObject = require("src.game.objects.game-object")

--[[
    Represents a damageable type, everything related to dealing damage.
]]--

---@class Damageable : GameObject
local Damageable = defineClass(GameObject)

---Constructor
---@param o any
---@param health number
function Damageable:init(o, health)
    GameObject.init(self, o)

    ---@protected
    ---@type number
    self.originalHealth = health
    ---@protected
    ---@type number
    self.health = health
    ---@protected
    ---@type boolean
    self.dead = false
    ---@protected
    ---@type boolean
    self.damaged = false
    ---@protected
    ---@type number
    self.percentage = 1
end

---Draw method
function Damageable:draw()
    --? Only draw if the damageable has been damaged.
    if not self.damaged then return end
    if self.dead then return end

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
end

---Returns whether the damageable is dead.
---@return boolean
function Damageable:isDead()
    return self.dead
end

---Resets the damageable to its initial state.
function Damageable:resetState()
    self.dead = false
    self.health = self.originalHealth
end

---Overrides the GameObject method, ideally we would use types for this.
---@return boolean
function Damageable:isDamageable() return true end

return Damageable
