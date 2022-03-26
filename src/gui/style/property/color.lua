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
    self.r = r or 0
    ---@type number
    self.g = g or 0
    ---@type number
    self.b = b or 0
    ---@type number
    self.a = a or 0
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
