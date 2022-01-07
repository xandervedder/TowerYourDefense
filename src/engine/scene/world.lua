local Camera = require("src.engine.camera.camera")
local Constants = require("src.engine.constants")
local Map = require("src.engine.map.map")
local Scene = require("src.engine.scene.scene")
local Player = require("src.engine.object.player")

World = Scene:new({
    name = "World Scene",
})

function World:initialize()
    self.player = Player:new()
    self.player:setPosition({ x = 512, y = 512 })
    self.camera = Camera:new({screen = {love.graphics.getDimensions()}})
    self.camera:followObject(self.player)

    self.maps = {
        Map.read("/assets/map/main.map"),
        Map.read("/assets/map/mountain.map"),
        Map.read("/assets/map/overview.map"),
    }
    self.activeMap = 1

    self.sheet = love.graphics.newImage("/assets/graphics/tile-spritesheet.png")
    self.sheet:setFilter("nearest", "nearest")
    self.quads = {
        -- TODO: this should come from something else, maybe even in a different way...
        S = love.graphics.newQuad(0, 0, 32, 32, self.sheet:getDimensions()),
        W = love.graphics.newQuad(33, 0, 32, 32, self.sheet:getDimensions()),
        D = love.graphics.newQuad(66, 0, 32, 32, self.sheet:getDimensions()),
        __error = love.graphics.newQuad(99, 0, 32, 32, self.sheet:getDimensions())
    }
    self.canvas = self.generateCanvas(#self.maps[self.activeMap])
end

function World.generateCanvas(mapSize)
    return love.graphics.newCanvas(
        Constants.tile.height * Constants.scale * mapSize,
        Constants.tile.height * Constants.scale * mapSize
    )
end

function World:update(dt)
    self.player:update(dt)
    self.camera:update(dt)
end

function World:draw()
    love.graphics.setColor(1, 1, 1, 1)

    for i = 1, #self.maps[self.activeMap], 1 do
        for j = 1, #self.maps[self.activeMap][i], 1 do
            local quad = self.quads[self.maps[self.activeMap][i][j]]
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
    --! Important: only draw the camera when all the other things have rendered
    self.camera:draw()
end

function World:keyPressed(key)
    self.player:keyPressed(key)

    --? For debugging purposes
    if key == "l" then
        self:switchMaps()
    end
end

function World:switchMaps()
    self.activeMap = self.activeMap + 1
    if self.activeMap > #self.maps then
        self.activeMap = 1
    end

    self.canvas = self.generateCanvas(#self.maps[self.activeMap])
end

function World:keyReleased(key)
    self.player:keyReleased(key)
end

return World
