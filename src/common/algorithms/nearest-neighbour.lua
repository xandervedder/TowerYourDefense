local Point = require("src.common.objects.point")

--[[
    Very simplified version of the nearest neighbour algorithm that will work
    for my use cases.
]]

---@class NearestNeighbour
local NearestNeighbour = {}
NearestNeighbour.__index = NearestNeighbour

setmetatable(NearestNeighbour, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---Constructor.
---@param points Point[]
function NearestNeighbour:init(points)
    ---@type Point[]
    self.points = points
end

---Retrieves the nearest neighbour.
---@param startPoint Point
---@return Point
function NearestNeighbour:get(startPoint)
    local start = self:toPower(startPoint)

    local nearestPoint = nil
    local nearestValue = nil
    for _, point in pairs(self.points) do
        if nearestPoint == nil then
            nearestPoint = point
            nearestValue = self:distance(start, point)
            goto continue
        end

        local poweredSum = self:distance(start, point)
        if poweredSum < nearestValue then
            nearestPoint = point
            nearestValue = poweredSum
        end

        ::continue::
    end

    return nearestPoint
end

---Returns the sum of the points' x and y to the power of 2.
---@param point Point
---@return number
function NearestNeighbour:toPower(point)
    return math.pow(point.x, 2) + math.pow(point.y, 2)
end

---Calculates the final distance between the startpoint and the endpoint.
---@param start number
---@param point Point
---@return number
function NearestNeighbour:distance(start, point)
    return math.abs(start - self:toPower(point))
end

return NearestNeighbour
