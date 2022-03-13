local Element = require("src.gui.element")

--[[
    TODO:
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

return HBox
