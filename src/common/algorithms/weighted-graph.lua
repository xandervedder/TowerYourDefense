local defineClass = require("src.common.objects.define-class")
local Point = require("src.common.objects.point")

--[[
    Implementation of a weighted graph in lua.
]]--

---@class WeightedGraph
local WeightedGraph = defineClass()

---Constructor
---@param width number
---@param height number
---@param obstacles? Point[]
function WeightedGraph:init(width, height, obstacles)
    self.width = width
    self.height = height
    self.obstacles = obstacles or {}
end

---Checks if the point given is within the bounds of the graph.
---@param point Point
function WeightedGraph:inBounds(point)
    local x = point.x
    local y = point.y

    return 0 <= x and 0 <= y and self.width >= x and self.height >= y
end

---Method that checks whether or not a `point` is obstructed by an obstacle.
---@param point Point
function WeightedGraph:obstructed(point)
    if #self.obstacles == 0 then return false end

    for _, value in pairs(self.obstacles) do
        if point == value then
            return true
        end
    end

    return false
end

---Retrieves the neighbours of the given location
---@param point Point
---@return table<Point>
function WeightedGraph:neighbours(point)
    local x = point.x
    local y = point.y
    ---@type table<Point>
    local neighbours = {}

    if (x + y) % 2 == 0 then
        neighbours = {
            Point(x, y + 1),
            Point(x, y - 1),
            Point(x - 1, y),
            Point(x + 1, y),
        }
    else
        neighbours = {
            Point(x + 1, y),
            Point(x - 1, y),
            Point(x, y - 1),
            Point(x, y + 1),
        }
    end

    for i = #neighbours, 1, -1 do
        if not self:inBounds(neighbours[i]) or self:obstructed(neighbours[i]) then
            table.remove(neighbours, i)
        end
    end

    return neighbours
end

---Returns how much it will cost to move from one location to the other.
---Note: In this case we don't do anything special with the cost yet, but it could be used for future functionality.
---Note: This could also use weights we previously defined in the constructor.
---@param from Point
---@param to Point
---@return integer
function WeightedGraph:cost(from, to)
    return 1
end

return WeightedGraph
