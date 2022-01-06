--[[
Base Object used for any game object in the game.
Whether it be an enemy or tower, every object inherits from GameObject.
]]--
GameObject = {}

function GameObject:new(o)
    o = o or {}
    setmetatable(o, self)
    self.__index = self
    self.position = o.position or { x = 0, y = 0 }
    self.size = o.size or 0
    return o
end

function GameObject:draw() end

function GameObject:update(dt) end

function GameObject:getPosition()
    return self.position
end

function GameObject:getSize()
    return self.size
end

return GameObject
