local Element = require("src.gui.element")
local Position = require("src.gui.style.property.position")

--[[
    Layout that aligns elements horizontally.
]]
---@class HBox : Element
local HBox = {}
HBox.__index = HBox

setmetatable(HBox, {
    __index = Element,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

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
    ---@type Position
    local nextPosition = nil

    for _, child in pairs(self.children) do
        local position = self.style.position
        local style = child.style

        if nextPosition then
            child:setPosition(nextPosition.x, nextPosition.y)

            local prevPosition = nextPosition
            nextPosition = Position(
                prevPosition.x + style.size.w + style:horizontalMargin() + style:horizontalMargin(),
                position.y
            )
        else
            child:setPosition(position.x, position.y)

            nextPosition = Position(
                position.x + style.size.w + style:horizontalMargin() + style:horizontalMargin(),
                position.y
            )
        end
    end
end

return HBox
