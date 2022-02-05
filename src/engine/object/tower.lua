local Constants = require("src.engine.constants")
local GameObject = require("src.engine.object.gameobject")
local Publisher = require("src.engine.event.publisher")

Tower = GameObject:new({ degree = 1 })
Tower.size = 16

-- For now, do it like this, but I really would like constructor overloading...
function Tower:initialize()
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
        return 0
    end

    local position = self.object:getPosition()
    -- TODO might want to rotate the images in the spritesheet, so we don't need this offset
    return math.atan2(self.scaled.y - position.y, self.scaled.x - position.x) + math.rad(-90)
end

return Tower

