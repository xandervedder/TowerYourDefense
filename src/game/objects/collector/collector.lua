local defineClass = require("src.common.objects.define-class")

local C = require("src.game.constants")
local Event = require("src.game.event.event")
local GameObject = require("src.game.objects.game-object")
local Publisher = require("src.game.event.publisher")
local SpriteLoader = require("src.game.graphics.loader.sprite-loader")

---@class Collector : GameObject
local Collector = defineClass(GameObject)

--Constructor.
function Collector:init(o)
    GameObject.init(self, o)

    ---@private
    self.sprite = SpriteLoader.getSprite("collection")

    ---@private
    self.center = {
        x = self.point.x + self.size.w / 2,
        y = self.point.y + self.size.h / 2,
    }
    ---@private
    self.rotation = 0
    ---@private
    self.collectionDelayInSeconds = 1
    ---@private
    self.collectionAmount = 1
    ---@private
    self.deltaPassed = 0
end

function Collector:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        self.sprite.image,
        self.sprite.quads[2],
        self.center.x,
        self.center.y,
        self.rotation,
        C.scale,
        C.scale,
        -- Origin points will be in the center of the image:
        C.tile.w / 2,
        C.tile.h / 2
    )

    love.graphics.draw(self.sprite.image, self.sprite.quads[1], self.point.x, self.point.y, 0, C.scale, C.scale)
end

function Collector:update(dt)
    self.rotation = self.rotation + 5 * dt

    self.deltaPassed = self.deltaPassed + dt
    if self.deltaPassed >= self.collectionDelayInSeconds then
        self.deltaPassed = 0
        Publisher.publish(Event("inventory.increase", { amount = self.collectionAmount }))
    end
end

function Collector:toImages()
    return GameObject.imagesFromQuads(self.sprite.imageData, { self.sprite.quads[1], self.sprite.quads[2] })
end

return Collector
