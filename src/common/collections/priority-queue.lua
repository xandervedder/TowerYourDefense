local defineClass = require("src.common.objects.define-class")

--[[
    Implementation of the PriorityQueue in lua.
]]--

---@class PriorityQueue
local PriorityQueue = defineClass()

function PriorityQueue:init()
    ---@generic T
    ---@private
    ---@type table<{[0]: T, [1]: number}>
    self.elements = {}
end

---Adds data to the queue and ordens it according to the priority.
---
---Note: the first number in the table is the value (which can be anything), the second one is the priority.
---@generic T
---@param data table<{[0]: T, [1]: number}>
function PriorityQueue:push(data)
    if data == nil then error("Data cannot be empty.") end
    if type(data) ~= "table" then error("Data must be of table type. Type '" .. type(data) .. "' given.") end
    if #data ~= 2 then error("Exactly 2 items must be in the table. Table contains '" .. #data .. "'.") end

    table.insert(self.elements, 1, data)
end

---Heapifies the list with data.
---@param size number
---@param index number
function PriorityQueue:heapify(size, index)
    local lowest = index
    local left = 2 * index
    local right = 2 * index + 1

    if left <= size and self.elements[index][2] > self.elements[left][2] then
        lowest = left
    end

    if right <= size and self.elements[lowest][2] > self.elements[right][2] then
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

---Helper method that starts the heapifying process.
function PriorityQueue:beginHeapify()
    for index = math.floor(#self.elements / 2), 1, -1 do
        self:heapify(#self.elements, index)
    end
end

---Returns the item that is at the front of the queue.
---@generic T
---@return T
function PriorityQueue:pop()
    -- This implementation only heapifies once an item is requested to be removed from the queue.
    self:beginHeapify()

    local last = #self.elements;
    -- Swap the first and the last items.
    self:swap(1, last)

    local item = self.elements[last]
    -- Remove the last node of the tree.
    self.elements[#self.elements] = nil

    -- Heapify the tree once more.
    self:beginHeapify()

    return item[1]
end

---Returns whether the queue is empty or not.
---@return boolean
function PriorityQueue:empty()
    return #self.elements == 0
end

---Returns the size of the queue.
---@return number
function PriorityQueue:size()
    return #self.elements
end

---Magic method that shows the internal array of the priority queue.
---@return string
function PriorityQueue:__tostring()
    local output = "["
    for index, value in pairs(self.elements) do
        output = output .. "{" .. value[1] .. ", " .. value[2] .. "}"
        if index ~= #self.elements then
            output = output .. ", "
        end
    end
    return output .. "]"
end

return PriorityQueue
