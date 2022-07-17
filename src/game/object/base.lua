local GameObject = require("src.game.object.gameobject")

---@class Base : GameObject
local Base = {}
Base.__index = Base

setmetatable(Base, {
    __index = GameObject,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Base:init(o)
    GameObject.init(self, o)

    self.destroyed = false
    self.health = 1000
    self.originalHealth = self.health
end

function Base:draw()
    love.graphics.setColor(0, 0, 1)
    love.graphics.rectangle(
        "fill",
        self.position.x,
        self.position.y,
        self.size.w,
        self.size.h
    )

    love.graphics.setColor(1, 1, 1)
    love.graphics.print("BASE", self.position.x, self.position.y)

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle(
        "fill",
        self.position.x,
        self.position.y + self.size.h - 10,
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
        self.position.x,
        self.position.y + self.size.h - 10,
        self.size.w * percentage,
        10
    )
end

function Base:update()
    if self.isdmged then
        self.health = self.health - 25
        self.isdmged = false
    end
end

function Base:damage(dmg)
    if self.destroyed then return end

    self.health = self.health - dmg
    if self.health == 0 or self.health < 0 then
        self.destroyed = true
    end
end

return Base
