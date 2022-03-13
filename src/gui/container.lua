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

    --? limit to one element?
    for _, child in pairs(self.children) do
        child:setPosition(self.style.position.x, self.style.position.y)
        child:setParent(self)
    end
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
    self:updateSelf()

    for _, child in pairs(self.children) do
        child:update(dt)
    end
end

function Container:updateSelf()
    if self.parent == nil then
        local width, height = love.graphics.getDimensions()
        if self.style.center.x then self:updateCenterX(width) end
        if self.style.center.y then self:updateCenterY(height) end
        if self.style.grow.x then self:growX(width) end
        if self.style.grow.y then self:growY(height) end
    else
        local parent = self.parent.style

        if self.style.center.x then
            self:updateCenterX(parent.size.w, parent.position.x)
        else
            self.style.position.x = parent.position.x + parent.margin.l + parent.padding.l
        end

        if self.style.center.y then
            self:updateCenterY(parent.size.h, parent.position.y)
        else
           self.style.position.y = parent.position.y + parent.margin.t + parent.padding.t
        end

        if self.style.grow.x then self:growX(parent.size.w, parent.padding.r + parent.padding.l) end
        if self.style.grow.y then self:growY(parent.size.h, parent.padding.t + parent.padding.b) end
    end
end

function Container:updateCenterX(width, parentWidth)
    parentWidth = parentWidth or 0
    self.style.position.x = parentWidth + (width - self.style.size.w) / 2
end

function Container:updateCenterY(height, parentHeight)
    parentHeight = parentHeight or 0
    self.style.position.y = parentHeight + (height - self.style.size.h) / 2
end

function Container:growX(width, parentPadding)
    parentPadding = parentPadding or 0
    self.style.size.w = width - (self.style.margin.r + self.style.margin.l + parentPadding)
end

function Container:growY(height, parentPadding)
    parentPadding = parentPadding or 0
    self.style.size.h = height - (self.style.margin.t + self.style.margin.b + parentPadding)
end

function Container:resize()
    self:updateSelf()
end

function Container:setParent(ref)
    self.parent = ref
end

function Container:setPosition(x, y)
    self.style.position = { x = x, y = y }
end

function Container:setSize(w, h)
    self.style.size = { h = h, w = w }
end

return Container
