-- https://www.redblobgames.com/pathfinding/a-star/implementation.html#python-astar
-- https://www.programiz.com/dsa/priority-queue
-- https://en.wikipedia.org/wiki/Heapsort#Pseudocode

--[[
    Implementation of the PriorityQueue in lua.

    Note: currently it only supports numbers (int, float).
]]

---@class PriorityQueue
local PriorityQueue = {}
PriorityQueue.__index = PriorityQueue

setmetatable(PriorityQueue, {
    __call = function(cls)
        local self = setmetatable({}, cls)
        self:init()
        return self
    end
})

function PriorityQueue:init()
    ---@type array<array<number, T>>
    self.elements = {}
end

---Adds data to the queue and ordens it according to the priority.
---@param data number
function PriorityQueue:push(data)
    if data == nil then
        error("Data is of incompatible type: " .. tostring(data))
    end

    table.insert(self.elements, data)

    -- We only heapify if the internal array has more than one element.
    if #self.elements == 1 then return end

    for index = math.floor(#self.elements / 2), 1, -1 do
        self:heapify(#self.elements, index)
    end
end

---Heapifies the list with data.
---@param size number
---@param index number
function PriorityQueue:heapify(size, index)
    local lowest = index
    local left = 2 * index
    local right = 2 * index + 1

    if left <= size and self.elements[index] > self.elements[left] then
        lowest = left
    end

    if right <= size and self.elements[lowest] > self.elements[right] then
        lowest = right
    end

    if lowest ~= index then
        self:swap(index, lowest)
        self:heapify(size, lowest)
    end
end

---Swaps the first with the second value in the internal list.
---@param first number
---@param second number
function PriorityQueue:swap(first, second)
    self.elements[first], self.elements[second] = self.elements[second], self.elements[first]
end

function PriorityQueue:__tostring()
    local output = "["
    for index, value in pairs(self.elements) do
        output = output .. value
        if index ~= #self.elements then
            output = output .. ", "
        end
    end
    return output .. "]"
end

---Returns whether the queue is empty or not.
---@return boolean
function PriorityQueue:empty()
    return #self.elements == 0
end
