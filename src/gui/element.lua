local Style = require("src.gui.style.style")

--[[
    Base class for all Graphical User Interface elements.
]]
---@class Element
local Element = {}
Element.__index = Element

setmetatable(Element, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Element:init(o)
    ---@type Element[]
    self.children = o.children or {}
    for _, child in pairs(self.children) do
        if child:isRoot() then
            error("Child can't be root.")
        end
    end

    ---@type boolean
    self.root = o.root or false
    ---@type Style
    self.style = o.style or Style({})
    -- TODO: is this the right place for this?
    ---@type boolean
    self.active = false

    --[[
        Callbacks.
    ]]

    ---@type function
    self.mouseEnter = o.mouseEnter or function() end
    ---@type function
    self.mouseOut = o.mouseOut or function() end
    ---@type function
    self.click = o.click or function() end
    ---@type function
    self.release = o.release or function() end
    ---@type function
    self.updateCallback = o.update or function() end
end

function Element:draw()
    love.graphics.setColor(self.style.color.r, self.style.color.g, self.style.color.b, self.style.color.a)
    love.graphics.rectangle(
        "fill",
        self.style.position.x + self.style.margin.l,
        self.style.position.y + self.style.margin.t,
        self.style.size.w,
        self.style.size.h
    )

    for _, child in pairs(self.children) do
        child:draw()
    end
end

---@param dt number
function Element:update(dt)
    self.updateCallback(self)

    for _, child in pairs(self.children) do
        child:update(dt)
    end
end

function Element:resize() end

---@param key string
function Element:keyPressed(key)
    for _, child in pairs(self.children) do
        child:mousePressed(key)
    end
end

---@param key string
function Element:keyReleased(key)
    for _, child in pairs(self.children) do
        child:mousePressed(key)
    end
end

---If registered, this method will also call the callback attached to the element.
---@param x number
---@param y number
---@param dx number
---@param dy number
---@param touch boolean
function Element:mouseMoved(x, y, dx, dy, touch)
    -- TODO: this check should go to a util top level package
    local position = self.style.position
    local size = self.style.size
    if (x > position.x and x < position.x + size.w) and (y > position.y and y < position.y + size.h) then
        self.mouseEnter(self)
    else
        self.mouseOut(self)
    end

    for _, child in pairs(self.children) do
        child:mouseMoved(x, y, dx, dy, touch)
    end
end



---If registered, this method will also call the callback attached to the element.
---@param x number
---@param y number
---@param button string
---@param touch string
---@param presses number
function Element:mousePressed(x, y, button, touch, presses)
    -- TODO: this check should go to a util top level package (common)
    local position = self.style.position
    local size = self.style.size
    if (x > position.x and x < position.x + size.w) and (y > position.y and y < position.y + size.h) then
        self.click(self)
    end

    for _, child in pairs(self.children) do
        child:mousePressed(x, y, button, touch, presses)
    end
end

function Element:mouseReleased()
    self.release(self)

    for _, child in pairs(self.children) do
        child:mouseReleased()
    end
end

function Element:mouseWheelMoved()
    for _, child in pairs(self.children) do
        child:mouseWheelMoved()
    end
end

---@param x number
---@param y number
function Element:setPosition(x, y)
    self.style.position.x = x
    self.style.position.y = y
end

---@param w number
---@param h number
function Element:setSize(w, h)
    self.style.size.w = w
    self.style.size.h = h
end

---@return Size
function Element:getSize()
    return self.style.size
end

---Sets the width of the element
---@param w number
function Element:setWidth(w)
    self.style.size.w = w
end

---Sets the height of the element
---@param h number
function Element:setHeight(h)
    self.style.size.h = h
end

---Returns whether the element is the root
---@return boolean
function Element:isRoot()
    return self.root
end

---Returns the grow property
---@return boolean
function Element:getGrow()
    return self.style.grow
end

---Returns the center property
---@return DirBool
function Element:getCenter()
    return self.style.center
end

---Returns the align property
---@return Align
function Element:getAlignment()
    return self.style.align
end

---Convenience method that sets the color according to what's in the 'color' property.
function Element:setColor()
    local color = self.style.color
    love.graphics.setColor(color.r, color.g, color.b, color.a)
end

return Element
