local defineClass = require("src.common.objects.define-class")
local Point = require("src.common.objects.point")
local Queue = require("src.common.collections.queue")

local Constants = require("src.game.constants")
local Event = require("src.game.event.event")
local Publisher = require("src.game.event.publisher")
local SpriteLoader = require("src.game.graphics.loader.sprite-loader")
local Damageable = require("src.game.objects.damageable")
local Util = require("src.game.util.util")

---@class Enemy : Damageable
local Enemy = defineClass(Damageable)

---Constructor
---@param o table
---@param parent Spawner
---@param base Base
---@param path table<Point>
---@param grid Size
---@param gameObjects Pool
---@param health number
function Enemy:init(o, parent, base, path, grid, gameObjects, health)
    Damageable.init(self, o, health)

    ---@private
    ---@type Base
    self.base = base
    ---@private
    ---@type Queue
    self.currentPath = Queue(path)
    --? Ignore first Point as it's the same as the start (we already know this).
    self.currentPath:pop()
    ---@private
    ---@type Point
    self.currentPoint = self.currentPath:pop()
    ---@private
    ---@type boolean
    self.dead = false
    ---@private
    ---@alias Direction
    --- | "up"
    --- | "right"
    --- | "down"
    --- | "left" 
    self.direction = "right"
    ---@private
    ---@type number
    self.dmg = 25
    ---@private
    ---@type number
    self.originalHealth = self.health
    ---@private
    ---@type number
    self.speed = 10 * Constants.scale
    ---@private
    ---@type Size
    self.grid = grid
    ---@private
    ---@type Pool
    self.gameObjects = gameObjects
    ---@private
    ---@type Sprite
    self.sprite = SpriteLoader.getSprite("enemy")
    ---@private
    ---@type Point
    --TODO: is this being used or not?
    self.center = self:getMiddle()

    self.type = "Enemy"
    ---@type Spawner
    self.parent = parent

    table.insert(gameObjects, self)
end

function Enemy:draw()
    if self.dead then return end

    Damageable.draw(self)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.sprite.image,
        self.sprite.quads[1],
        self.point.x,
        self.point.y,
        0,
        Constants.scale,
        Constants.scale
    )
end

---Update method.
---@param dt number
function Enemy:update(dt)
    Damageable.update(self, dt)

    if Util.isWithinPosition(self.point, self.base:getPoint(), self.base:getSize()) then
        self:dealDamageTo(self.base)
        return
    end

    local currentPointInTheMiddle = self:getCurrentPoint()
    local match = self.gameObjects:getBy(function(o)
        if o.type ~= 'Base' or o.type ~= 'Mech' then return false end

        return o:isDamageable() and Util.isWithinPosition(self.point, o:getPoint(), o:getSize()) or self.point == o:getPoint()
    end)
    if #match > 0 then
        self:dealDamageTo(match[1])
        return
    end

    if currentPointInTheMiddle == self.point then
        self.currentPoint = self.currentPath:pop()
        currentPointInTheMiddle = self:getCurrentPoint()
    end

    if currentPointInTheMiddle.x > self.point.x then
        self.point.x = self:limitHigh(self.point.x + (self.speed * dt), currentPointInTheMiddle.x)
        self.direction = "right"
    elseif currentPointInTheMiddle.x < self.point.x then
        self.point.x = self:limitLow(self.point.x - (self.speed * dt), currentPointInTheMiddle.x)
        self.direction = "left"
    elseif currentPointInTheMiddle.y > self.point.y then
        self.point.y = self:limitHigh(self.point.y + (self.speed * dt), currentPointInTheMiddle.y)
        self.direction = "bottom"
    else
        self.point.y = self:limitLow(self.point.y - (self.speed * dt), currentPointInTheMiddle.y)
        self.direction = "top"
    end
end

---Limits the value only if it's higher
---@param value number
---@param limiter number
---@return number
function Enemy:limitHigh(value, limiter)
    if value > limiter then
        return limiter
    end
    return value
end

---Limits the value only if it's lower.
---@param value number
---@param limiter number
---@return number
function Enemy:limitLow(value, limiter)
    if value < limiter then
        return limiter
    end
    return value
end

---Deals damage to a damageable and kills itself.
---@param damageable Damageable
function Enemy:dealDamageTo(damageable)
    damageable:damage(self.dmg)
    self:die()
end

---Gets the current Point, but to the middle of it.
---@return Point
function Enemy:getCurrentPoint()
    local x = self.currentPoint.x
    local y = self.currentPoint.y
    local scaledWidth = Constants.tile.scaledWidth()
    local scaledHeight = Constants.tile.scaledHeight()
    return Point(
        (x * scaledWidth) + (scaledWidth / 2) - (scaledWidth / 2),
        (y * scaledHeight) + (scaledHeight / 2) - (scaledHeight / 2)
    )
end

-- TODO: This should be based on the current force... improve:
---Returns the direction the enemy is currently walking towards.
---@return string
function Enemy:getDirection() return self.direction end

---Kills the enemy.
function Enemy:die()
    Damageable.die(self)

    self.gameObjects:delete(self)
    Publisher.publish(Event("enemy.death", self))
end

return Enemy
