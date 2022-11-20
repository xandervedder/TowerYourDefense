local Publisher = require("src.game.event.publisher")
local Scene = require("src.game.scene.scene")

local Align = require("src.gui.style.property.align")
local Color = require("src.gui.style.property.color")
local Container = require("src.gui.layout.container")
local DirBool = require("src.gui.style.property.dir-bool")
local Side = require("src.gui.style.property.side")
local Size = require("src.gui.style.property.size")
local Style = require("src.gui.style.style")
local TextView = require("src.gui.text-view")

---@class Inventory : Scene
local Inventory = {}
Inventory.__index = Inventory

setmetatable(Inventory, {
    __index = Scene,
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
    ---@type Element
    self.element = Container({
        style = Style({
            grow = DirBool(true, false),
            padding = Side(20, 20, 20, 20),
            size = Size(0, 100),
        }),
        root = true,
        children = {
            TextView({
                id = self.selector,
                style = Style({
                    align = Align(false, true, false, false),
                    color = Color(35, 35, 35, 1),
                    grow = DirBool(false, true),
                    size = Size(100, 0),
                    padding = Side(20, 20, 20, 20)
                }),
                text = tostring(self.amount),
            })
        }
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
    local textView = self.element:querySelector(self.selector)
    ---@cast textView TextView
    textView.text = tostring(self.amount)
end

function Inventory:draw()
    self.element:draw()
end

function Inventory:update(dt)
    self.element:update(dt)
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
