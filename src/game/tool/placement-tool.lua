local Point = require("src.common.objects.point")

local Constants = require("src.game.constants")
local Event = require("src.game.event.event")
local Publisher = require("src.game.event.publisher")
local Util = require("src.game.util.util")

---@class PlacementTool
local PlacementTool = {}
PlacementTool.__index = PlacementTool
---@private
PlacementTool.RIGHT_MOUSE_BUTTON = 2

setmetatable(PlacementTool, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---@param o table
function PlacementTool:init(o)
    ---@private
    ---@type Camera
    self.camera = o.camera
    ---@private
    ---@type boolean
    self.enabled = false
    ---@private
    ---@type GameObject
    self.gameObject = o.object({})
    ---@private
    ---@type Pool
    self.gameObjects = o.pool
    ---@private
    ---@type GameObject
    self.gameObjectRef = o.object
    ---@private
    ---@type boolean
    self.obstructed = false
    ---@type Point
    self.mouse = Point(0, 0)

    --[[
        Lambda initializations, used to customize the logic
        of the tool from the outside.
    ]]
    ---Lambda that runs when the click has executed.
    ---@type function
    self.clickedLambda = o.clicked
    ---Lambda that runs when the right click has executed.
    ---@type function
    self.rightClickedLambda = o.rightClick or function() --[[ noop ]] end
    ---Lambda that returns whether or not the click method will run.
    ---@type function
    self.shouldClickLambda = o.shouldClick
    ---Lambda that is intended for objects that need extra initialization.
    ---@type function
    self.objectCreatedLambda = o.objectCreated
    ---@type function
    self.obstructionLambda = o.obstruction or function() return false end
end

---Drawing method of the tool.
function PlacementTool:draw()
    if not self.enabled then return end

    if self.obstructed then
        love.graphics.setColor(1, 0, 0, 0.5)
    else
        love.graphics.setColor(1, 1, 1, 0.5)
    end

    local grid = Util.fromMousePoint(self.mouse.x, self.mouse.y)
    local images = self.gameObject:toImages()
    for i = 1, #images, 1 do
        images[i]:setFilter("nearest", "nearest")
        love.graphics.draw(images[i], grid.x, grid.y, 0, Constants.scale, Constants.scale)
    end
end

---Update method of the tool.
function PlacementTool:update(_)
    if not self.enabled then return end

    self.obstructed = self:isObstructed();
    self.mouse = self.camera:mousePosition()
end

---Checks whether the tool is obstructed by something in the object pool.
---@return boolean
function PlacementTool:isObstructed()
    for _, gameObject in pairs(self.gameObjects:get()) do
        local grid = Util.fromMousePoint(self.mouse.x, self.mouse.y)
        if gameObject:isWithinObstructionRange(Util.toGridPoint(grid)) or self.obstructionLambda() then
            return true
        end
    end
    return false
end

---Function that is called when the mouse has been pressed.
---@param button number
function PlacementTool:mousePressed(_, _, button, _, _)
    if button == self.RIGHT_MOUSE_BUTTON then
        self:disable()
        self:rightClickedLambda()
        return
    end

    if not self.enabled then return end
    if self.obstructed then return end
    if self.shouldClickLambda() then return end

    ---@type GameObject
    local object = self.gameObjectRef({ point = Util.fromMousePoint(self.mouse.x, self.mouse.y) }, self.gameObjects)
    self.objectCreatedLambda(object)
    Publisher.publish(Event("objects.created", object))

    self:clickedLambda()
end

---Enables the tool.
function PlacementTool:enable()
    self.enabled = true
end

---Disables the tool.
function PlacementTool:disable()
    self.enabled = false
end

---Gets the active gameObject.
---@return GameObject
function PlacementTool:getGameObject()
    return self.gameObject
end

---Sets the game object.
---@param gameObject GameObject
function PlacementTool:setGameObject(gameObject)
    self.gameObject = gameObject
end

---Sets the reference of the Object
---@param ref GameObject
function PlacementTool:setRef(ref)
    self.gameObjectRef = ref
end

return PlacementTool
