local Event = require("src.game.event.event")
local Publisher = require("src.game.event.publisher")
local Damageable = require("src.game.objects.damageable")

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
    Damageable.draw(self)

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
end

function Base:die()
    Damageable.die(self)

    Publisher.publish(Event("game.over"))
end

return Base
