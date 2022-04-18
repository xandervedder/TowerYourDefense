local Base = require("src.game.object.base")
local Camera = require("src.game.camera.camera")
local Constants = require("src.game.constants")
local DoubleBarrelTurret = require("src.game.object.tower.turret.double-barrel-turret")
local Map = require("src.game.map.map")
local Player = require("src.game.object.player")
local PlacementTool = require("src.game.tool.placement-tool")
local Scene = require("src.game.scene.scene")
local SingleBarrelTurret = require("src.game.object.tower.turret.single-barrel-turret")
local Spawner = require("src.game.object.spawner")
local Tiles = require("src.game.graphics.tiles")
local Tower = require("src.game.object.tower.tower")
local TripleBarrelTurret = require("src.game.object.tower.turret.triple-barrel-turret")
local Util = require("src.game.util.util")

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

    self:initUI()
    self.player = Player(Util.position(3, 3))
    self.camera = Camera:new({ screen = { love.graphics.getDimensions() } })
    self.camera:followObject(self.player)

    local base = Base(Util.position(3, 5))
    self.gameObjects = {
        Spawner({ position = Util.position(0, 0).position, base = base, }),
        Spawner({ position = Util.position(5, 0).position, base = base, }),
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
    self.ui:update()
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


--[[ UI Section ]]


function World:initUI()
    ---@type Element
    self.ui = Container({
        root = true,
        style = Style({
            color = Color(0, 0, 0, 0),
            padding = Side(20, 20, 20, 20),
            grow = DirBool(true, true),
        }),
        children = {
            self:inventoryBar()
        }
    })
end

function World:inventoryBar()
    ---@type Tower[]
    local towers = {
        Tower({ turret = SingleBarrelTurret({}), }),
        Tower({ turret = DoubleBarrelTurret({}), }),
        Tower({ turret = TripleBarrelTurret({}), }),
    }
    return Container({
        style =
         Style({
            align = Align(false, false, true),
            color = Color(35, 35, 35, 0.9),
            center = DirBool(true),
            padding = Side(10, 10, 10, 10),
            size = Size(280, 100),
        }),
        children = {
            HBox({
                children = {
                    self:inventoryItem(towers[1]:toImage(), SingleBarrelTurret),
                    self:inventoryItem(towers[2]:toImage(), DoubleBarrelTurret),
                    self:inventoryItem(towers[3]:toImage(), TripleBarrelTurret),
                }
            })
        }
    })
end

---@param images love.Image[]
---@param turretType Turret
---@return Container
function World:inventoryItem(images, turretType)
    self.activeTurret = nil
    return Container({
        ---@param ref Element
        mouseEnter = function(ref)
            if ref.active then return end
            ref.style.color = Color(255, 255, 255, 1)
            love.mouse.setCursor(love.mouse.getSystemCursor("hand"))
        end,
        ---@param ref Element
        mouseOut = function(ref)
            if ref.active then return end
            ref.style.color = Color(0, 0, 0, 1)
            love.mouse.setCursor(love.mouse.getSystemCursor("arrow"))
        end,
        ---@param ref Element
        click = function(ref)
            if ref.active then
                ref.active = false
                ref.style.color = Color(0, 0, 0, 1)
                self.placementTool.disable()
            else
                ref.active = true
                ref.style.color = Color(30, 189, 252, 1)

                self.activeTurret = turretType
                self.placementTool.enable()
                ---@type Tower
                local tower = self.placementTool.getObject()
                tower:setTurret(turretType({}))
                self.placementTool.setTurret(turretType)
            end
        end,
        ---@param ref Element
        update = function(ref)
            if ref.active and turretType ~= self.activeTurret then
                ref.active = false
                ref.style.color = Color(0, 0, 0, 1)
            elseif ref.active and not self.placementTool.active then
                ref.active = false
                ref.style.color = Color(0, 0, 0, 1)
            end
        end,
        style = Style({
            color = Color(0, 0, 0, 1),
            margin = Side(0, 10),
            size = Size(80, 80),
        }),
        children = {
            Image({
                images = images,
                style = Style({
                    size = Size(80, 80),
                })
            })
        }
    })
end

return World
