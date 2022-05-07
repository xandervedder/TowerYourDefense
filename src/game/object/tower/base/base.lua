local C = require("src.game.constants")
local GameObject = require("src.game.object.gameobject")

--[[
    Class used for the base of a Tower.

    The base of a Tower will eventually define what
    turrets can be placed on top of it. For now this
    behaviour is yet to be implemented, but in the future
    it will be.
]]
---@class Base : GameObject
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
    GameObject.setSheet(self, "/assets/graphics/tower-base-spritesheet.png")

    self.quad = love.graphics.newQuad(0, 0, C.tile.w, C.tile.h, self.sheet:getDimensions())
end

function Base:draw()
    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(
        self.sheet,
        self.quad,
        self.position.x,
        self.position.y,
        0,
        C.scale * self.scale,
        C.scale * self.scale
    )
end

function Base:getQuads()
    return { self.quad }
end

return Base
