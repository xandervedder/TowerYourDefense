--[[
    Property that is meant to be used for sizes.
]]
---@class Size
local Size = {}
Size.__index = Size

setmetatable(Size, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Size:init(w, h)
    ---@type number
    self.w = w or 0
    ---@type number
    self.h = h or 0
end

return Size
