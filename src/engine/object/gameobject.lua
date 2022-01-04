--[[
Base Object used for any game object in the game.
Whether it be an enemy or tower, every object inherits from GameObject.
]]--
GameObject = {}

function GameObject:new(o)
    o = o or {}
    print(o)
    setmetatable(o, self)
    self.__index = self
    return o
end

function GameObject:draw()

end

function GameObject:update()

end

return GameObject
