local Point = require("src.common.objects.point")

local Base = require("src.game.object.base")
local Camera = require("src.game.camera.camera")
local Collector = require("src.game.object.collector.collector")
local DoubleBarrelTurret = require("src.game.object.tower.turret.double-barrel-turret")
local MapRenderer = require("src.game.graphics.map.map-renderer")
local MegaTowerTool = require("src.game.tool.mega-tower-tool")
local Player = require("src.game.object.player")
local Scene = require("src.game.scene.scene")
local SingleBarrelTurret = require("src.game.object.tower.turret.single-barrel-turret")
local Tower = require("src.game.object.tower.tower")
local TripleBarrelTurret = require("src.game.object.tower.turret.triple-barrel-turret")
local Util = require("src.game.util.util")
local Spawner = require("src.game.object.spawner")

local CollectorHotbarItem = require("src.game.scene.world.component.hotbar-item.collector-hotbar-item")
local Hotbar = require("src.game.scene.world.component.hotbar")
local TowerHotbarItem = require("src.game.scene.world.component.hotbar-item.tower-hotbar-item")
local Inventory = require("src.game.scene.world.component.inventory")

local Color = require("src.gui.style.property.color")
local Container = require("src.gui.layout.container")
local DirBool = require("src.gui.style.property.dir-bool")
local Side = require("src.gui.style.property.side")
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

    ---@type MapRenderer
    self.mapRenderer = MapRenderer()

    ---@type Inventory
    self.inventory = Inventory()
    self.player = Player({ point = Util.fromCoordinate(3, 3) })
    self.camera = Camera:new({ screen = { love.graphics.getDimensions() } })
    self.camera:followObject(self.player)

    local base = Base({ point = Util.fromCoordinate(2, 3) })
    self.spawner = Spawner({ point = Util.fromCoordinate(4, 0) }, base, self.mapRenderer:getGridSize())
    self.gameObjects = {
        base,
        self.spawner,
        Collector({ point = Util.fromCoordinate(4, 1), }),
    }
    table.insert(self.gameObjects, self.player)

    local mapSize = self.mapRenderer:getDimensions();
    self.canvas = love.graphics.newCanvas(mapSize.w, mapSize.h)
    ---@type MegaTowerTool
    self.megaTowerTool = MegaTowerTool({ camera = self.camera, pool = self.gameObjects })

    self:initUI()
end

function World:update(dt)
    for i = 1, #self.gameObjects, 1 do
        self.gameObjects[i]:update(dt)
    end

    self.camera:update(dt)
    self.ui:update(dt)
    self.inventory:update(dt)
    self.megaTowerTool:update(dt)
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

        self.mapRenderer:draw()
        for i = 1, #self.gameObjects, 1 do
            self.gameObjects[i]:draw()
        end

        -- TODO: I do not like this solution, fix this...
        self.ui:querySelector("hotbar"):getTool():draw()
        self.megaTowerTool:draw()

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

function World:keyPressed(key)
    self.player:keyPressed(key)

    if key == "q" then
        self.megaTowerTool:toggle()
    end
end

function World:keyReleased(key)
    self.player:keyReleased(key)
end

function World:mouseMoved(x, y, dx, dy, touch)
    self.ui:mouseMoved(x, y, dx, dy, touch)
    self.megaTowerTool:mouseMoved(x, y, dx, dy, touch)
end

function World:mousePressed(x, y, button, touch, presses)
    self.ui:mousePressed(x, y, button, touch, presses)
    self.megaTowerTool:mousePressed(x, y, button, touch, presses)
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
                inventory = self.inventory,
                camera = self.camera,
                pool = self.gameObjects,
                children = {
                    TowerHotbarItem({
                        constraint = 10,
                        turretType = SingleBarrelTurret,
                        images = towers[1]:toImage()
                    }),
                    TowerHotbarItem({
                        constraint = 25,
                        turretType = DoubleBarrelTurret,
                        images = towers[2]:toImage()
                    }),
                    TowerHotbarItem({
                        constraint = 50,
                        turretType = TripleBarrelTurret,
                        images = towers[3]:toImage()
                    }),
                    CollectorHotbarItem({
                        constraint = 100,
                        allowedPoints = {
                            Point(4, 1),
                            Point(4, 2),
                            Point(5, 1),
                            Point(5, 2),
                        }
                    }),
                }
            })
        }
    })
end

return World
