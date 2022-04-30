local Constants = require("src.game.constants")
local Util = require("src.game.util.util")

-- TODO: Use actual type
---@class Position
---@field x number
---@field y number

---@class PlacementTool
local PlacementTool = {}
PlacementTool.__index = PlacementTool
PlacementTool.RIGHT_MOUSE_BUTTON = 2

setmetatable(PlacementTool, {
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function PlacementTool:init(o)
    ---@type Camera
    self.camera = o.camera
    ---@type boolean
    self.enabled = false
    ---@type GameObject
    self.gameObject = o.object({})
    ---@type GameObject[]
    self.gameObjectPool = o.pool
    ---@type GameObject
    self.gameObjectRef = o.object
    ---@type boolean
    self.obstructed = false
    ---@type Position
    self.mouse = { x = 0, y = 0 }
    ---@type Position
    self.untranslated = { x = 0, y = 0 }

    --[[
        Lambda initializations, used to customize the logic
        of the tool from outside.
    ]]
    ---Lambda that runs when the click has executed.
    ---@type function
    self.clickedLambda = o.clicked
    ---Lambda that runs when the right click has executed.
    ---@type function
    self.rightClickedLambda = o.rightClick
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

    local grid = Util.positionFromXY(self.mouse.x, self.mouse.y).position
    local images = self.gameObject:toImage()
    for i = 1, #images, 1 do
        images[i]:setFilter("nearest", "nearest")
        love.graphics.draw(images[i], grid.x, grid.y, 0, Constants.scale, Constants.scale)
    end
end

---Update method of the tool.
function PlacementTool:update(_)
    if not self.enabled then return end

    for _, value in pairs(self.gameObjectPool) do
        local position = value:getPosition()
        local objectGrid = Util.positionFromXY(position.x, position.y).position
        local grid = Util.positionFromXY(self.mouse.x, self.mouse.y).position
        if grid.x == objectGrid.x and grid.y == objectGrid.y or self.obstructionLambda() then
            self.obstructed = true
            break;
        else
            self.obstructed = false
        end
    end

    local x = self.untranslated.x
    local y = self.untranslated.y
    self:updatePosition(x, y)
end

---Updates the position of mouse based on where it is in the grid.
---@param x number
---@param y number
function PlacementTool:updatePosition(x, y)
    local camera = self.camera:getPosition()

    self.mouse = {
        x = math.abs(x - camera.x),
        y = math.abs(y - camera.y),
    }

    self.untranslated = { x = x, y = y, }
end

---Function that is called when the mouse has been moved.
---@param x number
---@param y number
function PlacementTool:mouseMoved(x, y, _, _, _)
    self:updatePosition(x, y)
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
    local object = self.gameObjectRef(Util.positionFromXY(self.mouse.x, self.mouse.y))
    self.objectCreatedLambda(object)
    table.insert(self.gameObjectPool, object)

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
