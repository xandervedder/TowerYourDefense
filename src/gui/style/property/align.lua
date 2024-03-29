local defineClass = require("src.common.objects.define-class")

---@class Align
local Align = defineClass()

function Align:init(t, r, b, l)
    ---@type boolean
    self.t = t or false
    ---@type boolean
    self.l = l or false
    ---@type boolean
    self.r = r or false
    ---@type boolean
    self.b = b or false

    if self.t and self.b then error("Cannot align to the top and to the bottom.") end
    if self.r and self.l then error("Cannot align to the right and to the left.") end
end

return Align
