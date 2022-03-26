--[[
    Property that is meant to be used for a position.
]]
---@class Position
local Position = {}
Position.__index = Position

setmetatable(Position, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Position:init(x, y)
    ---@type number
    self.x = x or 0
    ---@type number
    self.y = y or 0
end

return Position
