local defineClass = require("src.common.objects.define-class")

--[[
    Property that is meant to be used for sizes.
]]
---@class Size
local Size = defineClass()

function Size:init(w, h)
    ---@type number
    self.w = w or 0
    ---@type number
    self.h = h or 0
end

return Size
