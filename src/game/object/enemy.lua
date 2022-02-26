local Constants = require("src.game.constants")
local Event = require("src.game.event.event")
local GameObject = require("src.game.object.gameobject")
local Publisher = require("src.game.event.publisher")
local Util = require("src.game.util.util")

local Enemy = {}
Enemy.__index = Enemy

setmetatable(Enemy, {
    __index = GameObject,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Enemy:init(o)
    GameObject.init(self, o)

    self.base = o.base
    self.dead = false
    self.dmg = 25
    self.health = 100
    self.originalHealth = self.health
    self.parent = o.parent
    self.size = 2 * Constants.scale
    self.speed = 1
end

function Enemy:draw()
    if self.dead then return end

    love.graphics.setColor(1, 0, 0)
    love.graphics.circle(
        "fill",
        self.position.x,
        self.position.y,
        self.size
    )

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle(
        "fill",
        self.position.x - self.size,
        self.position.y + self.size + 10, -- Offset
        self.size * 2,
        10
    )

    local percentage = 1 * self.health / self.originalHealth
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle(
        "fill",
        self.position.x - self.size,
        self.position.y + self.size + 10, -- Offset
        (self.size * 2) * percentage,
        10
    )
end

function Enemy:update()
    if Util.isWithin(self, self.base) then
        self.base:damage(self.dmg)
        self:die()
        return
    end

    local bPosition = self.base:getMiddle()
    if bPosition.x > self.position.x then
        self.position.x = self.position.x + (0.5 * self.speed)
    elseif bPosition.x < self.position.x then
        self.position.x = self.position.x - (0.5 * self.speed)
    elseif bPosition.y > self.position.y then
        self.position.y = self.position.y + (0.5 * self.speed)
    else
        self.position.y = self.position.y - (0.5 * self.speed)
    end
end

function Enemy:damage(dmg)
    self.health = self.health - dmg
    if self.health < 0 or self.health == 0 then
        self:die()
    end
end

function Enemy:die()
    self.health = 0
    self.dead = true

    Publisher.publish(Event:new({ name = "enemy.death", data = self }))
end

function Enemy:isDead()
    return self.dead
end

return Enemy
