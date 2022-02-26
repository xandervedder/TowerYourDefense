local Base = require("src.game.object.base")
local Camera = require("src.game.camera.camera")
local Constants = require("src.game.constants")
local Event = require("src.game.event.event")
local Map = require("src.game.map.map")
local Player = require("src.game.object.player")
local Publisher = require("src.game.event.publisher")
local Scene = require("src.game.scene.scene")
local Spawner = require("src.game.object.spawner")
local Tiles = require("src.game.graphics.tiles")
local Tower = require("src.game.object.tower")
local Util = require("src.game.util.util")

local World = Scene:new({
    name = "World Scene",
})

function World:initialize()
    self.player = Player(Util.position(3, 3))
    self.camera = Camera:new({ screen = { love.graphics.getDimensions() } })
    self.camera:followObject(self.player)
    local base = Base(Util.position(3, 5))

    self.gameObjects = {
        Spawner({ position = Util.position(0, 0).position, base = base, }),
        Spawner({ position = Util.position(5, 0).position, base = base, }),
        base,
        Tower(Util.position(2, 2)),
        Tower(Util.position(2, 3)),
        Tower(Util.position(4, 2)),
        Tower(Util.position(4, 3)),
    }

    for i = 1, #self.gameObjects, 1 do
        self.gameObjects[i]:prepare()
    end

    table.insert(self.gameObjects, self.player)

    self.maps = {
        Map.read("/assets/map/main.map"),
    }
    self.activeMap = 1
    self.canvas = self.canvasFromMap(self.maps[self.activeMap])
    Publisher.publish(Event:new({ name = "events.enemy.follow", data = self.player }))
end

function World.canvasFromMap(map)
    local height = #map
    local width = #map[1]

    return love.graphics.newCanvas(
        Constants.tile.scaledWidth() * width,
        Constants.tile.scaledHeight() * height
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

    --! Important: only draw the camera when all the other objects have rendered
    self.camera:draw()
end

function World:drawMap()
    local map = self.maps[self.activeMap]
    for x = 1, #map, 1 do
        for y = 1, #map[1], 1 do
            local quad = Tiles.tile[tonumber(map[x][y])]

            love.graphics.draw(
                Tiles.spriteSheet,
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
