local Constants = require("src.engine.constants")
local GameObject = require("src.engine.object.gameobject")

Tower = GameObject:new({ degree = 1 })
Tower.size = 32

-- For now, do it like this, but I really would like constructor overloading...
function Tower:initialize()
    self.sheet = love.graphics.newImage("/assets/graphics/turret-spritesheet.png")
    self.sheet:setFilter("nearest", "nearest")
    self.turretBaseQuad = love.graphics.newQuad(0, 0, Tower.size, Tower.size, self.sheet:getDimensions())
    self.turretBarrelQuad = love.graphics.newQuad(32, 0, Tower.size, Tower.size, self.sheet:getDimensions())
    self.scaled = {
        x = self.position.x + Constants.tile.scaledWidth() / 2,
        y = self.position.y + Constants.tile.scaledHeight() / 2,
    }
end

function Tower:draw()
    love.graphics.draw(self.sheet, self.turretBaseQuad, self.position.x, self.position.y, 0, Constants.scale, Constants.scale)

    local player = self.player:getPosition()
    love.graphics.draw(
        self.sheet,
        self.turretBarrelQuad,
        self.scaled.x,
        self.scaled.y,
        -- TODO might want to rotate the images in the spritesheet, so we don't need this offset
        math.atan2(self.scaled.y - player.y, self.scaled.x - player.x) + math.rad(-90),
        Constants.scale,
        Constants.scale,
        -- Origin points will be in the center of the image:
        Tower.size / 2,
        Tower.size / 2
    )
end

return Tower

