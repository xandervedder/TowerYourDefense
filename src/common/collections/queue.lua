--[[
    Basic implementation of the Queue in Lua.
]]--

---@class Queue
local Queue = {}
Queue.__index = Queue

setmetatable(Queue, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---Constructor.
---@param data table<any>|nil
function Queue:init(data)
    ---@type table<any>
    self.data = {}
    ---@type number
    self.first = 1
    -- Last starts at 0 for a reason. When adding the first item and then popping said item
    -- first and last would point to the same thing.
    ---@type number
    self.last = 0

    if data ~= nil then
        for _, value in pairs(data) do
            self:push(value)
        end
    end
end

---Pushes into the queue whilst ensuring that the item
---being pushed is inserted in the last position.
---@param data any
function Queue:push(data)
    self.last = self.last + 1
    self.data[self.last] = data
end

---Pops the first item off the queue and returns it.
---@return any
function Queue:pop()
    -- If the queue runs out of items, return nil; we can't do anything anymore.
    if self.first > self.last then return nil end

    -- Retrieve the first from the Queue.
    local item = self.data[self.first]
    -- 'Delete' the reference in the actual list
    self.data[self.first] = nil
    -- Increment the pointer that points to the first item.
    -- Note that we are not reording the Queue, mainly for performance reasons.
    self.first = self.first + 1

    return item
end

---Reverses the order of the queue.
function Queue:reverse()
    if self:empty() then
        error("Illegal operation: Attempted to reverse an empty queue.")
    end

    local store = {}
    while not self:empty() do
        table.insert(store, self:pop())
    end

    for i = #store, 1, -1 do
        self:push(store[i])
    end
end

---Returns whether the Queue is empty or not.
---@return boolean
function Queue:empty()
    return self.first > self.last
end

return Queue
