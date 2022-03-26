--[[
    Property that can be used to retrieve sides of something.
]]
---@class Side
local Side = {}
Side.__index = Side

setmetatable(Side, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Side:init(o)
    ---@type number
    self.t = o.t or 0
    ---@type number
    self.r = o.r or 0
    ---@type number
    self.b = o.b or 0
    ---@type number
    self.l = o.l or 0
end

return Side
