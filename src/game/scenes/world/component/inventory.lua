local Publisher = require("src.game.event.publisher")

local Color = require("src.gui.style.property.color")
local Container = require("src.gui.layout.container")
local Side = require("src.gui.style.property.side")
local Size = require("src.gui.style.property.size")
local Style = require("src.gui.style.style")
local TextView = require("src.gui.text-view")

---@class Inventory : Container
local Inventory = {}
Inventory.__index = Inventory

setmetatable(Inventory, {
    __index = Container,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function Inventory:init()
    -- For now, we will use a single type of material,
    -- this will change in the future.
    ---@type number
    self.amount = 1000;
    ---@type string
    self.selector = "text-view"

    Container.init(self, {
        children = {
            TextView({
                id = self.selector,
                style = Style({
                    size = Size(125, 60),
                    padding = 20
                }),
                text = tostring(self.amount),
            })
        }
    })

    self.style = Style({
        color = Color(35, 35, 35, 0.9),
        size = Size(125, 60),
        margin = Side(0, 20, 0, 0),
    })

    Publisher.register(self, "inventory.increase", function(event) self:onEvent(event) end)
end

---Handles incoming events related to the inventory.
---@param event Event
function Inventory:onEvent(event)
    if event:getName() == "inventory.increase" then
        self.amount = self.amount + event:getPayload().amount
        self:updateText()
    end
end

---Updates the text on the TextView.
---@private
function Inventory:updateText()
    ---@type Element|nil
    local textView = self:querySelector(self.selector)
    ---@cast textView TextView
    textView.text = tostring(self.amount)
end

---Returns the amount of resources that have been gathered
---@return number
function Inventory:getAmount()
    return self.amount
end

---@param amount number
function Inventory:subtract(amount)
    self.amount = self.amount - amount
    self:updateText()
end

return Inventory
