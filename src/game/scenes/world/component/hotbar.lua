local defineClass = require("src.common.objects.define-class")

local Publisher = require("src.game.event.publisher")
local PlacementTool = require("src.game.tool.placement-tool")

local Align = require("src.gui.style.property.align")
local Color = require("src.gui.style.property.color")
local Container = require("src.gui.layout.container")
local DirBool = require("src.gui.style.property.dir-bool")
local HBox = require("src.gui.layout.h-box")
local Side = require("src.gui.style.property.side")
local Size = require("src.gui.style.property.size")
local Style = require("src.gui.style.style")

---@class Hotbar : Container
local Hotbar = defineClass(Container)

function Hotbar:init(o)
    o.children = {
        HBox({
            -- Eventually, this should come from the inventory.
            -- As the inventory will have all your placeables.
            children = o.children
        })
    }

    Container.init(self, o)

    ---@type string
    self.id = "hotbar"
    ---@private
    ---@type boolean
    self.hide = false
    ---@private
    ---@type Inventory
    self.inventory = o.inventory
    ---@private
    ---@type PlacementTool
    self.tool = PlacementTool({
        camera = o.camera,
        pool = o.pool,
        object = function() end,
        shouldClick = function()
            return self.mouseEntered
        end
    })
    ---@private
    ---@type Style
    self.style = Style({
        align = Align(false, false, true),
        color = Color(35, 35, 35, 0.9),
        center = DirBool(true),
        padding = Side(10, 10, 10, 10),
        size = Size(370, 120),
    })

    self:addEventListener("click", function(_)
        ---@type HotbarItem[]
        local children = self.child.children

        ---@type HotbarItem|nil
        local activeChild = nil
        for _, child in pairs(children) do
            if child.mouseEntered and not child.constrained then
                child.active = true
                child:configureTool(self.tool, self.inventory)
                self.tool:enable()
                activeChild = child
                break
            end
        end

        for _, child in pairs(children) do
            if not (child == activeChild) then
                child.active = false
            end
        end
    end)

    Publisher.register(self, "wave.started", function() self:handleWaveStartedEvent() end)
    Publisher.register(self, "wave.ended", function() self:handleWaveEndedEvent() end)
end

---Handles the wave started event.
function Hotbar:handleWaveStartedEvent()
    self.hide = true
    self.tool:disable()

    ---@type HotbarItem[]
    local children = self.child.children
    for _, child in pairs(children) do
        child.active = false
        child.hovering = false
    end
end

---Handles the wave ended event.
function Hotbar:handleWaveEndedEvent()
    self.hide = false
end

function Hotbar:draw()
    if self.hide then return end

    Container.draw(self)
end

function Hotbar:update(dt)
    if self.hide then return end

    Container.update(self, dt)
    self.tool:update(dt)

    self:checkConstraints()
end

function Hotbar:checkConstraints()
    ---@type HotbarItem[]
    local children = self.child.children
    local amount = self.inventory:getAmount()
    for _, child in pairs(children) do
        if child.constraint > amount then
            child.constrained = true
            child.active = false
        else
            child.constrained = false
        end
    end
end

function Hotbar:mousePressed(x, y, button, touch, presses)
    if self.hide then return end

    Container.mousePressed(self, x, y, button, touch, presses)
    self.tool:mousePressed(nil, nil, button, nil, nil)
end

function Hotbar:mouseMoved(x, y, dx, dy, touch)
    if self.hide then return end

    Container.mouseMoved(self, x, y, dx, dy, touch)
end

---@return PlacementTool
function Hotbar:getTool()
    return self.tool
end

return Hotbar
