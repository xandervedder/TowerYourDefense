local C = require("src.game.constants")
local GameObject = require("src.game.objects.game-object")
local SpriteLoader = require("src.game.graphics.loader.sprite-loader")

--[[
    Class used for the base of a Tower.

    The base of a Tower will eventually define what
    turrets can be placed on top of it. For now this
    behaviour is yet to be implemented, but in the future
    it will be.
]]
-- TODO: rename file and object
---@class TowerBase : GameObject
local Base = {}
Base.__index = Base

setmetatable(Base, {
    __index = GameObject,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

--Constructor.
function Base:init(o)
    GameObject.init(self, o)

    ---@private
    self.sprite = SpriteLoader.getSprite("towerBase")
end

function Base:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.sprite.image,
        self.sprite.quads[1],
        self.point.x,
        self.point.y,
        0,
        C.scale * self.scale,
        C.scale * self.scale
    )
end

---@return love.Image[]
function Base:toImages()
    return GameObject.imagesFromQuads(self.sprite.imageData, { self.sprite.quads[1] })
end

return Base
