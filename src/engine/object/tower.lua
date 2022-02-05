local Constants = require("src.engine.constants")
local GameObject = require("src.engine.object.gameobject")
local Publisher = require("src.engine.event.publisher")

Tower = GameObject:new({ degree = 1 })
Tower.size = 16

-- For now, do it like this, but I really would like constructor overloading...
function Tower:initialize()
    self.range = self.range or 200 -- For now in pixels
    self.rotation = 0
    self.sheet = love.graphics.newImage("/assets/graphics/turret-spritesheet.png")
    self.sheet:setFilter("nearest", "nearest")
    self.turretBaseQuad = love.graphics.newQuad(0, 0, Tower.size, Tower.size, self.sheet:getDimensions())
    self.turretBarrelQuad = love.graphics.newQuad(16, 0, Tower.size, Tower.size, self.sheet:getDimensions())
    self.scaled = {
        x = self.position.x + Constants.tile.scaledWidth() / 2,
        y = self.position.y + Constants.tile.scaledHeight() / 2,
    }

    Publisher.register(function (event) self:onTargetChange(event) end)
end

function Tower:draw()
    love.graphics.setColor(1, 0, 0, 0.25)
    love.graphics.circle("fill", self.scaled.x, self.scaled.y, self.range)
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

function Tower:onTargetChange(event)
    if event:getName() ~= "events.enemy.follow" then return end

    self.object = event:getData()
end

function Tower:barrelRotation()
    if self.object == nil then
        return self.rotation
    end

    if not self:withinRange() then
        return self.rotation
    end

    local position = self.object:getPosition()
    -- TODO might want to rotate the images in the spritesheet, so we don't need this offset
    self.rotation = math.atan2(self.scaled.y - position.y, self.scaled.x - position.x) + math.rad(-90)
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

return Tower
