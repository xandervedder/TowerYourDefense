local AStar = require("src.common.algorithms.a-star")
local WeightedGraph = require("src.common.algorithms.weighted-graph")
local Point = require("src.common.objects.point")

local Constants = require("src.game.constants")
local Enemy = require("src.game.object.enemy")
local GameObject = require("src.game.object.gameobject")
local Publisher = require("src.game.event.publisher")
local Util = require("src.game.util.util")

--[[
    Implementation spawner mechanics. Handles where enemies will travel and
    when they will spawn.
]]--

---@class Spawner : GameObject
local Spawner = {}
Spawner.enemies = {}
Spawner.__index = Spawner

setmetatable(Spawner, {
    __index = GameObject,
    __call = function(cls, ...)
        local self = setmetatable({}, cls)
        self:init(...)
        return self
    end
})

---Constructor
---@param o table
---@param base Base
---@param grid Size
function Spawner:init(o, base, grid)
    GameObject.init(self, o)

    ---@type Base
    self.base = base
    ---@type Size
    self.grid = grid

    ---@type table<number, Point>
    self.path = AStar(
        WeightedGraph(self.grid.w, self.grid.h),
        Util.toGridPoint(self:getPoint()),
        Util.toGridPoint(base:getPoint())
    )
        :search()
        :reconstructPath()
        :get()

    ---@type number
    self.deltaPassed = 0
    ---@type number
    self.spawnRate = self.spawnRate or 1 -- In seconds
    self.register(self)
    self.enemies = self.getEnemies(self)
end

function Spawner:draw()
    love.graphics.setColor(0, 1, 0)
    love.graphics.rectangle(
        "fill",
        self.point.x,
        self.point.y,
        self.size.w,
        self.size.h
    )

    love.graphics.setColor(0, 0, 0)
    love.graphics.print("SPAWNER", self.point.x, self.point.y)

    --TODO: add console command for this (see update v0.1.1)
    self:drawDebugPath()
    self:drawSpawnedEnemies()
end

function Spawner:drawDebugPath()
    ---@type table<number>
    local lineLocations = {}
    for _, location in pairs(self.path) do
        local x = location.x * Constants.tile.scaledWidth()
        local y = location.y * Constants.tile.scaledHeight()

        table.insert(lineLocations, x + (Constants.tile.scaledWidth() / 2))
        table.insert(lineLocations, y + (Constants.tile.scaledHeight() / 2))
    end

    love.graphics.setLineWidth(3)
    love.graphics.line(lineLocations)

    local lastItemIndex = #lineLocations
    love.graphics.circle("fill", lineLocations[1], lineLocations[2], 25)
    love.graphics.circle("fill", lineLocations[lastItemIndex - 1], lineLocations[lastItemIndex], 25)
end

function Spawner:drawSpawnedEnemies()
    for i = 1, #self.enemies, 1 do
        self.enemies[i]:draw()
    end
end

function Spawner:update(dt)
    self.deltaPassed = self.deltaPassed + dt
    if self.deltaPassed >= self.spawnRate then
        self.deltaPassed = 0
        self:spawn()
    end

    self:despawnOutOfBoundsEnemies()
    self:updateSpawnedEnemies(dt)
end

function Spawner:spawn()
    local enemy = Enemy({
        point = Point(
            self.point.x + (self.size.w / 2) - (Enemy.SIZE.w / 2),
            self.point.y + (self.size.h / 2) - (Enemy.SIZE.h / 2)
        ),
    }, self, self.base, self.path)
    table.insert(self.enemies, enemy)
end

function Spawner:despawnOutOfBoundsEnemies()
    local x, y = love.graphics.getDimensions()
    for i = #self.enemies, 1, -1 do
        local position = self.enemies[i]:getPosition()
        if position.x > x or position.y > y then
            table.remove(self.enemies, i)
        end
    end
end

function Spawner:updateSpawnedEnemies(dt)
    for _, enemy in pairs(self.enemies) do
        enemy:update(dt)
    end
end

function Spawner.register(instance)
    Spawner.enemies[instance] = {}
end

function Spawner.removeEnemy(event)
    local enemyRef = event:getPayload()
    local eTable = Spawner.enemies[enemyRef.parent]
    for i = #eTable, 1, -1 do
        local enemy = eTable[i]
        if enemy == enemyRef then
            table.remove(eTable, i)
        end
    end
end

function Spawner.getEnemies(instance)
    return Spawner.enemies[instance]
end

function Spawner.allEnemies()
    local flatEnemiesList = {}
    for _, eTable in pairs(Spawner.enemies) do
        for _, enemy in pairs(eTable) do
            table.insert(flatEnemiesList, enemy)
        end
    end
    return flatEnemiesList
end

Publisher.register(Spawner, "enemy.death", Spawner.removeEnemy)

return Spawner
