local Point = require("src.common.objects.point")
local Queue = require("src.common.collections.queue")

local Constants = require("src.game.constants")
local Event = require("src.game.event.event")
local GameObject = require("src.game.object.gameobject")
local Publisher = require("src.game.event.publisher")
local Util = require("src.game.util.util")

--TODO: move to common
local Size = require("src.gui.style.property.size")

---@class Enemy : GameObject
local Enemy = {}
Enemy.__index = Enemy
---@type Size
Enemy.SIZE = Size(16, 16)

setmetatable(Enemy, {
    __index = GameObject,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---Constructor
---@param o table
---@param parent Spawner
---@param base Base
---@param path table<Point>
function Enemy:init(o, parent, base, path)
    GameObject.init(self, o)

    ---@type Base
    self.base = base
    ---@type Spawner
    self.parent = parent
    ---@type Queue
    self.pathToBase = Queue(path)
    --? Ignore first Point as it's the same as the start (we already know this).
    self.pathToBase:pop()
    ---@type Point
    self.currentPoint = self.pathToBase:pop()
    ---@type boolean
    self.dead = false
    ---@alias Direction
    --- | "up"
    --- | "right"
    --- | "down"
    --- | "left" 
    self.direction = "right"
    ---@type number
    self.dmg = 25
    ---@type number
    self.health = 100
    ---@type number
    self.originalHealth = self.health
    ---@type number
    self.speed = 0.25
end

function Enemy:draw()
    if self.dead then return end

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle(
        "fill",
        self.point.x,
        self.point.y,
        self.SIZE.w,
        self.SIZE.h
    )

    love.graphics.setColor(1, 0, 0)
    love.graphics.rectangle(
        "fill",
        self.point.x,
        self.point.y + self.SIZE.h + 5, -- Offset
        self.SIZE.w,
        10
    )

    local percentage = 1 * self.health / self.originalHealth
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle(
        "fill",
        self.point.x,
        self.point.y + self.SIZE.h + 5, -- Offset
        self.SIZE.w * percentage,
        10
    )
end

---@param _ number
function Enemy:update(_)
    if Util.isWithinPosition(self.point, self.base:getPoint(), self.base:getSize()) then
        self.base:damage(self.dmg)
        self:die()
        return
    end

    local currentPoint = self:getCurrentPoint()
    if currentPoint.x == self.point.x and currentPoint.y == self.point.y then
        self.currentPoint = self.pathToBase:pop()
        currentPoint = self:getCurrentPoint()
    end

    if currentPoint.x > self.point.x then
        self.point.x = self.point.x + self.speed
        self.direction = "right"
    elseif currentPoint.x < self.point.x then
        self.point.x = self.point.x - self.speed
        self.direction = "left"
    elseif currentPoint.y > self.point.y then
        self.point.y = self.point.y + self.speed
        self.direction = "bottom"
    else
        self.point.y = self.point.y - self.speed
        self.direction = "top"
    end
end

---Gets the current Point, but to the middle of it.
---@return Point
function Enemy:getCurrentPoint()
    local x = self.currentPoint.x
    local y = self.currentPoint.y
    return Point(
        (x * Constants.tile.scaledWidth()) + (Constants.tile.scaledWidth() / 2) - (self.SIZE.w / 2),
        (y * Constants.tile.scaledHeight()) + (Constants.tile.scaledHeight() / 2) - (self.SIZE.h / 2)
    )
end

-- TODO: This should be based on the current force... improve:
---Returns the direction the enemy is currently walking towards.
---@return Direction
function Enemy:getDirection() return self.direction end

---Reduces the health of an enemy by the damage given.
---@param dmg number
function Enemy:damage(dmg)
    self.health = self.health - dmg
    if self.health < 0 or self.health == 0 then
        self:die()
    end
end

---Kills the enemy.
function Enemy:die()
    self.health = 0
    self.dead = true

    Publisher.publish(Event("enemy.death", self))
end

---Returns whether the enemy is dead or not.
---@return boolean
function Enemy:isDead()
    return self.dead
end

return Enemy
