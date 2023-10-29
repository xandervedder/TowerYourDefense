local AStar = require("src.common.algorithms.a-star")
local NearestNeighbour = require("src.common.algorithms.nearest-neighbour")
local WeightedGraph = require("src.common.algorithms.weighted-graph")
local Queue = require("src.common.collections.queue")
local defineClass = require("src.common.objects.define-class")

--[[
    Helper class that reduces code duplication.
]]--

---@class PathHelper
local PathHelper = defineClass()

---Overload for `getPath`, but returns the result in a Queue.
---@param width number
---@param height number
---@param currentPoint Point
---@param targetPoint Point
---@param obstacles Pool
---@return Queue
function PathHelper.getPathQueue(width, height, currentPoint, targetPoint, obstacles)
    return Queue(PathHelper.getPath(width, height, currentPoint, targetPoint, obstacles))
end

---Gets the next path from the updated location.
---Checks whether the path is searchable, if not it grabs the closest neighbour and tries to go there.
---@param width number
---@param height number
---@param currentPoint Point
---@param targetPoint Point
---@param obstaclesPool Pool
---@return Point[]
function PathHelper.getPath(width, height, currentPoint, targetPoint, obstaclesPool)
    obstaclesPool:restore()
    local obstacles = obstaclesPool:get()

    ---@type NearestNeighbour
    local nearestNeighbour = NearestNeighbour(obstacles)
    local graph = WeightedGraph(width, height, obstacles)
    ---@type AStar
    local aStar = AStar(graph, currentPoint, targetPoint)
    if not aStar:isSearchable() then
        local point = nearestNeighbour:get(currentPoint)
        obstaclesPool:softDeleteBy(function(o) return o == point end)
        obstacles = obstaclesPool:get()
        graph = WeightedGraph(width, height, obstacles)
        aStar = AStar(graph, currentPoint, point)
    end

    return aStar
        :search()
        :reconstructPath()
        :get()
end

return PathHelper
