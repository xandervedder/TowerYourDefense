local defineClass = require("src.common.objects.define-class")

---@class Event
local Event = defineClass()

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
