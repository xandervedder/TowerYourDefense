local defineClass = require("src.common.objects.define-class")

--[[
    Very simplified version of the nearest neighbour algorithm that will work
    for my use cases.
]]

---@class NearestNeighbour
local NearestNeighbour = defineClass()

---Constructor.
---@param points Point[]
function NearestNeighbour:init(points)
    ---@private
    ---@type Point[]
    self.points = points
end

---Retrieves the nearest neighbour.
---@param startPoint Point
---@return Point
function NearestNeighbour:get(startPoint)
    local nearestPoint = nil
    local nearestValue = nil
    for _, point in pairs(self.points) do
        if nearestPoint == nil then
            nearestPoint = point
            nearestValue = self:distance(startPoint, point)
            goto continue
        end

        local poweredSum = self:distance(startPoint, point)
        if poweredSum < nearestValue then
            nearestPoint = point
            nearestValue = poweredSum
        end

        ::continue::
    end

    return nearestPoint
end

---Calculates the final distance between the startpoint and the endpoint.
---@param start Point
---@param point Point
---@return number
function NearestNeighbour:distance(start, point)
    return math.sqrt(math.pow(point.x - start.x, 2) + math.pow(point.y - start.y, 2))
end

return NearestNeighbour
