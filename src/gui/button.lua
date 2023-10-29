local defineClass = require("src.common.objects.define-class")

local Element = require("src.gui.element")

---@class Button : Element
local Button = defineClass(Element)

function Button:init(o)
    Element.init(self, o)

    self.method = o.method
    self.text = o.text or ""
    self.mouseWithinBounds = false
    local x, _ = love.graphics.getDimensions()
    self.style.position.x = (x / 2) - (self.style.size.w / 2)
end

function Button:draw()
    Element.setColor(self)

    -- TODO: dependants should be using this
    love.graphics.rectangle(
        "fill",
        self.style.position.x,
        self.style.position.y,
        self.style.size.w,
        self.style.size.h
    )

    local text = love.graphics.newText(love.graphics.newFont(24), self.text)
    love.graphics.setColor(0, 0, 0)
    love.graphics.draw(
        text,
        self.style.position.x + (self.style.size.w / 2) - (text:getWidth() / 2),
        self.style.position.y + (self.style.size.h / 2) - 12
    )
end

function Button:mousePressed()
    local x, y = love.mouse.getPosition()
    if x < self.style.position.x then return end
    if y < self.style.position.y then return end

    if (x == self.style.position.x or x < self.style.position.x + self.style.size.w) and
       (y == self.style.position.y or y < self.style.position.y + self.style.size.h)
    then
        self.mouseWithinBounds = true
    else
        self.mouseWithinBounds = false
    end
end

function Button:mouseReleased()
    if self.mouseWithinBounds and self.method then
        self.method()
    end
end

return Button
