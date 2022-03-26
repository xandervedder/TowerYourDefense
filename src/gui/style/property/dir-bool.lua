--[[
    Property that is meant to be used to assign booleans to a direction, x or y.

    ? There has to be a better name for this...
]]
---@class DirBool
local DirBool = {}
DirBool.__index = DirBool

setmetatable(DirBool, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function DirBool:init(x, y)
    ---@type number
    self.x = x or false
    ---@type number
    self.y = y or false
end

return DirBool
