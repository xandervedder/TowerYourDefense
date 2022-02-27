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
    self.direction = ""
    self.dmg = 25
    self.health = 100
    self.originalHealth = self.health
    self.parent = o.parent
    self.size = Util.size(6)
    self.speed = 0.25
end

function Enemy:draw()
    if self.dead then return end

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle(
        "fill",
        self.position.x,
        self.position.y,
        self.size.w,
        self.size.h
    )

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle(
        "fill",
        self.position.x,
        self.position.y + self.size.h + 5, -- Offset
        self.size.w,
        10
    )

    local percentage = 1 * self.health / self.originalHealth
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle(
        "fill",
        self.position.x,
        self.position.y + self.size.h + 5, -- Offset
        self.size.w * percentage,
        10
    )
end

function Enemy:update()
    if Util.isWithin(self, self.base) then
        self.base:damage(self.dmg)
        self:die()
        return
    end

    -- TODO: enemies are not moving towards the middle of the base (offset)
    local bPosition = self.base:getMiddle()
    if bPosition.x > self.position.x then
        self.position.x = self.position.x + self.speed
        self.direction = "right"
    elseif bPosition.x < self.position.x then
        self.position.x = self.position.x - self.speed
        self.direction = "left"
    elseif bPosition.y > self.position.y then
        self.position.y = self.position.y + self.speed
        self.direction = "bottom"
    else
        self.position.y = self.position.y - self.speed
        self.direction = "top"
    end
end

-- TODO: This should be based on the current force... improve:
function Enemy:getDirection() return self.direction end

function Enemy:getPosition() return GameObject.getMiddle(self) end

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
