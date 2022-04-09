local Constants = require("src.game.constants")
local Util = require("src.game.util.util")

local PlacementTool = {}

-- Might be a little wierd, but it works and I like to keep it concise :)
local self = PlacementTool
self.active = false
self.canPlace = true
self.mouse = { x = 0, y = 0 }
self.untranslated = { x = 0, y = 0 }

function PlacementTool.initialize(pool, object, camera)
    self.objectPool = pool -- We will add objects to this once we place them
    self.ref = object
    ---@type GameObject
    self.object = object({})
    self.camera = camera
end

function PlacementTool.draw()
    if not self.active then return end

    if self.canPlace then
        love.graphics.setColor(1, 1, 1, 0.5)
    else
        love.graphics.setColor(1, 0, 0, 0.5)
    end

    local grid = Util.positionFromXY(self.mouse.x, self.mouse.y).position
    local sheets = self.object:getSheets()
    local quads = self.object:getQuads()
    for _, quad in pairs(quads) do
        for _, sheet in pairs(sheets) do
            love.graphics.draw(sheet, quad, grid.x, grid.y, 0, Constants.scale, Constants.scale)
        end
    end
end

function PlacementTool.update()
    if not PlacementTool.active then return end

    for _, value in pairs(PlacementTool.objectPool) do
        local position = value:getPosition()
        local objectGrid = Util.positionFromXY(position.x, position.y).position
        local grid = Util.positionFromXY(self.mouse.x, self.mouse.y).position
        if grid.x == objectGrid.x and grid.y == objectGrid.y then
            self.canPlace = false
            break;
        else
            self.canPlace = true
        end
    end

    local x = self.untranslated.x
    local y = self.untranslated.y
    self.updatePosition(x, y)
end

function PlacementTool.toggleActive()
    self.active = not self.active
end

function PlacementTool.mouseMoved(x, y, _, _, _)
    self.updatePosition(x, y)
end

function PlacementTool.updatePosition(x, y)
    local camera = self.camera:getPosition()

    self.mouse = {
        x = math.abs(x - camera.x),
        y = math.abs(y - camera.y),
    }
    self.untranslated = { x = x, y = y, }
end

function PlacementTool.mousePressed(_, _, _, _, _)
    if not self.active then return end
    if not self.canPlace then return end

    local placeable = self.ref(Util.positionFromXY(self.mouse.x, self.mouse.y))
    table.insert(self.objectPool, placeable)
    self.active = false
end

return PlacementTool
