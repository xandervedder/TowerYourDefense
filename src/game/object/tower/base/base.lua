local C = require("src.game.constants")
local GameObject = require("src.game.object.game-object")
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

function Base:init(o)
    GameObject.init(self, o)
    self.sprite = SpriteLoader.getSprite("base")

    self.quad = love.graphics.newQuad(0, 0, C.tile.w, C.tile.h, self.sprite.image:getDimensions())
end

function Base:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.sprite.image,
        self.quad,
        self.point.x,
        self.point.y,
        0,
        C.scale * self.scale,
        C.scale * self.scale
    )
end

function Base:toImages()
    return GameObject.imagesFromQuads(self.sprite.imageData, { self.quad })
end

return Base
