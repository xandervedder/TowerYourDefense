local Damageable = require("src.game.object.damageable")

---@class Base : Damageable
local Base = {}
Base.__index = Base

setmetatable(Base, {
    __index = Damageable,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Base:init(o)
    Damageable.init(self, o, 1000)

    self.destroyed = false
    self.originalHealth = self.health

    self.type = "Base"
end

function Base:draw()
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle(
        "fill",
        self.point.x,
        self.point.y,
        self.size.w,
        self.size.h
    )

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("BASE", self.point.x, self.point.y)

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle(
        "fill",
        self.point.x,
        self.point.y + self.size.h - 10,
        self.size.w,
        10
    )

    local percentage = 1 * self.health / self.originalHealth
    love.graphics.setColor(0, 1, 0)
    if self.destroyed then
        love.graphics.setColor(1, 0, 0)
    end
    love.graphics.rectangle(
        "fill",
        self.point.x,
        self.point.y + self.size.h - 10,
        self.size.w * percentage,
        10
    )
end

return Base
