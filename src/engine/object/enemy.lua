local Constants = require("src.engine.constants")
local Event = require("src.engine.event.event")
local GameObject = require("src.engine.object.gameobject")
local Publisher = require("src.engine.event.publisher")

Enemy = GameObject:new({ speed = 3 })

function Enemy:initialize()
    self.size = 2 * Constants.scale
    self.health = 100
    self.dead = false
    self.originalHealth = self.health
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
