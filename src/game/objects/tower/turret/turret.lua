local Point = require("src.common.objects.point")

local Constants = require("src.game.constants")
local GameObject = require("src.game.objects.game-object")
local Spawner = require("src.game.objects.spawner")
local SpriteLoader = require("src.game.graphics.loader.sprite-loader")
local Util = require("src.game.util.util")

---@class Turret : GameObject
local Turret = {}
Turret.__index = Turret

setmetatable(Turret, {
    __index = GameObject,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Turret:init(o)
    GameObject.init(self, o)

    self.sprite = SpriteLoader.getSprite("turret")
    self.quad = love.graphics.newQuad(o.q.x, o.q.y, Constants.tile.w, Constants.tile.h, self.sprite.image:getDimensions())

    ---@type table
    self.activeShells = {}
    ---@type Point
    self.center = Point(self.point.x + self.size.w / 2, self.point.y + self.size.h / 2)
    ---@type number
    self.damage = 25
    ---@type number
    self.diff = 0
    ---@type number
    self.elapsedTime = 0
    ---@type Enemy
    self.enemy = nil
    ---@type number
    self.firingDelay = 0.2
    ---@type Point
    self.projectedEnemyPosition = nil
    ---@type number
    self.range = o.range or 250
    ---@type number
    self.rotation = 0
    ---@type number
    self.rotationSpeed = 1
    ---@type number
    self.shotSpeed = 3
end

function Turret:draw()
    -- TODO: Move this a different file
    for i = 1, #self.activeShells, 1 do
        local bullet = self.activeShells[i]
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", bullet.x, bullet.y, 0.75 * Constants.scale * self.scale)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.sprite.image,
        self.quad,
        self.center.x,
        self.center.y,
        self.rotation,
        Constants.scale * self.scale,
        Constants.scale * self.scale,
        -- Origin points will be in the center of the image:
        Constants.tile.w / 2,
        Constants.tile.h / 2
    )
end

function Turret:update(dt)
    self:updateShells()

    if self.enemy == nil then
        self:findNextEnemy()
    elseif not self:withinRange(self.enemy) then
        self:findNextEnemy()
    elseif self.enemy:isDead() then
        self.enemy = nil
    end

    -- Enemy could still be empty
    if self.enemy == nil then return end

    self:rotateBarrel(dt)
    self:checkCollision()
end

function Turret:updateShells()
    if #self.activeShells == 0 then return end

    for i = #self.activeShells, 1, -1 do
        local shell = self.activeShells[i]
        shell.x = shell.x + shell.velocity.x
        shell.y = shell.y + shell.velocity.y
    end
end

function Turret:findNextEnemy()
    local enemies = Spawner.getAllEnemies()
    for _, enemy in pairs(enemies) do
        if self:withinRange(enemy) then
            self.enemy = enemy
            break
        end
    end
end

---Checks whether the enemy is within range of the turret.
---@param enemy Enemy
---@return boolean
function Turret:withinRange(enemy)
    local position = enemy:getPoint()
    local size = enemy:getSize()
    local dx = math.abs(self.center.x - position.x - size.w / 2)
    local dy = math.abs(self.center.y - position.y - size.h / 2)

    -- Great visual guide: https://jsfiddle.net/exodus4d/94mxLvqh/2691/
    if dx > (size.w / 2 + self.range) then return false end
    if dy > (size.h / 2 + self.range) then return false end
    if dx <= (size.w / 2) then return true end
    if dy <= (size.h / 2) then return true end

    local trX = dx - size.w / 2
    local trY = dy - size.h / 2
    return trX * trX + trY * trY <= self.range * self.range
end

function Turret:rotateBarrel(dt)
    if not self:withinRange(self.enemy) then return end

    local size = self.enemy:getSize()
    -- TODO: move this to the child class:
    -- Reason for this is, not all turrets should be accurate
    local position = self:predictPosition(dt)
    local x = position.x + size.w / 2
    local y = position.y + size.h / 2
    local radians = math.atan2(self.center.y - y, self.center.x - x)
    if radians < 0 then
        radians = radians + (2 * math.pi)
    end

    -- We don't want rotation above 360 (a.k.a. full circle):
    if math.deg(self.rotation) > 360 then
        self.rotation = math.rad(0)
    -- We also don't want this the other way around:
    elseif math.deg(self.rotation) < 0 then
        self.rotation = math.rad(360)
    end

    local target = math.deg(radians)
    local current = math.deg(self.rotation)
    self.diff = current - target

    if math.abs(self.diff) > 1 then
        -- When the barrel needs to move from 20 -> 290
        if 360 - target + current < 180 then
            self.rotation = self.rotation + (-0.01 * self.rotationSpeed)
        -- When the barrel needs to move from 290 -> 20
        elseif math.abs(self.diff) > 180 then
            self.rotation = self.rotation + (0.01 * self.rotationSpeed)
        elseif target > current then
            self.rotation = self.rotation + (0.01 * self.rotationSpeed)
        else
            self.rotation = self.rotation + (-0.01 * self.rotationSpeed)
        end
    end

    return self.rotation
end

function Turret:checkCollision()
    for i = #self.activeShells, 1, -1 do
        local bullet = self.activeShells[i]
        local x = bullet.x
        local y = bullet.y

        if Util.isWithin(bullet, self.enemy) then
            self.enemy:damage(self.damage)
            table.remove(self.activeShells, i)
        elseif (x > Constants.world.w or x < 0) or (y > Constants.world.h or y < 0) then -- Off screen
            table.remove(self.activeShells, i)
        end
    end
end

---Predicts the enemy position by calculating how long it would take for the 'bullet' to travel to the enemy. With
---this information it will also calculate the difference the turret would need to actually hit the enemy.
---@param dt number
---@return Point
function Turret:predictPosition(dt)
    local position = self.enemy:getMiddle()
    local distance = math.sqrt(math.pow(self.center.x - position.x, 2) + math.pow(self.center.y - position.y, 2))
    local time = dt * distance / self.shotSpeed
    local steps = time / dt

    local direction = self.enemy:getDirection()
    --! Will be improved at a later time:
    if direction == "right" then
        self.projectedEnemyPosition = Point(position.x + (steps * self.enemy:getSpeed()), position.y)
    elseif direction == "left" then
        self.projectedEnemyPosition = Point(position.x - (steps * self.enemy:getSpeed()), position.y)
    elseif direction == "top" then
        self.projectedEnemyPosition = Point(position.x, position.y - (steps * self.enemy:getSpeed()))
    elseif direction == "bottom" then
        self.projectedEnemyPosition = Point(position.x, position.y + (steps * self.enemy:getSpeed()))
    end

    return self.projectedEnemyPosition
end

---Function that will tell if the barrel is aimed at an enemy
---@return boolean
function Turret:isAimedAtEnemy()
    local absDiff = math.abs(self.diff)
    return absDiff >= 0 and absDiff <= 3
end

function Turret:setScale(scaleFactor)
    self.scale = scaleFactor
    self.center = Point(self.point.x + self.size.w / 2, self.point.y + self.size.h / 2)
end

function Turret:toImages()
    return GameObject.imagesFromQuads(self.sprite.imageData, { self.quad })
end

return Turret
