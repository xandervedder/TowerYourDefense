local Camera = require("src.engine.camera.camera")
local Constants = require("src.engine.constants")
local Scene = require("src.engine.scene.scene")
local Player = require("src.engine.object.player")

World = Scene:new({
    name = "World Scene",
})

function World:initialize()
    self.player = Player:new()
    self.camera = Camera:new({screen = {love.graphics.getDimensions()}})
    self.camera:followObject(self.player)
    self.map = {
        -- TODO: move to a text file
        {"W", "W", "W", "W", "W", "W", "W", "W", "W"},
        {"W", "D", "D", "D", "D", "D", "D", "D", "W"},
        {"W", "D", "W", "W", "D", "S", "S", "D", "W"},
        {"W", "D", "W", "W", "D", "S", "S", "D", "W"},
        {"W", "D", "D", "D", "D", "S", "S", "D", "W"},
        {"W", "D", "D", "D", "D", "S", "S", "D", "W"},
        {"W", "D", "D", "D", "D", "S", "S", "D", "W"},
        {"W", "D", "D", "D", "D", "D", "D", "D", "W"},
        {"W", "W", "W", "W", "W", "W", "W", "W", "W"}
    }
    self.sheet = love.graphics.newImage("/assets/graphics/tile-spritesheet.png")
    self.sheet:setFilter("nearest", "nearest")
    self.quads = {
        -- TODO: this should come from something else, maybe even in a different way...
        S = love.graphics.newQuad(0, 0, 32, 32, self.sheet:getDimensions()),
        W = love.graphics.newQuad(33, 0, 32, 32, self.sheet:getDimensions()),
        D = love.graphics.newQuad(66, 0, 32, 32, self.sheet:getDimensions()),
        __error = love.graphics.newQuad(99, 0, 32, 32, self.sheet:getDimensions())
    }
end

function World:update(dt)
    self.camera:update(dt)
    self.player:update(dt)
end

function World:draw()
    self.camera:draw()
    -- TODO: for now this will be drawn on the default layer, but we want
    -- TODO: to change this to a different rendering screen/canvas.
    love.graphics.setColor(1, 1, 1, 1)

    for i = 1, #self.map, 1 do
        for j = 1, #self.map[i], 1 do
            local quad = self.quads[self.map[i][j]]
            if not quad then
                quad = self.quads.__error
            end

            local xIndex = i - 1
            local yIndex = j - 1
            love.graphics.draw(
                self.sheet,
                quad,
                xIndex * Constants.tile.width * Constants.scale,
                yIndex * Constants.tile.height * Constants.scale,
                0,
                Constants.scale,
                Constants.scale
            )
        end
    end

    self.player:draw()
end

function World:keyPressed(key)
    self.player:keyPressed(key)
end

function World:keyReleased(key)
    self.player:keyReleased(key)
end

return World
