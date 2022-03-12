--[[
    Simple data class for getting and setting side properties.
]]
---@class SideProperty
local SideProperty = {}
SideProperty.__index = SideProperty

setmetatable(SideProperty, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function SideProperty:init(o)
    ---@type number
    self.t = o.t or 0
    ---@type number
    self.r = o.r or 0
    ---@type number
    self.b = o.b or 0
    ---@type number
    self.l = o.l or 0
end

return SideProperty
