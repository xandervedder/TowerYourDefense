local Constants = require("src.game.constants")
local Event = require("src.game.event.event")
local GameObject = require("src.game.object.gameobject")
local Publisher = require("src.game.event.publisher")

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

    self.dead = false
    self.health = 100
    self.originalHealth = self.health
    self.parent = o.parent
    self.size = 2 * Constants.scale
    self.speed = 3
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

function Enemy:update(dt)
    self.position.y = self.position.y + self.speed / 10
end

function Enemy:damage(dmg)
    self.health = self.health - dmg
    if self.health < 0 then
        self.health = 0
        self.dead = true

        Publisher.publish(Event:new({ name = "enemy.death", data = self }))
    end
end

function Enemy:isDead()
    return self.dead
end

return Enemy
