local Camera = require("src.engine.camera.camera")
local Scene = require("src.engine.scene.scene")
local Player = require("src.engine.object.player")

World = Scene:new({
    name = "World Scene",
    tiles = 128,
    tileSize = { width = 16, height = 16 },
})

function World:initialize()
    self.player = Player:new()
    self.camera = Camera:new({ screen = { love.graphics.getDimensions() } })
    self.camera:followObject(self.player)
end

function World:update(dt)
    self.camera:update(dt)
    self.player:update(dt)
end

function World:draw()
    self.camera:draw()
    -- TODO: for now this will be drawn on the default layer, but we want
    -- TODO: to change this to a different rendering screen/canvas.
    for i = 1, self.tiles do
        for j = 1, self.tiles do
            love.graphics.setColor(self:getColor(i, j))

            local xIndex = i - 1
            local yIndex = j - 1
            local tile = self.tileSize
            love.graphics.rectangle("fill", xIndex * tile.width, yIndex * tile.height, tile.width, tile.height)
        end
    end

    self.player:draw()
end

function World:getColor(xIndex, yIndex)
    local color = (xIndex * yIndex) / (self.tiles * self.tiles)
    return color, color, color, 1
end

function World:keyPressed(key)
    self.player:keyPressed(key)
end

function World:keyReleased(key)
    self.player:keyReleased(key)
end

return World
