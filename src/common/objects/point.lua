local defineClass = require("src.common.objects.define-class")

--[[
    Class that should be used when representing a coordinate.
]]--

---@class Point
local Point = defineClass()

---Constructor.
---@param x number
---@param y number
function Point:init(x, y)
    self.x = x
    self.y = y
end

---Add metamethod.
---@param otherPoint Point
---@return Point
function Point:__add(otherPoint)
    return Point(self.x + otherPoint.x, self.y + otherPoint.y)
end

---Subtract metamethod.
---@param otherPoint Point
---@return Point
function Point:__sub(otherPoint)
    return Point(self.x - otherPoint.x, self.y - otherPoint.y)
end

---Concatenation metamethod.
---@param str string
---@return string
function Point:__concat(str)
    return tostring(self) .. str
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
