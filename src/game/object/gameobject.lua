local Util = require("src.game.util.util")

--[[
Base Object used for any game object in the game.
Whether it be an enemy or tower, every object inherits from GameObject.
]]--
local GameObject = {}
GameObject.__index = GameObject

setmetatable(GameObject, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function GameObject:init(o)
    self.position = o.position
    self.size = o.size or Util.size()
    self.speed = o.speed or 1
end

function GameObject:prepare() end

function GameObject:draw() end

function GameObject:update(dt) end

function GameObject:fixedUpdate(dt) end

function GameObject:getPosition()
    return self.position
end

function GameObject:getMiddle()
    return {
        x = self.position.x + (self.size.w / 2),
        y = self.position.y + (self.size.h / 2)
    }
end

function GameObject:setPosition(position)
    self.position = position
end

function GameObject:getSize() return self.size end

function GameObject:getSpeed() return self.speed end

return GameObject
