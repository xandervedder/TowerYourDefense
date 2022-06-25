--[[
    Basic implementation of the Queue in Lua.
]]--

---@class Queue
local Queue = {}
Queue.__index = Queue

setmetatable(Queue, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init()
        return self
    end
})

function Queue:init()
    ---@type table<T>
    self.data = {}
    ---@type number
    self.first = 1
    -- Last starts at 0 for a reason. When adding the first item and then popping said item
    -- first and last would point to the same thing.
    ---@type number
    self.last = 0
end

---Pushes into the queue whilst ensuring that the item
---being pushed is inserted in the last position.
---@param data any
function Queue:push(data)
    self.last = self.last + 1
    self.data[self.last] = data
end

---Pops the first item off the queue and returns it.
---@return T
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

return Queue
