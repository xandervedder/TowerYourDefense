local defineClass = require("src.common.objects.define-class")

--[[
    Property that can be used to retrieve sides of something.
]]

---@class Side
local Side = defineClass()

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
