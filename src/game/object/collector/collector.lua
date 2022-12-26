local C = require("src.game.constants")
local Event = require("src.game.event.event")
local GameObject = require("src.game.object.game-object")
local Publisher = require("src.game.event.publisher")
local SpriteLoader = require("src.game.graphics.loader.sprite-loader")

---@class Collector : GameObject
local Collector = {}
Collector.__index = Collector

setmetatable(Collector, {
    __index = GameObject,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Collector:init(o)
    GameObject.init(self, o)

    self.sprite = SpriteLoader.getSprite("collection")
    self.structureQuad = love.graphics.newQuad(0, 0, C.tile.w, C.tile.h, self.sprite.image:getDimensions())
    self.drillQuad = love.graphics.newQuad(C.tile.w, 0, C.tile.w, C.tile.h, self.sprite.image:getDimensions())

    self.center = {
        x = self.point.x + self.size.w / 2,
        y = self.point.y + self.size.h / 2,
    }
    self.rotation = 0
    self.collectionDelayInSeconds = 1
    self.collectionAmount = 1
    self.deltaPassed = 0
end

function Collector:draw()
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.draw(
        self.sprite.image,
        self.drillQuad,
        self.center.x,
        self.center.y,
        self.rotation,
        C.scale,
        C.scale,
        -- Origin points will be in the center of the image:
        C.tile.w / 2,
        C.tile.h / 2
    )

    love.graphics.draw(self.sprite.image, self.structureQuad, self.point.x, self.point.y, 0, C.scale, C.scale)
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
    return GameObject.imagesFromQuads(self.sprite.imageData, { self.structureQuad, self.drillQuad })
end

return Collector
