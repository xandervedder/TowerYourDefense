local SideProperty = require("src.gui.style.side-property")

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
            self[key] = SideProperty({ t = property, r = property, b = property, l = property })
        end
    end

    self.color = o.color or { r = 1, g = 1, b = 1, a = 1, }
    self.center = o.center or { x = false, y = false }
    self.grow = o.grow or { x = false, y = false }
    self.position = o.position or { x = 0, y = 0 }
    self.size = o.size or { w = 0, h = 0 }
end

return Style
