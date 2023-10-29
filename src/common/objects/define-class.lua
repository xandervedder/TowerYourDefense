---Helper method that generates a class using metatables.
---
---Note: It is not possible to use generic classes yet in the type annotations.
---Note: Once it is available I will add that for better type support.
---@generic T : table
---@return T
local function defineClass(super)
    local class = {}
    class.__index = class

    setmetatable(class, {
        __index = super,
        __call = function (cls, ...)
            local self = setmetatable({}, cls)
            self:init(...)
            return self
        end
    })

    return class
end

return defineClass
