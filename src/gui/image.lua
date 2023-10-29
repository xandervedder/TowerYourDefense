local defineClass = require("src.common.objects.define-class")

local Element = require("src.gui.element")

---@class Image : Element
local Image = defineClass(Element)

function Image:init(o)
    Element.init(self, o)

    ---@private
    ---@type love.Image[]
    self.images = o.images
end

function Image:draw()
    for _, image in ipairs(self.images) do
        image:setFilter("nearest", "nearest")
        local w, h = image:getDimensions()
        local scaleX = self.style.size.w / w
        local scaleY = self.style.size.h / h

        self:setColor()
        love.graphics.draw(
            image,
            self.style.position.x,
            self.style.position.y,
            0,
            scaleX,
            scaleY
        )
    end
end

return Image
