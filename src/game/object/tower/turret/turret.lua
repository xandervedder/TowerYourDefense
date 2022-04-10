local C = require("src.game.constants")
local GameObject = require("src.game.object.gameobject")
local Spawner = require("src.game.object.spawner")
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
    GameObject.setSheet(self, o.location)

    self.quad = love.graphics.newQuad(o.q.x, o.q.y, C.tile.w, C.tile.h, self.sheet:getDimensions())

    --! TODO: type
    self.activeShells = {}
    --! TODO: type
    self.center = {
        x = self.position.x + self.size.w / 2,
        y = self.position.y + self.size.h / 2,
    }
    ---@type number
    self.damage = 25
    ---@type number
    self.elapsedTime = 0
    ---@type Enemy
    self.enemy = nil
    ---@type number
    self.firingDelay = 0.2
    --! TODO: Type
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
        love.graphics.circle("fill", bullet.x, bullet.y, 0.75 * C.scale)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.sheet,
        self.quad,
        self.center.x,
        self.center.y,
        self.rotation,
        C.scale,
        C.scale,
        -- Origin points will be in the center of the image:
        C.tile.w / 2,
        C.tile.h / 2
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
    local enemies = Spawner.allEnemies()
    for _, enemy in pairs(enemies) do
        if self:withinRange(enemy) then
            self.enemy = enemy
            break
        end
    end
end

function Turret:withinRange(enemy)
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

function Turret:checkCollision()
    local height, width = love.graphics.getDimensions()

    for i = #self.activeShells, 1, -1 do
        local bullet = self.activeShells[i]
        local x = bullet.x
        local y = bullet.y

        if Util.isWithin(bullet, self.enemy) then
            self.enemy:damage(self.damage)
            table.remove(self.activeShells, i)
        elseif (x > width or x < 0) or (y > height or y < 0) then -- Off screen
            table.remove(self.activeShells, i)
        end
    end
end

function Turret:predictPosition(dt)
    local position = self.enemy:getPosition()
    local distance = math.sqrt(math.pow(self.center.x - position.x, 2) + math.pow(self.center.y - position.y, 2))
    local time = dt * distance / self.shotSpeed
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

---Rotates the turret, not sure if I am going to keep this.
function Turret:rotate() end

return Turret
