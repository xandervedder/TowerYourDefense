--[[
    Property that is meant to be used for colors.
]]
---@class Color
local Color = {}
Color.__index = Color

setmetatable(Color, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Color:init(r, g, b, a)
    ---@type number
    self.r = self:_getColor(r or 0)
    ---@type number
    self.g = self:_getColor(g or 0)
    ---@type number
    self.b = self:_getColor(b or 0)
    ---@type number
    self.a = a or 0
end

---Converts the normal rgb range (0-255) and converts it to a value that LÖVE can use.
---@param value number
function Color:_getColor(value)
    return value / 255
end

---Returns a tuple of all color values (rgba)
---@return number
---@return number
---@return number
---@return number
function Color:get()
    return self.r, self.g, self.b, self.a
end

return Color
