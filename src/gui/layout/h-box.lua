local defineClass = require("src.common.objects.define-class")
local Point = require("src.common.objects.point")

local Element = require("src.gui.element")

--[[
    Layout that aligns elements horizontally.
]]
---@class HBox : Element
local HBox = defineClass(Element)

function HBox:init(o)
    Element.init(self, o)

    self:align()
end

function HBox:draw()
    for _, child in pairs(self.children) do
        child:draw()
    end
end

function HBox:update(dt)
    self:align()

    for _, child in pairs(self.children) do
        child:update(dt)
    end
end

function HBox:align()
    ---@type Point
    local nextPosition = nil

    for _, child in pairs(self.children) do
        local position = self.style.position
        local style = child.style

        if nextPosition then
            child:setPosition(nextPosition.x, nextPosition.y)

            local prevPosition = nextPosition
            nextPosition = Point(
                prevPosition.x + style.size.w + style:horizontalMargin(),
                position.y
            )
        else
            child:setPosition(position.x, position.y)

            nextPosition = Point(
                position.x + style.size.w + style:horizontalMargin(),
                position.y
            )
        end
    end
end

return HBox
