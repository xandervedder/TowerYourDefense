local Constants = require("src.game.constants")
local GameObject = require("src.game.object.gameobject")
local Spawner = require("src.game.object.spawner")
local Util = require("src.game.util.util")

local Tower = {}
Tower.__index = Tower

setmetatable(Tower, {
    __index = GameObject,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

Tower.bulletSize = 0.75

function Tower:init(o)
    GameObject.init(self, o)

    -- Time related
    self.delay = 0.2
    self.elapsedTime = 0
    -- Firing related
    self.activeBullets = {}
    self.damage = 25
    self.firingSpeed = 3
    -- This should be based on grid, maybe?
    self.range = self.range or 250
    self.rotationSpeed = 1
    self.center = {
        x = self.position.x + self.size.w / 2,
        y = self.position.y + self.size.h / 2,
    }
    self.projectedEnemyPosition = nil
end

function Tower:prepare()
    -- Graphics related setup
    self.sheet = love.graphics.newImage("/assets/graphics/turret-spritesheet.png")
    self.sheet:setFilter("nearest", "nearest")
    self.turretBaseQuad = love.graphics.newQuad(0, 0, Constants.tile.w, Constants.tile.h, self.sheet:getDimensions())
    self.turretBarrelQuad = love.graphics.newQuad(16, 0, Constants.tile.w, Constants.tile.h, self.sheet:getDimensions())
    self.rotation = 0
end

function Tower:draw()
    love.graphics.setColor(1, 0, 0, 0.25)
    love.graphics.circle("fill", self.center.x, self.center.y, self.range)
    love.graphics.setColor(1, 1, 1)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.sheet, self.turretBaseQuad, self.position.x, self.position.y, 0, Constants.scale, Constants.scale)

    for i = 1, #self.activeBullets, 1 do
        local bullet = self.activeBullets[i]
        love.graphics.setColor(0, 0, 0)
        love.graphics.circle("fill", bullet.x, bullet.y, Tower.bulletSize * Constants.scale)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.sheet,
        self.turretBarrelQuad,
        self.center.x,
        self.center.y,
        self.rotation,
        Constants.scale,
        Constants.scale,
        -- Origin points will be in the center of the image:
        Constants.tile.w / 2,
        Constants.tile.h / 2
    )
end

function Tower:update(dt)
    self:updateBullets()

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

    self.elapsedTime = self.elapsedTime + dt
    if not (self.elapsedTime >= self.delay) then return end
    self.elapsedTime = 0

    if self:withinRange(self.enemy) and not self.enemy:isDead() then
        self:shoot()
    end
end

function Tower:findNextEnemy()
    local enemies = Spawner.allEnemies()
    for _, enemy in pairs(enemies) do
        if self:withinRange(enemy) then
            self.enemy = enemy
            break
        end
    end
end

function Tower:updateBullets()
    if #self.activeBullets == 0 then return end

    for i = #self.activeBullets, 1, -1 do
        local bullet = self.activeBullets[i]
        bullet.x = bullet.x + bullet.velocity.x
        bullet.y = bullet.y + bullet.velocity.y
    end
end

function Tower:rotateBarrel(dt)
    if not self:withinRange(self.enemy) then return end

    local size = self.enemy:getSize()
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
    local diff = current - target

    if math.abs(diff) > 1 then
        -- When the barrel needs to move from 20 -> 290
        if 360 - target + current < 180 then
            self.rotation = self.rotation + (-0.01 * self.rotationSpeed)
        -- When the barrel needs to move from 290 -> 20
        elseif math.abs(diff) > 180 then
            self.rotation = self.rotation + (0.01 * self.rotationSpeed)
        elseif target > current then
            self.rotation = self.rotation + (0.01 * self.rotationSpeed)
        else
            self.rotation = self.rotation + (-0.01 * self.rotationSpeed)
        end
    end

    return self.rotation
end

function Tower:predictPosition(dt)
    local position = self.enemy:getPosition()
    local distance = math.sqrt(math.pow(self.center.x - position.x, 2) + math.pow(self.center.y - position.y, 2))
    local time = dt * distance / self.firingSpeed
    local steps = time / dt

    local direction = self.enemy:getDirection()
    --! Will be improved at a later time:
    if direction == "right" then
        self.projectedEnemyPosition = { x = position.x + (steps * self.enemy:getSpeed()), y = position.y }
    elseif direction == "left" then
        self.projectedEnemyPosition = { x = position.x - (steps * self.enemy:getSpeed()), y = position.y }
    elseif direction == "top" then
        self.projectedEnemyPosition = { x = position.x, y = position.y - (steps * self.enemy:getSpeed()) }
    elseif direction == "bottom" then
        self.projectedEnemyPosition = { x = position.x, y = position.y + (steps * self.enemy:getSpeed()) }
    end

    return self.projectedEnemyPosition
end

function Tower:checkCollision()
    local height, width = love.graphics.getDimensions()

    for i = #self.activeBullets, 1, -1 do
        local bullet = self.activeBullets[i]
        local x = bullet.x
        local y = bullet.y

        if Util.isWithin(bullet, self.enemy) then
            self.enemy:damage(self.damage)
            table.remove(self.activeBullets, i)
        elseif (x > width or x < 0) or (y > height or y < 0) then -- Off screen
            table.remove(self.activeBullets, i)
        end
    end
end

function Tower:withinRange(enemy)
    local position = enemy:getPosition()
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

function Tower:shoot()
    -- TODO: bullet should be its own object in a different file
    local bullet = {
        x = self.center.x,
        y = self.center.y,
        velocity = { x = 0, y = 0 },
        speed = self.firingSpeed,
    }
    bullet.getPosition = function ()
        return { x = bullet.x, y = bullet.y }
    end

    -- https://stackoverflow.com/a/14857424
    -- TODO: this works now, it shoots with the barrel but it can still be improved...
    bullet.velocity.x = -math.cos(self.rotation) * bullet.speed
    bullet.velocity.y = -math.sin(self.rotation) * bullet.speed

    table.insert(self.activeBullets, bullet)
end

return Tower
