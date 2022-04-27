local Base = require("src.game.object.base")
local Camera = require("src.game.camera.camera")
local Collector = require("src.game.object.collector.collector")
local Constants = require("src.game.constants")
local DoubleBarrelTurret = require("src.game.object.tower.turret.double-barrel-turret")
local Map = require("src.game.map.map")
local Player = require("src.game.object.player")
local PlacementTool = require("src.game.tool.placement-tool")
local Scene = require("src.game.scene.scene")
local SingleBarrelTurret = require("src.game.object.tower.turret.single-barrel-turret")
local Tiles = require("src.game.graphics.tiles")
local Tower = require("src.game.object.tower.tower")
local TripleBarrelTurret = require("src.game.object.tower.turret.triple-barrel-turret")
local Util = require("src.game.util.util")

local Hotbar = require("src.game.scene.world.component.hotbar")
local HotbarItem = require("src.game.scene.world.component.hotbar-item")
local Inventory = require("src.game.scene.world.component.inventory")

local Align = require("src.gui.style.property.align")
local Color = require("src.gui.style.property.color")
local Container = require("src.gui.layout.container")
local DirBool = require("src.gui.style.property.dir-bool")
local HBox = require("src.gui.layout.h-box")
local Image = require("src.gui.image")
local Side = require("src.gui.style.property.side")
local Size = require("src.gui.style.property.size")
local Style = require("src.gui.style.style")

---@class World : Scene
local World = {}
World.__index = World

setmetatable(World, {
    __index = Scene,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

function World:init()
    Scene.init(self, { name = "World Scene" })

    ---@type Inventory
    self.inventory = Inventory()
    self.player = Player(Util.position(3, 3))
    self.camera = Camera:new({ screen = { love.graphics.getDimensions() } })
    self.camera:followObject(self.player)
    self:initUI()

    local base = Base(Util.position(3, 5))
    self.gameObjects = {
        Collector({ position = Util.position(4, 2).position, base = base, }),
        Collector({ position = Util.position(4, 1).position, base = base, }),
        base,
    }

    table.insert(self.gameObjects, self.player)

    self.maps = {
        Map.read("/assets/map/main.map"),
    }
    self.activeMap = 1
    self.canvas = self.canvasFromMap(self.maps[self.activeMap])

    self.placementTool = PlacementTool
    self.placementTool.initialize(self.gameObjects, Tower, self.camera)
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

    PlacementTool.update()
    self.camera:update(dt)
    self.ui:update(dt)
    self.inventory:update(dt)
end

function World:fixedUpdate(dt)
    for i = 1, #self.gameObjects, 1 do
        self.gameObjects[i]:fixedUpdate(dt)
    end
end

function World:draw()
    love.graphics.push()

    self.canvas:renderTo(function ()
        love.graphics.setColor(1, 1, 1)

        self:drawMap()
        for i = 1, #self.gameObjects, 1 do
            self.gameObjects[i]:draw()
        end

        PlacementTool.draw()

        --! Important: only draw the camera when all the other objects have rendered
        self.camera:draw()
    end)

    love.graphics.setColor(1, 1, 1)
    love.graphics.draw(self.canvas)
    love.graphics.pop()

    -- UI should be drawn ontop of canvas
    self.ui:draw()
    self.inventory:draw()
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

function World:mouseMoved(x, y, dx, dy, touch)
    PlacementTool.mouseMoved(x, y, dx, dy, touch)
    self.ui:mouseMoved(x, y, dx, dy, touch)
end

function World:mousePressed(x, y, button, touch, presses)
    PlacementTool.mousePressed(x, y, button, touch, presses)
    self.ui:mousePressed(x, y, button, touch, presses)
end

function World:initUI()
    ---@type Tower[]
    local towers = {
        Tower({ turret = SingleBarrelTurret({}), }),
        Tower({ turret = DoubleBarrelTurret({}), }),
        Tower({ turret = TripleBarrelTurret({}), }),
    }

    ---@type Element
    self.ui = Container({
        root = true,
        style = Style({
            color = Color(0, 0, 0, 0),
            padding = Side(20, 20, 20, 20),
            grow = DirBool(true, true),
        }),
        children = {
            Hotbar({
                tool = PlacementTool,
                inventory = self.inventory,
                children = {
                    HotbarItem({
                        constraint = 1,
                        turretType = SingleBarrelTurret,
                        images = towers[1]:toImage()
                    }),
                    HotbarItem({
                        constraint = 5,
                        turretType = DoubleBarrelTurret,
                        images = towers[2]:toImage()
                    }),
                    HotbarItem({
                        constraint = 10,
                        turretType = TripleBarrelTurret,
                        images = towers[3]:toImage()
                    }),
                }
            })
        }
    })
end

return World