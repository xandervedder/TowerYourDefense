local PriorityQueue = require("src.common.collections.priority-queue")

local Point = require("src.common.objects.point")

--[[
    A* Algorithm implementation in Lua.
]]--

---@class AStar
local AStar = {}
AStar.__index = AStar
AStar.START_CHARACTER = '['
AStar.GOAL_CHARACTER = ']'
AStar.PATH_CHARACTER = '*'
AStar.VOID_CHARACTER = '.'

setmetatable(AStar, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---Constructor
---@param graph WeightedGraph
---@param start Point
---@param goal Point
function AStar:init(graph, start, goal)
    ---@type WeightedGraph
    self.graph = graph
    ---@type Point
    self.start = start
    ---@type Point
    self.goal = goal
    ---@type table<Point>
    self.path = nil
end

---Checks if the search operation is possible.
---This prevents errors when the goal is not reachable (surrounded by obstacles)
---@return boolean
function AStar:isSearchable()
    return pcall(function() self:search():reconstructPath():get() end)
end

---Returns the most optimal path in terms of distance.
---@return AStar
function AStar:search()
    local hashStart = self:toHash(self.start)
    ---@type PriorityQueue
    local frontier = PriorityQueue()
    frontier:push({self.start, 0})

    ---@type table<Point, Point>
    local cameFrom = {}
    cameFrom[hashStart] = nil
    ---@type table<Point, number>
    local costSoFar = {}
    costSoFar[hashStart] = 0

    while not frontier:empty() do
        ---@type Point
        local current = frontier:pop()
        if current == self.goal then break end

        for _, nextPoint in pairs(self.graph:neighbours(current)) do
            local newCost = costSoFar[self:toHash(current)] + self.graph:cost(current, nextPoint)
            local nextHash = self:toHash(nextPoint)
            if not costSoFar[nextHash] or newCost < costSoFar[nextHash] then
                local priority = newCost + self:heuristic(nextPoint, self.goal)
                frontier:push({nextPoint, priority})
                costSoFar[nextHash] = newCost
                cameFrom[nextHash] = current
            end
        end
    end

    self.cameFrom = cameFrom
    return self
end

---Converts a `Point` to a 'hash'. It will not really be a hash, but we can't use the classes
---since the hash of the class will be different (even if the contents of the table are the same).
---@param point Point
function AStar:toHash(point)
    return point.x .. ',' .. point.y
end

---@param a Point
---@param b Point
function AStar:heuristic(a, b)
    return math.abs(a.x - b.x) + math.abs(a.y - b.y)
end

---Reconstructs the path from goal to start. 
---@return AStar
function AStar:reconstructPath()
    local current = self.goal
    local path = {}

    while not (current == self.start) do
        table.insert(path, current)
        current = self.cameFrom[self:toHash(current)]
    end

    table.insert(path, self.start)

    self.path = {}
    -- Reverse the list since we want to start at the 'start' not the 'goal'.
    for i = #path, 1, -1 do
        table.insert(self.path, path[i])
    end

    return self
end

---Prints the found path in the console.
function AStar:print()
    for x = 0, self.graph.height, 1 do
        local output = ""
        for y = 0, self.graph.width, 1 do
            if self.start.x == x and self.start.y == y then
                output = output .. self.START_CHARACTER
            elseif self.goal.x == x and self.goal.y == y then
                output = output .. self.GOAL_CHARACTER
            else
                output = output .. self:isPath(x, y)
            end
        end
        print(output)
    end
end

---Checks whether or not the `x` and `y` is within the path. Returns the corresponding character.
---@param x number
---@param y number
---@return string
function AStar:isPath(x, y)
    for _, point in pairs(self.path) do
        if point.x == x and point.y == y then
            return self.PATH_CHARACTER
        end
    end

    return self.VOID_CHARACTER
end

---Returns the generated path.
---@return table<Point>
function AStar:get()
    return self.path
end

return AStar
