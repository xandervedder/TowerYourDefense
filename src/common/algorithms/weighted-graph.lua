local Location = require("src.common.location")

--[[
    Implementation of a weighted graph in lua.
]]--

---@class WeightedGraph
local WeightedGraph = {}
WeightedGraph.__index = WeightedGraph

setmetatable(WeightedGraph, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---Constructor
---@param width number
---@param height number
function WeightedGraph:init(width, height)
    self.width = width
    self.height = height
    ---@type table<Location>
    self.obstacles = {}
    self.weights = {}
end

---Checks if the location given is within bounds
---@param location Location
function WeightedGraph:inBounds(location)
    local x = location.x
    local y = location.y

    return 0 <= x and 0 <= y and self.width >= x and self.height >= y
end

---Method that checks whether or not a location is obstructed by an obstacle.
---@param location Location
function WeightedGraph:obstructed(location)
    if #self.obstacles == 0 then return false end

    local x = location.x
    local y = location.y

    for _, value in pairs(self.obstacles) do
        if value.x == x and value.y == y then
            return true
        end
    end

    return false
end

---Retrieves the neighbours of the given location
---@param location Location
---@return table<Location>
function WeightedGraph:neighbours(location)
    local x = location.x
    local y = location.y
    ---@type table<Location>
    local neighbours = {}

    -- TODO: This doesn't work as expected, look at this on a later date.
    if (x + y) % 2 == 0 then
        neighbours = {
            Location(x, y + 1),
            Location(x, y - 1),
            Location(x - 1, y),
            Location(x + 1, y),
        }
    else
        neighbours = {
            Location(x + 1, y),
            Location(x - 1, y),
            Location(x, y - 1),
            Location(x, y + 1),
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
---Note: in this case we don't do anything special with the cost yet, but it could be used for future functionality.
---@param from Location
---@param to Location
---@return integer
function WeightedGraph:cost(from, to)
    return 1
end

return WeightedGraph
