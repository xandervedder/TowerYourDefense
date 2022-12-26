local Point = require("src.common.objects.point")

local Event = require("src.game.event.event")
local Publisher = require("src.game.event.publisher")

local Base = require("src.game.objects.base")
local Camera = require("src.game.camera.camera")
local Wave = require("src.game.concept.wave")
local DoubleBarrelTurret = require("src.game.objects.tower.turret.double-barrel-turret")
local MapRenderer = require("src.game.graphics.map.map-renderer")
local MegaTowerTool = require("src.game.tool.mega-tower-tool")
local Mech = require("src.game.objects.mech")
local Pool = require("src.game.objects.pool")
local Spawner = require("src.game.objects.spawner")
local Scene = require("src.game.scenes.scene")
local SingleBarrelTurret = require("src.game.objects.tower.turret.single-barrel-turret")
local Tower = require("src.game.objects.tower.tower")
local TripleBarrelTurret = require("src.game.objects.tower.turret.triple-barrel-turret")
local Util = require("src.game.util.util")
local Constants = require("src.game.constants")

local CollectorHotbarItem = require("src.game.scenes.world.component.hotbar-item.collector-hotbar-item")
local Hotbar = require("src.game.scenes.world.component.hotbar")
local TowerHotbarItem = require("src.game.scenes.world.component.hotbar-item.tower-hotbar-item")
local Inventory = require("src.game.scenes.world.component.inventory")
local WaveCount = require("src.game.scenes.world.component.wave-count")

local Style = require("src.gui.style.style")
local Align = require("src.gui.style.property.align")
local Color = require("src.gui.style.property.color")
local Container = require("src.gui.layout.container")
local HBox = require("src.gui.layout.h-box")
local DirBool = require("src.gui.style.property.dir-bool")
local Side = require("src.gui.style.property.side")
local Size = require("src.gui.style.property.size")

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
    Constants.world = self.mapRenderer:getDimensions()
    ---@type Inventory
    self.inventory = Inventory()
    ---@type WaveCount
    self.waveCount = WaveCount()
    ---@type Camera
    self.camera = Camera({ screen = { love.graphics.getDimensions() } })
    ---@type Mech
    self.mech = Mech({ point = Util.fromCoordinate(3, 3) }, self.camera)
    self.camera:followObject(self.mech)
    ---@type Base
    local base = Base({ point = Util.fromCoordinate(2, 3) })
    ---@type Pool
    self.gameObjects = Pool()
    self.gameObjects:add(base)
    self.gameObjects:add(self.mech)
    ---@type Pool
    self.points = Pool()
    ---@type Spawner
    self.spawner = Spawner(
        { point = Util.fromCoordinate(4, 0) },
        base,
        self.mapRenderer:getGridSize(),
        self.points,
        self.gameObjects
    )
    self.gameObjects:add(self.spawner)
    ---@type Wave
    self.wave = Wave({ self.spawner });
    local mapSize = self.mapRenderer:getDimensions();
    self.canvas = love.graphics.newCanvas(mapSize.w, mapSize.h)
    ---@type MegaTowerTool
    self.megaTowerTool = MegaTowerTool({ camera = self.camera, pool = self.gameObjects })

    self:initUI()
    self:initTopBar()

    ---@param event Event
    Publisher.register(self, "objects.created", function(event) self:updateObjectPool(event.payload) end)
end

function World:update(dt)
    for _, object in pairs(self.gameObjects:get()) do
        object:update(dt)
    end

    self.camera:update(dt)
    self.wave:update(dt)
    self.ui:update(dt)
    self.topBar:update(dt)
    self.megaTowerTool:update()
end

function World:fixedUpdate(dt)
    for _, object in pairs(self.gameObjects:get()) do
        object:fixedUpdate(dt)
    end
end

function World:draw()
    love.graphics.push()

    self.canvas:renderTo(function ()
        love.graphics.setColor(1, 1, 1)

        self.mapRenderer:draw()
        for _, gameObject in pairs(self.gameObjects:get()) do
            gameObject:draw()
        end

        --! The tool should be rendered to the canvas.
        --! The UI however, should not be rendered to the canvas.
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
    self.topBar:draw()
end

function World:keyPressed(key)
    self.mech:keyPressed(key)

    if key == "q" then
        self.megaTowerTool:toggle()
    end
end

function World:keyReleased(key)
    self.mech:keyReleased(key)
end

function World:mouseMoved(x, y, dx, dy, touch)
    self.ui:mouseMoved(x, y, dx, dy, touch)
    self.megaTowerTool:mouseMoved(x, y, dx, dy, touch)
    self.mech:mouseMoved(x, y, dx, dy, touch)
end

function World:mousePressed(x, y, button, touch, presses)
    self.ui:mousePressed(x, y, button, touch, presses)
    self.megaTowerTool:mousePressed(x, y, button, touch, presses)
    self.mech:mousePressed()
end

function World:mouseReleased()
    self.mech:mouseReleased()
end

function World:resize()
    self.camera:resize()
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
                        images = towers[1]:toImages()
                    }),
                    TowerHotbarItem({
                        constraint = 25,
                        turretType = DoubleBarrelTurret,
                        images = towers[2]:toImages()
                    }),
                    TowerHotbarItem({
                        constraint = 50,
                        turretType = TripleBarrelTurret,
                        images = towers[3]:toImages()
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

function World:initTopBar()
    ---@type Element
    self.topBar = Container({
        root = true,
        style = Style({
            color = Color(0, 0, 0, 0),
            padding = Side(20, 20, 20, 20),
            grow = DirBool(true, true),
        }),
        children = {
            HBox({
                style = Style({
                    align = Align(false, true),
                    size = Size(380, 120),
                }),
                children = {
                    self.waveCount,
                    self.inventory,
                }
            })
        }
    })
end

---Updates the contents of the point and object pool.
---@param gameObject GameObject
function World:updateObjectPool(gameObject)
    self.gameObjects:add(gameObject)
    self.points:add(Util.toGridPoint(gameObject:getPoint()))

    Publisher.publish(Event("objects.updated"))
end

return World
