local Constants = require("src.engine.constants")
local GameObject = require("src.engine.object.gameobject")
local Spawner = require("src.engine.object.spawner")

Tower = GameObject:new({ degree = 1 })
Tower.size = 16
Tower.bulletSize = 0.75

function Tower:initialize()
    -- Time related
    self.delay = 0.2
    self.elapsedTime = 0

    -- Firing related
    self.activeBullets = {}
    self.damage = 25
    self.range = self.range or 250 -- For now in pixels
    self.rotationSpeed = 1

    -- Graphics related setup
    self.sheet = love.graphics.newImage("/assets/graphics/turret-spritesheet.png")
    self.sheet:setFilter("nearest", "nearest")
    self.turretBaseQuad = love.graphics.newQuad(0, 0, Tower.size, Tower.size, self.sheet:getDimensions())
    self.turretBarrelQuad = love.graphics.newQuad(16, 0, Tower.size, Tower.size, self.sheet:getDimensions())
    self.rotation = 0
    self.scaled = { -- This is just the center, name should reflect that...
        x = self.position.x + Constants.tile.scaledWidth() / 2,
        y = self.position.y + Constants.tile.scaledHeight() / 2,
    }
end

function Tower:draw()
    love.graphics.setColor(1, 0, 0, 0.25)
    love.graphics.circle("fill", self.scaled.x, self.scaled.y, self.range)
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
        self.scaled.x,
        self.scaled.y,
        self.rotation,
        Constants.scale,
        Constants.scale,
        -- Origin points will be in the center of the image:
        Tower.size / 2,
        Tower.size / 2
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

    self:rotateBarrel()
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

function Tower:rotateBarrel()
    if not self:withinRange(self.enemy) then return end

    local size = self.enemy:getSize()
    local position = self.enemy:getPosition()
    local x = position.x + size / 2
    local y = position.y + size / 2
    local radians = math.atan2(self.scaled.y - y, self.scaled.x - x)
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

function Tower:checkCollision()
    local enemy = self.enemy:getPosition()
    local size = self.enemy:getSize()
    local height, width = love.graphics.getDimensions()

    for i = #self.activeBullets, 1, -1 do
        local bullet = self.activeBullets[i]
        local x = bullet.x
        local y = bullet.y
        local diffX = (enemy.x + size / 2) - (x + Tower.bulletSize * Constants.scale)
        local diffY = (enemy.y + size / 2) - (y + Tower.bulletSize * Constants.scale)

        local offset = size / 2
        if (diffX < offset and diffX > -offset) and (diffY < offset and diffY > -offset) then -- Target hit
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
    local dx = math.abs(self.scaled.x - position.x - size / 2)
    local dy = math.abs(self.scaled.y - position.y - size / 2)

    -- Great visual guide: https://jsfiddle.net/exodus4d/94mxLvqh/2691/
    if dx > (size / 2 + self.range) then return false end
    if dy > (size / 2 + self.range) then return false end
    if dx <= (size / 2) then return true end
    if dy <= (size / 2) then return true end

    local trX = dx - size / 2
    local trY = dy - size / 2
    return trX * trX + trY * trY <= self.range * self.range
end

function Tower:shoot()
    local bullet = {
        x = self.scaled.x,
        y = self.scaled.y,
        velocity = { x = 0, y = 0 },
        speed = 4, -- Should be a tower stat
    }

    -- https://stackoverflow.com/a/14857424
    -- TODO: this works now, it shoots with the barrel but it can still be improved...
    bullet.velocity.x = -math.cos(self.rotation) * bullet.speed
    bullet.velocity.y = -math.sin(self.rotation) * bullet.speed

    table.insert(self.activeBullets, bullet)
end

return Tower
