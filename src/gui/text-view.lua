local defineClass = require("src.common.objects.define-class")

local Element = require("src.gui.element")

---@class TextView : Element
local TextView = defineClass(Element)

function TextView:init(o)
    Element.init(self, o)

    self.text = o.text or ""
    ---@private
    self.font = love.graphics.newFont(o.fontSize or 20)
    self.font:setFilter("nearest", "nearest")
end

function TextView:draw()
    Element.draw(self)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.setFont(self.font)
    love.graphics.print(
        self.text,
        self.style.position.x + self.style.margin.l + self.style.padding.l,
        self.style.position.y + self.style.margin.t + self.style.padding.t
    )
end

return TextView
