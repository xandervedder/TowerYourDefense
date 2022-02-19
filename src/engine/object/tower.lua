local Constants = require("src.engine.constants")
local GameObject = require("src.engine.object.gameobject")
local Publisher = require("src.engine.event.publisher")

Tower = GameObject:new({ degree = 1 })
Tower.size = 16
Tower.bulletSize = 0.75

function Tower:initialize()
    -- Time related
    self.delay = 0.2
    self.elapsedTime = 0

    -- Firing related
    self.activeBullets = {}
    self.hitBullets = {}
    self.range = self.range or 200 -- For now in pixels
    self.rotationSpeed = 1
    self.turning = false

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

    Publisher.register(self, "events.enemy.follow", function (event) self:onTargetChange(event) end)
end

function Tower:draw()
    love.graphics.setColor(1, 0, 0, 0.25)
    love.graphics.circle("fill", self.scaled.x, self.scaled.y, self.range)
    love.graphics.setColor(1, 1, 1)

    for i = 1, #self.hitBullets, 1 do
        local bullet = self.hitBullets[i]
        love.graphics.setColor(1, 0, 0)
        love.graphics.circle("fill", bullet.x, bullet.y, Tower.bulletSize * Constants.scale)
    end

    for i = 1, #self.activeBullets, 1 do
        local bullet = self.activeBullets[i]
        love.graphics.setColor(0, 0, 1)
        love.graphics.circle("fill", bullet.x, bullet.y, Tower.bulletSize * Constants.scale)
    end

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.sheet, self.turretBaseQuad, self.position.x, self.position.y, 0, Constants.scale, Constants.scale)
    love.graphics.draw(
        self.sheet,
        self.turretBarrelQuad,
        self.scaled.x,
        self.scaled.y,
        self:barrelRotation(),
        Constants.scale,
        Constants.scale,
        -- Origin points will be in the center of the image:
        Tower.size / 2,
        Tower.size / 2
    )
end

function Tower:update(dt)
    self:updateBullets()

    self.elapsedTime = self.elapsedTime + dt
    if not (self.elapsedTime >= self.delay) then return end
    self.elapsedTime = 0

    if self:withinRange() and not self.turning then
        self:shoot()
    end
end

function Tower:updateBullets()
    if #self.activeBullets == 0 then return end

    local enemy = self.object:getPosition()
    local size = self.object:getSize()
    for i = #self.activeBullets, 1, -1 do
        local bullet = self.activeBullets[i]
        bullet.x = bullet.x + bullet.velocity.x
        bullet.y = bullet.y + bullet.velocity.y

        local diffX = (enemy.x + size / 2) - bullet.x
        local diffY = (enemy.y + size / 2) - bullet.y

        local height, width = love.graphics.getDimensions()
        local x = bullet.x
        local y = bullet.y

        local offset = size / 2
        if (diffX < offset and diffX > -offset) and (diffY < offset and diffY > -offset) then
            table.insert(self.hitBullets, bullet)
            table.remove(self.activeBullets, i)
        elseif (x > width or x < 0) or (y > height or y < 0) then
            table.remove(self.activeBullets, i)
        end
    end
end

-- TODO: this should probably be changed
function Tower:onTargetChange(event)
    self.object = event:getData()
end

function Tower:barrelRotation()
    if self.object == nil then
        return self.rotation
    end

    if not self:withinRange() then
        return self.rotation
    end

    local size = self.object:getSize()
    local position = self.object:getPosition()
    local x = position.x + size / 2
    local y = position.y + size / 2
    local radians = math.atan2(self.scaled.y - y, self.scaled.x - x)
    if radians < 0 then
        radians = radians + (2 * math.pi)
    end

    local diff = self.rotation - radians
    if math.abs(diff) < 0.02 then
        self.turning = false
    elseif diff < 0 then
        self.turning = true
        self.rotation = self.rotation + (0.01 * self.rotationSpeed)
    else
        self.turning = true
        self.rotation = self.rotation + (-0.01 * self.rotationSpeed)
    end

    return self.rotation
end

function Tower:withinRange()
    local position = self.object:getPosition()
    local size = self.object:getSize()
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

    -- https://stackoverflow.com/a/16756618
    local enemy = self.object:getPosition()
    local size = self.object:getSize()
    local diffX = (enemy.x + size / 2) - bullet.x
    local diffY = (enemy.y + size / 2) - bullet.y
    local mag = math.sqrt(diffX * diffX + diffY * diffY)

    bullet.velocity.x = (diffX / mag) * bullet.speed
    bullet.velocity.y = (diffY / mag) * bullet.speed

    table.insert(self.activeBullets, bullet)
end

return Tower
