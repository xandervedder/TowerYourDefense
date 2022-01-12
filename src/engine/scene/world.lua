local Camera = require("src.engine.camera.camera")
local Constants = require("src.engine.constants")
local Map = require("src.engine.map.map")
local Player = require("src.engine.object.player")
local Scene = require("src.engine.scene.scene")
local Tower = require("src.engine.object.tower")

World = Scene:new({
    name = "World Scene",
})

function World:initialize()
    self.player = Player:new()
    self.player:setPosition({ x = 512, y = 512 })
    self.camera = Camera:new({screen = {love.graphics.getDimensions()}})
    self.camera:followObject(self.player)
    self.gameObjects = { self.player }

    for i = 1, 10, 1 do
        for j = 1, 10, 1 do
            local tower = Tower:new({
                position = {
                    y = (j - 1) * Constants.tile.scaledWidth(),
                    x = (i - 1) * Constants.tile.scaledHeight()
                },
                player = self.player
            })

            tower:initialize()
            table.insert(self.gameObjects, tower)
        end
    end

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
    self.canvas = self.canvasFromMap(self.maps[self.activeMap])
end

function World.canvasFromMap(map)
    local width = #map
    local height = #map[1]

    return love.graphics.newCanvas(
        Constants.tile.width * Constants.scale * width,
        Constants.tile.height * Constants.scale * height
    )
end

function World:update(dt)
    for i = 1, #self.gameObjects, 1 do
        self.gameObjects[i]:update(dt)
    end

    self.camera:update(dt)
end

function World:draw()
    love.graphics.setColor(1, 1, 1, 1)

    self:drawMap()

    for i = 1, #self.gameObjects, 1 do
        self.gameObjects[i]:draw()
    end

    --! Important: only draw the camera when all the other things have rendered
    self.camera:draw()
end

function World:drawMap()
    local map = self.maps[self.activeMap]
    for x = 1, #map, 1 do
        for y = 1, #map, 1 do
            local quad = self.quads[map[x][y]]
            if not quad then
                quad = self.quads.__error
            end

            love.graphics.draw(
                self.sheet,
                quad,
                -- Remove 1 from the current index, since coordinates are starting at 0
                (y - 1) * Constants.tile.scaledWidth(),
                (x - 1) * Constants.tile.scaledHeight(),
                0,
                Constants.scale,
                Constants.scale
            )
        end
    end
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

    self.canvas = self.canvasFromMap(self.maps[self.activeMap])
end

function World:keyReleased(key)
    self.player:keyReleased(key)
end

return World
