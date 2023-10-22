local Constants = require("src.game.constants")
local Event = require("src.game.event.event")
local Publisher = require("src.game.event.publisher")
local SpriteLoader = require("src.game.graphics.loader.sprite-loader")
local Damageable = require("src.game.objects.damageable")

---@class Base : Damageable
local Base = {}
Base.__index = Base

setmetatable(Base, {
    __index = Damageable,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---Constructor of Base.
function Base:init(o)
    Damageable.init(self, o, 1000)

    ---@private
    ---@type Sprite
    self.sprite = SpriteLoader.getSprite("base")
    ---@private
    ---@type Point
    self.center = self:getMiddle()

    ---@type string
    self.type = "Base"
end

---Draw method of Base.
function Base:draw()
    Damageable.draw(self)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.sprite.image,
        self.sprite.quads[1],
        self.center.x,
        self.center.y,
        0,
        Constants.scale,
        Constants.scale,
        -- Origin points will be in the center of the image:
        Constants.tile.w / 2,
        Constants.tile.h / 2
    )
end

---Method that excutes when the base gets destroyed.
function Base:die()
    Damageable.die(self)

    Publisher.publish(Event("game.over"))
end

return Base
