local Point = require("src.common.objects.point")

local Constants = require("src.game.constants")
local Enemy = require("src.game.objects.enemy")
local GameObject = require("src.game.objects.game-object")
local Pool = require("src.game.objects.pool")
local Event = require("src.game.event.event")
local Publisher = require("src.game.event.publisher")
local Util = require("src.game.util.util")
local PathHelper = require("src.game.util.path-helper")

--[[
    Implementation of spawner mechanics. Handles where enemies will travel and
    when they will spawn.
]]--

---@class Spawner : GameObject
local Spawner = {}
---@type Pool[]
---@private
Spawner.allEnemies = {}
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
---@param obstacles Pool
---@param gameObjects Pool
function Spawner:init(o, base, grid, obstacles, gameObjects)
    GameObject.init(self, o)

    ---@private
    ---@type Base
    self.base = base
    ---@private
    ---@type boolean
    self.shouldSpawn = false
    ---@private
    ---@type integer
    self.spawnAmount = 0
    ---@private
    ---@type integer
    self.spawnedAmount = 0
    ---@private
    ---@type number
    self.enemyHealth = 0
    ---@private
    ---@type Size
    self.grid = grid
    ---@private
    ---@type Pool
    self.obstacles = obstacles or {}
    ---@private
    ---@type Pool
    self.gameObjects = gameObjects
    ---@private
    ---@type number
    self.obstructionRange = 1;
    ---@private
    ---@type number
    self.deltaPassed = 0
    ---@private
    ---@type Point[]
    self.path = {}
    ---@private Spawn rate in seconds.
    ---@type number
    self.spawnRate = self.spawnRate or 1

    self.register(self)
    ---@private
    ---@type Pool
    self.enemies = self.getEnemies(self)

    self.type = "Spawner"
    self:setPath()

    Publisher.register(self, "objects.updated", function()
        if self:shouldUpdatePath() then
            self:setPath()
        end
    end)
end

---Draw method.
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

---@private
---Draws a debug path, useful to know where enemies are generally headed.
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

---@private
---Draws all the enemies that have spawned.
function Spawner:drawSpawnedEnemies()
    for _, enemy in pairs(self.enemies:get()) do
        enemy:draw()
    end
end

---Update method
---@param dt number
function Spawner:update(dt)
    if self:hasWaitedEnough(dt) and self.shouldSpawn then
        self:spawn()
    end

    self:updateSpawnedEnemies(dt)
end

---Method that checks whether or not a Spawner has waited enough time to spawn a new enemy.
---@param dt any
---@return boolean
function Spawner:hasWaitedEnough(dt)
    self.deltaPassed = self.deltaPassed + dt
    if self.deltaPassed >= self.spawnRate then
        self.deltaPassed = 0
        return true
    end

    return false
end

---@private
---Spawns enemies untill the spawn amount is reached.
function Spawner:spawn()
    if self.spawnAmount == self.spawnedAmount then
        self.shouldSpawn = false
        return
    end

    ---@type Enemy
    local enemy = Enemy({
        point = Point(
            self.point.x + (self.size.w / 2) - (Enemy.SIZE.w / 2),
            self.point.y + (self.size.h / 2) - (Enemy.SIZE.h / 2)
        ),
    }, self, self.base, self.path, self.grid, self.gameObjects, self.enemyHealth)

    self.enemies:add(enemy)
    self.spawnedAmount = self.spawnedAmount + 1
end

---Updates all the spawned enemies.
---@param dt number
function Spawner:updateSpawnedEnemies(dt)
    for _, enemy in pairs(self.enemies:get()) do
        enemy:update(dt)
    end
end

---Checks whether any object in the objectpool is 'colliding' with one of the paths.
---@return boolean
function Spawner:shouldUpdatePath()
    local collidingObjects = self.obstacles:getBy(function(o)
        for _, pathPoint in pairs(self.path) do
            if o == pathPoint then
                return true
            end
        end

        return false
    end)

    return #collidingObjects > 0
end

---Sets the path that the enemies will follow. 
---This method is generally called as a result from an event.
function Spawner:setPath()
    self.path = PathHelper.getPath(
        self.grid.w,
        self.grid.h,
        Util.toGridPoint(self:getPoint()),
        Util.toGridPoint(self.base:getPoint()),
        self.obstacles
    )

    Publisher.publish(Event("path.updated"))
end

---Begins spawning a certain amount of enemies.
---@param amount integer
---@param health number
function Spawner:beginSpawning(amount, health)
    self.shouldSpawn = true
    self.spawnAmount = amount
    self.spawnedAmount = 0
    self.enemyHealth = health
end

---Determines whether or not the Spawner is done with spawning the amount of enemies.
---@return boolean
function Spawner:isDone()
    return not self.shouldSpawn and self.enemies:size() == 0
end

---Registers a new pool to the Spawner instance.
---@param instance any
function Spawner.register(instance)
    Spawner.allEnemies[instance] = Pool()
end

---Removes an enemy caused by a death event.
---@param event Event
function Spawner.removeEnemy(event)
    ---@type Enemy
    local enemy = event:getPayload()
    Spawner.allEnemies[enemy.parent]:delete(enemy)
end

---Gets the enemies of a certain Spawner instance
---@param instance Spawner
---@return Pool
function Spawner.getEnemies(instance)
    return Spawner.allEnemies[instance]
end

---Gets all enemies that have been registered to any Spawner.
function Spawner.getAllEnemies()
    local enemies = {}
    for _, pool in pairs(Spawner.allEnemies) do
        for _, enemy in pairs(pool:get()) do
            table.insert(enemies, enemy)
        end
    end

    return enemies
end

Publisher.register(Spawner, "enemy.death", Spawner.removeEnemy)

return Spawner
