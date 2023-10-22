---@class Event
local Event = {}
Event.__index = Event

setmetatable(Event, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---Constructor
---@generic T
---@param name string
---@param payload T
function Event:init(name, payload)
    self.name = name
    self.payload = payload
end

---Returns the name of the event
---@return string
function Event:getName()
    return self.name
end

---Returns the data of the event
---@return table
function Event:getPayload()
    return self.payload
end

return Event
