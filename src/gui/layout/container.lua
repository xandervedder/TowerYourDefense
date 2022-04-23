local Element = require("src.gui.element")

---@class Container : Element
local Container = {}
Container.__index = Container

setmetatable(Container, {
    __index = Element,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Container:init(o)
    Element.init(self, o)

    local amount = #self.children
    if amount ~= 1 then
        error("Container must exactly have one child. " .. amount .. " given.")
    end

    ---@type Element
    self.child = self.children[1]
end

function Container:draw()
    local margin = self.style.margin
    love.graphics.setColor(self.style.color.r, self.style.color.g, self.style.color.b, self.style.color.a)
    love.graphics.rectangle(
        "fill",
        self.style.position.x + margin.l,
        self.style.position.y + margin.t,
        self.style.size.w,
        self.style.size.h
    )

    for _, child in pairs(self.children) do
        child:draw()
    end
end

function Container:update(dt)
    Element.update(self, dt)

    if self.root then
        self:updateRoot()
    end

    local padding = self.style.padding
    local position = self.style.position
    self.child:setPosition(position.x + padding.l, position.y + padding.t)

    local grow = self.child:getGrow()
    local center = self.child:getCenter()
    local size = self.style.size
    if grow.x then self.child:setWidth(size.w - (padding.l + padding.r)) end
    if grow.y then self.child:setHeight(size.h - (padding.t + padding.b)) end
    if center.x then self.child:setPosition((size.w - self.child.style.size.w) / 2, self.child.style.position.y) end
    if center.y then self.child:setPosition(self.child.style.position.x, (size.h - self.child.style.size.h) / 2) end

    self:handleChildAlignment()
end

---If the element is the root, we update height, width and position dependent on the window size.
function Container:updateRoot()
    local w, h = love.graphics.getDimensions()
    if self.style.grow.x then self.style.size.w = w end
    if self.style.grow.y then self.style.size.h = h end
    if self.style.center.x then self.style.position.x = (w - self.style.size.w) / 2 end
    if self.style.center.y then self.style.position.y = (h - self.style.size.h) / 2 end
end

function Container:handleChildAlignment()
    local alignment = self.child:getAlignment()
    local padding = self.style.padding
    local position = self.style.position
    local size = self.style.size

    if alignment.t then
        self.child:setPosition(self.child.style.position.x, position.y + padding.t)
    end
    if alignment.b then
        local cSize = self.child.style.size
        local parentY = position.y + size.h - padding.b
        self.child:setPosition(self.child.style.position.x, parentY - cSize.h)
    end
    if alignment.r then
        local x = position.x + size.w - self.child.style.size.w
        self.child:setPosition(x - padding.r, self.child.style.position.y)
    end
end

function Container:resize()
    self:update()
end

function Container:setPosition(x, y)
    self.style.position = { x = x, y = y }
end

function Container:setSize(w, h)
    self.style.size = { h = h, w = w }
end

return Container
