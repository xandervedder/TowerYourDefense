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

function Side:init(t, r, b, l)
    ---@type number
    self.t = t or 0
    ---@type number
    self.r = r or 0
    ---@type number
    self.b = b or 0
    ---@type number
    self.l = l or 0
end

return Side
