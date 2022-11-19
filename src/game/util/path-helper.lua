local AStar = require("src.common.algorithms.a-star")
local NearestNeighbour = require("src.common.algorithms.nearest-neighbour")
local WeightedGraph = require("src.common.algorithms.weighted-graph")
local Queue = require("src.common.collections.queue")

--[[
    Helper class that reduces code duplication.
]]--

---@class PathHelper
local PathHelper = {}
PathHelper.__index = PathHelper

setmetatable(PathHelper, {
    __call = function(cls, ...)
        return setmetatable({}, cls)
    end
})

---Overload for `getPath`, but returns the result in a Queue.
---@param width number
---@param height number
---@param currentPoint Point
---@param targetPoint Point
---@param obstaclesPool Point[]
---@return Queue
function PathHelper.getPathQueue(width, height, currentPoint, targetPoint, obstaclesPool)
    return Queue(PathHelper.getPath(width, height, currentPoint, targetPoint, obstaclesPool))
end

---Gets the next path from the updated location.
---Checks whether the path is searchable, if not it grabs the closest neighbour and tries to go there.
---@param width number
---@param height number
---@param currentPoint Point
---@param targetPoint Point
---@param obstaclesPool Point[]
---@return Point[]
function PathHelper.getPath(width, height, currentPoint, targetPoint, obstaclesPool)
    ---@type NearestNeighbour
    local nearestNeighbour = NearestNeighbour(obstaclesPool)
    local graph = WeightedGraph(width, height, obstaclesPool)
    ---@type AStar
    local aStar = AStar(graph, currentPoint, targetPoint)
    if not aStar:isSearchable() then
        local point = nearestNeighbour:get(currentPoint)
        -- TODO: This could a specific class (obstaclepool with softDelete and restore)
        -- We still want to hide from the pool temporarily (what if the path changes).
        for i = #obstaclesPool, 1, -1 do
            if obstaclesPool[i] == point then
                table.remove(obstaclesPool, i)
            end
        end

        aStar = AStar(graph, currentPoint, point)
    end

    return aStar
        :search()
        :reconstructPath()
        :get()
end

return PathHelper
