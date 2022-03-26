local Color = require("src.gui.style.property.color")
local DirBool = require("src.gui.style.property.dir-bool")
local Position = require("src.gui.style.property.position")
local Side = require("src.gui.style.property.side")
local Size = require("src.gui.style.property.size")

--[[
    Class used for styling, with defaults for everything.
]]
---@class Style
local Style = {}
Style.__index = Style

setmetatable(Style, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Style:init(o)
    ---@type SideProperty
    self.margin = {}
    ---@type SideProperty
    self.padding = {}

    local sideProperties = { margin = o.margin or 0, padding = o.padding or 0 }
    for key, property in pairs(sideProperties) do
        if type(property) == "table"  then
            self[key] = property
        else
            self[key] = Side({ t = property, r = property, b = property, l = property })
        end
    end

    ---@type Color
    self.color = o.color or Color()
    ---@type DirBool
    self.center = o.center or DirBool()
    ---@type DirBool
    self.grow = o.grow or DirBool()
    ---@type Position
    self.position = o.position or Position()
    ---@type Size
    self.size = o.size or Size()
end

---@return number
function Style:horizontalMargin()
    return self.margin.l + self.margin.r
end

---@return number
function Style:horizontalPadding()
    return self.padding.l + self.padding.r
end

---@return number
function Style:verticalMargin()
    return self.margin.t + self.margin.b
end

---@return number
function Style:verticalPadding()
    return self.padding.t + self.padding.b
end

return Style