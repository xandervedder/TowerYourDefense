local Element = require("src.gui.element")

-- TODO: this file could probably be merged with Element.

---@class TextView : Element
local TextView = {}
TextView.__index = TextView

setmetatable(TextView, {
    __index = Element,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function TextView:init(o)
    Element.init(self, o)

    self.text = o.text or ""
    self.font = love.graphics.newFont(20)
    self.font:setFilter("nearest", "nearest")
end

function TextView:draw()
    Element.draw(self)

    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print(
        self.text,
        self.font,
        self.style.position.x + self.style.margin.l + self.style.padding.l,
        self.style.position.y + self.style.margin.t + self.style.padding.t
    )
end

return TextView