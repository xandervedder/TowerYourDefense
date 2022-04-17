local Element = require("src.gui.element")

---@class Image : Element
local Image = {}
Image.__index = Image

setmetatable(Image, {
    __index = Element,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Image:init(o)
    Element.init(self, o)

    ---@type love.Image[]
    self.images = o.images
end

function Image:draw()
    for _, image in ipairs(self.images) do
        image:setFilter("nearest", "nearest")
        local w, h = image:getDimensions()
        local scaleX = self.style.size.w / w
        local scaleY = self.style.size.h / h

        love.graphics.setColor(1, 1, 1)
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
