local Element = require("src.gui.element")

--[[
    Layout that aligns elements vertically.
]]
---@class VBox : Element
local VBox = {}
VBox.__index = VBox

setmetatable(VBox, {
    __index = Element,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function VBox:init(o)
    Element.init(self, o)

    self:align()
end

function VBox:draw()
    for _, child in pairs(self.children) do
        child:draw()
    end
end

function VBox:update(dt)
    self:align()

    for _, child in pairs(self.children) do
        child:update(dt)
    end
end

function VBox:align()
    local width = self.style.size.w
    local nextPosition = nil

    for _, child in pairs(self.children) do
        child:setSize(width, child.style.size.h)

        if nextPosition then
            child:setPosition(nextPosition.x, nextPosition.y)

            local prevPosition = nextPosition
            nextPosition = {
                x = self.style.position.x,
                y = prevPosition.y + child.style.size.h + child.style:verticalMargin()
            }
        else
            child:setPosition(self.style.position.x, self.style.position.y + child.style.margin.t)
            nextPosition = {
                x = self.style.position.x,
                y = self.style.position.y + child.style.size.h + child.style:verticalMargin() + child.style.margin.t
            }
        end
    end
end

return VBox
