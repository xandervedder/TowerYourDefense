--[[
    Class that should be used when representing a coordinate.
]]--

---@class Point
local Point = {}
Point.__index = Point

setmetatable(Point, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---Constructor.
---@param x number
---@param y number
function Point:init(x, y)
    self.x = x
    self.y = y
end

---Equals metamethod.
---@param toCompare Point
function Point:__eq(toCompare)
    return self.x == toCompare.x and self.y == toCompare.y
end

---To string metamethod.
function Point:__tostring()
    return "{ x=" .. self.x .. ", y=" .. self.y .. " }"
end

return Point
